#!/bin/bash
#Prepare data to be run  in a k-fold cross validation experiment.
#Takes an input .txtbag and creates folders for each fold with the .bag belonging to the fold.
#Fold_01 has $stem_p01 as the test set

stem="stem" #Name of the file input. To be read after the options
folds=10 #Number of folds that will be run. Default is 10
isBagged=$false #Flag indicating if the input .txtbag is in bagged format. Default is false


#Read input and options for the program
function usage { 
	echo "Usage: $0 [-b|-B|-h] [-k folds] stem"
	exit 1
}
while getopts ":bBhk:" opt; do 
	case $opt in
	b)
		isBagged=true
		;;
	B)
		isBagged=true
		;;
	h)
		usage
		;;
	k)	
		if ! [[ $OPTARG =~ ^[0-9]+$ ]]; then #Argument is not a number
			echo "Invalid parameter $OPTARG for -k. Required a positive integer" 			
			usage;
		fi
		folds=$OPTARG		
		;;
	\?)	
		echo -e "Invalid option: -$OPTARG \n"
		;;
	:)
		echo -e "Parameter expected for option -$OPTARG \n"
		usage
		;;
	esac
done

shift $((OPTIND-1))

stem=$1

if [ $# -lt 1 ]; then 
	echo "Error: No file input received"
	usage;
fi

if ! [ -f $stem.txtbag ]; then
	echo "Error: File $stem.txtbag does not exist"
	exit 2;
fi

#****************** Start of the program **************************

#Reads number of documents and number of words
#$(command) executes the command and returns the output
docs=$(head -n1 $stem.txtbag)
words=$(head -n2 $stem.txtbag | tail -n1)
testSize=$(($docs/$folds + 1))

#Delete first two lines of the file
sed '1,2d' $stem.txtbag > $stem.tmp

#Split document into k chunks named $stem_p01, $stem_p02, etc.
split --numeric-suffixes=1 -n l/$folds $stem.tmp "$stem"_p

# Cluster: Use old version of split and change "$stem_p00" for "$stem_p$folds"
#split -d -l $testSize  $stem.tmp "$stem"_p #Command for old split
#mv "$stem"_p00 "$stem"_p$(printf %02.0f $folds) #Command for old split

#Delete temporal file
rm $stem.tmp

#Reconstruct the k files and apply mpdata
for foldNumber in $(seq -f "%02.0f" 1 $folds); do # Folds in format: 01, 02,...., 10, 11, ...., folds-1.

	# Create a new folder and a new document with the first two lines(documents, words)
	rm -r -f fold_$foldNumber
	mkdir fold_$foldNumber
	cd fold_$foldNumber
	echo -e "$docs\n$words" > $stem.txtbag

	# Append the data for the new document(all parts except the part of the fold number)
	for i in $(seq -f "%02.0f" 1 $folds | grep -v "$foldNumber"); do
		cat ../"$stem"_p$i >> $stem.txtbag
	done

	# Append the test data at the end
	cat ../"$stem"_p$foldNumber >> $stem.txtbag

	# Run mpdata
	echo -e "input=\"$stem.txtbag\"" > $stem.cnf
	if [ "$isBagged" = true ]; then 
		echo "baggedinput" >> $stem.cnf
	fi
	mpdata $stem

	# Append number of testdocs in fold.par
	echo "testdocs=$testSize" >> $stem.par

	# Clear unnnecesaary data
	rm $stem.txtbag
	cd ..
done


