// Written by: Erick Cobos T (erick.cobos@epfl.ch)
// Date: 14-05-2014

// This is an abstract class with the common functionalities used by the specific correlation instances. Parameters
// This program reads the data from the PubMed X DescriptorID matrix and the .tdist matrix (topic distribution per document)
// and computes the joint probability of ocurrences of an ID(either MeSHID, nodeID, or treeNumber) and a topic(loosely referred as correlation) 
// It generates a tsv(tab separated values file) with the following format:
//	Line 1: -1 0 1 2 ..... NumberOfTopics
//	Line 2-end: ID [p(m,z_#)]*, where # goes from 0 to NumberOfTopics. For example: "000001 0.03 0.02 0.02 0.1 0.004 ... p(000001,TopicN)"
//	is the correlation between MeshID 000001 and topics 0 through N or "A08.145.63 0.03 0.02 0.02 ... p(A08.145.63,TopicN)" is the correlation
//	between tree number A08.145.63 and topics 0 through N.
// The matrix is not declared for every ID but only the IDs that appear in the documents (all others will have correlation 0)
// Please set parameters as needed. Important: Set numberOfTopics


import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;


public abstract class CorrelationBase {

	//Set parameters
	private final int numberOfTopics = 200;
	private final String pubmedXMeshIDs = "./resources/PubmedXMeshIDs.tsv"; // PMID X MeshIDS matrix
	private final String topicDistribution = "./resources/100k_ns.tdist"; // Topic distribution per document
	private final double majorTopicThreshold = 0.05;
	private final int roundToThisNumberOfDecimals = 5; // Done before printing
	
	// Mapping from IDs to topic probabilities(double[numberOfTopics])
	private Map<String,double[]> correlationMatrix;

	public CorrelationBase () {
		correlationMatrix = new HashMap<String , double[]>(); 
	}

	// Opens the files and computes the correlations
	public void computeCorrelation(boolean onlyMajorDescriptors, boolean onlyMajorTopics){

		// Open the input files: meshs(PMIDxMeshIDs) and topics (Documents X TopicProbability)
		System.out.println("**Opening files");
		FileReader inputFile = null;
		try{
			inputFile = new FileReader(pubmedXMeshIDs);
		}catch(FileNotFoundException e){
			System.err.println("File " + pubmedXMeshIDs + " not found");
			e.printStackTrace();
		}
		BufferedReader meshs = new BufferedReader(inputFile);

		FileReader inputFile2 = null;
		try{
			inputFile2 = new FileReader(topicDistribution);
		}catch(FileNotFoundException e){
			System.err.println("File " + topicDistribution + " not found");
			e.printStackTrace();
		}
		BufferedReader topics = new BufferedReader(inputFile2);

		// Calculate the joint probability
		try{
			System.out.println("**Calculating joint probability");
			Set<String> IDs = null;
			double[] documentTopicDist = null;
			String line = null;
			while ((line = meshs.readLine()) != null) { // Over every article (that has at least one Mesh)
			
				// Read list of meshs/nodes/treeNumbers for this article as an Arraylist of Strings.
				IDs = getIDSet(line, onlyMajorDescriptors);

				// Read topic probabilities for this article as an array of doubles.
				if((line = topics.readLine()) != null){
					documentTopicDist = readTopicDistribution(line);
				}
				else{
					System.err.println("The two files do not have the same quantity of docs");
					System.exit(1);
				}

				// Update joint probability(mesh,topic). See formula
				for(String ID: IDs){ // Over every mesh in the article.
					updateProbability(ID, documentTopicDist, onlyMajorTopics);
				}	

			}
		}catch(IOException e){
			System.err.println("Error while reading file handlers");
			e.printStackTrace();
		}

		// Close file handlers
		try{
			meshs.close();
			topics.close();
		}catch(IOException e){
			System.err.println("Error while closing file handlers");
			e.printStackTrace();
		}

		// Normalization: None
	}
	
	// Read topic distribution for a document given a line as: DocID\t[ p(d,z)]*.
	private double[] readTopicDistribution(String line){
		String probability = null;
		double[] documentTopicDist = new double[numberOfTopics];

		StringTokenizer tokenizer = new StringTokenizer(line);
		tokenizer.nextToken(); // DocID

		for(int i = 0; i < numberOfTopics; i++){ //Over every topic probability
			probability = tokenizer.nextToken();
			documentTopicDist[i] = Double.parseDouble(probability);
		}

		return documentTopicDist;
	}

	// Writes results as specified in the header
	public void writeResults(String outputFileName) throws IOException {
		
		System.out.println("**Writing results");
		// Create the output directory if it does not exist
		File parentDirectory = new File(outputFileName).getParentFile();
		if (parentDirectory != null){
			parentDirectory.mkdirs();
		}

		// Open the output file
		FileWriter outputFile = null;
		try{
			outputFile = new FileWriter(outputFileName);
		}catch(IOException e){
			System.err.println("File " + outputFileName + "could not be created");
			e.printStackTrace();
		}
		BufferedWriter writer = new BufferedWriter(outputFile);

		// Writing first row (topic numbers). 
		// First element is not important, because it's the upper left corner of the table. Any number could be used
		writer.write("-1");
		for(int i = 0; i < numberOfTopics; i++){
			writer.write("\t"+i);
		}
		writer.newLine();
			
		// Writing the results
		String meshID= null;
		double[] matrixRow = null;
		for (Map.Entry<String, double[]> entry : correlationMatrix.entrySet()) {
			meshID = (String)entry.getKey();
			matrixRow = (double[])entry.getValue();

			writer.write(meshID); 
			for(int i = 0; i < matrixRow.length ; i++ ){
				writer.write("\t" + round(matrixRow[i],roundToThisNumberOfDecimals));
			}
			writer.newLine();
		}
		
		writer.close();
	}
	
	// Utility to round decimal numbers
	private double round(double value, int places) {
		if (places < 0) throw new IllegalArgumentException();
		BigDecimal bd = new BigDecimal(value);
		bd = bd.setScale(places, RoundingMode.HALF_UP);
		return bd.doubleValue();
	}

	// Updates the p(m,z) in the correlation matrix using the new document topic distribution p(z|d).
	protected void updateProbability(String meshID, double[] documentTopicDist, boolean onlyMajorTopics){
		// Read current topicDistribution for MeshID
		double[] currentTopicProbs = correlationMatrix.get(meshID);
		double sum = 0.0;

		// If it is the first ocurrence of the MeSH, insert an array with zeros
		if( currentTopicProbs == null ){
			correlationMatrix.put(meshID, new double[numberOfTopics]);
			currentTopicProbs = correlationMatrix.get(meshID);
		}
		
		// Check onlyMajorTopics
		if(onlyMajorTopics){
			// Remove small probabilities
			for(int z = 0; z < documentTopicDist.length; z++){
				if( documentTopicDist[z] < majorTopicThreshold){ // Check for MT if required
					documentTopicDist[z] = 0.0;
				}
				else{
					sum += documentTopicDist[z];
				}
			}
			
			// Renormalize probabilities
			for(int z = 0; z < documentTopicDist.length; z++){
				documentTopicDist[z] /= sum;
			}
		}

		// Update probability according to formula.
		for(int z = 0; z < currentTopicProbs.length; z++){
			currentTopicProbs[z] += documentTopicDist[z];
		}
	}

	// Given a line as PubMedID[\tMeshID\t[Y|N]]* returns the specific set of IDs (either MeshIds, nodeIDs or treeNumbers) for this article.
	// To be implemented by the specific instances of the class. 
	protected abstract Set<String> getIDSet(String line, boolean onlyMajorDescriptors);
}
