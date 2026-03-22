function aSafe = safety_shield(aRaw, lastA, cfg)
% aRaw, lastA are 2x1 vectors
% output = [Kp_corr; Ki_corr]

aMin = cfg.KcorrMin * ones(2,1);
aMax = cfg.KcorrMax * ones(2,1);

a = min(max(aRaw(:), aMin), aMax);

delta = a - lastA(:);
delta = min(max(delta, -cfg.dKcorrMax), cfg.dKcorrMax);
a = lastA(:) + delta;

alpha = 0.8;
aSafe = alpha*lastA(:) + (1-alpha)*a;
end