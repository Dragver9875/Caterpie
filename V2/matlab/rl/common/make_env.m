function env = make_env(cfg)
ensure_agent_obj(cfg);

if ~bdIsLoaded(cfg.modelName)
    load_system(cfg.modelPath);
end

obsInfo = rlNumericSpec([cfg.obsDim 1], ...
    'LowerLimit', -inf(cfg.obsDim,1), ...
    'UpperLimit',  inf(cfg.obsDim,1));
obsInfo.Name = "observations";

actInfo = rlNumericSpec([cfg.actDim 1], ...
    'LowerLimit', cfg.KcorrMin * ones(cfg.actDim,1), ...
    'UpperLimit', cfg.KcorrMax * ones(cfg.actDim,1));
actInfo.Name = "gain_corrections";

env = rlSimulinkEnv(cfg.modelName, cfg.agentBlk, obsInfo, actInfo);
env.ResetFcn = @(in) reset_fn(in, cfg);
end