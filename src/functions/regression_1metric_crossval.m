function regression_1metric_crossval(dataset, metric)
    % index of location in reduced features set
    SSIM = 1;
    CVVDP = 2;
    GSMD = 3;
    
    num_ref_img = length(dataset);

    all_params = struct('SourceImage', {}, 'ALPHA', 0, 'BETA', 0, 'RMSE', 0, 'MAE', 0, ...
        'PEARSON_corr', 0, 'TrueOutput', {}, ...
        'PredOutput', {});


    for test_img_idx = 1:num_ref_img

        all_train_inputs = [];
        all_train_outputs = [];

        for img = 1:num_ref_img
            if img == test_img_idx
                continue;
            end

            all_train_inputs = [all_train_inputs; dataset(img).Features(:, metric)];
            all_train_outputs = [all_train_outputs; dataset(img).groundTruth];
        end

        test_inputs = dataset(test_img_idx).Features(:, metric);

        if metric == SSIM
            % SSIM Model: alpha * max(0, 1-x)^beta
            model_fun = @(params, x) params(1) * (max(zeros(size(x)), 1 - x)) .^ params(2);
        elseif metric == CVVDP
            % CVVDP Model: alpha * max(0, 10-x)^beta
            model_fun = @(params, x) params(1) * (max(zeros(size(x)), 10 - x)) .^ params(2);
        elseif metric == GSMD
            % GSMD Model: alpha * x ^beta
            model_fun = @(params, x) params(1) * x .^ params(2);
        end

        % Objective: minimize RMSE
        %obj_fun = @(params) sqrt(mean((model_fun(params, all_train_inputs) - all_train_outputs).^2));
        % SSE - sum of squared errors
        obj_fun = @(params) sum((model_fun(params, all_train_inputs) - all_train_outputs).^2);


        % Initial guess and bounds
        init = [1, 1];          % [alpha, beta]
        lb = [0, -Inf];         % alpha >= 0
        ub = [Inf, Inf];

        % Optimize with fmincon
        options = optimoptions('fmincon', ...
                               'Display', 'iter', ...
                               'Algorithm', 'interior-point');
        params_hat = fmincon(obj_fun, init, [], [], [], [], lb, ub, [], options);

        test_pred = model_fun(params_hat, test_inputs);


        test_outputs = dataset(test_img_idx).groundTruth;

        % error metrics
        rmse = sqrt(mean((test_pred - test_outputs).^2));
        mae = mean(abs(test_pred - test_outputs));
        [pearson_r, ~] = corr(test_outputs, test_pred, 'Type', 'Pearson');

        % save into struct
        all_params(test_img_idx).SourceImage = dataset(test_img_idx).SourceImage;
        all_params(test_img_idx).ALPHA = params_hat(1);
        all_params(test_img_idx).BETA = params_hat(2);
        all_params(test_img_idx).RMSE = rmse;
        all_params(test_img_idx).MAE = mae;
        all_params(test_img_idx).PEARSON_corr = pearson_r;
        all_params(test_img_idx).TrueOutput = dataset(test_img_idx).groundTruth;
        all_params(test_img_idx).PredOutput = test_pred;

    end
    
    if metric == SSIM 
        save('data/regression_SSIM.mat', 'all_params', 'dataset')
    elseif metric == CVVDP
        save('data/regression_CVVDP.mat', 'all_params', 'dataset')
    elseif metric == GSMD
        save('data/regression_GSMD.mat', 'all_params', 'dataset');
    end

end