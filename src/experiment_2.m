function experiment_2(processed_data_struct, which_dataset, train_split, box_constraint_val, sigma)
    % Split data first, then create the proportion matrix
    % Train one SVR model per reference image and its alterations

    svr_models  = struct('SourceImage', {}, 'Model', {});
    results     = struct('SourceImage', {}, 'True', {}, 'Predicted', {}); % contains true and predicted proportions, not in matrix form
    
    % functions splits data and creates input output pairs for SVR
    [train_data, test_data] = train_test_split(processed_data_struct, train_split, sigma);

    for ref_img = 1:length(processed_data_struct)
        source_img = train_data(ref_img).SourceImage;

        fprintf('Training model for %s with %d pairs on %s\n', source_img, length(train_data(ref_img).Outputs), which_dataset);

        % svr_model = fitrsvm(train_data(ref_img).Inputs, train_data(ref_img).Outputs, 'KernelFunction', 'gaussian', ...
        %     'Epsilon', epsilon_val, 'BoxConstraint', box_constraint_val);
    %     svr_model = fitrsvm(train_data(ref_img).Inputs, train_data(ref_img).Outputs, 'OptimizeHyperparameters','auto',...
    % 'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    % 'expected-improvement-plus'));
        svr_model = fitrsvm(train_data(ref_img).Inputs, train_data(ref_img).Outputs, ...
                'KernelFunction', 'linear', ...
                'IterationLimit', 1e5, ...
                'KKTTolerance', 1e-8, ...
                'BoxConstraint', box_constraint_val);

        svr_models(ref_img).SourceImage = source_img;
        svr_models(ref_img).Model = svr_model;

        fprintf('Testing  model for %s with %d pairs\n\n', source_img, length(test_data(ref_img).Outputs));

        test_predictions = predict(svr_model, train_data(ref_img).Inputs);

        results(ref_img).SourceImage = source_img;
        results(ref_img).True = train_data(ref_img).Outputs;
        results(ref_img).Predicted = test_predictions;
    end

    errors = evaluate_models(results);

    reconstructed_scales = reconstruction(processed_data_struct, results, train_data, sigma);

    which_experiment = 2;
    save_results(which_dataset, which_experiment, processed_data_struct, results, errors, reconstructed_scales);

end
