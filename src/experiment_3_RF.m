function experiment_3_RF(processed_data_struct, which_dataset, num_trees, min_leaf_size, sigma)
    % Train one SVR model for 4 reference images, leave 1 for testing

    svr_models = struct('TestImage', {}, 'Model', {});
    results = struct('SourceImage', {}, 'True', {}, 'Predicted', {});
    %avg_errors = struct('MAE', 0, 'RMSE', 0, 'R2', 0);

    % only create train data, use all combinations of one set of images as
    % testing so no real split is needed
    [train_data, ~] = train_test_split(processed_data_struct, 1, sigma);
    
    test_data = train_data;
    

    for test_image_idx = 1:length(processed_data_struct)
        test_image_name = processed_data_struct(test_image_idx).SourceImage;

        all_train_inputs = [];
        all_train_outputs = [];

        for img = 1:length(processed_data_struct)
            if img == test_image_idx
                continue;
            end

            all_train_inputs = [all_train_inputs; train_data(img).Inputs];
            all_train_outputs = [all_train_outputs; train_data(img).Outputs];
        end

        % size is divided by 2 because there are left and right features
        % for each pair
        fprintf('Training RF model using %d samples from 4 training images using %d IQ features...\n', length(all_train_outputs), size(all_train_inputs, 2)/2);
        
        rf_model = TreeBagger(num_trees, all_train_inputs, all_train_outputs, ...
                      'Method', 'regression', ...
                      'MinLeafSize', min_leaf_size, ...
                      'OOBPrediction', 'on', ...
                      'NumPredictorsToSample', 'all');

        
        % % Get feature importance
        % feature_importance = rf_model.OOBPermutedPredictorDeltaError;
        % 
        % figure;
        % bar(feature_importance);
        % xlabel('Feature Index');
        % ylabel('Importance Score');
        % title(test_image_name, 'Interpreter', 'none');


        % let the current source image be the test image
        svr_models(test_image_idx).TestImage = test_image_name; 
        svr_models(test_image_idx).Model = rf_model;


        test_predictions = predict(rf_model, test_data(test_image_idx).Inputs);

        results(test_image_idx).SourceImage = test_image_name;
        results(test_image_idx).Predicted = test_predictions;
        results(test_image_idx).True = train_data(test_image_idx).Outputs;

    end
    
    reconstructed_scales = reconstruction(processed_data_struct, results, test_data, sigma);
    
    % Evaluate performance of ML
    errors = evaluate_models(results);

    % Evaluate performance of reconstructed JND
    recon_corr_metrics_struct = evaluate_corr_recon_jnd(processed_data_struct, reconstructed_scales);
    recon_error_metrics_struct = evaluate_error_recon_jnd(processed_data_struct, reconstructed_scales);
    

    % Display average errors - currently not being saved
    avg_SVR_error.MAE = mean(arrayfun(@(x) x.MAE, errors));
    avg_SVR_error.RMSE = mean(arrayfun(@(x) x.RMSE, errors));
    avg_SVR_error.R2 = mean(arrayfun(@(x) x.R2, errors));
    fprintf('---RF Performance Average---\n');
    disp(avg_SVR_error)
    
    fprintf('---Reconstruction Performance---\n');
    avg_corr_metrics.avg_PEARSON   = mean(arrayfun(@(x) x.r_PEARSON,   recon_corr_metrics_struct));
    avg_corr_metrics.avg_SPEARMAN  = mean(arrayfun(@(x) x.r_SPEARMAN,  recon_corr_metrics_struct));
    disp(avg_corr_metrics);

    avg_recon_error.avg_MAE = mean(arrayfun(@(x) x.MAE, recon_error_metrics_struct));
    avg_recon_error.avg_RMSE = mean(arrayfun(@(x) x.RMSE, recon_error_metrics_struct));
    avg_recon_error.avg_R2 = mean(arrayfun(@(x) x.R2, recon_error_metrics_struct));
    disp(avg_recon_error)
    fprintf('--------------------------------\n');


    which_experiment = 3;
    which_model = 'RF';
    save_results(which_dataset, which_experiment, which_model, processed_data_struct, results, errors, reconstructed_scales);


    
end