function [t, u, tuvar] = make_disturbance_profile(caseName, cfg)

Ts = cfg.Ts;
T  = cfg.T_end_train;
t  = (0:Ts:T)';

u = 0.5 * ones(size(t));

switch lower(string(caseName))
    case "step_5"
        u(t >= 4) = 0.55;

    case "step_10"
        u(t >= 4) = 0.60;

    case "step_15"
        u(t >= 4) = 0.65;

    case "step_20"
        u(t >= 4) = 0.70;

    case "large_drop"
        u(t < 8)  = 0.90;
        u(t >= 8) = 0.20;

    otherwise
        error('Unknown disturbance case: %s', caseName);
end

u = min(max(u, 0), 1);
tuvar = [t u];
end