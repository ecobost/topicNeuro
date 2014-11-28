//Written by: Erick Cobos T (erick.cobos@epfl.ch)
//Date: 16-05-2014

// This class encapsulates the information of a single MeSH descriptor.

import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.ArrayList;

public class Descriptor {
	private String ID; 
	private String name;
	private List<String> treeNumbers;
	private Set<String> nodesAbove; //Set with the nodeIDs of the nodes above this descriptor in the MeSH hierarchy.
	private Set<String> treeNumbersAbove; //Set with the treeNumbers above this descriptor in the MeSH hierarchy.
	
	public Descriptor(){
		ID = "";
		name = "";
		treeNumbers = new ArrayList<String>();
		nodesAbove = new HashSet<String>();
		treeNumbersAbove = new HashSet<String>();
	}

	//Setters and getters
	public void setName(String name){
		this.name = name;
	}
	
	public void setID(String ID){
		this.ID = ID;	
	}
	
	public void addTreeNumber(String treeNumber){
		this.treeNumbers.add(treeNumber);	
	}
	
	public void addNodeAbove(String nodeAbove){
		this.nodesAbove.add(nodeAbove);
	}
	
	public void addTreeNumberAbove(String treeNumberAbove){
		this.treeNumbersAbove.add(treeNumberAbove);
	}

	public String getID(){
		return this.ID;
	}

	public String getName(){
		return this.name;
	}

	public List<String> getTreeNumbers(){
		return this.treeNumbers;
	}
	
	public Set<String> getNodesAbove(){
		return this.nodesAbove;
	}

	public Set<String> getTreeNumbersAbove(){
		return this.treeNumbersAbove;
	}
	
	public String toString(){
		return "Descriptor " + ID + ": " + name;
	}	
}
