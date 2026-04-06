function in = reset_fn(in, cfg)
persistent epCount
if isempty(epCount)
    epCount = 0;
end
epCount = epCount + 1;

if epCount <= 100
    cases = cfg.trainCases_easy;
elseif epCount <= 200
    cases = [cfg.trainCases_easy, cfg.trainCases_medium];
else
    cases = [cfg.trainCases_easy, cfg.trainCases_medium, cfg.trainCases_hard];
end

caseName = cases{randi(numel(cases))};
[~,~,tuvar] = make_disturbance_profile(caseName, cfg);

in = setVariable(in, "tuvar", tuvar);
in = setVariable(in, "Ts", cfg.Ts);
in = setVariable(in, "T_end", cfg.T_end_train);
in = setVariable(in, "Kp_fixed", cfg.Kp_fixed);
in = setVariable(in, "Ki_fixed", cfg.Ki_fixed);
in = setVariable(in, "episodeCaseName", caseName);
end