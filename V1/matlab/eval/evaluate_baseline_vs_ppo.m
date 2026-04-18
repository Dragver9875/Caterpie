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

    fprintf('  - Set selector to baseline, then press any key.\n');
    pause;
    simOutBase = sim(cfg.modelName, 'StopTime', num2str(cfg.T_end_eval));

    fprintf('  - Set selector to RL, then press any key.\n');
    pause;
    simOutRL = sim(cfg.modelName, 'StopTime', num2str(cfg.T_end_eval));

end
end