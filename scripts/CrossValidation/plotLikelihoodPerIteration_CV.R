# Written by: Marc Zimmermann
# Modified by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014

# Usage: R -f plotLikelihoodPerIteration_CV.R --args iterationsLikelihood.dat
# Input: Data prepared using runScriptInKFolds and iterationFitting.sh. 
# iterationsLikelihood.dat has i*j lines (i number of iterations tried, j number of folds)

# This script plots the estimated likelihoods for different number of iterations run over various folds
# and should be tailored according to the problem in hand. A different script is available that plots the same results for only one fold

#Read file argument: iterationssLikelihood.dat
a <- commandArgs(trailingOnly=TRUE)
fileName <- a[1]


#Set important data
x <- seq(25, 1000, by=25) # Vector with all number of iterations for which data was collected
numberOfTopics <- length(x) # This may be confusing, but this is the size of the set with the diferent number of iterations used
folds <- 10 # Number of folds executed
ci <- 0.975 # Confidence interval(0.975= 95%,0.95 = 90%, 0.995= 99%)
plotYRange <- c(10.3,10.7) #Range of the y-axis in the plot
xLegend <- 280 # x coordinate for the legend
yLegend <- 10.6 # y coordinate for the legend

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
if (!interactive()) pdf("likelihoodPerIterations_CV.pdf")
plot(x, mean, col="blue", type="o", ylab="Neg. Log Likelihood",xlab="Iterations", ylim=range(plotYRange), cex=0.5)
legend(x=xLegend, y=yLegend, legend=c("Mean Likelihood", "95% Confidence Interval"), col=c("blue", "red"), lty=1)

lines(x, upper, col = "red", lty = 2)
lines(x, lower, col = "red", lty = 2)

#Draw a horizontal line on the minimum value achieved
abline(h=min(mean), col ="black", lty=3)

#Draw a horizontal line on iteration number 20.
#abline(v=20, col = "black", lty=3)
#text(35,y=12, "20 Iterations")

if (!interactive()) dev.off()

