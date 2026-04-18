function aSafe = safety_shield(aRaw, prevA, cfg)
% Safety shield for gain correction factors
%
% Inputs
%   aRaw  : raw action [2x1] = [Kp_corr; Ki_corr]
%   prevA : previous safe action [2x1]
%   cfg   : config struct
%
% Output
%   aSafe : safe action [2x1]

aRaw  = aRaw(:);
prevA = prevA(:);

amin = cfg.KcorrMin * ones(2,1);
amax = cfg.KcorrMax * ones(2,1);

a = min(max(aRaw, amin), amax);

delta = a - prevA;
delta = min(max(delta, -cfg.dKcorrMax), cfg.dKcorrMax);
a = prevA + delta;

alpha = cfg.smoothAlpha;
aSafe = alpha * prevA + (1 - alpha) * a;
end