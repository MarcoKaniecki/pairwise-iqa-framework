function regression_3metrics_crossval(dataset, metric1, metric2, metric3)
     
    num_ref_img = length(dataset);

    all_params = struct('SourceImage', {}, ...
        'ALPHA1', 0, 'BETA1', 0, ...
        'ALPHA2', 0, 'BETA2', 0, ...
        'ALPHA3', 0, 'BETA3', 0, ...
        'RMSE', 0, 'MAE', 0, 'PEARSON_corr', 0, ...
        'TrueOutput', {}, 'PredOutput', {});


    for test_img_idx = 1:num_ref_img

        all_train_inputs = [];
        all_train_outputs = [];

        for img = 1:num_ref_img
            if img == test_img_idx
                continue;
            end

            all_train_inputs = [all_train_inputs; dataset(img).Features(:, [metric1, metric2, metric3])];
            all_train_outputs = [all_train_outputs; dataset(img).groundTruth];
        end

        test_inputs1 = dataset(test_img_idx).Features(:, metric1);
        test_inputs2 = dataset(test_img_idx).Features(:, metric2);
        test_inputs3 = dataset(test_img_idx).Features(:, metric3);


        % Define model function using the transforms
        model_fun = @(params, x, y, z) ...
            params(1) * metric_transform3(metric1, x) .^ params(2) + ...
            params(3) * metric_transform3(metric2, y) .^ params(4) + ...
            params(5) * metric_transform3(metric3, z) .^ params(6);


        % Objective: minimize SSE
        metric1_train = all_train_inputs(:, 1);
        metric2_train = all_train_inputs(:, 2);
        metric3_train = all_train_inputs(:, 3);
        obj_fun = @(params) sum((model_fun(params, metric1_train, metric2_train, metric3_train) - all_train_outputs).^2);


        % Initial guess and bounds
        init = [1, 1, 1, 1, 1, 1];          % [alpha1, beta1, alpha2, beta2, alpha3, beta3]
        lb = [0, -Inf, 0, -Inf, 0, -Inf];         % alpha1,2 and 3 >= 0
        ub = [100, 100, 100, 100, 100, 100];

        % Optimize with fmincon
        options = optimoptions('fmincon', ...
                               'Display', 'iter', ...
                               'Algorithm', 'interior-point');
        params_hat = fmincon(obj_fun, init, [], [], [], [], lb, ub, [], options);

        test_pred = model_fun(params_hat, test_inputs1, test_inputs2, test_inputs3);


        test_outputs = dataset(test_img_idx).groundTruth;

        % error metrics
        rmse = sqrt(mean((test_pred - test_outputs).^2));
        mae = mean(abs(test_pred - test_outputs));
        [pearson_r, ~] = corr(test_outputs, test_pred, 'Type', 'Pearson');
        %fprintf("SROCC = %.4f\n", corr(test_outputs, test_pred, 'Type', 'Spearman'));
        % SROCC = 0.9739

        % save into struct
        all_params(test_img_idx).SourceImage = dataset(test_img_idx).SourceImage;
        all_params(test_img_idx).ALPHA1 = params_hat(1);
        all_params(test_img_idx).BETA1 = params_hat(2);
        all_params(test_img_idx).ALPHA2 = params_hat(3);
        all_params(test_img_idx).BETA2 = params_hat(4);
        all_params(test_img_idx).ALPHA3 = params_hat(5);
        all_params(test_img_idx).BETA3 = params_hat(6);
        all_params(test_img_idx).RMSE = rmse;
        all_params(test_img_idx).MAE = mae;
        all_params(test_img_idx).PEARSON_corr = pearson_r;
        all_params(test_img_idx).TrueOutput = dataset(test_img_idx).groundTruth;
        all_params(test_img_idx).PredOutput = test_pred;

    end
    
    save(sprintf('data/regression_%d_%d_%d.mat', metric1, metric2, metric3), 'all_params', 'dataset')
end


% Build model for any combination of metrics
% Helper functions for each metric
function f = metric_transform3(metric_idx, vals)
    % index of location in features set
    SSIM = 1;
    CVVDP = 2;
    GSMD = 3;

    if metric_idx == CVVDP
        f = max(zeros(size(vals)), 10 - vals); % CVVDP best is 10
    elseif metric_idx == GSMD
        f = vals; % GSMD best is 0
    elseif metric_idx == SSIM
        f = max(zeros(size(vals)), 1 - vals); % SSIM best is 1
    else
        f = vals; % Default: identity
    end
end