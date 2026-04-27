function sig = extract_logged_signals(simOut)
logs = simOut.logsout;
names = string(logs.getElementNames);

sig = struct();
sig.t = simOut.tout;

sig.r       = getLoggedSignal(logs, names, "Desired Response");
sig.d       = getLoggedSignal(logs, names, "Disturbance");
sig.u       = getLoggedSignal(logs, names, "Controller Out");
sig.u_ml    = getLoggedSignal(logs, names, "u_ml");
sig.u_app   = getLoggedSignal(logs, names, "Applied Control");
sig.y       = getLoggedSignal(logs, names, "Actual Response");
sig.A       = getLoggedSignal(logs, names, "Disturbance A");
sig.e       = getLoggedSignal(logs, names, "Error");
sig.Kp_corr = getLoggedSignal(logs, names, "Kp_corr");
sig.Ki_corr = getLoggedSignal(logs, names, "Ki_corr");

if isempty(sig.r)
    sig.r = 900 * ones(size(sig.t));
end

if isempty(sig.u_app)
    sig.u_app = sig.u_ml;
end

if isempty(sig.u_app)
    sig.u_app = sig.u;
end
end

function data = getLoggedSignal(logs, names, targetName)
idx = find(names == targetName, 1);

if isempty(idx)
    data = [];
    return;
end

elem = logs.getElement(idx);
vals = elem.Values;

if isprop(vals, 'Data')
    data = vals.Data;
else
    data = vals;
end
end