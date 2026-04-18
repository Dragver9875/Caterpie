function [simOut, sig, M] = test_sac(caseName, agentFile)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(caseName)
    caseName = 'step_10';
end

stdAgentDir = fullfile(cfg.projectRoot, 'results', 'sac', 'standard', 'agents');

if nargin < 2 || isempty(agentFile)
    files = dir(fullfile(stdAgentDir, 'sac_standard_*.mat'));
    if isempty(files)
        error('No trained standard SAC checkpoint found in %s', stdAgentDir);
    end
    [~,idx] = max([files.datenum]);
    agentFile = fullfile(files(idx).folder, files(idx).name);
end

S = load(agentFile);
if ~isfield(S, 'agentObj')
    error('agentObj not found in %s', agentFile);
end

agentObj = S.agentObj;
assignin('base', 'agentObj', agentObj);

fprintf('[test_sac] Using agent: %s\n', agentFile);

simOut = run_sim(caseName, 'eval');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, ...
    ['Standard SAC - ' char(caseName)]);

M = compute_metrics(sig.t, sig.y, sig.r);
disp(M)
end