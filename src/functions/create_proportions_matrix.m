%% Function: Derive Thurstonian Proportions from ground truth values
function forward_thurstonian_struct = create_proportions_matrix(processed_data_struct, sigma)
    % Define the standard normal CDF function
    Phi = @(x) normcdf(x);

    forward_thurstonian_struct = struct('SourceImage', {}, 'PropMatrix', {});
    
    for i = 1:length(processed_data_struct)
        % Extract data for the current source image
        source_image = processed_data_struct(i).SourceImage;
        ground_truth_values = processed_data_struct(i).groundTruth;

        % Number of distorted versions for this source image
        num_variations_with_reference = length(ground_truth_values);

        % Initialize storage for proportion matrices
        prop_matrix = zeros(num_variations_with_reference, num_variations_with_reference);

        % Compute Prop_right for all pairs (j, k)
        for j = 1:num_variations_with_reference
            for k = 1:num_variations_with_reference
                if j ~= k
                    % Compute the probability using the Thurstonian model
                    prop_matrix(j, k) = Phi((ground_truth_values(k) - ground_truth_values(j)) / sigma);
                end
            end
        end
  
        % Store the results in the struct
        forward_thurstonian_struct(i).SourceImage = source_image;
        forward_thurstonian_struct(i).PropMatrix = prop_matrix;
    end
    
    fprintf('Created prop matrix of size %dx%d\n', num_variations_with_reference, num_variations_with_reference);
end