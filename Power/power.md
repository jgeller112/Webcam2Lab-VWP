---
title: "Read-Me"
---

# A Priori Power Analysis for a Cohort Effect in the Visual World Paradigm

This repository contains a Quarto (`.qmd`) workflow for conducting an **a priori power analysis** targeting a **cohort competition effect** in a Visual World Paradigm (VWP) task. The analysis is based on pilot webcam eye-tracking data collected during development of the `{webgazeR}` package and is designed to closely mirror the planned confirmatory statistical analysis.

---

## Overview

The workflow focuses on **TCUU trials** and proceeds through three primary stages: data binarization, mixed-effects modeling, and simulation-based power estimation.

---

## Head-to-Head Binarization

The analysis implements a direct comparison between the **cohort competitor** and an **unrelated competitor**, rather than comparing multiple competitors simultaneously.

For each *subject × trial × time bin*:

- Looks directed toward the `cohort` and `unrelated` competitors are summed.
- The competitor receiving the greater number of looks within that time bin is labeled the winner.
- Time bins containing ties are excluded from further analysis.

This procedure produces a binary outcome variable:

- `1` — the cohort competitor received more looks  
- `0` — the unrelated competitor received more looks  

This head-to-head comparison avoids statistical inflation that can occur when multiple unrelated competitors are pooled or jointly modeled.

---

## Binomial Mixed-Effects Modeling

Binary outcomes are aggregated within participant to obtain:

- the total number of **cohort wins**
- the total number of **valid comparison bins**

These counts are analyzed using a binomial generalized linear mixed-effects model (GLMM) fit with `{lme4}`:

```r
glmer(
  cbind(cohort_looks, all_looks - cohort_looks) ~
    1 + (1 | subject),
  family = binomial
)
```

In this model:

- The **intercept** represents the probability that the cohort competitor wins a time bin.
- A random intercept for subject accounts for between-participant variability.
- Effect sizes are estimated on the **log-odds scale**, consistent with binomial GLMM conventions.

The fitted model serves as the basis for power simulations.

---

## Power Simulation

Statistical power is estimated using the `{simr}` package.

The simulation workflow proceeds as follows:

1. The fitted GLMM is extended to larger hypothetical sample sizes.
2. A prespecified **smallest effect size of interest (SESOI)** is imposed by modifying the model intercept on the log-odds scale.
3. New datasets are simulated under this assumed effect.
4. The model is repeatedly re-fit to simulated datasets.

Power is defined as the proportion of simulations in which the cohort advantage is detected.

Power curves are evaluated across increasing participant sample sizes:

- 30 participants  
- 40 participants  
- 50 participants  
- 60 participants  

Each sample size is evaluated using **5,000 simulations**.

---

## Data Requirements

The workflow assumes an in-memory data frame named `gaze_sub` containing, at minimum, the following variables:

| Column | Description |
|--------|-------------|
| `subject` | Participant identifier |
| `trial` | Trial identifier |
| `trialtype` | Trial type (e.g., `TCUU`) |
| `time_bin` | Discretized time window |
| `condition` | Competitor label (`cohort`, `unrelated`) |
| `Looks` | Binary gaze sample indicator |

---

## Required R Packages

The analysis requires the following R packages:

- `dplyr`
- `tidyr`
- `lme4`
- `simr`
- `quarto`

---

## Reproducibility

All preprocessing, modeling, and simulation steps are implemented within a **Quarto-based reproducible workflow**. Rendering the `.qmd` file reproduces the complete analysis pipeline, including:

- data preprocessing  
- binarization procedures  
- model estimation  
- power simulations  
- power curve visualization  

---

## Notes

- The analysis evaluates whether the cohort competitor wins gaze competition more often than chance in direct competition with an unrelated item.
- Modeling aggregated binomial counts improves stability relative to bin-wise GLMM approaches.
- The simulation framework is intentionally aligned with the planned confirmatory analysis to minimize analysis–simulation mismatch.
- Effect sizes are interpreted on the log-odds scale.

---

## Author

Jason Geller, Ph.D.  
Human Neuroscience Lab  
Boston College  

---

## License

Specify license here (e.g., MIT License).
