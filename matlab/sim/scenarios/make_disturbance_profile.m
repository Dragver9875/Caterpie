function [t, u, tuvar] = make_disturbance_profile(caseName, cfg)
% Returns time vector t, disturbance u, and Nx2 matrix tuvar=[t u]
%
% Disturbance A is assumed to live in [0,1].

Ts = cfg.Ts;
T  = cfg.T_end_train;
t  = (0:Ts:T)';

u = 0.5 * ones(size(t));   % nominal baseline

switch lower(string(caseName))
    case "step_5"
        u(t >= 40) = 0.55;

    case "step_10"
        u(t >= 40) = 0.60;

    case "step_15"
        u(t >= 40) = 0.65;

    case "step_20"
        u(t >= 40) = 0.70;

    case "step_30"
        u(t >= 40) = 0.80;

    case "large_drop"
        u(t < 80)  = 0.90;
        u(t >= 80) = 0.20;

    case "random_piecewise"
        nSeg = 6;
        brks = round(linspace(1,numel(t),nSeg+1));
        vals = 0.2 + 0.7*rand(nSeg,1);
        for k = 1:nSeg
            u(brks(k):brks(k+1)) = vals(k);
        end

    otherwise
        error('Unknown disturbance case: %s', caseName);
end

u = min(max(u,0),1);
tuvar = [t u];
end