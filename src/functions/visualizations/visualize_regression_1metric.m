function visualize_regression_1metric(params, dataset, metric)
    SSIM = 1;
    CVVDP = 2;
    GSMD = 3;

    avg_alpha = mean([params.ALPHA]);
    avg_beta = mean([params.BETA]);
    avg_rmse = mean([params.RMSE]);
    avg_mae = mean([params.MAE]);
    avg_pearson = mean([params.PEARSON_corr]);

    all_metric_values = vertcat(dataset.Features);
    all_metric_values = all_metric_values(:, metric);

    metric_range = linspace(min(all_metric_values), max(all_metric_values), 200);
    
    if metric == SSIM
        jnd_pred_curve = avg_alpha * max(0, 1-metric_range) .^ avg_beta;
    elseif metric == CVVDP
        jnd_pred_curve = avg_alpha * max(0, 10-metric_range) .^ avg_beta;
    elseif metric == GSMD
        jnd_pred_curve = avg_alpha * metric_range .^ avg_beta;
    end
    
    
    figure;
    scatter(dataset(1).Features(:, metric), dataset(1).groundTruth, 30, 'black', 'filled'); % actual data
    hold on;
    scatter(dataset(2).Features(:, metric), dataset(2).groundTruth, 30, 'green', 'filled');
    scatter(dataset(3).Features(:, metric), dataset(3).groundTruth, 30, 'yellow', 'filled');
    scatter(dataset(4).Features(:, metric), dataset(4).groundTruth, 30, 'magenta', 'filled');
    scatter(dataset(5).Features(:, metric), dataset(5).groundTruth, 30, 'red', 'filled');

    plot(metric_range, jnd_pred_curve, 'k-', 'LineWidth', 2);
    

    metrics_str = sprintf('RMSE = %.4f   MAE = %.4f   PLCC = %.4f', avg_rmse, avg_mae, avg_pearson);
    
    if metric == SSIM
        model_str = sprintf('f(x) = %.4f * max(0,1-x) \\^ %.4f', avg_alpha, avg_beta);
        title({'SSIM', model_str, metrics_str}, 'FontSize', 16);
        xlabel('SSIM');
    elseif metric == CVVDP
        model_str = sprintf('f(x) = %.4f * max(0,10-x) \\^ %.4f', avg_alpha, avg_beta);
        title({'CVVDP', model_str, metrics_str}, 'FontSize', 16);
        xlabel('CVVDP');
    elseif metric == GSMD
        model_str = sprintf('f(x) = %.4f * x \\^ %.4f', avg_alpha, avg_beta);
        title({'GSMD', model_str, metrics_str}, 'FontSize', 16);
        xlabel('GSMD');
    end

    ylabel('Distortion [JND]');

    if metric == GSMD
        legend('ref_10', 'ref_2', 'ref_6', 'ref_7', 'ref_9', 'Location', 'northwest', 'FontSize', 20, 'Interpreter', 'None');
    else
        legend('ref_10', 'ref_2', 'ref_6', 'ref_7', 'ref_9', 'Location', 'northeast', 'FontSize', 20, 'Interpreter', 'None');
    end

    grid on;
    
end