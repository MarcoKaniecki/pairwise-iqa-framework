% Main script for creating visualizations

% set to true or false
% currently not used/outdated
%visualize_jnd_comparison = false; % plots True/Predicted qualities vs Distortion (1 to 10)

% set to true or false
visualize_jnd_comp = true; % plots Predicted vs True quality scores
visualize_prop_comparison = true; % plots predicted vs true proportions




%% Experiment 1
% exp1_reduced_exists = exist('exp1_reduced_results.mat', 'file');
% exp1_extended_exists = exist('exp1_extended_results.mat', 'file');
% 
% % Plot JND comparison
% if visualize_jnd_comparison == true
%     % Experiment 1
%     if exp1_reduced_exists && exp1_extended_exists
%        load('exp1_reduced_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp1_reduced_dataset = processed_data_struct;
%        exp1_reduced_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 1 reduced feature set data.\n');
% 
%        load('exp1_extended_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp1_extended_dataset = processed_data_struct;
%        exp1_extended_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 1 extended feature set data.\n');
% 
%        % Plot
%        create_jnd_comparison_plot(exp1_reduced_dataset, exp1_reduced_reconstructed, exp1_extended_dataset, exp1_extended_reconstructed);
%     end
% end
% 
% % Plot Predicted vs True proportions comparison
% if visualize_prop_comparison == true
%     if exp1_reduced_exists && exp1_extended_exists
%         load('exp1_reduced_results.mat', 'true_and_predicted_prop')
%         exp1_reduced_pred_prop = true_and_predicted_prop;
% 
%         load('exp1_extended_results.mat', 'true_and_predicted_prop')
%         exp1_extended_pred_prop = true_and_predicted_prop;
% 
%         % Plot
%         create_prop_plot(exp1_reduced_pred_prop, 'reduced');
%         create_prop_plot(exp1_extended_pred_prop, 'extended');
%     end
% end

%% Experiment 2
% exp2_reduced_exists = exist('exp2_reduced_results.mat', 'file');
% exp2_extended_exists = exist('exp2_extended_results.mat', 'file');
% 
% % Plot JND comparison
% if visualize_jnd_comparison == true
%     if exp2_reduced_exists && exp2_extended_exists
%        load('exp2_reduced_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp2_reduced_dataset = processed_data_struct;
%        exp2_reduced_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 2 reduced feature set data.\n');
% 
%        load('exp2_extended_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp2_extended_dataset = processed_data_struct;
%        exp2_extended_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 2 extended feature set data.\n');
% 
%        % Plot
%        create_jnd_comparison_plot(exp2_reduced_dataset, exp2_reduced_reconstructed, exp2_extended_dataset, exp2_extended_reconstructed);
%     end
% end
% 
% % Plot Predicted vs True proportions comparison
% if visualize_prop_comparison == true
%     if exp2_reduced_exists && exp2_extended_exists
%         load('exp2_reduced_results.mat', 'true_and_predicted_prop')
%         exp2_reduced_pred_prop = true_and_predicted_prop;
% 
%         load('exp2_extended_results.mat', 'true_and_predicted_prop')
%         exp2_extended_pred_prop = true_and_predicted_prop;
% 
%         % Plot
%         create_prop_plot(exp2_reduced_pred_prop, 'reduced');
%         create_prop_plot(exp2_extended_pred_prop, 'extended');
%     end
% end

%% Experiment 3

exp3_reduced_SVR_exists = exist('exp3_reduced_SVR_results.mat', 'file');
exp3_extended_SVR_exists = exist('exp3_extended_SVR_results.mat', 'file');

exp3_reduced_RF_exists = exist('exp3_reduced_RF_results.mat', 'file');
exp3_extended_RF_exists = exist('exp3_extended_RF_results.mat', 'file');


% % Plot quality value vs distortion (1 to 10) per codec per image
% % OUTDATED
% if visualize_jnd_comparison == true
%     if exp3_reduced_exists && exp3_extended_exists
%        load('exp3_reduced_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp3_reduced_dataset = processed_data_struct;
%        exp3_reduced_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 3 reduced feature set data.\n');
% 
%        load('exp3_extended_results.mat', 'processed_data_struct', 'reconstructed_scales')
%        exp3_extended_dataset = processed_data_struct;
%        exp3_extended_reconstructed = reconstructed_scales;
%        fprintf('Loaded experiment 3 extended feature set data.\n');
% 
%        % Plot
%        create_jnd_comparison_plot(exp3_reduced_dataset, exp3_reduced_reconstructed, exp3_extended_dataset, exp3_extended_reconstructed);
%        create_jnd_comparison_plot(exp3_extended_dataset, exp3_extended_reconstructed, exp3_extended_dataset, exp3_extended_reconstructed);
%     end
% end


if visualize_jnd_comp == true
    if exp3_extended_SVR_exists && exp3_reduced_SVR_exists && exp3_reduced_RF_exists && exp3_extended_RF_exists
        load('exp3_extended_SVR_results.mat', 'processed_data_struct', 'reconstructed_scales')
        dataset = processed_data_struct;
        SVR_ext = reconstructed_scales;
        
        load('exp3_reduced_SVR_results.mat', 'reconstructed_scales')
        SVR_red = reconstructed_scales;

        load('exp3_reduced_RF_results.mat', 'reconstructed_scales')
        RF_red = reconstructed_scales;

        load('exp3_extended_RF_results.mat', 'reconstructed_scales')
        RF_ext = reconstructed_scales;
        
        % plot true vs predicted quality scores - combined
        % also prints RMSE, MAE, PLCC performance metrics
        visualize_reconstruction_combined(dataset, SVR_ext, SVR_red, RF_ext, RF_red);
        
        % plot true vs predicted quality scores - separately
        % visualize_jnd_diff(SVR_extended_reconstructed, dataset, 'SVR_extended');
        % visualize_jnd_diff(SVR_reduced_reconstructed, dataset, 'SVR_reduced');
        % visualize_jnd_diff(RF_extended_reconstructed, dataset, 'RF_extended');
        % visualize_jnd_diff(RF_reduced_reconstructed, dataset, 'RF_reduced');
    end

end


% Plot Predicted vs True proportions
if visualize_prop_comparison == true
    if exp3_reduced_SVR_exists && exp3_extended_SVR_exists
        load('exp3_reduced_SVR_results.mat', 'true_and_predicted_prop')
        exp3_reduced_pred_prop = true_and_predicted_prop;

        load('exp3_extended_SVR_results.mat', 'true_and_predicted_prop')
        exp3_extended_pred_prop = true_and_predicted_prop;

        % Density plot
        create_prop_plot(exp3_reduced_pred_prop, 'reduced');
        create_prop_plot(exp3_extended_pred_prop, 'extended');
    end
end

%% Experiment 5

% compare with best performing Thurstonian model
exp3_reduced_RF_exists = exist('exp3_reduced_RF_results.mat', 'file');
exp5_reduced_exists = exist('exp5_reduced_results.mat', 'file');

if exp3_reduced_RF_exists && exp5_reduced_exists
    load('exp3_reduced_RF_results.mat', 'processed_data_struct', 'reconstructed_scales')
    dataset = processed_data_struct;
    RF_red = reconstructed_scales;
    
    load('exp5_reduced_results.mat', 'results')
    SVR_red_plain = results;

    % plot true vs predicted scores
    visualize_plain_thurstone(dataset, SVR_red_plain, RF_red)
end

%% Experiment 4
% % OLD
% exp4_reduced_exists = exist('exp4_reduced_results.mat', 'file');
% exp4_extended_exists = exist('exp4_extended_results.mat', 'file');
% 
% if visualize_jnd_comp == true
%     if exp4_extended_exists
%         load('exp4_extended_results.mat', 'processed_data_struct', 'reconstructed_scales')
%         exp4_extended_dataset = processed_data_struct;
%         exp4_extended_reconstructed = reconstructed_scales;
% 
%         visualize_jnd_diff(exp4_extended_reconstructed, exp4_extended_dataset);
%     end
% 
% end


%% Direct Mapping (Regression) - 1 metric

regression_ssim_exists = exist('regression_SSIM.mat', 'file');
regression_cvvdp_exists = exist('regression_CVVDP.mat', 'file');
regression_gsmd_exists = exist('regression_GSMD.mat', 'file');

% index locations in REDUCED features/metrics matrix
SSIM = 1;
CVVDP = 2;
GSMD = 3;



if regression_ssim_exists
    load('regression_SSIM.mat', 'all_params', 'dataset')
    regression_ssim_params = all_params;
    used_dataset = dataset;

    visualize_regression_1metric(regression_ssim_params, used_dataset, SSIM);
end


if regression_cvvdp_exists
    load('regression_CVVDP.mat', 'all_params', 'dataset')
    regression_cvvdp_params = all_params;
    used_dataset = dataset;

    visualize_regression_1metric(regression_cvvdp_params, used_dataset, CVVDP);
end


if regression_gsmd_exists
    load('regression_GSMD.mat', 'all_params', 'dataset')
    regression_gsmd_params = all_params;
    used_dataset = dataset;

    visualize_regression_1metric(regression_gsmd_params, used_dataset, GSMD);
end


%% Direct Mapping - 2 metrics
% 
% regression_2metrics_exists = exist('regression_2_3.mat', 'file');
% 
% if regression_2metrics_exists
%     load('regression_2_3.mat', 'all_params', 'dataset')
%     regression_2metrics_params = all_params;
%     used_dataset = dataset;
% 
%     visualize_regression_2metrics(regression_2metrics_params, used_dataset, CVVDP, GSMD);
% end


%% Direct Mapping - 3 metrics

regression_3metrics_exists = exist('regression_1_2_3.mat', 'file');

if regression_3metrics_exists
    load('regression_1_2_3.mat', 'all_params', 'dataset')
    regression_3metrics_params = all_params;
    used_dataset = dataset;

    SSIM = 1;
    CVVDP = 2;
    GSMD = 3;

    visualize_regression_3metrics(regression_3metrics_params, used_dataset, SSIM, CVVDP, GSMD);
end

