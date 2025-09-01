%% Preprocessing: Load and Prepare Image Quality Data
% This function loads and processes excel file dataset 

% Function to load and prepare data
function processed_data_struct = load_and_prepare_data(filepath, feature_columns)
    raw_data = readtable(filepath, "VariableNamingRule", "preserve");

    % outputs cell array
    source_images = unique(raw_data.source_image);
    
    % Remove 'NA' from codecs (reference images)
    if ismember('Codec', raw_data.Properties.VariableNames)
        codecs = unique(raw_data.Codec);
        codecs(strcmp(codecs, 'NA')) = [];
    elseif ismember('codec', raw_data.Properties.VariableNames)
        codecs = unique(raw_data.codec);
        codecs(strcmp(codecs, 'NA')) = [];
    end

    num_ref_images = length(source_images);
    num_codecs = length(codecs);

    % Initialize a struct array to store the processed data
    processed_data_struct = struct('SourceImage', {}, 'ImageFiles', {}, 'Codec', {}, ...
        'Distortion', {}, 'Bitrate', {}, 'Features', {}, 'groundTruth', {});

    % Process the data by grouping according to source images
    for i = 1:num_ref_images
        current_source = source_images{i};
        
        % Extract data for certain reference image and all its' distortions for parsing
        source_data = raw_data(strcmp(raw_data.source_image, current_source), :);
        
        % Extract relevant information (handle different column names)
        if ismember('Image_filename', raw_data.Properties.VariableNames)
            image_files = source_data.Image_filename;
        else
            image_files = source_data.image_filename;
        end
        
        if ismember('Codec', raw_data.Properties.VariableNames)
            codecs_for_source = source_data.Codec;
        else
            codecs_for_source = source_data.codec;
        end
        
        if ismember('Distortion', raw_data.Properties.VariableNames)
            distortion_levels = source_data.Distortion;
        else
            distortion_levels = source_data.distortion_level;
        end
        
        if ismember('bitrate', raw_data.Properties.VariableNames)
            bitrates = source_data.bitrate;
        else
            bitrates = [];
        end
        
        % Extract JND ground truth values
        ground_truth = source_data.jnd;
        
        % Extract all features
        features = source_data{:, feature_columns};
        
        % Store in the struct
        processed_data_struct(i).SourceImage = current_source;
        processed_data_struct(i).ImageFiles = image_files;
        processed_data_struct(i).Codec = codecs_for_source;
        processed_data_struct(i).Distortion = distortion_levels;
        processed_data_struct(i).Bitrate = bitrates;
        processed_data_struct(i).Features = features;
        processed_data_struct(i).groundTruth = ground_truth;
    end

    % Move ref_10 to the end
    idx10 = find(strcmp({processed_data_struct.SourceImage}, 'ref_10'), 1, 'first');
    if ~isempty(idx10) && idx10 < numel(processed_data_struct)
        processed_data_struct = [processed_data_struct([1:idx10-1, idx10+1:end]), processed_data_struct(idx10)];
    end

    fprintf('Loaded and prepared data for %d source images containing %d codecs and %d features from %s\n', ...
        numel(processed_data_struct), numel(codecs), numel(feature_columns), filepath);

end
