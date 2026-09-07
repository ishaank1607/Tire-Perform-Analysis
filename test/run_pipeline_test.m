% Generates a synthetic first-order step-response dataset with known
% parameters, runs it through the pipeline, and checks the recovered
% parameters are close to ground truth. Fails (non-zero exit) if not.

rng(1); % reproducible noise

t = (0:0.1:50)';
y_L_true = 0; y_H_true = 25; t_s_true = 6; tau_true = 2;

v = y_L_true + (y_H_true - y_L_true) * (1 - exp(-max(t - t_s_true, 0)/tau_true));
v(t < t_s_true) = y_L_true;
v = v + 0.1*randn(size(v)); % sensor noise

T = table(t, v, 'VariableNames', {'time', 'speed_compact_summer_test1'});
tmp_csv = [tempname, '.csv'];
writetable(T, tmp_csv);

[time_vec, speed_vec, metadata] = cruiseAuto_dataHandling_015_19_jain925(tmp_csv);
t_start = cruiseAuto_timeAccel_015_19_ikhambas(time_vec, speed_vec);
assert(~isnan(t_start), 'FAILED: t_start is NaN');
assert(abs(t_start - t_s_true) < 1.0, 'FAILED: t_start off by more than 1s');

[v_initial, v_ss] = cruiseAuto_speedInitialFinal_015_19_aanajpur(time_vec, speed_vec, t_start);
assert(abs(v_initial - y_L_true) < 1.0, 'FAILED: v_initial off');
assert(abs(v_ss - y_H_true) < 1.0, 'FAILED: v_ss off');

tau = cruiseAuto_timeConst_015_19_lee5698(time_vec, speed_vec, t_start, v_initial, v_ss);
assert(~isnan(tau), 'FAILED: tau is NaN');
assert(abs(tau - tau_true) < 1.0, 'FAILED: tau off by more than 1s');

fprintf('All checks passed. t_start=%.2f v_initial=%.2f v_ss=%.2f tau=%.2f\n', ...
    t_start, v_initial, v_ss, tau);

delete(tmp_csv);
