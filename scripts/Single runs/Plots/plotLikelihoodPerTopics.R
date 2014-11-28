# Written by: Marc Zimmermann
# Modified by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014

# Usage: R -f plotLikelihodPerTopics.R --args topicsLikelihood.dat
# Input: The input file has n lines (n is the number of different topics used).
# Each line has the likelihood of the given number of topics

# This script plots the estimated likelihoods for different number of topics

# Reading the arguments
a <- commandArgs(trailingOnly=TRUE)
fileName <- a[1]

#Set important data
x = c(5,10,15,18,20,22,25,30,40,50,75,100,150,200) # Vector with all number of topics for which data was collected
plotYRange <- c(9,14)

#Reading the data
d <- read.table(file=fileName, header=FALSE)
scores <- d$V1

# Make the draw
if (!interactive()) pdf("likelihoodPerTopics.pdf")
plot(x, scores, type="o", col="green", xlab="Number of Topics",ylab="Neg. Log Likelihood", ylim=range(plotYRange), cex=0.5)
if (!interactive()) dev.off()
