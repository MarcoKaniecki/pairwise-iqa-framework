function visualize_reconstruction_combined(dataset, SVR_ext, SVR_red, RF_ext, RF_red)
% Plot true vs predicted JND for multiple models/datasets on shared subplots
% Inputs:
%   dataset   : struct array with fields SourceImage, groundTruth
%   SVR_ext   : struct array with field JND (SVR extended predictions)
%   SVR_red   : struct array with field JND (SVR reduced predictions)
%   RF_ext    : struct array with field JND (RF extended predictions)
%   RF_red    : struct array with field JND (RF reduced predictions)
%
% Creates a single figure with up to 5 subplots (3x2 grid). Each subplot
% corresponds to one reference image (dataset(i)) and includes four
% scatter series for the four model/dataset combinations.
%
% Performance Metrics (RMSE, MAE, PLCC, R^2, SROCC) are printed
% to the command window, not shown in the plots.

    % Colors/markers for each type
    styles = struct( ...
        'SVR_ext', struct('name','SVR Extended', 'color',[0.09 0.45 0.82], 'marker','o'), ...
        'SVR_red', struct('name','SVR Reduced',  'color',[0.93 0.69 0.13], 'marker','s'), ...
        'RF_ext',  struct('name','RF Extended',  'color',[0.47 0.67 0.19], 'marker','^'), ...
        'RF_red',  struct('name','RF Reduced',   'color',[0.85 0.33 0.10], 'marker','d') ...
    );

    figure('Color','w');
    t = tiledlayout(3, 2, 'TileSpacing','compact', 'Padding','compact');
    title(t, 'True vs Reconstructed Quality Scores in JND (SVR/RF, Extended/Reduced)', ...
        'FontWeight','bold', 'FontSize', 14);

    max_plots = min(numel(dataset), 5); % up to 5 plots as requested

    for i = 1:max_plots
        % Ground truth and predictions for image i
        src = dataset(i).SourceImage;
        y   = dataset(i).groundTruth(:);

        preds = struct( ...
            'SVR_ext', SVR_ext(i).JND(:), ...
            'SVR_red', SVR_red(i).JND(:), ...
            'RF_ext',  RF_ext(i).JND(:), ...
            'RF_red',  RF_red(i).JND(:) ...
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
            plcc = corr(yhat, y, 'type','Pearson');      % Pearson (PLCC)
            sroc = corr(yhat, y, 'type','Spearman');     % Spearman (SROCC)
            r2   = 1 - sum((yhat - y).^2) / sum((y - mean(y)).^2);  % R^2

            fprintf('  %-12s -> RMSE=%.4f  MAE=%.4f  R^2=%.4f  PLCC=%.4f  SROCC=%.4f\n', ...
                    name, rmse, mae, r2, plcc, sroc);
        end

        % Create subplot
        nexttile(t);
        hold on;

        % Scatter all four series
        order = {'SVR_ext','SVR_red','RF_ext','RF_red'}; % legend/order
        h = gobjects(1, numel(order));
        for k = 1:numel(order)
            key = order{k};
            s = styles.(key);
            h(k) = scatter(preds.(key), y, 26, 'Marker', s.marker, ...
                           'MarkerEdgeColor', s.color, 'MarkerFaceColor', s.color, ...
                           'MarkerFaceAlpha', 0.7);
        end

        % Diagonal y=x
        plot([0, 3], [0, 3], 'k--', 'LineWidth', 1.2);

        % Axes, labels, grid
        xlim([0, 3]); ylim([0, 3]);
        axis square; grid on;
        xlabel('Reconstructed [JND]');
        ylabel('True [JND]');
        title(char(src), 'Interpreter','none', 'FontSize', 14);

        % Legend in every subplot
        legend(h, {styles.SVR_ext.name, styles.SVR_red.name, styles.RF_ext.name, styles.RF_red.name}, ...
               'Location','southeast', 'Box','off', 'FontSize',14);

        hold off;
    end
end
