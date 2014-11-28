// Written by: Erick Cobos T (erick.cobos@epfl.ch)
// Date: 16-03-2014

// This programs reads the datafrom the PubMed X DescriptorNames matrix and maps every descriptor name to its corresponding Unique ID
// Thus generates a tsv(tab separated values file) with the following format:
// PubMedID [DescriptorUID [Y|N]]+
// The Y or N letter shows if the given descriptor is a major descriptor in this pubmed article.
// Please set parameters as needed

import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import java.util.StringTokenizer;

public class MeshDescriptors2IDS{

	// Set parameters
	private static String meshData = "./MeSHDescriptors.tsv"; // List of Mesh Descriptor and its data
	private static String pubmedData = "./PMIDSXDescriptors.tsv"; // Matrix Pubmed X DescriptorNames
	private static String output = "PubmedXMeshIDs.tsv";

	public static void main(String [] args) throws IOException{
		// Create a mapping with the data from the mesh descriptors from MeshName to MeshID
		Map <String,String> nameToID = createDescriptorMapping(meshData);
		System.out.println("Mapping descriptor names -> descriptor IDs  generated");

		// Open the input file (pubmed Data) and the outputFile()
		FileReader inputFile = null;
		try{
			inputFile = new FileReader(pubmedData);
		}catch(FileNotFoundException e){
			System.err.println("File " + pubmedData + " not found");
			e.printStackTrace();		
		}
		BufferedReader reader = new BufferedReader(inputFile);

		FileWriter outputFile = null;
		try{
			outputFile = new FileWriter(output);
		}catch(IOException e){
			System.err.println("File " + output + "could not be created");
			e.printStackTrace();		
		}
		BufferedWriter writer = new BufferedWriter(outputFile);

		// Make the translataion for every line in the input
		String pubMedID = null;
		String descriptorName = null;
		String majorString = null;
		StringTokenizer tokenizer = null;
		String line = null;
		
		// For every line in the file do the translation
		while ((line = reader.readLine()) != null) {
			tokenizer = new StringTokenizer(line,"\t");
			pubMedID = tokenizer.nextToken();
			writer.write(pubMedID);

			// For every Mesh Descriptor
			while (tokenizer.hasMoreTokens()) {
 				descriptorName = tokenizer.nextToken();
				majorString = tokenizer.nextToken();
				writer.write("\t"+nameToID.get(descriptorName));
				if(majorString.contains("Y")){
					writer.write("\tY");
				}
				else{
					writer.write("\tN");
				}
			}
			writer.newLine();
		}
		System.out.println("Translation done!");
		reader.close();
		writer.close(); 
		  
	}

	public static Map<String,String> createDescriptorMapping(String meshFile){
		//Read file
		FileReader file = null;
		try{
			file = new FileReader(meshFile);
		}catch(FileNotFoundException e){
			System.err.println("File " + meshFile + " not found");
			e.printStackTrace();		
		}
		BufferedReader reader = new BufferedReader(file);

		//Create dictionary
		Map<String,String> nameToID = new HashMap<String,String>();

		//Populate dictionary
		String line = null;
		StringTokenizer tokenizer = null;
		String descriptorName = null;
		String descriptorID = null;
		try{
			while ((line = reader.readLine()) != null) {
				tokenizer = new StringTokenizer(line,"\t");
				descriptorName = tokenizer.nextToken();
				descriptorID = tokenizer.nextToken();
				nameToID.put(descriptorName,descriptorID);
			} 
			reader.close();
		}catch(IOException e){
			System.err.println("Error at reading BufferedReader in createDescriptorMapping()");
			e.printStackTrace();		
		}    
		return nameToID;
	}
	


}
