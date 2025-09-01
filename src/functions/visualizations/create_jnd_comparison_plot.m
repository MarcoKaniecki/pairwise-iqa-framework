function create_jnd_comparison_plot(~, reduced_reconstructed_scales, extended_dataset, extended_reconstructed_scales)
    % reduced_dataset variable not in use, since JND should be the same for
    % both datasets, so it doesn't matter which one is taken

    % Use one of the datasets as the base for our visualizations
    base_dataset = extended_dataset;

    num_ref_images = size(base_dataset, 2);

    % Get unique codecs from the data
    all_codecs = [];
    for i = 1:num_ref_images
        all_codecs = [all_codecs; unique(base_dataset(i).Codec)];
    end
    codecs = unique(all_codecs);
    % Remove 'NA' if it exists (reference images)
    codecs(strcmp(codecs, 'NA')) = [];
    num_codecs = length(codecs);

    for i = 1:num_ref_images
        ref_image = base_dataset(i).SourceImage;

        ground_truth = base_dataset(i).groundTruth;
        codecs_for_set = base_dataset(i).Codec;

        reduced_reconstructed = reduced_reconstructed_scales(i).JND;
        extended_reconstructed = extended_reconstructed_scales(i).JND;


        figure;

        % create subplot for each codec
        for c = 1:num_codecs
            % retrieve codec name
            codec_name = codecs{c};
            
            % Find indices for this codec
            codec_indices = strcmp(codecs_for_set, codec_name);

            % Skip if this codec doesn't exist for this image
            if ~any(codec_indices)
                continue;
            end

            original_jnd_scales = ground_truth(codec_indices);

            subplot(ceil(num_codecs / 2), 2, c);

            plot(1:length(original_jnd_scales), original_jnd_scales, '-o', 'LineWidth', 2, 'DisplayName', 'Original');
            hold on;

            reduced_reconstructed_per_codec = reduced_reconstructed(codec_indices);
            plot(1:length(reduced_reconstructed_per_codec), reduced_reconstructed_per_codec, '-x', 'LineWidth', 2, 'DisplayName', 'Reduced Features');

            extended_reconstructed_per_codec = extended_reconstructed(codec_indices);
            plot(1:length(extended_reconstructed_per_codec), extended_reconstructed_per_codec, '-s', 'LineWidth', 2, 'DisplayName', 'Extended Features');
            hold off;

            % add labeling for each subfigure
            title(codec_name, 'Interpreter', 'none');
            xlabel('Distortion Index');
            ylabel('JND Scale Value');
            legend('Location', 'northwest');
            grid on;

        end
        
        % add labeling for entire figure
        sgtitle(sprintf('JND Scales Comparison for %s', ref_image), 'Interpreter', 'none');

    end
end