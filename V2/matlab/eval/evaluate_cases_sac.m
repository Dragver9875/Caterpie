function results = evaluate_cases_sac(agentFile)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(agentFile)
    files = dir(fullfile(cfg.saveAgentDirectory, 'sac_*.mat'));
    if isempty(files)
        files = dir(fullfile(cfg.saveAgentDirectory, '*.mat'));
    end
    if isempty(files)
        error('No SAC checkpoint found in %s', cfg.saveAgentDirectory);
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

fprintf('\n[evaluate_cases_sac] Using agent: %s\n', agentFile);
fprintf('Set the selector to RL/SAC branch before proceeding.\n');
fprintf('Press any key to continue...\n');
pause;

caseNames = string(cfg.evalCases(:));
nCases = numel(caseNames);

FinalValue      = zeros(nCases,1);
SteadyStateError= zeros(nCases,1);
MaxOvershootPct = zeros(nCases,1);
MaxUndershootPct= zeros(nCases,1);
IAE             = zeros(nCases,1);
ISE             = zeros(nCases,1);
Settle1Pct      = nan(nCases,1);

for i = 1:nCases
    thisCase = caseNames(i);
    fprintf('\n[evaluate_cases_sac] Running case: %s\n', thisCase);

    simOut = run_sim(char(thisCase), 'eval');
    sig    = extract_logged_signals(simOut);
    M      = compute_metrics(sig.t, sig.y, sig.r);

    plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, ...
        ['SAC - ' char(thisCase)]);

    FinalValue(i)       = M.finalValue;
    SteadyStateError(i) = M.ssError;
    MaxOvershootPct(i)  = M.maxOvershootPct;
    MaxUndershootPct(i) = M.maxUndershootPct;
    IAE(i)              = M.IAE;
    ISE(i)              = M.ISE;
    Settle1Pct(i)       = M.tSettle1Pct;
end

results = table( ...
    caseNames, ...
    FinalValue, ...
    SteadyStateError, ...
    MaxOvershootPct, ...
    MaxUndershootPct, ...
    IAE, ...
    ISE, ...
    Settle1Pct, ...
    'VariableNames', { ...
        'Case', ...
        'FinalValue', ...
        'SteadyStateError', ...
        'MaxOvershootPct', ...
        'MaxUndershootPct', ...
        'IAE', ...
        'ISE', ...
        'Settle1Pct' ...
        });

disp(results);

outFile = fullfile(cfg.evalDirectory, 'sac_eval_results.csv');
writetable(results, outFile);
fprintf('[evaluate_cases_sac] Saved results to %s\n', outFile);
end