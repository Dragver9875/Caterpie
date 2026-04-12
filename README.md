# Caterpie

Adaptive PI gain tuning in **MATLAB/Simulink** using **Reinforcement Learning**.

This project tackles a control problem where a baseline **PI controller** is retained, and an RL agent learns **multiplicative gain correction factors** online:

$K_{p,\text{eff}} = K_{p,\text{fixed}} \cdot K_{p,\text{corr}}$

$K_{i,\text{eff}} = K_{i,\text{fixed}} \cdot K_{i,\text{corr}}$



The goal is to improve disturbance rejection and tracking performance while preserving the interpretability and structure of classical PI control.

---

## Project Goal

Build an **adaptive PI tuning framework** where the learning system:

- observes only the allowed runtime signals
- predicts PI gain correction factors
- improves tracking under disturbance
- remains compatible with the provided Simulink plant model

At inference time, the controller is constrained to use only:

- **tracking error**
- **Disturbance A**

---

## Core Idea

The RL agent does **not** replace the controller.

Instead, it acts as a **supervisory gain tuner**:

1. Read plant feedback
2. Build an observation vector
3. Predict `Kp_corr` and `Ki_corr`
4. Pass corrections through a safety layer
5. Apply corrected gains to the PI controller
6. Drive the plant and receive new feedback

---

## Current Workflows

### Workflow 1 — PPO-based adaptive PI tuning
This is the main implemented workflow in V1.

- PPO policy predicts gain correction factors
- observation vector is built from:
  - error
  - Disturbance A
  - error derivative
  - error integral
  - disturbance derivative
- Simulink environment handles plant rollout, reward, and episode termination

### Workflow 2 — supervised teacher-student baseline
Planned parallel workflow.

- build a fixed dataset from rollout traces
- train a student model to imitate a better controller or RL teacher
- compare against PPO/SAC

### Workflow 3 / Stage 2 — SAC-based adaptive tuning
Planned next stage after stabilizing Workflow 1.

- same Simulink environment
- same controller structure
- different RL algorithm for potentially better continuous-control performance

---

## Observation and Action Design

### Action
The agent outputs:

$$
a_t =
\begin{bmatrix}
K_{p,\text{corr}} \\
K_{i,\text{corr}}
\end{bmatrix}
$$

### Observation
The normalized observation vector is:

$$
o_t =
\begin{bmatrix}
\dfrac{e_t}{900} \\
A_t \\
\dfrac{\dot e_t}{2 \cdot 900} \\
\dfrac{\int e_t \, dt}{3 \cdot 900} \\
\dfrac{\dot A_t}{2}
\end{bmatrix}
$$
These are passed through a safety shield before entering the PI controller.

---

## Simulink Structure

The main RL-enabled model is:

```text
models/rl/ProblemState_RL.slx
````

A dedicated subsystem `RL_IO` handles the learning interface:

* `obs_builder`
* `RL Agent`
* `safety_shield`
* `PI_ML`
* `reward_fn`
* `done_fn`

Top-level routing:

* `Error -> RL_IO/e`
* `Disturbance A -> RL_IO/A`
* `RL_IO/u_ml -> selector switch`
* selector output -> plant controller input

---

## Repository Structure

```text
Caterpie/
├── README.md
├── assets/
│   └── ps/
├── models/
│   ├── original/
│   │   ├── ProblemState.mdl
│   │   └── Simulink_Data.mat
│   └── rl/
│       └── ProblemState_RL.slx
├── matlab/
│   ├── setup_paths.m
│   ├── config/
│   │   └── defaults.m
│   ├── controllers/
│   │   └── safety_shield.m
│   ├── sim/
│   │   ├── run_sim.m
│   │   └── scenarios/
│   │       └── make_disturbance_profile.m
│   ├── metrics/
│   │   ├── compute_metrics.m
│   │   └── compute_margins.m
│   ├── rl/
│   │   ├── common/
│   │   │   ├── ensure_agent_obj.m
│   │   │   ├── make_env.m
│   │   │   └── reset_fn.m
│   │   ├── ppo/
│   │   │   ├── make_agent_ppo.m
│   │   │   └── train_ppo.m
│   │   └── sac/
│   │       ├── make_agent_sac.m
│   │       ├── train_sac.m
│   │       └── test_sac.m
│   └── eval/
│       ├── extract_logged_signals.m
│       └── plot_episode_results.m
└── results/
    ├── ppo/
    └── eval/
