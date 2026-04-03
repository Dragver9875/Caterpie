function trainingStats = train_ppo_smoke()
setup_paths();
cfg = defaults();

% --- Short smoke-test overrides ---
cfg.maxEpisodes = 5;
cfg.T_end_train = 60;
cfg.maxStepsPerEpisode = floor(cfg.T_end_train / cfg.Ts);
cfg.trainCases = {'step_10','step_15'};
assignin('base','T_end',cfg.T_end_train);

% Make sure RL branch is active if you use a workspace-driven switch
assignin('base','useRL',1);

env = make_env(cfg);
agentObj = make_agent_ppo(cfg, env);
assignin('base','agentObj',agentObj);

trainOpts = rlTrainingOptions( ...
    MaxEpisodes = cfg.maxEpisodes, ...
    MaxStepsPerEpisode = cfg.maxStepsPerEpisode, ...
    ScoreAveragingWindowLength = 3, ...
    StopTrainingCriteria = "EpisodeCount", ...
    StopTrainingValue = cfg.maxEpisodes, ...
    Verbose = true, ...
    Plots = "training-progress" ...
    );

trainingStats = train(agentObj, env, trainOpts);

stamp = datestr(now,'yyyymmdd_HHMMSS');
save(fullfile(cfg.saveAgentDirectory, "ppo_smoke_" + stamp + ".mat"), ...
    "agentObj", "cfg", "trainingStats");

fprintf('[train_ppo_smoke] Smoke test complete.\n');
end