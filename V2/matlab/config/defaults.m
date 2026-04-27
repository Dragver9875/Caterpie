function cfg = defaults()

projectRoot = evalin('base', 'PROJECT_ROOT');

cfg = struct();

cfg.projectRoot = projectRoot;
cfg.modelPath   = fullfile(projectRoot, 'models', 'rl', 'ProblemState_RL.slx');
cfg.modelName   = "ProblemState_RL";
cfg.agentBlk    = cfg.modelName + "/RL_IO/RL Agent";

cfg.Ts          = 0.05;
cfg.T_end_train = 40;
cfg.T_end_eval  = 100;

cfg.Kp_fixed    = 0.5;
cfg.Ki_fixed    = 0.1;

cfg.publicObsDim = 5;
cfg.privObsDim   = 1;
cfg.obsDim       = cfg.publicObsDim + cfg.privObsDim;

cfg.actDim = 2;

cfg.KcorrMin    = 0.5;
cfg.KcorrMax    = 6.0;
cfg.dKcorrMax   = 0.08;
cfg.smoothAlpha = 0.85;

cfg.rpmSetpoint = 900;

cfg.maxEpisodes        = 500;
cfg.maxStepsPerEpisode = floor(cfg.T_end_train / cfg.Ts);
cfg.scoreWindowLength  = 20;

cfg.trainCases_easy   = {'step_5', 'step_10'};
cfg.trainCases_medium = {'step_15', 'step_20'};
cfg.trainCases_hard   = {'large_drop'};

cfg.evalCases = {'step_10', 'large_drop'};

cfg.saveAgentDirectory = fullfile(projectRoot, 'results', 'sac', 'agents');
cfg.logDirectory       = fullfile(projectRoot, 'results', 'sac', 'logs');
cfg.plotDirectory      = fullfile(projectRoot, 'results', 'sac', 'plots');
cfg.evalDirectory      = fullfile(projectRoot, 'results', 'eval');

dirs = { ...
    cfg.saveAgentDirectory, ...
    cfg.logDirectory, ...
    cfg.plotDirectory, ...
    cfg.evalDirectory ...
    };

for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
    end
end

assignin('base', 'Ts', cfg.Ts);
assignin('base', 'T_end', cfg.T_end_train);
assignin('base', 'Kp_fixed', cfg.Kp_fixed);
assignin('base', 'Ki_fixed', cfg.Ki_fixed);
assignin('base', 'cfg', cfg);
end