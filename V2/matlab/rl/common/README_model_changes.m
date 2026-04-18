function README_model_changes()
disp("Caterpie V2 model assumptions:");
disp("1) RL Agent block path: ProblemState_RL/RL_IO/RL Agent");
disp("2) Observation is 7x1: [public(5); privileged(2)]");
disp("3) Public features = [e, A, de, ie, dA]");
disp("4) Privileged features = [y, B]");
disp("5) Actor uses only the public slice through a fixed selector layer.");
disp("6) Critics use the full privileged observation.");
disp("7) Action = [Kp_corr; Ki_corr]");
disp("8) Safety shield is applied before PI_ML.");
disp("9) Disturbance is injected through workspace variable 'tuvar'.");
disp("10) If using a manual switch, training/evaluation scripts assume the RL branch is selected.");
end