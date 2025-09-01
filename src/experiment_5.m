function experiment_5(processed_data_struct, svr_box_constraint, svr_epsilon)
    svr_models = struct('TestImage', {}, 'Model', {});
    results = struct('SourceImage', {}, 'True', {}, 'Predicted', {}); % in JND units, not proportions
    avg_SVR_error = struct('MAE', 0, 'RMSE', 0, 'R2', 0);
    corr_metrics = struct('PEARSON', 0, 'SPEARMAN', 0);


    for test_image_idx = 1:length(processed_data_struct)
        test_image_name = processed_data_struct(test_image_idx).SourceImage;

        all_train_inputs = [];
        all_train_outputs = [];

        for img = 1:length(processed_data_struct)
            if img == test_image_idx
                continue;
            end

            all_train_inputs = [all_train_inputs; processed_data_struct(img).Features];
            all_train_outputs = [all_train_outputs; processed_data_struct(img).groundTruth];
        end

        
        test_inputs = processed_data_struct(test_image_idx).Features;
        

        fprintf('Training SVR model using %d samples from 4 training image sets using %d IQ features...\n', length(all_train_outputs), size(all_train_inputs, 2));

        % currently best SVR parameters
        svr_model = fitrsvm(all_train_inputs, all_train_outputs, ...
                'KernelFunction', 'gaussian', ...
                'IterationLimit', 1e8, ...
                'BoxConstraint', svr_box_constraint, ...
                'Epsilon', svr_epsilon);


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

        test_predictions = predict(svr_model, test_inputs);

        results(test_image_idx).SourceImage = test_image_name;
        results(test_image_idx).Predicted = test_predictions;
        results(test_image_idx).True = processed_data_struct(test_image_idx).groundTruth;

        corr_metrics(test_image_idx).PEARSON = corr(results(test_image_idx).True, results(test_image_idx).Predicted, 'Type', 'Pearson');
        corr_metrics(test_image_idx).SPEARMAN = corr(results(test_image_idx).True, results(test_image_idx).Predicted, 'Type', 'Spearman');
    end


    % Evaluate performance of SVR - prints individual performances in
    % function to command window
    errors = evaluate_models(results);

    % Display average errors - currently not being saved
    avg_SVR_error.MAE = mean(arrayfun(@(x) x.MAE, errors));
    avg_SVR_error.RMSE = mean(arrayfun(@(x) x.RMSE, errors));
    avg_SVR_error.R2 = mean(arrayfun(@(x) x.R2, errors));
    disp(avg_SVR_error)

    disp(mean([corr_metrics.PEARSON]))
    disp(mean([corr_metrics.SPEARMAN]))

    
    % Save resuls
    save('data/exp5_reduced_results.mat', 'processed_data_struct', ...
        'results')
end
