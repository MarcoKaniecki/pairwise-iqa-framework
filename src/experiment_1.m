function experiment_1(processed_data_struct, which_dataset, train_split, box_constraint_val, sigma)
    % Create proportion matrix first, then split the data
    % Train one SVR model per reference image and its alterations

    svr_models  = struct('SourceImage', {}, 'Model', {});
    results     = struct('SourceImage', {}, 'True', {}, 'Predicted', {}); % contains true and predicted proportions, not in matrix form
    train_data  = struct('SourceImage', {}, 'Inputs', {}, 'Outputs', {});
    test_data   = struct('SourceImage', {}, 'Inputs', {}, 'Outputs', {});

    forward_thurstonian_struct = create_proportions_matrix(processed_data_struct, sigma);


    for img = 1:length(processed_data_struct)
        source_image = processed_data_struct(img).SourceImage;
        
        prop_matrix = forward_thurstonian_struct(img).PropMatrix;
        features = processed_data_struct(img).Features;
        num_variations_with_reference = size(features, 1);

        % Create input-output pairs for SVR training
        inputs = [];
        outputs = [];

        for j = 1:num_variations_with_reference
            for k = 1:num_variations_with_reference
                if j ~= k
                    % Concatenate features of distortion j and distortion k
                    input_vector = [features(j, :), features(k, :)];
                    
                    % add data
                    inputs = [inputs; input_vector];
                    outputs = [outputs; prop_matrix(j, k)];
      
                end
            end
        end

        % split data
        % Determine the number of samples
        num_samples = size(inputs, 1);
        
        % Create random indices for split
        indices = randperm(num_samples);
        train_size = round(train_split * num_samples);
        
        % Split the data
        train_indices = indices(1 : train_size);
        test_indices = indices(train_size + 1 : end);
        
        % Create training and test sets
        train_inputs = inputs(train_indices, :);
        train_outputs = outputs(train_indices);
        test_inputs = inputs(test_indices, :);
        test_outputs = outputs(test_indices);

        % Store training and test data
        train_data(img).SourceImage = source_image;
        train_data(img).Inputs = train_inputs;
        train_data(img).Outputs = train_outputs;

        test_data(img).SourceImage = source_image;
        test_data(img).Inputs = test_inputs;
        test_data(img).Outputs = test_outputs;
        
        fprintf('Training SVR model for %s with %d training samples...\n', source_image, size(train_inputs, 1));


        % Train the SVR model using only the training features
        % The algorithm always tries to minimize f(x) and uses first-order
        % optimality to know when it's finished
        % svr_model = fitrsvm(train_inputs, train_outputs, 'KernelFunction', 'gaussian', ...
        %     'Epsilon', epsilon_val, 'BoxConstraint', box_constraint_val);

        svr_model = fitrsvm(train_inputs, train_outputs, ...
                'KernelFunction', 'linear', ...
                'IterationLimit', 1e5, ...
                'KKTTolerance', 1e-8, ...
                'BoxConstraint', box_constraint_val);

        %disp(svr_model.ConvergenceInfo);


        % Store the trained model in the struct
        svr_models(img).SourceImage = source_image;
        svr_models(img).Model = svr_model;

        % Make predictions on test set
        test_predictions = predict(svr_model, test_inputs);

        % Store results
        results(img).SourceImage = source_image;
        results(img).True = test_outputs;
        results(img).Predicted = test_predictions;
    end

    % Evaluate performance of SVR models
    % returns struct errors = struct('SourceImage', {}, 'MAE', {}, 'RMSE', {}, 'R2', {});
    errors = evaluate_models(results);
    
    reconstructed_scales = reconstruction(processed_data_struct, results, test_data, sigma);
    
    which_experiment = 1;
    save_results(which_dataset, which_experiment, processed_data_struct, results, errors, reconstructed_scales)
    
end