function evaluate_baseline_vs_ppo()
setup_paths();
cfg = defaults();

fprintf('[eval] For full automation, replace Manual Switch with a variable-driven Switch.\n');
fprintf('[eval] Current script is a template and assumes signal logging is already configured.\n');

for i = 1:numel(cfg.evalCases)
    caseName = cfg.evalCases{i};
    fprintf('[eval] Running case: %s\n', caseName);

    [~,~,tuvar] = make_disturbance_profile(caseName, cfg);
    assignin('base','tuvar',tuvar);

    % Baseline run
    fprintf('  - Set selector to baseline, then press any key.\n');
    pause;
    simOutBase = sim(cfg.modelName, 'StopTime', num2str(cfg.T_end_eval));

    % PPO run
    fprintf('  - Set selector to RL, then press any key.\n');
    pause;
    simOutRL = sim(cfg.modelName, 'StopTime', num2str(cfg.T_end_eval));

    %#ok<NASGU>
    % Add your logged-signal extraction here once you confirm exact signal names
end
end