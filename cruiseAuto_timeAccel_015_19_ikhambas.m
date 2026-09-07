function t_start = cruiseAuto_timeAccel_015_19_ikhambas(time_vec, speed_vec)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% This function identifies the start of the acceleration phase by detecting 
% a sustained increase in speed above the initial baseline noise.
%
% Function Call
% t_start = cruiseAuto_accel_time_SSS_TT_ikhambas(time_vec, speed_vec)
%
% Input Arguments
% 1. time_vec - Time data in [seconds]
% 2. speed_vec - Cleaned speed data in [m/s]
%
% Output Arguments
% 1. t_start - The detected time when acceleration begins [seconds]
%
% Assignment Information
%   Assignment:     Cruise Auto - Accel Start Time
%   Version:        M4
%   Primary author: Ishaan Kedar Khambaswadkar, ikhambas@purdue.edu
%   Team members:   Aarav Jain, jain925@purdue.edu
%                   Abir Anajpur, aanajpur@purdue.edu
%                   Nathan Lee, lee5698@purdue.edu
%   Team ID:        015-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION

% Smoothing parameters
windowSize = 5;
filt = ones(1, windowSize) / windowSize;

% Detection parameters
lookahead = 5;      % Number of points to check for sustained growth
accel_limit = 0.05; % Minimum change per data point to count as acceleration

%% ____________________
%% CALCULATIONS

% 1. Apply a moving average filter to reduce sensor noise
velocity_smooth = conv(speed_vec, filt, 'same');

% 2. Establish a baseline from the first few data points
baseline = mean(velocity_smooth(1:3));

% 3. Define a trigger threshold (10% above the max observed speed)
threshold = baseline + 0.1 * max(velocity_smooth);

% 4. Search for the first point that meets both threshold and growth criteria
t_start = NaN; 
i = 1; % Initialize index
max_idx = length(velocity_smooth) - lookahead;

% The loop runs as long as t_start is unknown AND we haven't hit the end
while isnan(t_start) && i <= max_idx
    if velocity_smooth(i) > threshold
        future_segment = velocity_smooth(i:i+lookahead);
        diffs = diff(future_segment);
        
        if mean(diffs) > accel_limit 
            t_start = time_vec(i); % This will stop the while loop
        end
    end
    i = i + 1; % Move to the next point
end

%% ____________________
%% FORMATTED TEXT/FIGURE DISPLAYS
% (Displays are handled in the main function)

%% ____________________
%% RESULTS

% The variable 't_start' is returned to the calling function.

end