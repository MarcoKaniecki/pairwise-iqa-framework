function experiment_4_SVR(processed_data_struct, which_dataset, box_constraint, epsilon, sigma)
    % Train one SVR model for 4 reference images, leave 1 for testing

    svr_models = struct('TestImage', {}, 'Model', {});
    results = struct('SourceImage', {}, 'True', {}, 'Predicted', {}); % proportions
    avg_SVR_error = struct('MAE', 0, 'RMSE', 0, 'R2', 0);
    avg_recon_error = struct('avg_MAE', 0, 'avg_RMSE', 0, 'avg_R2', 0);
    avg_corr_metrics = struct('avg_PEARSON', 0, 'avg_SPEARMAN', 0);

    % only create train data, use all combinations of one set of images as
    % testing so no real split is needed
    % This function splits data and creates IO pairs
    % I (INPUT) input metrics pairs
    % O (OUTPUT) respective proportions
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


        %idx = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26];

        % Currently most important: SSIM  - #2
        %                           CVVDP - #13
        %                           GMSD  - #15

        idx = [2 13 15];
        both_idx = [idx, idx + 26]; % left and right pair features
        
        all_train_inputs = all_train_inputs(:, both_idx); % extract
        temp = test_data(test_image_idx).Inputs;
        test_inputs = temp(:, both_idx);              % extract

        % current order: [SSIM_L, CVVDP_L, GSMD_L, SSIM_R, CVVDP_R, GSMD_R]
        % reorder order: [SSIM_L, SSIM_R, CVVDP_L, CVVDP_R, GSMD_L, GSMD_R]
        % reorder = [1 3 2 4 3 6];
        % all_train_inputs = all_train_inputs(:, reorder);  % rearrange
        % test_inputs = test_inputs(:, reorder);        % rearrange


        fprintf('Training SVR model using %d samples from 4 training image sets using %d IQ features...\n', length(all_train_outputs), size(all_train_inputs, 2)/2);

        % currently best SVR parameters
        svr_model = fitrsvm(all_train_inputs, all_train_outputs, ...
                'KernelFunction', 'gaussian', ...
                'IterationLimit', 1e8, ...
                'BoxConstraint', box_constraint, ...
                'Epsilon', epsilon);

        % num_trees = 300; % Number of trees in the forest
        % min_leaf_size = 1; % Minimum number of observations per leaf
        % rf_model = TreeBagger(num_trees, all_train_inputs, all_train_outputs, ...
        %               'Method', 'regression', ...
        %               'MinLeafSize', min_leaf_size, ...
        %               'OOBPrediction', 'on', ...
        %               'NumPredictorsToSample', 'all');


        % let the current source image be the test image
        svr_models(test_image_idx).TestImage = test_image_name; 
        svr_models(test_image_idx).Model = svr_model;

        %test_predictions = predict(svr_model, test_data(test_image_idx).Inputs);
        test_predictions = predict(svr_model, test_inputs);

        results(test_image_idx).SourceImage = test_image_name;
        results(test_image_idx).Predicted = test_predictions;
        results(test_image_idx).True = train_data(test_image_idx).Outputs; % test_data = train_data 

    end

    reconstructed_scales = reconstruction(processed_data_struct, results, test_data, sigma);
    
    % Evaluate perofmance of SVR
    errors = evaluate_models(results);

    % Evaluate performance of reconstructed JND
    recon_corr_metrics_struct = evaluate_corr_recon_jnd(processed_data_struct, reconstructed_scales);
    recon_error_metrics_struct = evaluate_error_recon_jnd(processed_data_struct, reconstructed_scales);
    

    % Display average errors - currently not being saved
    avg_SVR_error.MAE = mean(arrayfun(@(x) x.MAE, errors));
    avg_SVR_error.RMSE = mean(arrayfun(@(x) x.RMSE, errors));
    avg_SVR_error.R2 = mean(arrayfun(@(x) x.R2, errors));
    disp(avg_SVR_error)

    avg_corr_metrics.avg_PEARSON   = mean(arrayfun(@(x) x.r_PEARSON,   recon_corr_metrics_struct));
    avg_corr_metrics.avg_SPEARMAN  = mean(arrayfun(@(x) x.r_SPEARMAN,  recon_corr_metrics_struct));
    disp(avg_corr_metrics);

    avg_recon_error.avg_MAE = mean(arrayfun(@(x) x.MAE, recon_error_metrics_struct));
    avg_recon_error.avg_RMSE = mean(arrayfun(@(x) x.RMSE, recon_error_metrics_struct));
    avg_recon_error.avg_R2 = mean(arrayfun(@(x) x.R2, recon_error_metrics_struct));
    disp(avg_recon_error)



    which_experiment = 4;
    save_results(which_dataset, which_experiment, processed_data_struct, results, errors, reconstructed_scales);
end