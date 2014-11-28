#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 07-03-2014

# This script "topicFitting.sh" will run the data on different number of topics and store the likelihood in a general .dat file
# Output: topicsLikelihood.dat file . This file will have topics lines (topics=number of topics). Each line will have the final test likelihood
# for a given number of topics. 
# Example: Topics in {10,100,500}. The file will have three lines corresponding to te likelihood of 10, 100 and 500



##****************** Start of the program **************************

# Name of the input file (20news, abstracts, pubmed_ns, etc)
stem="20news"
gibbsCycles=100 # Gibbs cycles for the model estimation
likelihoodCycles=20 # Number of cycles for the estimation of the log likelihood
threadNumber=4 # Number of threads available
 

# Modify parameters if not already set
if [ $(grep "alpha" $stem.par | wc -l) -lt 1 ]; then
	echo "alpha_update" >> $stem.par
fi
if [ $(grep "components" $stem.par | wc -l) -lt 1 ]; then
	echo "components=1" >> $stem.par # Will be changed shortly
fi


#Empty the file topicsLikelihood.dat. Used to store the final likelihoods for different topics (in this fold)
cat /dev/null > topicsLikelihood.dat

for topics in {5,10,15,20,25,30,50,75,100,150,200}; do
	# Remove old log	
	rm $stem.err
	
	# Set number of components in .par. 
	sed -e "s/^components=\([0-9]*\)$/components=$topics/g" $stem.par > $stem.tmppar
	mv $stem.tmppar $stem.par


	echo "Training on $topics topics..."
	mphier -L $gibbsCycles -e $stem
	
	echo "Calculating likelihood..."	
	mphier -r -t $threadNumber -X $likelihoodCycles,M -e $stem

	grep Final $stem.err | sed 's/^.*test.lp=\([0-9.nan-]*\).*$/\1/g' >> topicsLikelihood.dat
	
done
