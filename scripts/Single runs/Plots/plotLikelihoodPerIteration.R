# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014

# Usage: R -f plotLikelihoodPerIteration.R --args iterationsLikelihood.dat
# Input: Data prepared using runScriptInKFolds and iterationFitting.sh. 
# interationsLikelihood.dat has ilines (i number of iterations tried)

# This script plots the estimated likelihoods for different number of iterations

#Read file argument: iterationssLikelihood.dat
a <- commandArgs(trailingOnly=TRUE)
fileName <- a[1]

#Set important data
x <- seq(10, 50, by=10) # Vector with all number of iterations for which data was collected
plotYRange <- c(9,14) #Range of the y-axis in the plot

#Reading the data
d <- read.table(file=fileName, header=FALSE)
scores <- d$V1

# Make the draw
if (!interactive()) pdf("likelihoodPerIterations.pdf")
plot(x, scores, type="o", col="green", xlab="Number of Topics",ylab="Neg. Log Likelihood", ylim=range(plotYRange), cex=0.5)
if (!interactive()) dev.off()
