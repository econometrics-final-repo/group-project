# Ruijia Wu
# I am the starter of the program
This code prepares and analyzes data from a lottery experiment to study the causal effects of winning the lottery on later outcomes. It begins by loading required R packages and importing the dataset. After inspecting the structure of the data, the script constructs treatment indicators that classify individuals into big winners, small winners, and controls. It also creates a binary variable for college education.

Next, the code subsets the data to compare big winners with the control group (or alternatively small winners vs. controls). It computes average pre-treatment and post-treatment earnings measures to use as covariates.

To adjust for observable differences between treated and control groups, the code estimates propensity scores using a Generalized Random Forest (GRF). These scores summarize each individual's predicted probability of being treated given their covariates.

Using these estimated propensity scores, the script performs 1:1 nearest-neighbor matching (without replacement) via the MatchIt package. The resulting matched dataset (s2) contains treated and control individuals who are comparable in observable characteristics, allowing for more credible estimation of treatment effects.

Overall, the purpose of this code is to construct treatment groups, generate covariates, estimate propensity scores, and create a matched sample that can be used for causal inference in the group project analysis.

# Yicheng Zhao
# I am responsible for Part 2 of the project
I analyze lines 61–159 of the script. This block builds on the matched sample `s2` and turns a plain matching exercise into a full causal analysis with diagnostics and reusable outputs. First, `table(s2$tr)` is used to check the treated–control composition in the matched data, verifying that one-to-one matching produced a balanced number of treated and control observations. The next section generates four diagnostic figures: log-odds of the propensity score and raw propensity scores, each plotted before matching (using `s`) and after matching (using `s2`), and saved as PDF files. These plots allow us to visually assess common support and the degree of overlap between treated and control groups pre- and post-matching. The script then performs a more formal covariate balance check. Using `summary(match.out, standardize = TRUE)`, it extracts standardized mean differences (SMDs) for all covariates before and after matching, reshapes them into long format, and creates a balance plot with `ggplot`. The plot shows SMDs by covariate for “before” and “after” and includes ±0.1 reference lines, making it easy to judge whether matching has reduced imbalance to acceptable levels. Once balance is assessed, the code estimates the treatment effect on the matched sample, using average post-treatment earnings `yearn.avg` as the outcome. It first runs a simple regression of `yearn.avg` on the treatment indicator `tr` to obtain a baseline ATT estimate, then augments the model with the full set of covariates for a more robust specification. Finally, the script creates an `output` directory if needed and saves the key objects (original and matched samples, matching object, and regression models) into a single `.RData` file, enabling reproducibility and further analysis. Compared with the original code, which stopped after computing propensity scores and matching, this extended block adds rigorous graphical diagnostics, explicit balance checks, formal ATT estimation, and systematic result storage, considerably improving transparency and credibility of the causal conclusions.
# Ruochen Su
# I am responsible for Part 5 of the project
This script mainly takes the QTE results we calculated earlier and turns them into a set of clean, easy-to-compare plots. The code starts by loading the saved RDS file, which already contains all the adjusted and unadjusted QTE objects we need.

To avoid repeating code, a small function called make_qte_plot() is created. It plots the adjusted and unadjusted QTE curves, adds a simple legend, and exports each figure as a PDF. This keeps the script short and makes the plotting steps more organized.

The script then uses this function to produce four main figures: pre-treatment and post-treatment QTEs for both the full sample and the trimmed sample. The y-axis range is fixed across all plots so we can compare them more easily.

In the last part, the code puts all four plots into one 2×2 layout and saves it as a single PDF. This gives a quick overview of how the treatment effect looks under different sample choices and whether adjusting the data changes the pattern.

Overall, the code is about turning the QTE results into visuals that we can use for interpretation later. It doesn’t run new models—it just organizes and presents the results in a clearer way.
