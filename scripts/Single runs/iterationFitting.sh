#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014

# This specific script "iterationFitting.sh" will run different number of iterations and store the likelihood in a general .dat file
# There will be a step number of iterations such that the model will be run in: step, 2*step, 3*step, etc iterations. For example: 20, 40, 60, etc.
# Output: iterationsLikelihood.dat file . This file will have iterations lines (iterations=number of iterations). Each line will have the 
# final test likelihood for the given number of iterations. 
# Example: Iterations in {20,40,60}. The file will have three lines corresponding to the likelihoods on iteration 20, 40 and 60 respectively.



##****************** Start of the program **************************

# Name of the input file (20news, abstracts, pubmed_ns, etc)
stem="20news"
topics=10 # Number of topics used to train the model
likelihoodCycles=3 # Number of cycles for the estimation of the log likelihood
threadNumber=4 # Number of threads available
iterationStep=10 # Increment from one iteration to the other
maxIterations=50 # Maximum number of iterations to execute

# Modify parameters if not already set
if [ $(grep "alpha" $stem.par | wc -l) -lt 1 ]; then
	echo "alpha_update" >> $stem.par
fi
if [ $(grep "components" $stem.par | wc -l) -lt 1 ]; then
	echo "components=$topics" >> $stem.par
fi

# Set number of components in .par file in case it was set to a different number
sed -e "s/^components=\([0-9]*\)$/components=$topics/g" $stem.par > $stem.tmppar
mv $stem.tmppar $stem.par


# Empty the file iterationsLikelihood.dat. Used to store the final likelihoods for different iterations (in this fold)
cat /dev/null > iterationsLikelihood.dat

# This will loop from iterationStep to maxIteration taking increments of iterationStep size
mphier -L0 -e $stem
for ((iteration=$iterationStep; iteration<=$maxIterations; iteration+=$iterationStep)); do
	# Remove old log	
	rm $stem.err

	echo "Training on $iteration iterations..."
	mphier -r -L $iterationStep -e $stem
	
	echo "Calculating likelihood..."	
	mphier -r -t $threadNumber -X $likelihoodCycles,M -e $stem

	grep Final $stem.err | sed 's/^.*test.lp=\([0-9.nan-]*\).*$/\1/g' >> iterationsLikelihood.dat
done
