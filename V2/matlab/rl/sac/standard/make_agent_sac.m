function agentObj = make_agent_sac(cfg, env)

obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

obsDim = cfg.obsDim;
actDim = cfg.actDim;

actorBase = [
    featureInputLayer(obsDim, Normalization="none", Name="obs")
    fullyConnectedLayer(128, Name="a_fc1")
    reluLayer(Name="a_relu1")
    fullyConnectedLayer(128, Name="a_fc2")
    reluLayer(Name="a_relu2")
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

actorNet = layerGraph(actorBase);
actorNet = addLayers(actorNet, meanPath);
actorNet = addLayers(actorNet, stdPath);
actorNet = connectLayers(actorNet, "a_relu2", "mean_fc");
actorNet = connectLayers(actorNet, "a_relu2", "std_fc");

actor = rlContinuousGaussianActor(actorNet, obsInfo, actInfo, ...
    ActionMeanOutputNames="mean_scale", ...
    ActionStandardDeviationOutputNames="std_softplus");

obsPath1 = [
    featureInputLayer(obsDim, Normalization="none", Name="obs")
    fullyConnectedLayer(128, Name="c1_obs_fc")
    ];

actPath1 = [
    featureInputLayer(actDim, Normalization="none", Name="act")
    fullyConnectedLayer(128, Name="c1_act_fc")
    ];

commonPath1 = [
    concatenationLayer(1,2, Name="c1_concat")
    reluLayer(Name="c1_relu1")
    fullyConnectedLayer(128, Name="c1_fc2")
    reluLayer(Name="c1_relu2")
    fullyConnectedLayer(1, Name="c1_q")
    ];

criticNet1 = layerGraph();
criticNet1 = addLayers(criticNet1, obsPath1);
criticNet1 = addLayers(criticNet1, actPath1);
criticNet1 = addLayers(criticNet1, commonPath1);

criticNet1 = connectLayers(criticNet1, "c1_obs_fc", "c1_concat/in1");
criticNet1 = connectLayers(criticNet1, "c1_act_fc", "c1_concat/in2");

critic1 = rlQValueFunction(criticNet1, obsInfo, actInfo, ...
    ObservationInputNames="obs", ...
    ActionInputNames="act");

obsPath2 = [
    featureInputLayer(obsDim, Normalization="none", Name="obs")
    fullyConnectedLayer(128, Name="c2_obs_fc")
    ];

actPath2 = [
    featureInputLayer(actDim, Normalization="none", Name="act")
    fullyConnectedLayer(128, Name="c2_act_fc")
    ];

commonPath2 = [
    concatenationLayer(1,2, Name="c2_concat")
    reluLayer(Name="c2_relu1")
    fullyConnectedLayer(128, Name="c2_fc2")
    reluLayer(Name="c2_relu2")
    fullyConnectedLayer(1, Name="c2_q")
    ];

criticNet2 = layerGraph();
criticNet2 = addLayers(criticNet2, obsPath2);
criticNet2 = addLayers(criticNet2, actPath2);
criticNet2 = addLayers(criticNet2, commonPath2);

criticNet2 = connectLayers(criticNet2, "c2_obs_fc", "c2_concat/in1");
criticNet2 = connectLayers(criticNet2, "c2_act_fc", "c2_concat/in2");

critic2 = rlQValueFunction(criticNet2, obsInfo, actInfo, ...
    ObservationInputNames="obs", ...
    ActionInputNames="act");

opt = rlSACAgentOptions;
opt.SampleTime = cfg.Ts;
opt.DiscountFactor = 0.99;
opt.ExperienceBufferLength = 1e6;
opt.MiniBatchSize = 256;
opt.TargetSmoothFactor = 5e-3;

agentObj = rlSACAgent(actor, [critic1 critic2], opt);
end