% Reconstruct JND Scales
function reconstructed_scales = reconstruction(processed_data_struct, results, test_data, sigma)
    % Initialize container for reconstructed scales
    reconstructed_scales = struct('SourceImage', {}, 'JND', {});
    
    % Loop through each source image
    for i = 1:length(processed_data_struct)
        source_image = processed_data_struct(i).SourceImage;
    
        % Get number of distortions for this source image
        num_variations_with_reference = length(processed_data_struct(i).groundTruth);
    
        % Get predicted proportions from the test set
        predicted_proportions = results(i).Predicted;
    
        [j, k] = getIndices(processed_data_struct, test_data, i);

        % Initial guess for scale values
        x0 = zeros(num_variations_with_reference, 1);
    
        % Check initial negative log-likelihood
        initial_nll = NegLogLikelihood(x0, j, k, predicted_proportions, sigma);
        %fprintf('Initial NLL for %s: %.4f\n', source_image, initial_nll);
    
        % Define the objective function (negative log-likelihood)
        f = @(x) NegLogLikelihood(x, j, k, predicted_proportions, sigma);
    
        % Minimize NLL using fminunc
        options = optimset('MaxIter', 500, ...
            'TolFun', 1e-10, 'TolX', 1e-10, 'MaxFunEvals', 50000, 'Display', 'off');
        [x_optimal, nll_value, exitflag, output] = fminunc(f, x0, options);
    
        % Ensure proper orientation (match ground truth direction)
        if sum(x_optimal) < 0
            x_optimal = -x_optimal;
        end
    
        % Check final negative log-likelihood
        final_nll = NegLogLikelihood(x_optimal, j, k, predicted_proportions, sigma);
        %fprintf('Final NLL for %s: %.4f\n', source_image, final_nll);
    
        % Store reconstructed JND scale values
        reconstructed_scales(i).JND = x_optimal;
        reconstructed_scales(i).SourceImage = source_image;
    
        fprintf('Reconstruction completed for %s (Exit flag: %d)\n', source_image, exitflag);
    end
    
    fprintf('Completed Thurstonian reconstruction to predict JND scales\n\n');
end


% Compute Negative Log-Likelihood
function nll = NegLogLikelihood(x, j, k, predicted_proportions, sigma)
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


function [j, k] = getIndices(processed_data_struct, test_data, i)
    % Get test set indices
    test_indices = test_data(i).Inputs;

    num_variations_with_reference = length(processed_data_struct(i).groundTruth);
    
    % Find the pairs (j,k) from the test set
    [test_rows, ~] = size(test_indices);
    j = zeros(test_rows, 1);
    k = zeros(test_rows, 1);
    
    feature_size = size(processed_data_struct(i).Features, 2);
    
    % determine which (j,k) pair test data corresponds to by comparing
    % feature values
    % test set doesn't explicilty store j,k values from proccessed_data_struct
    for idx = 1:test_rows
        test_sample = test_indices(idx, :);
        features_j = test_sample(1:feature_size);
        features_k = test_sample(feature_size+1:end);
    
        for m = 1:num_variations_with_reference
            if all(features_j == processed_data_struct(i).Features(m, :))
                j(idx) = m;
            end
            if all(features_k == processed_data_struct(i).Features(m, :))
                k(idx) = m;
            end
        end
    end
end