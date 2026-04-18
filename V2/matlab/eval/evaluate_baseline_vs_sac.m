function T = evaluate_baseline_vs_sac(caseName, agentFile)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(caseName)
    caseName = 'step_10';
end

if nargin < 2 || isempty(agentFile)
    files = dir(fullfile(cfg.saveAgentDirectory, 'sac_*.mat'));
    if isempty(files)
        files = dir(fullfile(cfg.saveAgentDirectory, '*.mat'));
    end
    if isempty(files)
        error('No SAC agent checkpoint found in %s', cfg.saveAgentDirectory);
    end
    [~,idx] = max([files.datenum]);
    agentFile = fullfile(files(idx).folder, files(idx).name);
end

S = load(agentFile);
if isfield(S, 'agentObj')
    agentObj = S.agentObj;
else
    error('agentObj not found in %s', agentFile);
end
assignin('base', 'agentObj', agentObj);

fprintf('\n[compare_baseline_vs_sac] Case: %s\n', caseName);

fprintf('\nSet the selector to BASELINE PI branch, then press any key...\n');
pause;
simBase = run_sim(caseName, 'eval');
baseSig = extract_logged_signals(simBase);
baseM   = compute_metrics(baseSig.t, baseSig.y, baseSig.r);

fprintf('\nSet the selector to RL/SAC branch, then press any key...\n');
pause;
simSAC = run_sim(caseName, 'eval');
sacSig = extract_logged_signals(simSAC);
sacM   = compute_metrics(sacSig.t, sacSig.y, sacSig.r);

figure('Name', ['Baseline vs SAC - ' char(caseName)]);

subplot(3,1,1);
plot(baseSig.t, baseSig.y, 'LineWidth', 1.2); hold on;
plot(sacSig.t,  sacSig.y,  'LineWidth', 1.2);
grid on;
title(['Actual Response - ' char(caseName)]);
legend('Baseline', 'SAC', 'Location', 'best');
ylabel('Response');

subplot(3,1,2);
plot(baseSig.t, baseSig.e, 'LineWidth', 1.2); hold on;
plot(sacSig.t,  sacSig.e,  'LineWidth', 1.2);
grid on;
title('Error');
legend('Baseline', 'SAC', 'Location', 'best');
ylabel('Error');

subplot(3,1,3);
plot(baseSig.t, baseSig.u, 'LineWidth', 1.2); hold on;
plot(sacSig.t,  sacSig.u,  'LineWidth', 1.2);
grid on;
title('Controller Output');
legend('Baseline', 'SAC', 'Location', 'best');
ylabel('Control');
xlabel('Time (s)');

T = table( ...
    ["Baseline"; "SAC"], ...
    [baseM.finalValue;      sacM.finalValue], ...
    [baseM.ssError;         sacM.ssError], ...
    [baseM.maxOvershootPct; sacM.maxOvershootPct], ...
    [baseM.maxUndershootPct;sacM.maxUndershootPct], ...
    [baseM.IAE;             sacM.IAE], ...
    [baseM.ISE;             sacM.ISE], ...
    [baseM.tSettle1Pct;     sacM.tSettle1Pct], ...
    'VariableNames', { ...
        'Controller', ...
        'FinalValue', ...
        'SteadyStateError', ...
        'MaxOvershootPct', ...
        'MaxUndershootPct', ...
        'IAE', ...
        'ISE', ...
        'Settle1Pct' ...
        });

disp(T);

outFile = fullfile(cfg.evalDirectory, ['compare_' char(caseName) '.csv']);
writetable(T, outFile);
fprintf('[compare_baseline_vs_sac] Saved summary to %s\n', outFile);
end