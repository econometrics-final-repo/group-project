# Ruijia Wu
# I am the starter of the program

This code prepares and analyzes data from a lottery experiment to study the causal effects of winning the lottery on later outcomes. It begins by loading required R packages and importing the dataset. After inspecting the structure of the data, the script constructs treatment indicators that classify individuals into big winners, small winners, and controls. It also creates a binary variable for college education.

Next, the code subsets the data to compare big winners with the control group (or alternatively small winners vs. controls). It computes average pre-treatment and post-treatment earnings measures to use as covariates.

To adjust for observable differences between treated and control groups, the code estimates propensity scores using a Generalized Random Forest (GRF). These scores summarize each individual's predicted probability of being treated given their covariates.

Using these estimated propensity scores, the script performs 1:1 nearest-neighbor matching (without replacement) via the MatchIt package. The resulting matched dataset (s2) contains treated and control individuals who are comparable in observable characteristics, allowing for more credible estimation of treatment effects.

Overall, the purpose of this code is to construct treatment groups, generate covariates, estimate propensity scores, and create a matched sample that can be used for causal inference in the group project analysis.
