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

pdf("graphs/irs/irs1_odds.pdf", width = 5.5, height = 5.5)
plot_hist(s, "ps", "tr", breaks = 30, odds = TRUE, xlim = c(-5.5, 1), ylim = c(-0.4, 0.4))
graphics.off()



pdf("graphs/irs/irs1_odds_trim.pdf", width = 5.5, height = 5.5)
s2$ps <- probability_forest(X = s2[, covar], 
                            Y = as.factor(s2$tr), seed = 1234)$predictions[,2]
plot_hist(s2, "ps", "tr", breaks = 30, odds = TRUE, xlim = c(-1, 1), ylim = c(-0.4, 0.4))
graphics.off()


## PS

pdf("graphs/irs/irs1_ps.pdf", width = 5.5, height = 5.5)
s$ps <- probability_forest(X = s[, covar], 
                           Y = as.factor(s$tr), seed = 1234)$predictions[,2]
plot_hist(s, "ps", "tr", breaks = 30, odds = FALSE, xlim = c(0, 1), ylim = c(-0.4, 0.4))
graphics.off()

pdf("graphs/irs/irs1_ps_trim.pdf", width = 5.5, height = 5.5)
s2$ps <- probability_forest(X = s2[, covar], 
                            Y = as.factor(s2$tr), seed = 1234)$predictions[,2]
plot_hist(s2, "ps", "tr", breaks = 30, odds = FALSE, xlim = c(0, 1), ylim = c(-0.4, 0.4))
graphics.off()



