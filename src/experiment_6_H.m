function experiment_6_H(processed_data_struct, sigma)

    fprintf('Running experiment_6 hallucinations\n');

    % On JPEG AIC Github
    true_data = {
        'ref_7', 'PTC_00007_0ref_00.png',       0,           1;
        'ref_7', 'PTC_00007_AVIF_01.png', 0.090231714, 0.986292116;
        'ref_7', 'PTC_00007_AVIF_02.png', 0.537907985, 0.972614157;
        'ref_7', 'PTC_00007_AVIF_03.png', 1.024530848, 0.962853962;
        'ref_7', 'PTC_00007_AVIF_04.png', 1.473278702, 0.953214307;
        'ref_7', 'PTC_00007_AVIF_05.png', 1.780422097, 0.945743136;
        'ref_7', 'PTC_00007_AVIF_06.png', 2.057346113, 0.939090926;
        'ref_7', 'PTC_00007_AVIF_07.png', 2.383576944, 0.929531949;
        'ref_7', 'PTC_00007_AVIF_08.png', 2.693956218, 0.919857107;
        'ref_7', 'PTC_00007_AVIF_09.png', 2.843612132, 0.914444981;
        'ref_7', 'PTC_00007_AVIF_10.png', 3.16951272,  0.903548312;
        };
    
    true_tbl = cell2table(true_data, ...
        'VariableNames', {'source_image', 'img_name', 'JND', 'SSIM'});


    % only using ref_7 for proof of concept
    ref_7_idx = 3;

    [train_data, ~] = train_test_split(processed_data_struct, 1, sigma);
    

    train_inputs = [train_data(ref_7_idx).Inputs];
    train_outputs = [train_data(ref_7_idx).Outputs];


    fprintf('Training RF model using %d samples %d IQ features...\n', length(train_outputs), size(train_inputs, 2)/2);

    num_trees = 100;
    min_leaf_size = 10;
    rf_model = TreeBagger(num_trees, train_inputs, train_outputs, ...
                      'Method', 'regression', ...
                      'MinLeafSize', min_leaf_size, ...
                      'OOBPrediction', 'on', ...
                      'NumPredictorsToSample', 'all');


    % input images
    ref = im2double(imread('data/PTC_00007_0ref_00.png'));
    dist = im2double(imread('data/PTC_00007_AVIF_08.png'));

    % create hallucinations
    alphas = [0.2, 0.3, 0.4, 0.5, 0.6, 0.8, 1.1, 1.2];
    hallucinations = cell(numel(alphas), 1);
    for i = 1:numel(alphas)
        hallucinations{i} = (1 - alphas(i)) * ref + alphas(i) * dist;
        hallucinations{i} = min(max(hallucinations{i}, 0), 1);
    end

    % reorder
    image_list{1} = ref;
    image_list{2} = hallucinations{1}; % alpha=0.2
    image_list{3} = hallucinations{2}; % alpha=0.3
    image_list{4} = hallucinations{3}; % alpha=0.4
    image_list{5} = hallucinations{4}; % alpha=0.5
    image_list{6} = hallucinations{5}; % alpha=0.6
    image_list{7} = hallucinations{6}; % alpha=0.8
    image_list{8} = dist;              % distorted image, e.g. AVIF_08
    image_list{9} = hallucinations{7}; 
    image_list{10}= hallucinations{8}; 
    
    % Compute SSIM values
    ssim_values = zeros(numel(image_list),1);
    for i = 1:numel(image_list)
        ssim_values(i) = windowed_ssim(image_list{i}, ref, 11);
    end

    % with 10 values (2 input + 8 halluc) -  ssim values
    % create 10*9 pairs
    pairs = [];         % To store index pairs
    ssim_pairs = [];    % To store value pairs

    n = numel(ssim_values);
    for i = 1:n
        for j = 1:n
            if i ~= j
                pairs = [pairs; i, j];
                ssim_pairs = [ssim_pairs; ssim_values(i), ssim_values(j)];
            end
        end
    end
    

    predictions = predict(rf_model, ssim_pairs);

    results(ref_7_idx).SourceImage = 'ref_7';
    results(ref_7_idx).Predicted = predictions;
    

    reconstructed_scales = reconstruction_H(processed_data_struct, results, pairs, sigma);

    pred_jnd = reconstructed_scales(3).JND;

    % plot
    ref_idx = 1;
    dist8_idx = 8;   % 'dist8' is at position 8 in image_list
    halluc7_idx = 9;
    halluc8_idx = 10;
    
    true_ssim = true_tbl.SSIM;
    true_jnd = true_tbl.JND;
    all_idx = 1:height(true_tbl);
    
    % Hallucination and distortion path: ref (1), halluc1-6 (2:7), dist8 (8), halluc7 (9), halluc8 (10)
    halluc_line_idx = [1 2 3 4 5 6 7 8 9 10];
    
    figure; hold on;
    
    % Plot hallucination path (gray line), no legend entry
    plot(ssim_values(halluc_line_idx), pred_jnd(halluc_line_idx), '-', ...
        'Color', [0.6 0.6 0.6], 'LineWidth', 2, 'HandleVisibility','off');
    
    % Plot hallucination points (gray circles, except special colors for ref/dist8)
    plot(ssim_values(2:7), pred_jnd(2:7), 'o', ...
        'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.7 0.7 0.7], ...
        'MarkerSize', 8, 'DisplayName', 'Hallucinations');
    
    % Plot predicted reference (blue circle)
    plot(ssim_values(ref_idx), pred_jnd(ref_idx), 'o', ...
        'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', ...
        'MarkerSize', 10, 'DisplayName', 'Reference Pred');
    
    % Plot predicted hallucination 7 (gray circle at idx 9)
    plot(ssim_values(halluc7_idx), pred_jnd(halluc7_idx), 'o', ...
        'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.7 0.7 0.7], ...
        'MarkerSize', 8, 'HandleVisibility','off');
    
    % Plot predicted hallucination 8 (gray circle at idx 10)
    plot(ssim_values(halluc8_idx), pred_jnd(halluc8_idx), 'o', ...
        'Color', [0.5 0.5 0.5], 'MarkerFaceColor', [0.7 0.7 0.7], ...
        'MarkerSize', 8, 'HandleVisibility','off');
    
    % Plot predicted distortion 8 (red circle, now on the path!)
    plot(ssim_values(dist8_idx), pred_jnd(dist8_idx), 'o', ...
        'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 10, 'DisplayName', 'Distortion 8 Pred');
    
    % Plot ground truth X's with lines between them (no legend entry)
    plot(true_ssim, true_jnd, '-k', 'LineWidth', 1.5, 'HandleVisibility','off');
    
    % Plot ground truth for reference (blue X)
    plot(true_ssim(ref_idx), true_jnd(ref_idx), 'x', ...
        'Color', 'b', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Reference True');
    
    red_x_idx = 9;
    % Plot ground truth for distortion 8 (red X)
    plot(true_ssim(red_x_idx), true_jnd(red_x_idx), 'x', ...
        'Color', 'r', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Distortion True');
    
    % Plot all other ground truth as black X
    other_idx = setdiff(all_idx, [ref_idx, red_x_idx]);
    plot(true_ssim(other_idx), true_jnd(other_idx), 'x', ...
        'Color', 'k', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Other Distortions (True)');
    
    xlabel('SSIM');
    ylabel('Distortion [JND]');
    title('Quality prediction from SSIM in JND (hallucinations in gray)');
    
    legend('Location', 'northeast', 'FontSize', 14);
    grid on;
    hold off;


end

% Reconstruct JND Scales for hallucinations
function reconstructed_scales = reconstruction_H(processed_data_struct, results, pairs, sigma)
% Initialize container for reconstructed scales
reconstructed_scales = struct('SourceImage', {}, 'JND', {});
i = 3; % index of ref_7

source_image = processed_data_struct(i).SourceImage;
    
    % Get number of distortions for this source image
    num_variations_with_reference = 10;
    
    % Get predicted proportions from the test set
    predicted_proportions = results(i).Predicted;
    
    j = pairs(:, 1);
    k = pairs(:, 2);
    
    % Initial guess for scale values
    x0 = zeros(num_variations_with_reference, 1);
    
    % Check initial negative log-likelihood
    initial_nll = NegLogLikelihood_H(x0, j, k, predicted_proportions, sigma);
    %fprintf('Initial NLL for %s: %.4f\n', source_image, initial_nll);
    
    % Define the objective function (negative log-likelihood)
    f = @(x) NegLogLikelihood_H(x, j, k, predicted_proportions, sigma);
    
    % Minimize NLL using fminunc
    options = optimset('MaxIter', 500, ...
        'TolFun', 1e-10, 'TolX', 1e-10, 'MaxFunEvals', 50000, 'Display', 'off');
    [x_optimal, nll_value, exitflag, output] = fminunc(f, x0, options);
    
    % Ensure proper orientation (match ground truth direction)
    if sum(x_optimal) < 0
        x_optimal = -x_optimal;
    end
    
    % Check final negative log-likelihood
    final_nll = NegLogLikelihood_H(x_optimal, j, k, predicted_proportions, sigma);
    %fprintf('Final NLL for %s: %.4f\n', source_image, final_nll);
    
    % Store reconstructed JND scale values
    reconstructed_scales(i).JND = x_optimal;
    reconstructed_scales(i).SourceImage = source_image;
    
    fprintf('Reconstruction completed for %s (Exit flag: %d)\n', source_image, exitflag);
    fprintf('Completed Thurstonian reconstruction to predict JND scales\n\n');
end


% Compute Negative Log-Likelihood for hallucinations
function nll = NegLogLikelihood_H(x, j, k, predicted_proportions, sigma)
    % Inputs:
    %   x: Vector of scale values (to be optimized)
    %   j, k: Pairwise indices (distortion level j vs. k)
    %   predicted_proportions: Predicted pairwise proportions from SVR
    %   sigma: constant for thurstonian model
    %
    % Output:
    %   nll: Computed negative log-likelihood value
    
    % Compute model probabilities using the normal CDF
    pright = normcdf((x(k) - x(j)) / sigma);
    pleft = 1 - pright;

    % length of pright is 2550 (51*50)
    
    % Compute Negative Log-Likelihood
    n = length(j); % total number of comparisons in test set
    nll_values = -(predicted_proportions .* log(pright) + (1 - predicted_proportions) .* log(pleft));
    
    nll_values = nll_values(:); % Reshape into column vector
    
    % x(1)^2 is added to fix the reference point, first image is the
    % reference image
    nll = sum(nll_values) / n + x(1)^2;
end


function mssim = windowed_ssim(img1, img2, win_size)
    % Convert to grayscale if needed
    if size(img1,3) == 3
        img1 = rgb2gray(img1);
    end
    if size(img2,3) == 3
        img2 = rgb2gray(img2);
    end
    img1 = double(img1);
    img2 = double(img2);

    K1 = 0.01; K2 = 0.03;
    L = 1; % Dynamic range (assume images in [0,1])
    C1 = (K1*L)^2;
    C2 = (K2*L)^2;

    % Create window (uniform or Gaussian)
    window = fspecial('gaussian', win_size, 1.5);

    mu1 = filter2(window, img1, 'valid');
    mu2 = filter2(window, img2, 'valid');
    mu1_sq = mu1 .* mu1;
    mu2_sq = mu2 .* mu2;
    mu1_mu2 = mu1 .* mu2;

    sigma1_sq = filter2(window, img1.^2, 'valid') - mu1_sq;
    sigma2_sq = filter2(window, img2.^2, 'valid') - mu2_sq;
    sigma12 = filter2(window, img1.*img2, 'valid') - mu1_mu2;

    ssim_map = ((2*mu1_mu2 + C1).*(2*sigma12 + C2)) ./ ...
               ((mu1_sq + mu2_sq + C1).*(sigma1_sq + sigma2_sq + C2));
    mssim = mean(ssim_map(:));
end
