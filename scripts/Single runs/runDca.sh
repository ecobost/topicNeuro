#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 03-06-2014

# This script runs DCA on the 1M input. 
# You need two files: the corpus in DCA bagged format and the list of tokens (vocab)

# Set parameters!!!!!
corpus="1m_ns.dca_corpus" #File where the corpus is
vocab="1m_ns.dca_corpus.vocab" #File where the filetered vocab is
stem="1m_ns" # Stem name to generate files (e.g $stem.topic, $stem.theta, etc)
topics=600
cycles=600
threadNumber=6

# First, let's change the corpus file to add the corpusSize and vocabSize in the beggining of the file.
# Important: Run just once. After you can comment it out.
echo "Adding corpus size and vocabulary size to the corpus $corpus"
corpusSize=$(wc -l < $corpus)
vocabSize=$(wc -l < $vocab)
echo -e "$corpusSize\n$vocabSize" | cat - $corpus > temp && mv temp $corpus


#******************************Start of the program************************************************
# Run mpdata
echo "**Generating $stem.cnf to run mpdata"
echo -e "input=\"$corpus\"\nbaggedinput" > $stem.cnf

echo "Running mpdata"
mpdata $stem

# Run mphier
echo "**Setting topics to $topics in $stem.par"
echo "alpha_update" >> $stem.par
echo "components=$topics" >> $stem.par

echo "**Running DCA(mphier)"
echo "**Command: mphier -L$cycles -t$threadNumber -e $stem"
echo "**Check file $stem.err to see the advance of the run"
mphier -L$cycles -t$threadNumber -e $stem

# Generate reports
echo "**Generating topic distribution per document (documentXtopicProbability matrix)"
mpupd -m 0 $stem > $stem.tdist

echo "**Generating word probabilities for each topic (10 highest prob words per topic)"
#This needs the files $stem.tokens and $stem.theta(this one is generated with the -T option)
mv $vocab $stem.tokens
mpupd -T -t 10,0 $stem > $stem.wprob
mv $stem.tokens $vocab
