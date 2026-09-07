# CruiseAuto — ACC Step-Response Parameter Identification

MATLAB pipeline that identifies first-order step-response parameters (acceleration start time, initial and steady-state speed, time constant τ) from adaptive cruise control (ACC) road-test data, in order to evaluate whether new eco-friendly tires preserve ACC performance across vehicle and tire types.

Developed for Purdue ENGR 132 by Team 015-19: Aarav Jain, Abir Anajpur, Nathan Lee, Ishaan Kedar Khambaswadkar.

## Problem

A fictional client, CruiseAuto, needed to know whether a new eco-friendly tire line preserves the acceleration behavior their ACC system was tuned for. Given raw speed-vs-time sensor logs from road tests across multiple vehicle classes and tire types, this program automatically cleans the data and fits a first-order step-response model:

```
v(t) = y_L + (y_H - y_L) * (1 - exp(-(t - t_s) / τ))
```

where `y_L` is the pre-acceleration speed, `y_H` is the steady-state speed, `t_s` is the time acceleration begins, and `τ` is the time constant (time to reach 63.2% of the step from `y_L` to `y_H`).

## What it does

1. **Imports and cleans raw sensor data** — locates the speed column by header name, detects frozen/stuck sensor readings and outlier spikes using sliding-window statistics, and repairs both via linear interpolation.
2. **Detects the acceleration start time (`t_s`)** — smooths the speed signal with a moving average, then scans for the first point where speed exceeds a baseline threshold *and* keeps rising over a lookahead window (avoids false triggers from single noisy points).
3. **Estimates initial and steady-state speed (`y_L`, `y_H`)** — averages the pre-acceleration window and the final 20% of the recording, respectively.
4. **Computes the time constant (`τ`)** — finds the time to reach `y_L + 0.632*(y_H - y_L)` after `t_s`.
5. **Visualizes the fit** — plots raw data against the identified acceleration start, time constant marker, and steady-state line.

## Repo structure

| File | Role |
|---|---|
| `cruiseAuto_main_M7_015_19.m` | Main function — coordinates the pipeline and produces the summary plot/printout |
| `cruiseAuto_dataHandling_015_19_jain925.m` | Imports the CSV, detects the speed column, cleans frozen readings and outlier spikes |
| `cruiseAuto_timeAccel_015_19_ikhambas.m` | Detects the acceleration start time `t_s` |
| `cruiseAuto_speedInitialFinal_015_19_aanajpur.m` | Estimates `y_L` (initial) and `y_H` (steady-state) speed |
| `cruiseAuto_timeConst_015_19_lee5698.m` | Computes the time constant `τ` |

## Usage

Requires base MATLAB (no additional toolboxes). Input CSV files should have a time column first, followed by a speed column whose header contains `speed` (e.g. `speed_compact_winter_01`), which is also used to infer vehicle/tire/trial metadata.

```matlab
cruiseAuto_main_M7_015_19('path/to/test_data.csv')
```

This prints the identified parameters and opens a plot of the raw data with the fitted model overlaid.

## Results

The algorithm was validated against reference parameter values across 9 benchmark vehicle–tire combinations (Compact/MidSize/FullSize × Winter/AllSeason/Summer), then applied to 45 eco-friendly tire test trials (5 per combination).

**Benchmark accuracy — before vs. after refinement**

| Metric | Earlier version | Refined version |
|---|---|---|
| Acceleration start time (`t_s`) error | 54–81% | **2–4.5%** |
| Steady-state speed (`y_H`) error | <1% | <1% |
| Modified SSE (fit quality) | ~27–29 | **0.05–0.25** |

The largest early source of error was a fixed-threshold detector for `t_s` that was sensitive to noise; replacing it with a smoothed, sustained-growth (lookahead-window) detector was the single biggest accuracy improvement in the project.

**Eco-friendly tire findings (45 trials, 9 vehicle–tire combinations)**

- Steady-state speed (`y_H`) decreased with vehicle size: Compact ≈24.9–25.6 m/s, MidSize ≈24.6–25.1 m/s, FullSize ≈23.5–23.9 m/s.
- Time constant (`τ`) varied by tire type: summer tires responded fastest (as low as 1.22–1.40 s), winter tires slowest (up to 3.81 s), consistent with expected tread and rolling-resistance differences.
- Initial speed (`y_L`) stayed close to 0 m/s across all trials, confirming consistent pre-acceleration test conditions.

## Limitations

- Acceleration-start detection is still sensitive to sensor noise; an unusually noisy trial can trigger a false early detection, which shifts the entire fitted curve since `t_s` anchors the model.
- The representative parameter set for each vehicle–tire combination is drawn from a single trial (the one with the earliest detected `t_s`) rather than averaged across all trials, so a noise-driven anomaly in that trial is not diluted by the others.
- `y_L` was consistently the least precisely estimated parameter.

## Team

Aarav Jain (`jain925@purdue.edu`) · Abir Anajpur (`aanajpur@purdue.edu`) · Nathan Lee (`lee5698@purdue.edu`) · Ishaan Khambaswadkar (`ikhambas@purdue.edu`)

Purdue ENGR 132, Team 015-19
