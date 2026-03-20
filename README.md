# Central Limit Theorem — Interactive Proof by Simulation

**Course:** Space Missions and Systems  
**Programme:** MSc Space and Astronautical Engineering  
**University:** Sapienza Università di Roma — A.Y. 2025–2026  

---
<img width="2560" height="1368" alt="Screenshot 2026-03-20 022336" src="https://github.com/user-attachments/assets/e6738716-5b21-4385-bc08-2308fe208d06" />

## Overview

This MATLAB interactive application provides a live, visual proof of the
**Central Limit Theorem (CLT)** using Monte-Carlo simulation of a
uniform distribution.

The terminology follows the standard **Orbit Determination** convention
from the primary course textbook:

> Tapley, B.D., Schutz, B.E., Born, G.H. (2004).  
> *Statistical Orbit Determination.* Elsevier Academic Press.  
> Appendix A — Probability and Statistics (pp. 439–471)  
> §A.20 — The Central Limit Theorem (p. 465)

Monte-Carlo results are labelled **Observed (O)** and analytical
N(0,1) values are labelled **Computed (C)**, consistent with the
residual framework O − C introduced in TSB §1.2.3.

---

## The Theorem

Given i.i.d. random variables X₁, X₂, ..., Xₙ ~ U(a, b) with:

```
μ  = (a + b) / 2          [mean]
σ² = (b − a)² / 12        [variance]
```

The standardised sum converges to a standard normal:

```
Z_n = (S_n − n·μ) / (√n · σ)  →  N(0,1)   as  n → ∞
```

**Assumptions (Lindeberg-Lévy):**
- (A1) Independent
- (A2) Identically distributed
- (A3) Finite mean μ = E[X]
- (A4) Finite variance 0 < σ² < ∞

**68 – 95 – 99.7 % Rule** (TSB §A.8.2):

| Band | Computed | Verified live |
|------|----------|---------------|
| ±1σ  | 68.27 %  | ✅ |
| ±2σ  | 95.45 %  | ✅ |
| ±3σ  | 99.73 %  | ✅ |

---

## Files

| File | Description |
|------|-------------|
| `CLT_Demo_Sapienza.m` | Main interactive MATLAB application |
| `README.md` | This file |

---

## Requirements

| Tool | Version |
|------|---------|
| MATLAB | R2019b or later |
| Toolboxes | None required |

---

## How to Run

1. Download or clone this repository:
   ```bash
   git clone https://github.com/YourUsername/CLT-Demo-Sapienza.git
   ```

2. Open MATLAB and navigate to the folder:
   ```matlab
   cd('path/to/CLT-Demo-Sapienza')
   ```

3. Run the demo:
   ```matlab
   CLT_Demo_Sapienza
   ```

---

## Layout

```
┌─────────────────┬──────────────────────┬──────────────┐
│  Theorem box    │                      │              │
│                 │   Main CLT           │  CONTROLS    │
│  Parent dist    │   histogram          │  n  slider   │
│  U(a,b)         │   + N(0,1) curve     │  N  slider   │
│                 │                      │  a  slider   │
│  68-95-99.7%    │   O-C Statistics     │  b  slider   │
│  bar chart      │   panel              │  ±σ bands    │
└─────────────────┴──────────────────────┴──────────────┘
```

---

## Interactive Controls

| Control | Range | Effect |
|---------|-------|--------|
| **n** — # RVs summed | 1 → 100 | Controls CLT convergence speed |
| **N** — MC samples | 100 → 50 000 | Controls statistical smoothness |
| **a** — lower bound | −5 → 0 | Changes the parent distribution |
| **b** — upper bound | 0.1 → 5 | Changes the parent distribution |
| **±σ bands** checkbox | ON / OFF | Toggles shaded probability bands |

Each slider has a paired **white edit box** — type any value and press
**Enter** to apply it directly.

---

## Suggested Demo Sequence

| Step | Setting | What you see |
|------|---------|--------------|
| 1 | n = 1 | Flat histogram — pure uniform, no CLT |
| 2 | n = 3 | Triangular shape |
| 3 | n = 10 | Recognisable bell curve |
| 4 | n = 30 | Histogram overlaps N(0,1) perfectly |
| 5 | Change a, b | CLT holds for any finite-variance distribution |
| 6 | Enable ±σ | Live verification of 68–95–99.7 % rule |

---

## O-C Statistics Panel

The bottom-centre panel reports live **O-C residuals** (Observed minus
Computed) for the standardised variable Z_n:

| Statistic | Observed (MC) | Computed N(0,1) |
|-----------|---------------|-----------------|
| Mean      | varies        | 0.0000 |
| Sigma     | varies        | 1.0000 |
| Skewness  | varies        | 0.0000 |
| Excess kurtosis | varies  | 0.0000 |

A **Convergence Index** (0–100 %) summarises how close the simulation
is to the theoretical N(0,1) distribution.

---

## Code Structure

The file is organised into 10 named `%%` sections — it prints as a
structured document from the MATLAB editor (File → Print):

| Section | Contents |
|---------|----------|
| 1 | Colour palette |
| 2 | Figure window and banner |
| 3 | All five axes |
| 4 | Right control panel |
| 5 | `update()` — all five panels (A–E) |
| 6 | Slider callbacks |
| 7 | Edit-box callbacks |
| 8 | Attach all callbacks |
| 9 | Initial draw |
| 10 | Command-window output and dataset |

---

## Reference

```
Tapley, B.D., Schutz, B.E., Born, G.H. (2004).
Statistical Orbit Determination.
Elsevier Academic Press, Burlington MA.
ISBN 0-12-683630-2
Appendix A: Probability and Statistics, pp. 439–471
```

---

*Developed for the oral examination in Space Missions and Systems,  
Sapienza Università di Roma, A.Y. 2025–2026.*
