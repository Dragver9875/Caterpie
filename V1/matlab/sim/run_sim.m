function simOut = run_sim(caseName)
setup_paths();
cfg = defaults();

if nargin < 1
    caseName = 'step_10';
end

assignin('base','Ts',cfg.Ts);
assignin('base','T_end',cfg.T_end_train);

[~,~,tuvar] = make_disturbance_profile(caseName, cfg);
assignin('base','tuvar',tuvar);

% IMPORTANT: create agentObj before loading the model
ensure_agent_obj(cfg);

load_system(cfg.modelPath);

fprintf('[run_sim] Case: %s\n', caseName);
fprintf('[run_sim] Make sure controller selector is set as intended.\n');

simOut = sim(cfg.modelName, ...
    'StopTime', num2str(cfg.T_end_train), ...
    'FastRestart', 'off');

fprintf('[run_sim] Simulation complete.\n');
end