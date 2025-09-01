function save_results(which_dataset, which_experiment, which_model, processed_data_struct, true_and_predicted_prop, errors, reconstructed_scales)
    if strcmp(which_dataset, 'reduced')
        if which_experiment == 1
            save('data/exp1_reduced_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved reduced feature set results for experiment 1\n');
        elseif which_experiment == 2
            save('data/exp2_reduced_results.mat', 'processed_data_struct', ...
                    'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved reduced feature set results for experiment 2\n');
        elseif which_experiment == 4
            save('data/exp4_reduced_results.mat', 'processed_data_struct', ...
                    'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved reduced feature set results for experiment 4\n');
        elseif which_experiment == 3
            if strcmp(which_model, 'SVR')
                save('data/exp3_reduced_SVR_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
                fprintf('Saved reduced feature set results for experiment 3 SVR\n');
            elseif strcmp(which_model, 'RF')
                save('data/exp3_reduced_RF_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
                fprintf('Saved reduced feature set results for experiment 3 RF\n');
            end
        end
    end
    if strcmp(which_dataset, 'extended')
        if which_experiment == 1
            save('data/exp1_extended_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved extended feature set results for experiment 1\n');
        elseif which_experiment == 2
            save('data/exp2_extended_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved extended feature set results for experiment 2\n'); 
        elseif which_experiment == 4
            save('data/exp4_extended_results.mat', 'processed_data_struct', ...
                'true_and_predicted_prop', 'errors', 'reconstructed_scales')
            fprintf('Saved extended feature set results for experiment 4\n'); 
        elseif which_experiment == 3
            if strcmp(which_model, 'SVR')
                save('data/exp3_extended_SVR_results.mat', 'processed_data_struct', ...
                    'true_and_predicted_prop', 'errors', 'reconstructed_scales')
                fprintf('Saved extended feature set results for experiment 3 SVR\n');
            elseif strcmp(which_model, 'RF')
                save('data/exp3_extended_RF_results.mat', 'processed_data_struct', ...
                    'true_and_predicted_prop', 'errors', 'reconstructed_scales')
                fprintf('Saved extended feature set results for experiment 3 RF\n');
            end
        end
    end
    fprintf('\n');
end