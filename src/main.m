% Main script
addpath('data/');
addpath('functions/');
addpath('functions/preprocessing/')
addpath('functions/visualizations/')


%% Preliminaries
reduced_dataset_path = 'data/reduced_features.xlsx';
%extended_dataset_path = 'data/extended_features.xlsx';


reduced_feature_columns = {'ssim', 'CVVDP', 'GMSD'};
% extended_feature_columns = {'psnry','ssim','ms_ssim','uqi','vif','nlpd','iw_ssim',...
%         'fsim','fsimc','vsi','Butteragli','Butteragli2','CVVDP','DISTS_pytorch',...
%         'GMSD','LPIPS','PieAPP','SSIMULACRA2','vmaf','vmaf_psnr_y',...
%         'vmaf_float_ssim','vmaf_float_ms_ssim','vmaf_neg','A-DISTS','Flip','topiq'};

% debug
extended_dataset_raw = readtable(reduced_dataset_path, "VariableNamingRule", "preserve");

fprintf('Loading and preparing datasets...\n');
reduced_dataset_prepared = load_and_prepare_data(reduced_dataset_path, reduced_feature_columns);
%extended_dataset_prepared = load_and_prepare_data(extended_dataset_path, extended_feature_columns); 

fprintf('Creating normalized datasets...\n');
reduced_normalized = normalize_data(reduced_dataset_prepared);
%extended_normalized = normalize_data(extended_dataset_prepared);


%% parameters
% set rng seed for repeatability
rng(42);

sigma = 1.0483;

% SVR hyperparameters - Thurstonian
svr_box_constraint = 0.01;
svr_epsilon = 0.001;

% SVR hyperparameters - Plain
svr_box_constraint_p = 1;
svr_epsilon_p = 0.1;

% RF hyperparameters
num_trees = 100; % Number of trees in the forest
min_leaf_size = 10; % Minimum number of observations per leaf


% used for saving results - Do not change
reduced_dataset = 'reduced';
extended_dataset = 'extended';

% Used in Exp1 and 2
%train_split = 0.8;


%% Experiment 1
% NOT IN THESIS - flawed train/test splitting
% Create proportion matrix first, then split the data
% Train one ML model per reference image and its alterations

%experiment_1(reduced_dataset_prepared, reduced_dataset, train_split, svr_box_constraint, sigma);
%experiment_1(extended_dataset_prepared, extended_dataset, train_split, svr_box_constraint, sigma);


%% Experiment 2
% NOT IN THESIS - not enough data after train/test split
% Split data first, then create the proportion matrix
% Train one ML model per reference image and its alterations

%experiment_2(reduced_normalized, reduced_dataset, train_split, svr_box_constraint, sigma);
%experiment_2(extended_normalized, extended_dataset, train_split, svr_box_constraint, sigma);


%% Experiment 3
% MAIN EXPERIMENT
% Train/test model on metrics and proportions
% Train ML model on 4 images, test on 1 image - 5-fold cross validation
% extended - 26 metrics, reduced - 3 metrics

experiment_3_SVR(reduced_normalized, reduced_dataset, svr_box_constraint, svr_epsilon, sigma);
%experiment_3_SVR(extended_normalized, extended_dataset, svr_box_constraint, svr_epsilon, sigma);

experiment_3_RF(reduced_dataset_prepared, reduced_dataset, num_trees, min_leaf_size, sigma);
%experiment_3_RF(extended_dataset_prepared, extended_dataset, num_trees, min_leaf_size, sigma);


%% Experiment 4
% Same as experiment 3, but using reduced number of features
% REPLACED with EXP3
%experiment_4_SVR(extended_normalized, extended_dataset, svr_box_constraint, svr_epsilon, sigma);


%% Experiment 5
% ALTERNATE METHOD TO THURSTONIAN MODEL
% Train/test model on metrics and quality values
% 4 image sets for training, 1 for testing - 5-fold cross validation
experiment_5(reduced_dataset_prepared, svr_box_constraint_p, svr_epsilon_p);

%% Experiment 6 - Hallucinations

% removed the 2 input images from dataset
hallu_path = 'data/filtered_hallucination_dataset.xlsx';

feature_columns = {'ssim'};

% Codecs not in dataset since they're currently not needed
processed_data_struct_6 = load_and_prepare_data(hallu_path, feature_columns);


experiment_6_H(processed_data_struct_6, sigma);


%% Direct Mapping - Regression - 1 metric
SSIM = 1;
CVVDP = 2;
GSMD = 3;
regression_1metric_crossval(reduced_dataset_prepared, SSIM);
regression_1metric_crossval(reduced_dataset_prepared, CVVDP);
regression_1metric_crossval(reduced_dataset_prepared, GSMD);

%% Direct Mapping - Regression - 2 metrics
% CVVDP = 2;
% GSMD = 3;
% regression_2metrics_crossval(reduced_dataset_prepared, CVVDP, GSMD);

%% Direct Mapping - Regression - 3 metrics
SSIM = 1;
CVVDP = 2;
GSMD = 3;
regression_3metrics_crossval(reduced_dataset_prepared, SSIM, CVVDP, GSMD);

