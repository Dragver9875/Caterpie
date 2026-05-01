# Caterpie

Adaptive PI gain tuning in **MATLAB/Simulink** using **Reinforcement Learning**.

Caterpie is an adaptive control project where a baseline **PI controller** is retained, while reinforcement learning agents learn multiplicative gain correction factors online.

The learned controller does **not** replace the PI controller. Instead, it acts as a supervisory tuner for the proportional and integral gains:

$K_{p,\text{eff}} = K_{p,\text{fixed}} \cdot K_{p,\text{corr}}$

$K_{i,\text{eff}} = K_{i,\text{fixed}} \cdot K_{i,\text{corr}}$

The goal is to improve tracking and disturbance rejection while preserving the interpretability and structure of classical PI control.

---

## Project Goal

Build an **adaptive PI gain-tuning framework** where the learning system:

* observes plant feedback and disturbance information,
* predicts PI gain correction factors,
* improves tracking under disturbance,
* preserves the classical PI controller structure,
* remains compatible with the provided Simulink plant model.

At deployment/inference time, the controller is constrained to use only:

* **tracking error**
* **Disturbance A**

Version 1 establishes the PPO-based RL baseline. Version 2 extends the system to **SAC with asymmetric privileged learning**, where privileged information is used only by the critics during training while the deployable actor remains restricted to public runtime signals.

---

## Core Idea

The RL agent acts as a **supervisory gain tuner**:

1. Read plant feedback.
2. Build a normalised observation vector.
3. Predict `Kp_corr` and `Ki_corr`.
4. Pass corrections through a safety and smoothing layer.
5. Apply corrected gains to the PI controller.
6. Drive the plant and receive new feedback.
7. Compute reward and update the RL agent during training.

The control law remains PI-based:

$u(t) = K_{p,\text{eff}}e(t) + K_{i,\text{eff}}\int e(t),dt$

---

# Workflow Overview

The repository contains two major development stages.

## Version 1 — PPO-Based Adaptive PI Gain Tuning

Version 1 is the first working RL baseline.

### V1 Objective

V1 integrates a **PPO agent** into the Simulink control loop to learn adaptive PI gain correction factors.

The agent predicts:

$$
a_t =
\begin{bmatrix}
K_{p,\text{corr}} \
K_{i,\text{corr}}
\end{bmatrix}
$$

The PPO policy observes public features derived from:

* tracking error,
* Disturbance A,
* error derivative,
* error integral,
* disturbance derivative.

### V1 Observation

The normalised V1 public observation vector is:

$$
o_t^{\text{pub}} =
\begin{bmatrix}
\dfrac{e_t}{900} \
A_t \
\dfrac{\dot e_t}{2 \cdot 900} \
\dfrac{\int e_t , dt}{3 \cdot 900} \
\dfrac{\dot A_t}{2}
\end{bmatrix}
$$

### V1 Role

V1 was used to:

* build the first RL-compatible Simulink environment,
* verify the `RL_IO` subsystem,
* implement logging and evaluation helpers,
* test reward and termination logic,
* validate the adaptive PI formulation,
* provide a baseline before moving to SAC.

### V1 Status

Implemented in V1:

* PPO agent construction,
* PPO training script,
* Simulink RL environment,
* observation builder,
* safety shield,
* reward and done functions,
* logging of response, error, control, and gain corrections,
* plotting and metric computation.

V1 established the working control-learning pipeline, but PPO was sensitive to reward shaping and showed limited final tracking performance compared with the later SAC workflow.

---

## Version 2 — SAC + Asymmetric Privileged Learning

Version 2 is the current main workflow.

It uses **Soft Actor-Critic (SAC)** with an **asymmetric privileged actor-critic architecture**.

### Why SAC?

SAC is used because the action space is continuous:

$$
a_t =
\begin{bmatrix}
K_{p,\text{corr}} \
K_{i,\text{corr}}
\end{bmatrix}
$$

This makes SAC more suitable than discrete-action RL methods for smooth adaptive gain tuning.

---

# V2 Asymmetric Privileged SAC Architecture

The V2 architecture separates the information available to the actor from that available to the critics.

## Actor

The actor is deployment-compliant.

