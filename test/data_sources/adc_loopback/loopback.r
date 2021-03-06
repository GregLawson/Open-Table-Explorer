loopback_channel2 <- read.csv("~/Desktop/git/Open-Table-Explorer/test/data_sources/loopback_channel2.csv", header=F)
m <- lm(loopback_channel2$V2~loopback_channel2$V4+loopback_channel2$V5+loopback_channel2$V6+loopback_channel2$V7+loopback_channel2$V8+loopback_channel2$V9+loopback_channel2$V10)
summary(m)
plot(loopback_channel2$V2,loopback_channel2$V3)
loopback_channel2$excess <- loopback_channel2$V3-loopback_channel2$V2
plot(loopback_channel2$V2,loopback_channel2$excess,type="p")
require(car)
scatterplot(loopback_channel2$V2,loopback_channel2$excess)
scatterplotMatrix(~ loopback_channel2$V2+loopback_channel2$V4+loopback_channel2$V5+loopback_channel2$V6+loopback_channel2$V7+loopback_channel2$V8+loopback_channel2$V9+loopback_channel2$V10)
loopback_channel2$i<-array(1:length(loopback_channel2$V1))
loopback_channel2$group<-factor(array(1:length(loopback_channel2$V1)-loopback_channel2$V2))
scatterplot(loopback_channel2$V2,loopback_channel2$excess,groups=loopback_channel2$group, type="p")
loopback_channel2$segment<-factor(loopback_channel2$V2>64)
loopback_channel2$subproblems <- factor(ifelse(loopback_channel2$segment, loopback_channel2$group+1000, loopback_channel2$group))
View(loopback_channel2)
m2 <- lm(loopback_channel2$excess~loopback_channel2$i*loopback_channel2$segment*loopback_channel2$group)
summary(m2)
require(ggplot2)
library(ggplot2)
set.seed(955)
dat <- data.frame(cond = rep(c("A", "B"), each=10),
                  xvar = 1:20 + rnorm(20,sd=3),
                  yvar = 1:20 + rnorm(20,sd=3))
ggplot(dat, aes(x=xvar, y=yvar)) + geom_point(shape=1)
head(diamonds)
qplot(clarity, data=diamonds, ﬁll=cut, geom="bar")
ggplot(diamonds, aes(clarity, ﬁll=cut)) + geom_bar()
ggplot(loopback_channel2, aes(x=V2, y=excess)) +  geom_point(shape=1) 
installed.packages()
loopback_channel2$model <- ifelse(loopback_channel2$V2<60, 80, 110-loopback_channel2$V2/1.925)
loopback_channel2$residual <- loopback_channel2$excess-loopback_channel2$model
ggplot(loopback_channel2, aes(x=V2, y=residual)) +  geom_point(shape=1) 
