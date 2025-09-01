% function create_prop_plot(prop_struct, which_dataset)
%     for i = 1:length(prop_struct)
%         true_prop = prop_struct(i).True;
%         pred_prop = prop_struct(i).Predicted;
%         source_image = prop_struct(i).SourceImage;
% 
%         % create scatterplot
%         figure;
%         scatter(true_prop, pred_prop, 'filled');
%         hold on;
% 
%         % add line of perfect prediction (y = x)
%         plot([0, 1], [0, 1], 'r--', 'LineWidth', 1.5); % Assumes proportions are in [0, 1]
% 
%         title(['Scatter Plot for ', source_image, ' of ', which_dataset, ' dataset'], 'Interpreter', 'none');
%         xlabel('True Proportions');
%         ylabel('Predicted Proportions');
%         grid on;
%         axis([0 1 0 1]); % Enforce the proportions range [0, 1]
% 
%         % Save plot as an image (optional)
%         %saveas(gcf, ['scatter_' source_name '.png']);
%     end
% end


function create_prop_plot(prop_struct, which_dataset)
    nbins = 100;
    n = min(numel(prop_struct), 6);
    edges = linspace(0,1,nbins+1);

    % Simple visibility tweaks
    use_log = true;      % set false to disable
    cap_at = 5;          % color cap after transform ([] = auto)

    counts_all = cell(n,1);
    zmax = 0;

    % Metrics storage
    RMSE = nan(n,1);
    MAE  = nan(n,1);
    R    = nan(n,1);

    for i = 1:n
        x = prop_struct(i).True(:);
        y = prop_struct(i).Predicted(:);
        in = x >= 0 & x <= 1 & y >= 0 & y <= 1;
        x = x(in); y = y(in);

        % Metrics
        if ~isempty(x)
            d = y - x;
            RMSE(i) = sqrt(mean(d.^2));
            MAE(i)  = mean(abs(d));
            if numel(x) > 1
                C = corrcoef(x, y);
                if numel(C) >= 4
                    R(i) = C(1,2);
                end
            end
        end

        % 2D histogram
        C = histcounts2(x, y, edges, edges);
        if use_log, C = log1p(C); end
        counts_all{i} = C;
        zmax = max(zmax, max(C, [], 'all'));
    end
    if isempty(cap_at)
        zupper = max(zmax, 1);
    else
        zupper = max(min(zmax, cap_at), 1);
    end

    figure('Color','w');
    t = tiledlayout(3, 2, 'TileSpacing','compact', 'Padding','compact');

    for i = 1:6
        ax = nexttile;
        if i <= n
            imagesc(edges, edges, counts_all{i}'); axis(ax,'xy');
            hold(ax,'on'); plot(ax,[0 1],[0 1],'r--','LineWidth',1);
            colormap(ax, parula);

            % Two-line title: first line as before, second line with metrics
            line1 = sprintf('%s (%s)', prop_struct(i).SourceImage, which_dataset);
            if isnan(R(i)), rstr = 'NA'; else, rstr = sprintf('%.3f', R(i)); end
            if isnan(RMSE(i)), rmsestr = 'NA'; else, rmsestr = sprintf('%.3f', RMSE(i)); end
            if isnan(MAE(i)), maestr = 'NA'; else, maestr = sprintf('%.3f', MAE(i)); end
            line2 = sprintf('RMSE=%s, MAE=%s, PLCC=%s', rmsestr, maestr, rstr);
            title(ax, {line1; line2}, 'Interpreter','none');

            xlabel(ax,'True'); ylabel(ax,'Predicted');
            axis(ax,[0 1 0 1]); axis(ax,'square');
            ax.FontSize = 11; ax.XTick = 0:0.25:1; ax.YTick = 0:0.25:1;
            grid(ax,'on'); ax.GridAlpha = 0.07;
            clim(ax, [0 zupper]);
        else
            axis(ax,'off');
        end
    end

    cb = colorbar; 
    cb.Layout.Tile = 'east';
    if use_log
        cb.Label.String = 'log(1+count)';
    else
        cb.Label.String = 'count';
    end

    title(t, 'Predicted vs True Proportion Density');
end
