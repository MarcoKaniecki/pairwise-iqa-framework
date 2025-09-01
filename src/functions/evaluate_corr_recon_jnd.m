function corr_metrics = evaluate_corr_recon_jnd(reference_dataset_struct, reconstructed_values_struct)
    
    % r_ value - correlation coefficient - range: -1 (perfect negative correlation) to +1 (perfect positive correlation)
    % p_ value - statistical significance - range: 0 to 1 (where lower =
    % stronger evidence against the null hypothesis), p < 0.05: Commonly
    % accepted threshold for statistically significant
    corr_metrics = struct('SourceImage', {}, 'r_PEARSON', 0, 'r_SPEARMAN', 0, ...
        'p_PEARSON', 0, 'p_SPEARMAN', 0);

    for i = 1:length(reference_dataset_struct)
        source_image = reference_dataset_struct(i).SourceImage;

        ground_truth_jnd = reference_dataset_struct(i).groundTruth;
        reconstructed_jnd = reconstructed_values_struct(i).JND;

        % Pearson correlation
        [r_pearson, p_pearson] = corr(ground_truth_jnd, reconstructed_jnd, 'Type', 'Pearson');
        % Spearman rank correlation
        [r_spearman, p_spearman] = corr(ground_truth_jnd, reconstructed_jnd, 'Type', 'Spearman');

        corr_metrics(i).SourceImage = source_image;
        corr_metrics(i).r_PEARSON = r_pearson;
        corr_metrics(i).p_PEARSON = p_pearson;
        corr_metrics(i).r_SPEARMAN = r_spearman;
        corr_metrics(i).p_SPEARMAN = p_spearman;


        fprintf('Source Image: %s\n', source_image);
        fprintf('Pearson r: %.3f (p=%.3g)\n', r_pearson, p_pearson);
        fprintf('Spearman rho: %.3f (p=%.3g)\n\n', r_spearman, p_spearman);

    end

    fprintf('\nEvaluated correlation of reconstructed JND\n\n');
end