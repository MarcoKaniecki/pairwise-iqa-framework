function visualize_plain_thurstone(dataset, SVR_red_plain, RF_red)
% Plot true vs reconstructed/predicted JND for two models (SVR reduced-plain and RF reduced)
% Inputs:
%   dataset        : struct array with fields:
%                    - SourceImage : name/ID of the reference image
%                    - groundTruth : vector of true JNDs for that image
%   SVR_red_plain  : struct array with field:
%                    - Predicted : vector of predicted JNDs (same length as groundTruth)
%   RF_red         : struct array with field:
%                    - JND : vector of predicted JNDs (same length as groundTruth)
%
% Creates a single figure with up to 5 subplots (3x2 grid). Each subplot
% corresponds to one reference image (dataset(i)) and includes two scatter
% series for the two models. Prints RMSE, MAE, PLCC, R^2, SROCC for each.

    % Styles for the two series
    styles = struct( ...
        'SVR_red_plain', struct('name','SVR Reduced (Plain)', 'color',[0.93 0.69 0.13], 'marker','s'), ...
        'RF_red',        struct('name','RF Reduced',           'color',[0.09 0.45 0.82], 'marker','d') ...
    );

    figure('Color','w');
    t = tiledlayout(3, 2, 'TileSpacing','compact', 'Padding','compact');
    title(t, 'True vs Reconstructed/Predicted Quality Scores in JND (SVR Reduced Plain vs RF Reduced)', ...
        'FontWeight','bold', 'FontSize', 14);

    max_plots = min(numel(dataset), 5); % up to 5 plots

    for i = 1:max_plots
        % Ground truth and predictions for image i
        src = dataset(i).SourceImage;
        y   = dataset(i).groundTruth(:);

        preds = struct( ...
            'SVR_red_plain', SVR_red_plain(i).Predicted(:), ...
            'RF_red',        RF_red(i).JND(:) ...
        );

        % Validate lengths
        fns = fieldnames(preds);
        for k = 1:numel(fns)
            yhat = preds.(fns{k});
            if numel(yhat) ~= numel(y)
                error('Length mismatch at image %d (%s) for %s: predicted=%d, true=%d', ...
                    i, char(src), fns{k}, numel(yhat), numel(y));
            end
        end

        % Compute and print metrics per model (RMSE, MAE, PLCC, R^2, SROCC)
        fprintf('\nImage %d: %s\n', i, char(src));
        for k = 1:numel(fns)
            key  = fns{k};
            name = styles.(key).name;
            yhat = preds.(key);

            d    = yhat - y;
            rmse = sqrt(mean(d.^2));
            mae  = mean(abs(d));
            plcc = corr(yhat, y, 'type','Pearson');      % PLCC
            sroc = corr(yhat, y, 'type','Spearman');     % SROCC
            r2   = 1 - sum((yhat - y).^2) / sum((y - mean(y)).^2);  % R^2

            fprintf('  %-20s -> RMSE=%.4f  MAE=%.4f  R^2=%.4f  PLCC=%.4f  SROCC=%.4f\n', ...
                    name, rmse, mae, r2, plcc, sroc);
        end

        % Subplot
        nexttile(t);
        hold on;

        % Scatter two series
        order = {'SVR_red_plain','RF_red'};
        h = gobjects(1, numel(order));
        for k = 1:numel(order)
            key = order{k};
            s = styles.(key);
            h(k) = scatter(preds.(key), y, 28, ...
                           'Marker', s.marker, ...
                           'MarkerEdgeColor', s.color, ...
                           'MarkerFaceColor', s.color, ...
                           'MarkerFaceAlpha', 0.7);
        end

        % Diagonal y=x (adjust limits as needed)
        lo = min(0, min(y)); hi = max(3, max(y));
        plot([lo, hi], [lo, hi], 'k--', 'LineWidth', 1.2);

        % Axes, labels, grid
        xlim([lo, hi]); ylim([lo, hi]);
        axis square; grid on;
        xlabel('Reconstructed/Predicted [JND]');
        ylabel('True [JND]');
        title(char(src), 'Interpreter','none', 'FontSize', 13);

        legend(h, {styles.SVR_red_plain.name, styles.RF_red.name}, ...
               'Location','southeast', 'Box','off', 'FontSize', 12);

        hold off;
    end
end