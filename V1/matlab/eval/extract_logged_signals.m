function sig = extract_logged_signals(simOut)
% Extract logged signals from Simulink.SimulationOutput

logs = simOut.logsout;

sig = struct();
sig.t = simOut.tout;

sig.r = logs.get("Desired Response").Values.Data;
sig.d = logs.get("Disturbance").Values.Data;
sig.u = logs.get("Controller Out").Values.Data;
sig.y = logs.get("Actual Response").Values.Data;
sig.A = logs.get("Disturbance A").Values.Data;
sig.B = logs.get("Disturbance B").Values.Data;
sig.e = logs.get("Error").Values.Data;
end