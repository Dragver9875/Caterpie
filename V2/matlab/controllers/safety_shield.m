function aSafe = safety_shield(aRaw, cfg)

aRaw = aRaw(:);

amin = cfg.KcorrMin * ones(2,1);
amax = cfg.KcorrMax * ones(2,1);

aSafe = min(max(aRaw, amin), amax);
end