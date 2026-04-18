function trainingStats = train_sac()

setup_paths();
cfg = defaults();

stdRoot = fullfile(cfg.projectRoot, 'results', 'sac', 'standard');
agentDir = fullfile(stdRoot, 'agents');
logDir   = fullfile(stdRoot, 'logs');
plotDir  = fullfile(stdRoot, 'plots');

dirs = {stdRoot, agentDir, logDir, plotDir};
for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
    end
end

fprintf('\n[train_sac] IMPORTANT:\n');
fprintf('Set the controller selector in ProblemState_RL.slx to the RL branch (RL_IO/u_ml).\n');
fprintf('Then press any key to continue...\n');
pause;

env = make_env(cfg);
agentObj = make_agent_sac(cfg, env);
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
save(fullfile(agentDir, "sac_standard_" + stamp + ".mat"), ...
    "agentObj", "cfg", "trainingStats");

fprintf('[train_sac] Training complete.\n');
fprintf('[train_sac] Saved artifacts under: %s\n', stdRoot);
end