```

## Requirements

### Software

* MATLAB
* Simulink
* Reinforcement Learning Toolbox

### Recommended

* a MATLAB release compatible with the supplied Simulink model

---

## Quick Start

### 1. Add MATLAB paths

```matlab
setup_paths();
cfg = defaults();
```

### 2. Run a sanity simulation

```matlab
simOut = run_sim('step_10');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, 'Sanity Run');

M = compute_metrics(sig.t, sig.y, 900);
disp(M)
```

### 3. Train PPO

Set the selector switch to the **RL branch** in `ProblemState_RL.slx`, then run:

```matlab
trainingStats = train_ppo();
```

### 4. Load the latest trained agent

```matlab
files = dir(fullfile(cfg.saveAgentDirectory, '*.mat'));
[~,idx] = max([files.datenum]);
latestFile = fullfile(files(idx).folder, files(idx).name);

S = load(latestFile);
agentObj = S.agentObj;
assignin('base','agentObj',agentObj);
```

### 5. Evaluate a trained PPO controller

```matlab
simOut = run_sim('step_10');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u, sig.Kp_corr, sig.Ki_corr, ...
    'PPO Test - Step 10');

M = compute_metrics(sig.t, sig.y, 900);
disp(M)
```

### 6. Stage 2 SAC training

```matlab
trainingStats = train_sac();
```

---

## Disturbance Cases

Examples currently used in training/evaluation:

* `step_5`
* `step_10`
* `step_15`
* `step_20`
* `large_drop`

Disturbance generation is handled by:

```text
matlab/sim/scenarios/make_disturbance_profile.m
```

---

## Metrics

The project currently tracks:

* final value
* steady-state error
* overshoot
* undershoot
* IAE
* ISE
* settling time

Computed with:

```text
matlab/metrics/compute_metrics.m
```

---

## Current Status

### Implemented

* RL-enabled Simulink environment
* PPO-based adaptive PI workflow
* signal logging and extraction
* plotting and metric evaluation
* SAC scaffolding for Stage 2

### In progress

* PPO stability tuning
* reducing gain chatter
* improving steady-state tracking
* reproducible baseline-vs-RL evaluation

### Planned

* SAC benchmarking
* supervised teacher-student workflow
* automated switching/evaluation
* broader disturbance testing

---

## Design Principles

This project intentionally keeps the controller:

* **classical in structure**
* **adaptive in gain tuning**
* **bounded in action**
* **interpretable in behavior**

The RL agent is treated as a **high-level tuner**, not a black-box direct controller.

---

## Known Limitations

* PPO training is still sensitive to reward and episode design
* gain oscillation can appear under permissive settings
* full PS-level requirement satisfaction is not yet achieved
* some evaluation steps still rely on manual switch selection

---

## Roadmap

### V1

* PPO environment and training pipeline
* logging and evaluation
* stable RL-ready Simulink integration

### V2

* SAC training and comparison
* better safety constraints
* improved curriculum training

### V3

* supervised teacher-student workflow
* automated benchmarking
* final PS-aligned evaluation package

---

## Summary

Caterpie V1 is the first working version of an **adaptive PI tuning framework using RL in Simulink**.

It provides:

* a working PPO-based gain tuning setup
* a reusable RL-control environment
* signal logging and evaluation tools
* a foundation for SAC and supervised learning extensions

```
