function trainingStats = train_sac_priv_teacher()

setup_paths();
cfg = defaults();

teacherRoot = fullfile(cfg.projectRoot, 'results', 'sac', 'privileged_teacher');
agentDir    = fullfile(teacherRoot, 'agents');
logDir      = fullfile(teacherRoot, 'logs');
plotDir     = fullfile(teacherRoot, 'plots');

dirs = {teacherRoot, agentDir, logDir, plotDir};
for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
    end
end

fprintf('\n[train_sac_priv_teacher] IMPORTANT:\n');
fprintf('Set the controller selector in ProblemState_RL.slx to the RL branch (RL_IO/u_ml).\n');
fprintf('Then press any key to continue...\n');
pause;

env = make_env(cfg);
agentObj = make_agent_sac_priv_teacher(cfg, env);
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
save(fullfile(agentDir, "sac_priv_teacher_" + stamp + ".mat"), ...
    "agentObj", "cfg", "trainingStats");

fprintf('[train_sac_priv_teacher] Training complete.\n');
fprintf('[train_sac_priv_teacher] Saved artifacts under: %s\n', teacherRoot);
end