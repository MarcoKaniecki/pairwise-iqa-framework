function visualize_regression_3metrics(params, dataset, metric1, metric2, metric3)

    % Mean params
    avg_alpha1 = mean([params.ALPHA1]);
    avg_beta1  = mean([params.BETA1]);
    avg_alpha2 = mean([params.ALPHA2]);
    avg_beta2  = mean([params.BETA2]);
    avg_alpha3 = mean([params.ALPHA3]);
    avg_beta3  = mean([params.BETA3]);
    avg_rmse = mean([params.RMSE]);
    avg_mae = mean([params.MAE]);
    avg_pearson = mean([params.PEARSON_corr]);

    all_features = vertcat(dataset.Features);
    x_vals = all_features(:, metric1);
    y_vals = all_features(:, metric2);
    z_vals = all_features(:, metric3);


    % Assuming metrics are passed into function in this order: SSIM, CVVDP,
    % GSMD
    JND_vals = avg_alpha1 * max(0, 1 - x_vals).^avg_beta1 + ...
                   avg_alpha2 * max(0, 10 - y_vals).^avg_beta2 + ...
                   avg_alpha3 * z_vals.^avg_beta3;

    % plot
    figure;
    scatter3(x_vals, y_vals, z_vals, 40, JND_vals, 'filled');
    colormap parula; 
    handle = colorbar('eastoutside');
    handle.Label.String = 'Distortion [JND]';
    handle.Label.FontSize = 14;
    handle.Label.FontWeight = 'bold';
    xlabel('SSIM');
    ylabel('CVVDP');
    zlabel('GSMD');


    first_line = 'SSIM + CVVDP + GSMD';
    
    second_line = sprintf('f(x, y, z) = %.4f * max(0,1-x) ^ %.4f + %.4f * max(0,10-y) ^ %.4f + %.4f * z ^ %.4f', ...
        avg_alpha1, avg_beta1, avg_alpha2, avg_beta2, avg_alpha3, avg_beta3);

    third_line = sprintf('RMSE = %.4f   MAE = %.4f   PLCC = %.4f', ...
        avg_rmse, avg_mae, avg_pearson);

    % Set the title with three lines
    title({first_line, second_line, third_line}, 'FontSize', 16, 'Interpreter', 'None');
    
    grid on;
    hold off;
end