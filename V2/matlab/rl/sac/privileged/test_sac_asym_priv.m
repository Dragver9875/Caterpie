function [simOut, sig, M] = test_sac_asym_priv(caseName, agentFile)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(caseName)
    caseName = 'step_10';
end

asymAgentDir = fullfile(cfg.projectRoot, 'results', 'sac', 'asym_privileged', 'agents');

if nargin < 2 || isempty(agentFile)
    files = dir(fullfile(asymAgentDir, 'sac_asym_priv_*.mat'));
    if isempty(files)
        error('No trained asymmetric privileged SAC checkpoint found in %s', asymAgentDir);
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

fprintf('[test_sac_asym_priv] Using agent: %s\n', agentFile);

simOut = run_sim(caseName, 'eval');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, ...
    ['Asymmetric Privileged SAC - ' char(caseName)]);

M = compute_metrics(sig.t, sig.y, sig.r);
disp(M)
end