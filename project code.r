#install packages
install.packages("ggplot2")
install.packages("tidyverse")
install.packages("tidyr")
install.packages("dplyr")
install.packages("grf")
install.packages("R.matlab")
install.packages("qte")
install.packages("SparseM")
install.packages("MatrixModels")
install.packages("MatchIt")
install.packages("estimate_all")
install.packages("probability_forest")
#library
library(ggplot2)
library(tidyverse)
library(tidyr)
library(dplyr)
library(grf)
library(R.matlab)
library(qte)
library(MatchIt)
#load data
load("~/Desktop/homework/group-project/lottery.RData")
head(d)
names(d)
str(d)
summary(d)
class(d)
str(d)

#hist(d$agew)
#hist(log10(d$yearlpr), breaks = 50)
table(d$winner, d$bigwinner)

d$tr <- d$winner                                                 
d$tr1 <- ifelse(d$bigwinner == 1, 1, 0) # big winner
d$tr2 <- ifelse(d$bigwinner == 0 & d$winner == 1, 1, 0) # small winner
d$co <- ifelse(d$winner == 0, 1, 0) # control

d$college <- ifelse(d$educ >= 16, 1, 0)

table(d$tr1, d$tr2)
table(d$tr1, d$co)
table(d$tr2, d$co)
s <- subset(d, tr1 == 1 | co == 1)
#s <- subset(d, tr2 == 1 | co == 1)

s$xearn.avg <- apply(s[, paste0("xearn.", 4:6)], 1, mean) # avg pre outcome
s$yearn.avg <- apply(s[, paste0("yearn.", 1:7)], 1, mean) # avg pst outcome

table(s$tr)

treat <- "tr"
covar <- c("tixbot", "male", "workthen", "agew", "educ", "college", 
           "xearn.1", "xearn.2", "xearn.3", "yearw")
s$ps <- probability_forest(X = s[, covar], 
                           Y = as.factor(s$tr), seed = 1234)$predictions[,2]

match.out <- matchit(tr ~ ps, ratio = 1, data = s, replace = FALSE)
s2 <- s[which(match.out$weights == 1), ]
table(s2$tr)
############################################################
## Code for figures (screenshot part) + extensions
############################################################

## Propensity score log-odds distribution (before matching)
pdf("graphs/irs/irs1_odds.pdf", width = 5.5, height = 5.5)
plot_hist(s, "ps", "tr",
          breaks = 30, odds = TRUE,
          xlim = c(-5.5, 1), ylim = c(-0.4, 0.4))
graphics.off()

## Propensity score log-odds distribution (matched / trimmed sample)
pdf("graphs/irs/irs1_odds_trim.pdf", width = 5.5, height = 5.5)
s2$ps <- probability_forest(X = s2[, covar],
                            Y = as.factor(s2$tr), seed = 1234)$predictions[,2]
plot_hist(s2, "ps", "tr",
          breaks = 30, odds = TRUE,
          xlim = c(-1, 1), ylim = c(-0.4, 0.4))
graphics.off()

## PS

## PS distribution (before matching)
pdf("graphs/irs/irs1_ps.pdf", width = 5.5, height = 5.5)
s$ps <- probability_forest(X = s[, covar],
                           Y = as.factor(s$tr), seed = 1234)$predictions[,2]
plot_hist(s, "ps", "tr",
          breaks = 30, odds = FALSE,
          xlim = c(0, 1), ylim = c(-0.4, 0.4))
graphics.off()

## PS distribution (matched / trimmed sample)
pdf("graphs/irs/irs1_ps_trim.pdf", width = 5.5, height = 5.5)
s2$ps <- probability_forest(X = s2[, covar],
                            Y = as.factor(s2$tr), seed = 1234)$predictions[,2]
plot_hist(s2, "ps", "tr",
          breaks = 30, odds = FALSE,
          xlim = c(0, 1), ylim = c(-0.4, 0.4))
graphics.off()



############################################################
## Extensions: covariate balance diagnostics + treatment effect
############################################################

## 1. Covariate balance: standardized mean differences before/after matching
sum_m <- summary(match.out, standardize = TRUE)
print(sum_m)  # quick check of overall balance in the console

## Put before/after SMDs into a data frame and plot with ggplot
bal_tab <- as.data.frame(sum_m$sum.all[, "Std. Mean Diff."])
bal_tab$var <- rownames(bal_tab)
bal_tab$after <- sum_m$sum.matched[, "Std. Mean Diff."]

colnames(bal_tab) <- c("before", "var", "after")

bal_long <- bal_tab %>%
  pivot_longer(cols = c("before", "after"),
               names_to = "stage", values_to = "smd")

