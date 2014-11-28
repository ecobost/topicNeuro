#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 10-03-2014


# This script will be executed inside every fold_## folder. This script should be tailored to each purpose of the crossvalidation. 


# This specific script "iterationFitting.sh" will run every fold on different number of iterations and store the likelihood in a general .dat file
# There will be a step number of itertions such that the model will be run in step, 2*step, 3*step, etc iterations. For example: 20, 40, 60, etc.
# Output: iterationsLikelihood.dat file . This file will have iterations*folds lines (iterations=number of iterations, folds = number of folds). 
# There will be iterations number of lines for each fold. Each line will have the final test likelihood for the given number of iterations. 
# Example: 10 folds and iterations in {20,40,60}. The file will have the results for the fold 1 on the first three lines, fold 2 in lines 4-6, etc.



##****************** Start of the program **************************

# Name of the input file (20news, abstracts, pubmed_ns, etc)
stem="20news"
topics=30 # Number of topics used to train the model
likelihoodCycles=20 # Number of cycles for the estimation of the log likelihood
threadNumber=4 # Number of threads available
iterationStep=20 # Increment from one iteration to the other
maxIterations=200 # Maximum number of iterations to execute

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

# Take the likelihood estimation for this fold and append it at the end of the general iterationsLikelihood.dat
# This part will be removed if we are running this script for only one fold or for the final training
# Notice that if this script is run more than one, the results will be append to the same general file.
# To avoid this manually delete the general topicsLikelihood.dat before running all the folds
cat iterationsLikelihood.dat >> ../iterationsLikelihood.dat