It only receives public observation:

$$
o_t^{\text{pub}} =
\begin{bmatrix}
\dfrac{e_t}{900} \
A_t \
\dfrac{\dot e_t}{2 \cdot 900} \
\dfrac{\int e_t , dt}{3 \cdot 900} \
\dfrac{\dot A_t}{2}
\end{bmatrix}
$$

The actor outputs:

$$
a_t =
\begin{bmatrix}
K_{p,\text{corr}} \
K_{i,\text{corr}}
\end{bmatrix}
$$

## Critics

The critics receive the full privileged observation:

$$
o_t^{\text{full}} =
\begin{bmatrix}
o_t^{\text{pub}} \
\dfrac{y_t}{900}
\end{bmatrix}
$$

where:

* $e_t$ is tracking error,
* $A_t$ is Disturbance A,
* $y_t$ is the actual plant response,
* $y_t$ is used as privileged critic-only information.

The full V2 observation is therefore 6-dimensional:

$$
o_t =
\begin{bmatrix}
\dfrac{e_t}{900} \
A_t \
\dfrac{\dot e_t}{2 \cdot 900} \
\dfrac{\int e_t , dt}{3 \cdot 900} \
\dfrac{\dot A_t}{2} \
\dfrac{y_t}{900}
\end{bmatrix}
$$

The actor internally uses only the first 5 entries. The critics use all 6 entries.

---

## Privileged Teacher SAC vs Asymmetric Privileged SAC

V2 supports both privileged SAC variants.

### Privileged Teacher SAC

In privileged teacher SAC:

* actor uses full public + privileged observation,
* critics use full public + privileged observation.

This acts as a high-performance teacher or upper-bound controller, but it is not deployment-compliant because the actor can depend on privileged signals.

### Asymmetric Privileged SAC

In asymmetric privileged SAC:

* actor uses only public features,
* critics use public + privileged features.

This is the preferred final architecture because the actor remains deployment-compliant while still benefiting from richer critic training.

---

# Safety, Smoothing, and PI Control

The raw SAC action is not applied directly.

The V2 control path is:

```text
SAC action
    -> action delay
    -> safety_shield
    -> gain_smoother
    -> PI_ML
    -> applied plant control
```

## Safety Shield

The safety shield clamps raw gain corrections to a safe range.

The latest effective range is broader than early experiments because the controller required more authority to reach the 900 setpoint:

```text
KcorrMin = 0.5
KcorrMax = 6.0
```

## Gain Smoother

The gain smoother applies:

* rate limiting,
* low-pass smoothing,
* near-target gain relaxation.

This prevents excessive gain chatter and reduces overshoot.

The near-target relaxation was critical for moving from fast but overshooting behaviour to zero-overshoot convergence.

## Anti-Windup PI Controller

The adaptive PI block `PI_ML` includes:

* integral state clamping,
* output saturation,
* corrected effective PI gains.

This prevents runaway integral windup and unrealistic control effort.

---

# Simulink Structure

The main RL-enabled model is:

```text
models/rl/ProblemState_RL.slx
```

The dedicated RL interface subsystem is:

```text
RL_IO
```

`RL_IO` contains:

* `obs_builder`
* `RL Agent`
* `safety_shield`
* `gain_smoother`
* `PI_ML`
* `reward_fn`
* `done_fn`

Top-level routing:

```text
Error           -> RL_IO/e
Disturbance A   -> RL_IO/A
Actual Response -> RL_IO/y
RL_IO/u_ml      -> selector switch
selector output -> Plant Model / Controller Output
```

The actual post-switch signal entering the plant is logged as:

```text
Applied Control
```

This is the preferred signal for evaluation plots.

---

# Requirements

## Software

* MATLAB
* Simulink
* Reinforcement Learning Toolbox

## Recommended

* MATLAB release compatible with the provided Simulink model.

---

# Quick Start

## 1. Add MATLAB paths

```matlab
setup_paths();
cfg = defaults();
```

## 2. Create the environment and SAC agent

