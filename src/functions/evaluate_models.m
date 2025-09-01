function errors = evaluate_models(results)
    % Initialize error metrics storage
    errors = struct('SourceImage', {}, 'MAE', {}, 'RMSE', {}, 'R2', {});
    
    % Calculate error metrics for each source image
    for i = 1:length(results)
        source_image = results(i).SourceImage;
    
        % Retrieve true and predicted values
        true_values = results(i).True;
        test_predicted = results(i).Predicted;
    
        % Compute error metrics
        mae = mean(abs(true_values - test_predicted));
        rmse = sqrt(mean((true_values - test_predicted).^2));
        r2 = 1 - sum((true_values - test_predicted).^2) / sum((true_values - mean(true_values)).^2);
    
        % Store the metrics
        errors(i).SourceImage = source_image;
        errors(i).MAE = mae;
        errors(i).RMSE = rmse;
        errors(i).R2 = r2;
        
    
        % Display the metrics
        fprintf('Source Image: %s (Test Set Performance)\n', source_image);
        fprintf('  MAE = %.4f, RMSE = %.4f, R² = %.4f\n', mae, rmse, r2);
    end
    
    fprintf('\nEvaluated SVR models prediction performance on test set\n\n');
end