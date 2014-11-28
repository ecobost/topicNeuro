# Written by: Marc Zimmermann
# Modified by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014

# Usage: R -f plotLikelihoodPerTopics_CV.R --args topicsLikelihood.dat
# Input: Data prepared using runScriptInKFolds and topicFitting.sh. 
# topicsLikelihood.dat has i*j lines (i number of topics, j number of folds)

# This script plots the estimated likelihoods for different number of topics run over various folds
# and should be tailored according to the problem in hand. A different script is available that plots the same results for only one fold

#Read file argument: topicsLikelihood.dat
a <- commandArgs(trailingOnly=TRUE)
fileName <- a[1]


#Set some important data
x = c(10,25,50,75,100,150,200,300,400) # Vector with all number of topics for which data was collected
numberOfTopics <- length(x) # This may be confusing, but this is the size of the set with the diferent number of topics used
folds <- 10 # Number of folds executed
ci <- 0.975 # Confidence interval(0.975= 95%,0.95 = 90%, 0.995= 99%)
plotYRange <- c(10.3,11.2) #Range of the y-axis in the plot

#Read and organize our data. Scores will have the data for every fold organized by columns(topicsXfolds matrix)
d <- read.table(file=fileName, header=FALSE)
scores <- sapply(0:(folds-1), function(x) d[x*numberOfTopics+(1:numberOfTopics),])

# Statistics per topic (it is, per row)
mean <-  apply(scores, 1, function(x) mean(x, na.rm=TRUE))
std <- apply(scores, 1, function(x) sd(x, na.rm = TRUE))
error <- (qnorm(ci)/sqrt(folds))*std 
upper <- mean + error
lower <- mean - error


# Make the plot
if (!interactive()) pdf("likelihoodPerTopics_CV.pdf")
plot(x, mean, col="green", type="o", ylab="Neg. Log Likelihood",xlab="Number of Topics", ylim=range(plotYRange), cex = 0.5)
legend(x=200, y=11.2, legend=c("Mean Likelihood", "95% Confidence Interval"), col=c("green", "red"), lty=1)

lines(x, upper, col = "red", lty = 2)
lines(x, lower, col = "red", lty = 2)

#Draw a horizontal line on the minimum value achieved
abline(h=min(mean), col ="black", lty=3)
#text(10, y=min(mean), labels = round(min(mean), 2))

#Draw a vertical line on topic number 20.
#abline(v=20, col = "black", lty=3)
#text(35,y=12, "20 Topics")



if (!interactive()) dev.off()
