// Written by: Erick Cobos T. (erick.cobos@epfl.ch)
// Date: 16-05-2014

// This class reads the MeSH file (.tsv) and generates a list of Descriptor objects

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.StringTokenizer;


public class DescriptorList implements Iterable<Descriptor> {
	
	// Set parameters
	private static String meshFile = "./resources/MeSHDescriptors.tsv";

	private List<Descriptor> descriptorList;
	//Indices to improve acces time 
	private Map<String, Descriptor> IDIndex; 
	private Map<String, Descriptor> treeNumberIndex;
	
	public DescriptorList(){
		this(meshFile);
	}
	
	public DescriptorList(String meshFile){
		this.meshFile = meshFile;
		descriptorList = new ArrayList<Descriptor>();
		IDIndex = new HashMap<String, Descriptor>();
		treeNumberIndex = new HashMap<String, Descriptor>();
		populateList();
	}
	
	private void populateList(){
		// Open MeSH file
		FileReader file = null;
		try{
			file = new FileReader(meshFile);
		}catch(FileNotFoundException e){
			System.err.println("File " + meshFile + " not found");
			e.printStackTrace();		
		}
		BufferedReader reader = new BufferedReader(file);
		
		// Create Descriptors
		String line = null;
		Descriptor descriptor = null;
		StringTokenizer tokenizer = null;
		try{
			while ((line = reader.readLine()) != null) { // For every MeSH descriptor
				descriptor = new Descriptor();
				tokenizer = new StringTokenizer(line, "\t");
	
				descriptor.setName(tokenizer.nextToken()); // Name
				descriptor.setID(tokenizer.nextToken()); // ID

				while(tokenizer.hasMoreTokens()){ 
					descriptor.addTreeNumber(tokenizer.nextToken()); // Tree numbers
				}
				
				descriptorList.add(descriptor);
			} 
			reader.close();
		}catch(IOException e){
			System.err.println("Error while reading BufferedReader");
			e.printStackTrace();		
		}

		//Create indices
		createIndices();

		// Set tree numbers above and nodes above for every descriptor.
		// Does not include the tree numbers of the descriptor itself or the node represented by the descriptor itself.
		String treeNumberAbove = null;
		String nodeAbove = null;
		for(Descriptor d: descriptorList){
			for(String treeNumber: d.getTreeNumbers()){
				tokenizer = new StringTokenizer(treeNumber, ".");
				treeNumberAbove = tokenizer.nextToken();
				while(tokenizer.hasMoreTokens()){ // For every chunk of the tree number except the last.
					d.addTreeNumberAbove(treeNumberAbove); // Tree numbers above
					nodeAbove = getDescriptorByTreeNumber(treeNumberAbove).getID();
					d.addNodeAbove(nodeAbove);// Nodes above
					
					treeNumberAbove += ".";
					treeNumberAbove += tokenizer.nextToken();
				}		
			}
		}
		
			
	}
	
	private void createIndices(){
		for(Descriptor descriptor: descriptorList){
			IDIndex.put(descriptor.getID(), descriptor);
			for(String treeNumber: descriptor.getTreeNumbers()){
				treeNumberIndex.put(treeNumber,descriptor);
			}	
		}	
	}

	public Descriptor getDescriptorByTreeNumber (String treeNumber) {
		return treeNumberIndex.get(treeNumber);
	}

	public Descriptor getDescriptorByID(String ID) {
		return IDIndex.get(ID);
	}
	
	public Iterator<Descriptor> iterator() {
		return descriptorList.iterator();
	}

	public String toString(){
		return "Descriptor List from " + meshFile + " with size " + descriptorList.size();
	}
}