```matlab
bdclose('all');
clear agentObj;

setup_paths();
cfg = defaults();

env = make_env(cfg);
agentObj = make_agent_sac_asym_priv(cfg, env);
assignin('base', 'agentObj',agentObj);

open_system(cfg.modelPath);
set_param(cfg.modelName,'SimulationCommand','update');
```

## 3. Train Asymmetric Privileged SAC

Before training, set the Simulink selector switch to the **RL branch**.

```matlab
trainingStats = train_sac_asym_priv();
```

## 4. Load the latest trained SAC agent

```matlab
agentDir = fullfile(cfg.projectRoot,'results','sac','asym_privileged','agents');
files = dir(fullfile(agentDir,'sac_asym_priv_*.mat'));

[~,idx] = max([files.datenum]);
latestFile = fullfile(files(idx).folder, files(idx).name);

S = load(latestFile);
agentObj = S.agentObj;
assignin('base', 'agentObj',agentObj);
```

## 5. Evaluate on `step_10`

```matlab
simOut = run_sim('step_10','eval');
sig = extract_logged_signals(simOut);

plot_episode_results(sig.t, sig.y, sig.e, sig.u_app, sig.Kp_corr, sig.Ki_corr, ...
    'Asymmetric Privileged SAC - step_10');

M = compute_metrics(sig.t, sig.y, sig.r);
disp(M)
```

## 6. Run V1 PPO Workflow

If using the V1 PPO baseline, set the selector switch to the RL branch and run:

```matlab
trainingStats = train_ppo();
```

Then load and evaluate the PPO checkpoint using the same logging and metrics utilities.

---

# Disturbance Cases

The current disturbance cases include:

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

# Metrics

The project evaluates:

* final value,
* steady-state error,
* maximum overshoot,
* maximum undershoot,
* IAE,
* ISE,
* first-hit time,
* settling time.

Metrics are computed using:

```text
matlab/metrics/compute_metrics.m
```

---

# Current Status

## Implemented

* RL-enabled Simulink environment
* V1 PPO-based adaptive PI workflow
* V2 SAC-based adaptive PI workflow
* standard SAC baseline structure
* privileged SAC teacher structure
* asymmetric privileged SAC architecture
* public-only actor with privileged critic
* normalized observation pipeline
* safety-bounded gain corrections
* external gain smoothing
* near-target gain relaxation
* anti-windup adaptive PI controller
* applied-control logging
* reward and termination logic
* evaluation and plotting utilities

## Current Best Workflow

```text
Asymmetric Privileged SAC
    -> safety shield
    -> gain smoother
    -> anti-windup PI_ML
    -> applied plant control
```

## Current Improvement Target

The controller currently tracks accurately with zero overshoot. The next optimisation target is:

```text
reduce rise time and settling time without reintroducing overshoot
```

---

# Design Principles

This project intentionally keeps the controller:

* **classical in structure**,
* **adaptive in gain tuning**,
* **bounded in action**,
* **interpretable in behavior**,
* **deployment-compliant at the actor level**.

The RL agent is treated as a high-level gain tuner rather than a direct black-box controller.

---

# Known Limitations

* Training performance is sensitive to reward design and gain constraints.
* Evaluation depends on correct selector-switch routing in Simulink.
* The current best controller is accurate but relatively conservative.
* Settling time can still be improved.
* Results should be evaluated across all disturbance cases, not only `step_10`.
* V1 PPO remains useful as a baseline, but V2 SAC is the current primary workflow.

---

# Notes on Data

The current RL workflow does not use a fixed supervised dataset.

Training data is generated online through Simulink rollouts:

```text
disturbance profile
    -> plant response
    -> observation
    -> SAC/PPO action
    -> corrected PI control
    -> reward
    -> policy update
```

The provided `.mat` files are used mainly for:

* model initialisation,
* signal inspection,
* debugging,
* validation of expected plant behaviour.

---

# Summary

Caterpie is an adaptive PI gain-tuning framework built in MATLAB/Simulink using reinforcement learning.

V1 established the PPO-based RL baseline and verified the Simulink-in-the-loop adaptive PI formulation.

V2 extends the project with SAC and asymmetric privileged learning, where the actor remains deployment-compliant while critics use additional training-time information.

The next development focus is response-speed improvement while maintaining stability and zero-overshoot behavior.
