function visualize_jnd_diff(reconstructed_scales, dataset, which_dataset)
    % reconstructed_scales contains ref_imgs and predicted recon. JND
    % dataset contains distortions and ground truth JND
    % which_dataset: 'extended' or 'reduced'

    num_images = length(dataset);

    figure;
    t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    switch string(which_dataset)
        case "SVR_extended"
            mainTitle = '[SVR] True vs Reconstructed Quality Scores in JND (Extended Dataset)';
        case "SVR_reduced"
            mainTitle = '[SVR] True vs Reconstructed Quality Scores in JND (Reduced Dataset)';
        case "RF_extended"
            mainTitle = '[RF] True vs Reconstructed Quality Scores in JND (Extended Dataset)';
        case "RF_reduced"
            mainTitle = '[RF] True vs Reconstructed Quality Scores in JND (Reduced Dataset)';
        otherwise
            mainTitle = 'True vs Reconstructed Quality Scores in JND';
    end
    title(t, mainTitle, 'FontWeight', 'bold', 'FontSize', 14);

    for i = 1:num_images
        source_image = dataset(i).SourceImage;
        y = dataset(i).groundTruth(:);          % True JND (vectorize)
        yhat = reconstructed_scales(i).JND(:);  % Reconstructed JND (vectorize)

        if numel(yhat) ~= numel(y)
            error('Length mismatch at index %d: predicted=%d, true=%d', i, numel(yhat), numel(y));
        end

        % Metrics
        dif  = yhat - y;
        rmse = sqrt(mean(dif.^2));
        mae  = mean(abs(dif));

        % Pearson (PLCC) and Spearman (SROCC)
        plcc = corr(yhat, y, 'type', 'Pearson');

        % Plot
        nexttile;
        scatter(yhat, y, 40, 'filled');
        hold on;
        plot([0, 3], [0, 3], 'r--', 'LineWidth', 1.5);

        metricsLine = sprintf('RMSE=%.3f  MAE=%.3f  PLCC=%.3f', rmse, mae, plcc);
        title({char(source_image), metricsLine}, 'Interpreter', 'none', 'FontSize', 12);

        xlabel('Reconstructed [JND]');
        ylabel('True [JND]');

        xlim([0, 3]);
        ylim([0, 3]);
        axis square;
        grid on;

        hold off;
    end
end