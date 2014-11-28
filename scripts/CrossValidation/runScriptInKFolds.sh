#!/bin/bash
# Written by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 07-03-2014

# Run an input script in an already prepared set of data (with prepareKFolds)
# The script passed will be run inside each folder fold_##

# Default values
script="script" # Name of the script to be executed for every fold. Will be assigned later
folds=10	# Number of folds that will be run. Default is 10

# Read input and options for the program
function usage { 
	echo "Usage: $0 [-h] [-k folds] script"
	exit 1
}
while getopts ":hk:" opt; do 
	case $opt in
	h)
		usage
		;;
	k)	
		if ! [[ $OPTARG =~ ^[0-9]+$ ]]; then # Argument is not a number
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

if [ $# -lt 1 ]; then 
	echo "Error: No script file received"
	usage;
fi

script=$1

if ! [ -f $script ]; then
	echo "Error: Script $script does not exist"
	exit 2;
fi

# We assume the folds were created properly and do not check their existence ([ -d fold_01, fold_02, etc.]).


##****************** Start of the program **************************

# Make script executable
chmod a+x $script

workingDirectory=$(pwd) # Current directory where *this* script is called
for foldNumber in $(seq -f "%02.0f" 1 $folds); do # Folds in format: 01, 02,...., 10, 11, ...., folds-1.

	echo -e "\n$0: Executing in fold $foldNumber"

	# Change to fold directory where the script is going to be executed
	cd fold_$foldNumber

	# Call execution of the script.
	../$script
	
	# Get back to the working directory. Will normally be just a 'cd ..'
	cd $workingDirectory
done
