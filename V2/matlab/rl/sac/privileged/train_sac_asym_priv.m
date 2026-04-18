function trainingStats = train_sac_asym_priv()

setup_paths();
cfg = defaults();

asymRoot = fullfile(cfg.projectRoot, 'results', 'sac', 'asym_privileged');
agentDir = fullfile(asymRoot, 'agents');
logDir   = fullfile(asymRoot, 'logs');
plotDir  = fullfile(asymRoot, 'plots');

dirs = {asymRoot, agentDir, logDir, plotDir};
for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
    end
end

fprintf('\n[train_sac_asym_priv] IMPORTANT:\n');
fprintf('Set the controller selector in ProblemState_RL.slx to the RL branch (RL_IO/u_ml).\n');
fprintf('Then press any key to continue...\n');
pause;

env = make_env(cfg);
agentObj = make_agent_sac_asym_priv(cfg, env);
assignin('base', 'agentObj', agentObj);

trainOpts = rlTrainingOptions( ...
    MaxEpisodes = cfg.maxEpisodes, ...
    MaxStepsPerEpisode = cfg.maxStepsPerEpisode, ...
    ScoreAveragingWindowLength = cfg.scoreWindowLength, ...
    StopTrainingCriteria = "EpisodeCount", ...
    StopTrainingValue = cfg.maxEpisodes, ...
    SaveAgentCriteria = "EpisodeCount", ...
    SaveAgentValue = 25, ...
    SaveAgentDirectory = agentDir, ...
    Verbose = true, ...
    Plots = "training-progress" ...
    );

trainingStats = train(agentObj, env, trainOpts);

stamp = datestr(now, 'yyyymmdd_HHMMSS');
save(fullfile(agentDir, "sac_asym_priv_" + stamp + ".mat"), ...
    "agentObj", "cfg", "trainingStats");

fprintf('[train_sac_asym_priv] Training complete.\n');
fprintf('[train_sac_asym_priv] Saved artifacts under: %s\n', asymRoot);
end