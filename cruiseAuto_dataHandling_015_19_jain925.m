function [time_vec, speed_vec, metadata] = cruiseAuto_dataHandling_015_19_jain925(data_file)

    %sub1_data_handler - Imports, cleans, and normalizes raw ACC speed test
    %data
    %
    % Inputs: 
    %   filepath - string to the CSV data file
        % Outputs: 
    %   time_vec - raw time vector as read from the file (s), unmodified
    %
    %   speed_vec - cleaned speed vector (m/s); frozen readings and
    %   outlier spikes are detected and replaced via linear interpolation
    %
    %   metadata - struct with fields: vehicle, tire, trial_id
    raw_table = readtable(data_file); 
    time_vec = raw_table{:, 1};
    var_names = raw_table.Properties.VariableNames;
    speed_col_idx = find(contains(lower(var_names), 'speed'), 1);
    
    if isempty(speed_col_idx)
        error('cruiseAuto_dataHandling_015_19_jain925:noSpeedColumn', ...
            'No column containing "speed" was found in %s.', data_file);
    end
    
    speed_vec = raw_table{:, speed_col_idx};
    col_name = var_names{speed_col_idx};
    parts = strsplit(col_name, "_"); 
        metadata.vehicle = parts{2}; 
    metadata.tire = parts{3}; 

    if length(parts) >= 4
        metadata.trial_id = parts{4};
    else
        metadata.trial_id = '';
    end


    % Array that defines if the value needs to be updated
    flag = false(size(speed_vec));


    % Detect the frozen readings window size = 5
    window_size = 5; 
    speed_diff = diff(speed_vec);  
    count = 0; 
    for k = 1:length(speed_diff)
        if speed_diff(k) == 0
            count=count+1; 
        else
            if count >= (window_size - 1)
                flag((k-count):k) = true; 
            end
            count = 0; 
        end
    end

    %Check if frozen sequences extends all the way to the end 
    if count >= (window_size - 1)
        n = length(speed_vec);
        flag((n-count):n) = true; 
    end 
    % Make all the missing values to be true 
    flag(isnan(speed_vec)) = true; 
    
    % Detect spikes using slididng window (choose 3 dtd from the mean in
    % the window) 
    window_size = 15; 
    n = length(speed_vec);

    for k = 1:n
        % Define the window bounds using floor to make sure it doesnt
        % exceed past certain bounds 
        start_pointer = max(1, k-floor(window_size/2)); 
        end_pointer = min(n, k+floor(window_size/2)); 
        window_vals = speed_vec(start_pointer:end_pointer); 


        % Remove already flagged points from the windows 
        window_flags = flag(start_pointer:end_pointer); 
        
        %~is used to invert all of the flags
        mask = ~window_flags; 
        valid_window = window_vals(mask); 

        if length(valid_window) > 2 
            local_mean = mean(valid_window);
            local_std = std(valid_window);
            if abs(speed_vec(k) - local_mean) > (3*local_std)
                flag(k) = true; 
            end 
        end 
    end 

    % Replace all of the points flagged as problemated with a linear
    % interpolation 

    valid_idx = find(~flag);
    flagged_idx = find(flag);

    if ~isempty(flagged_idx) && length(valid_idx) >= 2
        speed_vec(flagged_idx) = interp1(valid_idx, speed_vec(valid_idx), flagged_idx, 'linear', 'extrap'); 
    end 

    % Estimate the raw acceleration start time

    % Find the first points where rate of change exceeds a threshold 
    speed_gradient = diff(speed_vec) ./ diff(time_vec); 
    accel_threshold = 0.5; 

    accel_start_idx = find(speed_gradient > accel_threshold, 1); 

    if isempty(accel_start_idx)
        % Just in case no clear acceleration is detected just use the
        % midpoint
        t_s_raw = time_vec(round(length(time_vec) / 2)); 
        warning("No clear acceleration detected"); 
    else 
        t_s_raw = time_vec(accel_start_idx); 
    end 


    
     
    
end 
