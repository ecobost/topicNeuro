// Written by: Erick Cobos T (erick.cobos@epfl.ch)
// Date: 14-05-2014

// Specific implementation to compute correlation between descriptors and topics. Including main
// Implements getIDSet from CorrelationBase
// Some parameters should be set in CorrelationBase.java (make sure you recompile that if you change any parameter) 

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import java.util.StringTokenizer;

public class CorrelateDescriptors extends CorrelationBase {

	//Set parameters
	private static final String output = "./results/descriptorMatrix_MD.tsv";
	private static final boolean onlyMajorDescriptors = true;
	private static final boolean onlyMajorTopics = false;
	
	public static void main(String[] args){
		// Initialize the Correlation Base
		CorrelateDescriptors correlationEngine = new CorrelateDescriptors();
		
		// Calculate the correlation
		correlationEngine.computeCorrelation(onlyMajorDescriptors, onlyMajorTopics);

		// Print results
		try{
			correlationEngine.writeResults(output);
		}catch(IOException e){
			System.err.println("Error while writing results on " + output);
			e.printStackTrace();
		}
	}

	// Given a line as PubMedID[\tMeshID\t[Y|N]]* returns the specific set of MeSHIDs for this article.
	protected Set<String> getIDSet(String line, boolean onlyMajorDescriptors){
		String descriptorID = null;
		boolean isMajorDescriptor = false;
		Set<String> meshIDs = new HashSet<String>();

		StringTokenizer tokenizer = new StringTokenizer(line,"\t");
		tokenizer.nextToken(); // PubMedID

		while (tokenizer.hasMoreTokens()) { //Over every mesh descriptor
			descriptorID = tokenizer.nextToken();
			isMajorDescriptor = tokenizer.nextToken().equals("Y");

			if(isMajorDescriptor || !onlyMajorDescriptors){ // Check for MD if required
				meshIDs.add(descriptorID);
			}
		}

		return meshIDs;
	}

}
