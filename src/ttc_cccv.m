function out = ttc_cccv(cfg)
% TTC estimation using CC-CV simulation with a simple ECM:
% V = OCV(SOC) + I*R0
%
% cfg fields (required):
% SOC0, SOC_target, Q_As, V_max, I_max, I_end, dt
% optional: P_max, R0, ocv_fn (function handle)

SOC0 = cfg.SOC0;
SOCt = cfg.SOC_target;

dt   = cfg.dt;
Q    = cfg.Q_As;

Vmax = cfg.V_max;
Imax = cfg.I_max;
Iend = cfg.I_end;

if isfield(cfg,"R0"), R0 = cfg.R0; else, R0 = 0.02; end
if isfield(cfg,"P_max"), Pmax = cfg.P_max; else, Pmax = inf; end
if isfield(cfg,"ocv_fn"), ocv_fn = cfg.ocv_fn; else, ocv_fn = @(s) 3.0 + 1.2*s; end

SOC = SOC0;
t = 0;

% logs (optional)
T = [];
SOC_log = [];
I_log = [];
V_log = [];
phase_log = []; % 1=CC, 2=CV

cc_time = 0;
cv_time = 0;

phase = 1; % start CC

while SOC < SOCt
    ocv = ocv_fn(SOC);

    % determine current with CC and power limit
    % use last predicted voltage for power limit; simple iterative step
    Vpred = ocv + Imax*R0;
    IlimP = Pmax / max(Vpred, 1e-6);
    Icc = min(Imax, IlimP);

    if phase == 1
        I = Icc;
        V = ocv + I*R0;

        if V >= Vmax
            phase = 2; % enter CV
            continue;  % re-evaluate at CV
        end

        cc_time = cc_time + dt;

    else
        % CV phase: V = Vmax
        % Solve I from Vmax = OCV + I*R0  => I = (Vmax - OCV)/R0
        I = (Vmax - ocv) / max(R0, 1e-6);
        I = utils_clamp(I, 0, Icc); % cannot exceed CC/power limits

        V = Vmax;
        cv_time = cv_time + dt;

        if I <= Iend
            break; % terminate CV at end-current
        end
    end

    % SOC update
    SOC = SOC + (I*dt)/Q;
    SOC = utils_clamp(SOC, 0, 1);
    t = t + dt;

    % log
    T(end+1,1) = t; %#ok<AGROW>
    SOC_log(end+1,1) = SOC; %#ok<AGROW>
    I_log(end+1,1) = I; %#ok<AGROW>
    V_log(end+1,1) = V; %#ok<AGROW>
    phase_log(end+1,1) = phase; %#ok<AGROW>

    % safety
    if t > 24*3600
        error("Simulation exceeded 24h. Check config.");
    end
end

out.ttc_s = t;
out.cc_time_s = cc_time;
out.cv_time_s = cv_time;

out.t_s = T;
out.soc = SOC_log;
out.I_A = I_log;
out.V_V = V_log;
out.phase = phase_log;
end
