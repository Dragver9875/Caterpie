function README_model_changes()
disp("Model assumptions for Step 1 PPO:");
disp("1) RL Agent block path is ProblemState_RL/RL_IO/RL Agent");
disp("2) RL_IO observation = [e; A; de; ie; dA]");
disp("3) RL action = [Kp_corr; Ki_corr]");
disp("4) Safety shield is inside RL_IO");
disp("5) Plant actuation path goes through controller selector into Plant Model/Controller Output");
disp("6) Disturbance source uses variable 'tuvar' from workspace");
disp("7) For scripted baseline-vs-RL evaluation, replace Manual Switch with a Switch driven by 'useRL'");
end