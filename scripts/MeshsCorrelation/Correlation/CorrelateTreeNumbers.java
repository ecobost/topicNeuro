// Written by: Erick Cobos T (erick.cobos@epfl.ch)
// Date: 16-05-2014

// Specific implementation to compute correlation between tree numbers and topics. Including main
// Implements getIDSet from CorrelationBase
// Some parameters should be set in CorrelationBase.java (make sure you recompile that if you change any parameter) 

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import java.util.StringTokenizer;

public class CorrelateTreeNumbers extends CorrelationBase {

	//Set parameters	
	private static final String output = "./results/treenumberMatrix_MD_MT.tsv";
	private static final boolean onlyMajorDescriptors = true;
	private static final boolean onlyMajorTopics = true;
	private final String meshData = "./resources/MeSHDescriptors.tsv"; //List of Mesh Descriptor and its data

	// Descriptors data
	private final DescriptorList descriptorList;

	public CorrelateTreeNumbers(){
		System.out.println("**Loading MeSH data");
		descriptorList = new DescriptorList(meshData);
	}
	
	public static void main(String[] args){
		// Initialize the Correlation Base
		CorrelateTreeNumbers correlationEngine = new CorrelateTreeNumbers();
		
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

	// Given a line as PubMedID[\tMeshID\t[Y|N]]* returns the specific set of treeNumbers for this article.
	protected Set<String> getIDSet(String line, boolean onlyMajorDescriptors){
		Descriptor descriptor = null;
		String descriptorID = null;
		String descriptorIDforTN = null;
		boolean isMajorDescriptor = false;
		Set<String> treeNumberIDs = new HashSet<String>();

		StringTokenizer tokenizer = new StringTokenizer(line, "\t");
		tokenizer.nextToken(); // PubMedID

		while (tokenizer.hasMoreTokens()) { //Over every mesh descriptor
			descriptorID = tokenizer.nextToken();
			descriptor = descriptorList.getDescriptorByID(descriptorID);
			isMajorDescriptor = tokenizer.nextToken().equals("Y");

			if(isMajorDescriptor || !onlyMajorDescriptors){ // Check for MD if required
				for(String treeNumber: descriptor.getTreeNumbers()){
					treeNumberIDs.add(treeNumber+"["+descriptorID+"]");
				}

				for(String treeNumber: descriptor.getTreeNumbersAbove()){
					descriptorIDforTN = descriptorList.getDescriptorByTreeNumber(treeNumber).getID(); // Reusing descriptorID
					treeNumberIDs.add(treeNumber+"["+descriptorIDforTN+"]");
				}			
			}
		}

		return treeNumberIDs;
	}


}
