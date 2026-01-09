clc; clear; close all;
addpath(genpath(pwd));

cfg = struct();
cfg.SOC0 = 0.20;
cfg.SOC_target = 0.80;

cfg.Q_As = 2.2*3600;  % 2.2Ah example cell
cfg.V_max = 4.20;     % LiPo max
cfg.I_max = 2.0;      % 2A CC
cfg.I_end = 0.2;      % 0.2A termination
cfg.dt = 0.5;         % 0.5s sim step

% Optional limits/model
cfg.P_max = inf;      % set to e.g. 20W if you want power-limited
cfg.R0 = 0.03;
cfg.ocv_fn = @(s) 3.0 + 1.2*s - 0.1*s.*(1-s);

out = ttc_cccv(cfg);

fprintf("TTC: %.1f min (CC=%.1f min, CV=%.1f min)\n", ...
    out.ttc_s/60, out.cc_time_s/60, out.cv_time_s/60);

figure; plot(out.t_s/60, out.soc*100); grid on;
xlabel("Time (min)"); ylabel("SOC (%)"); title("SOC vs Time");

figure; plot(out.t_s/60, out.I_A); grid on;
xlabel("Time (min)"); ylabel("Current (A)"); title("Charge Current vs Time");

figure; plot(out.t_s/60, out.V_V); grid on;
xlabel("Time (min)"); ylabel("Voltage (V)"); title("Voltage vs Time");
