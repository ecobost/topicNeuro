# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 09-04-2014

# Usage: R -f reorderAndPlotMatrix.R --args correlationMatrix.tsv

# Reads a matrix from a .tsv. Reorders (using the seriation package), plots and prints the matrix
# Output(.pdf): Plot with the reordered matrix
# Output(.tsv): Data of the reordered matrix

# Set parameters
outputName = "CorrelationMatrix_MD"
plotName = "Correlation Matrix MD"
numberOfGrays = 200

# Read arguments
a = commandArgs(trailingOnly=TRUE)
fileName = a[1]
matrix = read.delim(fileName, header=TRUE)
matrix = as.matrix(matrix)

# Use seriation library
library(seriation)

# Seriate it
newOrder <- seriate(matrix)
#newOrder <- seriate(matrix, control = list(rep=5)) # Run it five times and take the best answer.

# Reorder old matrix
matrix = permute(matrix, newOrder)
#matrix = apply(matrix, 2, rev) #Flip it so that higher value is on upper left corner

# Plot it
pdf(paste(outputName,".pdf"))
pimage( matrix,
 main = plotName ,
 xlab = "Topics",
 ylab= "MeSH Descriptors",
 col = rev(gray(1:numberOfGrays/numberOfGrays))
)
dev.off()

# Print results
write.table(matrix, file = paste(outputName, "_order.tsv"), sep = "\t")
