function visualize_regression_2metrics(params, dataset, metric1, metric2)

    % Mean params
    avg_alpha1 = mean([params.ALPHA1]);
    avg_beta1  = mean([params.BETA1]);
    avg_alpha2 = mean([params.ALPHA2]);
    avg_beta2  = mean([params.BETA2]);
    avg_rmse = mean([params.RMSE]);
    avg_mae = mean([params.MAE]);
    avg_pearson = mean([params.PEARSON_corr]);
    
    % Gather all features
    all_features = vertcat(dataset.Features);
    x_vals = all_features(:, metric1);
    y_vals = all_features(:, metric2);

    x_range = linspace(min(x_vals), max(x_vals), 100);
    y_range = linspace(min(y_vals), max(y_vals), 100);
    [X, Y] = meshgrid(x_range, y_range);

    % Define transforms
    CVVDP = 13;
    GSMD = 15;

    if metric1 == CVVDP
        tx = @(x) max(0, 10 - x);
        xlab = 'CVVDP';
    elseif metric1 == GSMD
        tx = @(x) x;
        xlab = 'GSMD';
    else
        tx = @(x) x;
        xlab = ['Metric ' num2str(metric1)];
    end

    if metric2 == CVVDP
        ty = @(y) max(0, 10 - y);
        ylab = 'CVVDP';
    elseif metric2 == GSMD
        ty = @(y) y;
        ylab = 'GSMD';
    else
        ty = @(y) y;
        ylab = ['Metric ' num2str(metric2)];
    end

    % Compute surface
    Z = avg_alpha1 * tx(X).^avg_beta1 + avg_alpha2 * ty(Y).^avg_beta2;

    % Plot
    figure;
    surf(X, Y, Z, 'FaceColor', [0.6 0.6 0.6], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    hold on;
    for i = 1:numel(dataset)
        scatter3(dataset(i).Features(:, metric1), dataset(i).Features(:, metric2), dataset(i).groundTruth, 36, 'filled');
    end
    xlabel(xlab, 'FontSize', 14);
    ylabel(ylab, 'FontSize', 14);
    zlabel('Distortion [JND]', 'FontSize', 14);
    
    
    first_line = 'CVVDP + GSMD';

    second_line = sprintf('f(x, y) = %.4f * max(0,10-x) ^ %.4f + %.4f * y ^ %.4f', ...
        avg_alpha1, avg_beta1, avg_alpha2, avg_beta2);

    third_line = sprintf('RMSE = %.4f   MAE = %.4f   PLCC = %.4f', ...
        avg_rmse, avg_mae, avg_pearson);

    % Set the title with three lines
    title({first_line, second_line, third_line}, 'FontSize', 16, 'Interpreter', 'None');
    
    grid on;
    hold off;
end