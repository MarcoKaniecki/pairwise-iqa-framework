function normalized_dataset = normalize_data(prepared_data)
    for i = 1:length(prepared_data)
       prepared_data(i).Features = normalize(prepared_data(i).Features, 'range');
    end

    normalized_dataset = prepared_data;
end

