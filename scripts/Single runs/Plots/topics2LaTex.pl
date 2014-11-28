#! /usr/bin/perl

# Written by: Marc Zimmerman
# Modified by: Erick Cobos T (erick.cobos@epfl.ch)
# Date: 04-05-2014

# Usage: perl topics2LaTex.pl $stem.wprob > $stem.tex

# Generates LaTeX table of most common terms per topics 
# Takes as input the output of DCA's "mpupd -t [#OfWordsPerTopic],0 $stem".
# Important: 
#	Will not work if there's an empty line in the file 
#	Will not work correctly when words have spaces (usually they do not)


use warnings;
use strict;

# Set parameters
my $topicsPerRow = 5;
my $probabilityFormat = "%.3f"; # C-style
my $wordsPerTopic = 10;
my $topicNumberStartsIn = 0;
my $typeOfTable = "longtable";

# Get information from input file and store it in @info
my @info;
my $topics = 0;
while(<>) { # For each topic/line in input
	#Get ocurrences of this regexp for this topic. res = (word1, count1, prob1, word2, count2, prob2, word3, ...);
	# my @res = /([a-z0-9]*)\(([0-9]+),([0-9.]+)\)/g; # Old regexp
	#my @res = /([^\(]*)\(([0-9]+),([0-9.]+)\)/g; # New regexp
	#my @res = /([a-zA-Z0-9\_\-\]*)\(([0-9]+),([0-9.]+)\)/g; # New regexp
	my @res = /([^ ]*)\(([0-9]+),([0-9.]+)\)/g; # New regexp

	my $resSize = @res;

	my @wordsInLaTex = ();	
	for(my $i = 0; $i < $resSize; $i+=3) { # For each word 
		my $lp = sprintf($probabilityFormat, $res[$i+2]); # Get probability
		my $escapedword = escape($res[$i]);
		push(@wordsInLaTex, "$escapedword\t& $lp"); # Store string "word\t& prob" in array 
	}
	push(@info, @wordsInLaTex); # Store all words for this topic in @info
	$topics++;
}

print escape("");

#Print table in LaTex
print "\\begin{$typeOfTable}{" . "|l r"x$topicsPerRow .  "|}\n";
my $topicNumber = $topicNumberStartsIn;
for(my $k = 0; $k < $topics; $k+=$topicsPerRow) {   #For each row 
	
	print "\t\\hline\n";

	#Print topic titles "Topic #"
	print "\t";
	for(my $j = 0; $j < $topicsPerRow-1 && $j + $k < $topics-1; $j++) {
		print "\\textbf{Topic $topicNumber}\t&\t& ";
		$topicNumber++;
	}
	print "\\textbf{Topic $topicNumber}\t& \\\\\n";
	$topicNumber++;

	print "\t\\hline\n";

	for(my $i = 0; $i < $wordsPerTopic; $i++) {
		print "\t";
		for(my $j = 0; $j < $topicsPerRow-1 && $j +$k < $topics-1; $j++) {
			print "$info[ ($k+$j)*$wordsPerTopic + $i]\t& ";
		}
		my $last = min( ($k + $topicsPerRow-1) * $wordsPerTopic + $i, ($topics-1) * $wordsPerTopic + $i);

		print "$info[$last] \\\\\n";
	}
	print "\t\\hline\n";
}
print "\\end{$typeOfTable}" . "\n";

# Subroutine min: Returns the minimum of two values
sub min{
	if($_[0] < $_[1]){
		return $_[0];
	}
	else{
		return $_[1];
	}
}

# Subroutine escape: Escapes any character that needs to be escaped in latex. 
# Taken from the web: http://www.mail-archive.com/templates@template-toolkit.org/msg07971.html
sub escape {
	my $text = shift;
	
	# Replace a \ with $\backslash$
	# This is made more complicated because the dollars will be escaped by the subsequent replacement. 
	# Easiest to add \backslash now and then add the dollars
	$text =~ s/\\/\\backslash/g;

	# Must be done after escape of \ since this command adds latex escapes
	# Replace characters that can be escaped
	$text =~ s/([\$\#&%_{}])/\\$1/g;
	
	# Replace ^ characters with \^{} so that $^F works okay
	$text =~ s/(\^)/\\$1\{\}/g;

	# Replace tilde (~) with \texttt{\~{}}
	$text =~ s/~/\\texttt\{\\~\{\}\}/g;

	# Now add the dollars around each \backslash
	$text =~ s/(\\backslash)/\$$1\$/g;

	return $text;
}
