function agentObj = ensure_agent_obj(cfg)
% Ensure a valid agentObj exists in base workspace before loading the model

if evalin('base', 'exist(''agentObj'',''var'')')
    agentObj = evalin('base', 'agentObj');
    return;
end

% Observation and action specs
obsInfo = rlNumericSpec([cfg.obsDim 1], ...
    'LowerLimit', -inf(cfg.obsDim,1), ...
    'UpperLimit',  inf(cfg.obsDim,1));
obsInfo.Name = "observations";

actInfo = rlNumericSpec([cfg.actDim 1], ...
    'LowerLimit', cfg.KcorrMin * ones(cfg.actDim,1), ...
    'UpperLimit', cfg.KcorrMax * ones(cfg.actDim,1));
actInfo.Name = "gain_corrections";

obsDim = cfg.obsDim;
actDim = cfg.actDim;

% -------- Actor network --------
statePath = [
    featureInputLayer(obsDim, Normalization="none", Name="obs")
    fullyConnectedLayer(128, Name="fc1")
    reluLayer(Name="relu1")
    fullyConnectedLayer(128, Name="fc2")
    reluLayer(Name="relu2")
    ];

meanPath = [
    fullyConnectedLayer(actDim, Name="mean_fc")
    tanhLayer(Name="mean_tanh")
    scalingLayer(Name="mean_scale", ...
        Scale=(cfg.KcorrMax-cfg.KcorrMin)/2, ...
        Bias=(cfg.KcorrMax+cfg.KcorrMin)/2)
    ];

stdPath = [
    fullyConnectedLayer(actDim, Name="std_fc")
    softplusLayer(Name="std_softplus")
    ];

actorNet = layerGraph(statePath);
actorNet = addLayers(actorNet, meanPath);
actorNet = addLayers(actorNet, stdPath);
actorNet = connectLayers(actorNet, "relu2", "mean_fc");
actorNet = connectLayers(actorNet, "relu2", "std_fc");

actor = rlContinuousGaussianActor(actorNet, obsInfo, actInfo, ...
    ActionMeanOutputNames="mean_scale", ...
    ActionStandardDeviationOutputNames="std_softplus");

% -------- Critic network --------
criticNet = [
    featureInputLayer(obsDim, Normalization="none", Name="obs")
    fullyConnectedLayer(128, Name="c_fc1")
    reluLayer(Name="c_relu1")
    fullyConnectedLayer(128, Name="c_fc2")
    reluLayer(Name="c_relu2")
    fullyConnectedLayer(1, Name="value")
    ];

critic = rlValueFunction(criticNet, obsInfo);

% -------- PPO agent --------
opt = rlPPOAgentOptions;
opt.SampleTime = cfg.Ts;
opt.ExperienceHorizon = 256;
opt.MiniBatchSize = 256;
opt.NumEpoch = 3;
opt.ClipFactor = 0.2;
opt.EntropyLossWeight = 0.01;
opt.DiscountFactor = 0.99;
opt.AdvantageEstimateMethod = "gae";
opt.GAEFactor = 0.95;

agentObj = rlPPOAgent(actor, critic, opt);

assignin('base', 'agentObj', agentObj);
end