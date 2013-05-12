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
loopback_channel2$group<-array(1:length(loopback_channel2$V1)-loopback_channel2$V2)
scatterplot(loopback_channel2$V2,loopback_channel2$excess,groups=loopback_channel2$group, type="p")
loopback_channel2$segment<-loopback_channel2$V2>64
View(loopback_channel2)
if loopback_channel2$segment then loopback_channel2$group+1000 else loopback_channel2$group end