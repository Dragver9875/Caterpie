function cfg = defaults()
% Central configuration for Step 1 PPO

projectRoot = evalin('base','PROJECT_ROOT');

cfg = struct();

% Paths
cfg.projectRoot = projectRoot;
cfg.modelPath   = fullfile(projectRoot,'models','rl','ProblemState_RL.slx');
cfg.modelName   = "ProblemState_RL";
cfg.agentBlk    = cfg.modelName + "/RL_IO/RL Agent";

% Timing
cfg.Ts          = 0.05;
cfg.T_end_train = 200;
cfg.T_end_eval  = 1000;

% Baseline controller gains from your model
cfg.Kp_fixed    = 0.5;
cfg.Ki_fixed    = 0.1;

% Observation/action dimensions
cfg.obsDim      = 5;   % [e; A; de; ie; dA]
cfg.actDim      = 2;   % [Kp_corr; Ki_corr]

% Action limits
cfg.KcorrMin    = 0.2;
cfg.KcorrMax    = 5.0;
cfg.dKcorrMax   = 0.05;

% Setpoint
cfg.rpmSetpoint = 900;

% PPO options
cfg.maxEpisodes             = 300;
cfg.maxStepsPerEpisode      = floor(cfg.T_end_train / cfg.Ts);
cfg.scoreWindowLength       = 20;
cfg.stopTrainingValue       = -0.02;   % starter threshold; tune later
cfg.saveAgentDirectory      = fullfile(projectRoot,'results','ppo','agents');
cfg.logDirectory            = fullfile(projectRoot,'results','ppo','logs');
cfg.plotDirectory           = fullfile(projectRoot,'results','ppo','plots');

% Disturbance cases for training
cfg.trainCases = {'step_5','step_10','step_15','step_20','step_30','large_drop','random_piecewise'};

% Eval cases
cfg.evalCases = {'step_5','step_10','step_15','step_20','step_30','large_drop'};

% Create output dirs
dirs = {cfg.saveAgentDirectory,cfg.logDirectory,cfg.plotDirectory,...
        fullfile(projectRoot,'results','eval')};
for i = 1:numel(dirs)
    if ~exist(dirs{i},'dir')
        mkdir(dirs{i});
    end
end

assignin('base','Ts',cfg.Ts);
assignin('base','T_end',cfg.T_end_train);
assignin('base','Kp_fixed',cfg.Kp_fixed);
assignin('base','Ki_fixed',cfg.Ki_fixed);
assignin('base','cfg',cfg);
end