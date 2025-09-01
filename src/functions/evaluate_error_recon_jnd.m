function error_metrics = evaluate_error_recon_jnd(reference_dataset_struct, reconstructed_values_struct)
    
    error_metrics = struct('SourceImage', {}, 'MAE', {}, 'RMSE', {}, 'R2', {});
    

    % Calculate error metrics for each source image
    for i = 1:length(reference_dataset_struct)
        source_image = reference_dataset_struct(i).SourceImage;
    
        true_jnd = reference_dataset_struct(i).groundTruth;
        recon_jnd = reconstructed_values_struct(i).JND;
    
        % Compute error metrics
        mae = mean(abs(true_jnd - recon_jnd));
        rmse = sqrt(mean((true_jnd - recon_jnd).^2));
        r2 = 1 - sum((true_jnd - recon_jnd).^2) / sum((true_jnd - mean(true_jnd)).^2);
    
        % Store the metrics
        error_metrics(i).SourceImage = source_image;
        error_metrics(i).MAE = mae;
        error_metrics(i).RMSE = rmse;
        error_metrics(i).R2 = r2;
        
    
        % Display the metrics
        fprintf('Source Image: %s (Reconstructed JND Performance)\n', source_image);
        fprintf('  MAE = %.4f, RMSE = %.4f, R² = %.4f\n', mae, rmse, r2);
    end
    
    fprintf('\nEvaluated errors of reconstructed JND\n\n');
end