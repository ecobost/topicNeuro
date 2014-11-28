#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 19-03-2014

# Script used to retrieve the list of PMID \t [DescriptorName [N|Y]+]+ from a list of PMIDs
# Needs to have efetch and edirect and xtract scripts (from the edirect API) in the same folder
# IMPORTANT: You need to connect at least once to the database to register, so if this script gives error paste all the
# content from folder edirect and run it. It will now run normally, next time, only efetch, edirect and xtract will be needed. 

#Set parameters
pmids="100k_ns.pmids.txt"
output="PubmedXDescriptors.tsv"
chunks=1000 #It takes around 10 secs per thousand articles. It depends on the internet connection and the Entrez API

echo "Emptying the file $output" # If it had previous content. Otherwise it creates it.
cat /dev/null > $output

echo "Generating file $output"
counter=0
ids=""
while read pmid; do

	counter=$(($counter + 1))
	ids="$ids$pmid"

	# Fetch data every chunks number of pmids
	if [ $counter -ge $chunks ];then
		# Retrieves data from $pmid. Only the ones that have Meshs (if desired otherwise, remove "-match MeshHeadingList"). 
		./efetch -db pubmed -id $ids -format xml | ./xtract -pattern PubmedArticle -match MeshHeadingList -element MedlineCitation/PMID -group MeshHeading -element DescriptorName -block MeshHeading -sep "" -element @MajorTopicYN >> $output
		counter=0
		ids=""
		echo "$chunks articles processed. Until PMID: $pmid"
	else
		ids="$ids," #This seems odd, but is needed, to avoid problems of commas at the end of beggining of $ids
	fi

done < $pmids

# Some articles may have remained unproccesed
if [ $counter -gt 0 ];then
	./efetch -db pubmed -id $ids -format xml | ./xtract -pattern PubmedArticle -match MeshHeadingList -element MedlineCitation/PMID -group MeshHeading -element DescriptorName -block MeshHeading -sep "" -element @MajorTopicYN >> $output
	echo "$counter articles processed. Until PMID: $pmid"
fi

totalArticles=$(wc -l < $pmids)
totalArticlesGenerated=$(wc -l < $output)
echo "Done!. $totalArticlesGenerated/$totalArticles read."

