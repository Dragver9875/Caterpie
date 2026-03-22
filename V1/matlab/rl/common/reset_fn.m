function in = reset_fn(in, cfg)
% Randomize the disturbance scenario every episode

caseName = cfg.trainCases{randi(numel(cfg.trainCases))};
[~,~,tuvar] = make_disturbance_profile(caseName, cfg);

in = setVariable(in, "tuvar", tuvar);
in = setVariable(in, "Ts", cfg.Ts);
in = setVariable(in, "T_end", cfg.T_end_train);
in = setVariable(in, "Kp_fixed", cfg.Kp_fixed);
in = setVariable(in, "Ki_fixed", cfg.Ki_fixed);

% Helpful for debugging
in = setVariable(in, "episodeCaseName", caseName);
end