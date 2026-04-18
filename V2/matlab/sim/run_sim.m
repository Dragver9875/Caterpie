function simOut = run_sim(caseName, mode)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(caseName)
    caseName = 'step_10';
end

if nargin < 2 || isempty(mode)
    mode = 'train';
end

switch lower(string(mode))
    case "train"
        T_use = cfg.T_end_train;
    case "eval"
        T_use = cfg.T_end_eval;
    otherwise
        error('Unknown mode: %s', mode);
end

assignin('base', 'Ts', cfg.Ts);
assignin('base', 'T_end', T_use);

cfgLocal = cfg;
cfgLocal.T_end_train = T_use;
[~,~,tuvar] = make_disturbance_profile(caseName, cfgLocal);
assignin('base', 'tuvar', tuvar);

if ~bdIsLoaded(cfg.modelName)
    load_system(cfg.modelPath);
end

fprintf('[run_sim] Case: %s\n', caseName);
fprintf('[run_sim] Mode: %s\n', mode);
fprintf('[run_sim] Make sure controller selector is set as intended.\n');

simOut = sim(cfg.modelName, ...
    'StopTime', num2str(T_use), ...
    'FastRestart', 'off');

fprintf('[run_sim] Simulation complete.\n');
end