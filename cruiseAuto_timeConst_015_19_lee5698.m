function tau = cruiseAuto_timeConst_015_19_lee5698(time_vec, speed_vec, t_start, v_initial, v_ss)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% This function calculates the system time constant (tau) for a 1st-order 
% speed response by identifying the time required to reach 63.2% of the 
% steady-state velocity.
%
% Function Call
% tau = cruiseAuto_time_constant_015_19_lee5698(time_vec, filtered_speed, t_start)
%
% Input Arguments
% time_vec - Time data in [seconds]
% filtered_speed - Processed speed data in [m/s]
% t_start  - The time at which the acceleration step began [seconds]
%
% Output Arguments
% tau - The calculated time constant in [seconds]
%
% Assignment Information
%   Assignment:     Cruise Auto - Time Constant
%   Version:        M4
%   Primary author: Nathan Lee, lee5698@purdue.edu
%   Team members:   Ishaan Kedar Khambaswadkar, ikhambas@purdue.edu
%                   Aarav Jain, jain925@purdue.edu
%                   Abir Anup Anajpure, aanajpur@purdue.edu
%   Team ID:        015-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION
tau_multiplier = 0.632; % The multiplier for a first-order system time constant

%% ____________________
%% CALCULATIONS
target_val = v_initial + tau_multiplier * (v_ss - v_initial);

% Only search after acceleration begins, so pre-accel noise can't match
idx = find(time_vec >= t_start & speed_vec >= target_val, 1, 'first');

if ~isempty(idx)
    t_at_threshold = time_vec(idx);
    tau = t_at_threshold - t_start;
else
    tau = NaN; 
end


%% ____________________
%% FORMATTED TEXT/FIGURE DISPLAYS


%% ____________________
%% RESULTS



