function [simOut, sig, M] = test_sac_priv_teacher(caseName, agentFile)

setup_paths();
cfg = defaults();

if nargin < 1 || isempty(caseName)
    caseName = 'step_10';
end

teacherAgentDir = fullfile(cfg.projectRoot, 'results', 'sac', 'privileged_teacher', 'agents');

if nargin < 2 || isempty(agentFile)
    files = dir(fullfile(teacherAgentDir, 'sac_priv_teacher_*.mat'));
    if isempty(files)
        error('No trained privileged SAC teacher checkpoint found in %s', teacherAgentDir);
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

fprintf('[test_sac_priv_teacher] Using agent: %s\n', agentFile);

simOut = run_sim(caseName, 'eval');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, ...
    ['Privileged SAC Teacher - ' char(caseName)]);

M = compute_metrics(sig.t, sig.y, sig.r);
disp(M)
end