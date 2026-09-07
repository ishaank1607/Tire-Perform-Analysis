function cruiseAuto_main_M7_015_19(inputdata)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENGR 132 
% Program Description 
% Coordinates Alpha Version of CruiseAuto algorithm. Imports data, 
% identifies accel start, steady-state speed, and time constant.
%
% Function Call
% cruiseAuto_main_M7_015_19()
%
% Input Arguments
% None
%
% Output Arguments
% None
%
% Assignment Information
%   Assignment:     Cruise Auto - Main Function
%   Version:        M7
%   Team members:   Aarav Jain, jain925@purdue.edu 
%                   Abir Anajpur, aanajpur@purdue.edu 
%                   Nathan Lee, lee5698@purdue.edu 
%                   Ishaan Kedar Khambaswadkar, ikhambas@purdue.edu
%   Team ID:        015-19
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ____________________
%% INITIALIZATION
data_file = inputdata;

%% ____________________
%% CALCULATIONS

% 1. Import and clean data
[time_vec, speed_vec, metadata] = cruiseAuto_dataHandling_015_19_jain925(data_file);

% 2. Acceleration Start Time
t_start = cruiseAuto_timeAccel_015_19_ikhambas(time_vec, speed_vec);

if isnan(t_start)
    error('cruiseAuto_main_M7_015_19:noAccelDetected', ...
        'Could not detect an acceleration start time in %s. Check the input data.', data_file);
end

% 3. Steady State Speed
[v_initial, v_ss] = cruiseAuto_speedInitialFinal_015_19_aanajpur(time_vec, speed_vec, t_start);

% 4. Time Constant
tau = cruiseAuto_timeConst_015_19_lee5698(time_vec, speed_vec, t_start, v_initial, v_ss);

%% ____________________
%% FORMATTED TEXT/FIGURE DISPLAYS

fprintf('Vehicle: %s; Tire: %s\n', char(metadata.vehicle), char(metadata.tire));
fprintf('Accel Start: %.2f s\n', t_start);
fprintf('Initial Speed: %.2f m/s\n', v_initial);
fprintf('Steady-State Speed: %.2f m/s\n', v_ss);
fprintf('Time Constant (Tau): %.4f s\n', tau);

figure;
plot(time_vec, speed_vec, 'b.');
hold on; grid on;
xline(t_start, 'r--', 'Accel Start');
xline(t_start + tau, 'g--', 'Tau (63.2%)');
yline(v_ss, 'k:', 'Steady State');
title(['Speed Response: ', char(metadata.vehicle), ' - ', char(metadata.tire)]);
xlabel('Time (s)');
ylabel('Speed (m/s)');

%% ____________________
%% RESULTS

end