ggplot(bal_long,
       aes(x = smd, y = reorder(var, smd), shape = stage)) +
  geom_point(size = 2) +
  geom_vline(xintercept = c(-0.1, 0, 0.1), linetype = "dashed") +
  labs(x = "Standardized mean difference",
       y = NULL,
       shape = NULL) +
  theme_bw()

ggsave("graphs/irs/irs1_balance_smd.pdf",
       width = 6, height = 5)


## 2. Treatment effect estimation on matched sample (outcome: yearn.avg)

# ATT estimate with only the treatment indicator
att_lm <- lm(yearn.avg ~ tr, data = s2)
summary(att_lm)

# Add covariate controls for a more robust regression
att_lm_cov <- lm(yearn.avg ~ tr + tixbot + male + workthen + agew + educ +
                   college + xearn.1 + xearn.2 + xearn.3 + yearw,
                 data = s2)
summary(att_lm_cov)

## 3. Save key objects for later analysis/plotting
if (!dir.exists("output")) dir.create("output", recursive = TRUE)

save(s, s2, match.out, att_lm, att_lm_cov,
     file = "output/irs_matching_results.RData")


#----Part three estimate
covar <- c("tixbot", "male", "workthen", "agew", "educ", "college", "xearn.1", "xearn.2", "xearn.3", "yearw")

#full dataset
outcomes <- c(paste0("xearn.", 1:6), paste0("yearn.", 1:7))
est <- vector("list", length(outcomes))
names(est) <- outcomes
for (i in 1:length(outcomes)) {
  est[[i]] <- estimate_all(s, outcomes[i], "tr", covar,
                           methods = c("diff", "aipw_grf"))
  cat(i, "\n")
}
# matched dataset
est2 <- vector("list", lengh(outcomes))
names(est2) <- outcomes
for (i in 1:length(outcomes)) {
  est2[[i]] <- estimate_all(s2, outcomes[i], "tr", covar,
                            methods = c("diff", "aipw_grf"))
  cat(i, "\n")
}

pdf("graphs/irs/irs1_dyn.pdf", width = 7, height = 5)
par(mar = c(4, 4, 1, 2))
plot(1, xlim = c(3.7, 13.3), ylim = c(-20, 10), type = "n", axes = FALSE,
     ylab = "Effects on Earnings (thousand USD)", xlab = "Year Relative to Winning")
box(); axis(2)
axis(1, at = 4:13, labels = c(-3:6))
abline(h = 0, v = 6.5, col = "gray60", lty = 2, lwd = 2)
for (i in 4:13) {
  # full dataset with DIM
  lines(c(i-0.075, i-0.075), est[[i]][1,3:4], lty = 1, lwd = 2, col = "gray60") # CI
  points(i-0.075, est[[i]][1,1], pch = 18, col = "grey60", cex = 1.2) # Coef
  # full dataset
  lines(c(i+0.075, i+0.075), est[[i]][2,3:4], lwd = 2) #CI
  points(i+0.075, est[[i]][2,1], pch = 16) # Coef
}
legend("topright", legend = c("DIM", "AIPW"), lwd = 2, cex = 1.2,
       lty = 1, pch = c(18, 16), col = c("grey60", "black"), bty = "n")
graphics.off()

pdf("graph/irs/irs1_dyn2.pdf", width = 7, height = 5)
par(mar = c(4, 4, 1, 2))
plot(1, xlim = c(3.7, 13.3), ylim = c(-20, 10), type = "n", axes = FALSE,
     ylab = "Effects on Earnings (thousand USD)", xlab = "Year Relative to Winning")
box(); axis(2)
axis(1, at = 4:13, labels = c(-3:6))
abline(h = 0, v = 6.5, col = "grey60", lty = 2, lwd = 2)
for (i in 4:13) {
  #full dataset with DIM 
  lines(c(i-0.15, i-0.15), est[[i]][1,3:4], lty = 1, lwd = 2, col = "grey60") # CI
  points(i-0.15, est[[i]][1,1], pch = 18, col = "grey60", cex = 1.2)
  #full dataset
  lines(c(i, i), est[[i]][2,3:4], lwd = 2) # CI
  points(i, est[[i]][2,1], col = "maroon", pch = 17) # Coef
}
legend("topright", legend = c("DIM, Full (194: 259)", "AIPW, Full (194: 259)",
                              "AIPW, PS Matched (194: 194)"), lwd = 2,
       lty = c(1, 1, 1), pch = c(18, 16, 17), 
       col = c("grey50", "black", "maroon"), bty = "n")
graphics.off()

## --- added by chuanlong tian

# save main IRS estimates so that they can be easily re-used later
save(outcomes, est, est2, file = "irs_results_CT.RDate")

# Export the first outcome's estimates from the full sample as a CSV file
irs_first_outcome_CT <- as.data.frame(est[[1]])
write.csv(irs_first_outcome_CT, "irs_first_outcome_CT.csv")

###---- End of code added by chuanlong tian ------

