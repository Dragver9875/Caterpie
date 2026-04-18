function aSafe = safety_shield(aRaw, prevA, cfg)
aRaw  = aRaw(:);
prevA = prevA(:);

amin = cfg.KcorrMin * ones(2,1);
amax = cfg.KcorrMax * ones(2,1);

a = min(max(aRaw, amin), amax);

delta = a - prevA;
delta = min(max(delta, -cfg.dKcorrMax), cfg.dKcorrMax);
a = prevA + delta;

alpha = 0.9;
aSafe = alpha*prevA + (1-alpha)*a;
end