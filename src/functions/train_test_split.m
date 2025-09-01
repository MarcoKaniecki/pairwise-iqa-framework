% splits data, and creates pairs with respective proportions for SVR
function [train_data, test_data] = train_test_split(data_struct, train_split, sigma)

    train_data  = struct('SourceImage', {}, 'Inputs', {}, 'Outputs', {});
    test_data   = struct('SourceImage', {}, 'Inputs', {}, 'Outputs', {});
        
    for ref_img = 1:length(data_struct)
        % Create random indices for split
        num_samples = size(data_struct(ref_img).groundTruth, 1);
        indices = randperm(num_samples);
        train_size = round(train_split * num_samples);
        test_size = num_samples - train_size;

        train_indices = indices(1 : train_size);
        test_indices = indices(train_size+1 : end);

        % Split data
        train_inputs = data_struct(ref_img).Features(train_indices, :);
        train_outputs = data_struct(ref_img).groundTruth(train_indices);
        test_inputs = data_struct(ref_img).Features(test_indices, :);
        test_outputs = data_struct(ref_img).groundTruth(test_indices);

        % create proportions matrix from ground truth values
        train_prop_matrix = create_simple_prop_matrix(train_outputs, train_size, sigma);
        test_prop_matrix = create_simple_prop_matrix(test_outputs, test_size, sigma);

        % create io pairs for SVR training
        [train_input_pairs, train_output_pair] = create_io_pairs(train_inputs, train_prop_matrix, train_size);
        [test_input_pairs, test_output_pair] = create_io_pairs(test_inputs, test_prop_matrix, test_size);

        % store data
        train_data(ref_img).SourceImage = data_struct(ref_img).SourceImage;
        train_data(ref_img).Inputs = train_input_pairs;
        train_data(ref_img).Outputs = train_output_pair;

        test_data(ref_img).SourceImage = data_struct(ref_img).SourceImage;
        test_data(ref_img).Inputs = test_input_pairs;
        test_data(ref_img).Outputs = test_output_pair;



    end
        
end


function prop_matrix = create_simple_prop_matrix(ground_truth, size, sigma)
    Phi = @(x) normcdf(x);

    prop_matrix = zeros(size, size);

    for j = 1:size
        for k = 1:size
            % When j = k the value is 0.5
            prop_matrix(j, k) = Phi((ground_truth(k) - ground_truth(j)) / sigma);
        end
    end
end


function [input_pairs, output] = create_io_pairs(inputs, prop_matrix, size)
    input_pairs = [];
    output = [];

    for j = 1:size
        for k = 1:size
            if j ~= k
                input_vector = [inputs(j, :), inputs(k, :)];

                input_pairs = [input_pairs; input_vector];
                output = [output; prop_matrix(j, k)];
            end
        end
    end
end
