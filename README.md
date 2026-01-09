TIME-TO-CHARGE (TTC) ALGORITHM FOR EV / LI-ION BATTERIES
=======================================================

OVERVIEW
--------
This repository implements a Time-to-Charge (TTC) estimation algorithm for
Li-ion batteries and EV packs. The estimator predicts the remaining time to
reach a target SOC (or target energy) based on charger limits and a CC-CV
charging profile.

The goal is a practical algorithm suitable for BMS / EV applications:
- supports constant-current (CC) and constant-voltage (CV) phases
- supports current limits and power limits
- supports termination based on end-current (I_end) or target SOC


INPUTS
------
Required:
- SOC0        : initial state of charge (0 to 1)
- SOC_target  : target state of charge (0 to 1)
- Q_As        : nominal capacity in A*s  (Q_As = Ah * 3600)
- V_max       : max cell voltage (or pack voltage limit)
- I_max       : max charging current (A)   (CC limit)
- I_end       : end current threshold (A)  (CV termination)

Optional:
- P_max       : max charger power (W) (power-limited charging)
- R0          : internal resistance (ohm) (can be constant or SOC-dependent)
- OCV(SOC)    : open-circuit voltage model (function or lookup)


CHARGING MODEL (CC-CV)
----------------------

1) SOC dynamics (capacity model):
SOC(k+1) = SOC(k) + (I(k) * dt) / Q_As

2) Terminal voltage model (simple ECM):
V(k) = OCV(SOC(k)) + I(k)*R0

3) CC phase:
I(k) = min( I_max,  P_max / V(k) )    (if P_max is provided)
Continue CC until V(k) reaches V_max

4) CV phase:
V(k) = V_max
Current tapers based on battery model until:
- I(k) <= I_end  OR  SOC >= SOC_target

5) TTC output:
TTC = sum(dt) over the simulation horizon until termination condition is met


ALGORITHM OUTPUTS
-----------------
- Estimated time to reach SOC_target (seconds / minutes)
- Phase split: CC time and CV time
- Predicted current, voltage, SOC trajectories (optional)


REPOSITORY STRUCTURE
--------------------
ev-time-to-charge-algorithm/
|
|-- README.md
|-- scripts/
|   |-- 01_run_demo_ttc.m
|
|-- src/
|   |-- ttc_cccv.m
|   |-- ttc_power_limited.m
|   |-- utils_clamp.m
|
|-- docs/
    |-- assumptions.md


HOW TO RUN (MATLAB VERSION)
---------------------------
1) Open MATLAB
2) Set repo root as current folder
3) Run:

scripts/01_run_demo_ttc


ASSUMPTIONS
-----------
- SOC dynamics use nominal capacity (capacity fade not modeled)
- Temperature effects not modeled
- OCV(SOC) can be a simple function or lookup table
- R0 may be constant or SOC-dependent (extension)
- The model is designed for practical TTC estimation rather than electrochemical fidelity


POSSIBLE EXTENSIONS
-------------------
- Use SOC-dependent R0 and OCV from your parameter-estimation repo
- Add pack scaling (N_series, N_parallel)
- Include thermal derating and charger derating
- Add SOH effects and capacity fade
- Validate against real charger logs


AUTHOR
------
Dhyaan Radhakrishnamurthy

M.Eng Electrical & Computer Engineering, University of Ottawa

LinkedIn: https://www.linkedin.com/in/dhyaan-r-83b0a9198/
