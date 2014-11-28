// Written by: Erick Cobos T (erick.cobos@epfl.ch)
// Date: 14-03-2014

// This programs reads the data about the MeSH vocabulary obtained  as .xml from the MeSH webpage (https://www.nlm.nih.gov/mesh/filelist.html)
// and transform it into a tsv(tab separated values) file with the following format:
// DescriptorName	DescriptorUI	[TreeNumber]+
// This features will be extracted from the xml using a standard XML reader. The descriptor ID will be stripped down of the initial D
// Please set parameters as needed

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;


public class MeshInXml2Tsv extends DefaultHandler {
 	
	// Set parameters
	private static String filename = "/home/michael/Documents/MasterProject/lda_mesh/Corpora/MeSH_Vocabulary/desc2014.xml";
	private static String outputFile= "MeSHDescriptors.tsv";

	//Variables used for parsing
	private PrintWriter output; 
	private Descriptor descriptor;
	private int depth = 0;
	private StringBuilder builder;

	public static void main (String[] args) throws Exception {

		//Prepare and start the parser
		SAXParserFactory spf = SAXParserFactory.newInstance();
		spf.setNamespaceAware(true);
		SAXParser saxParser = spf.newSAXParser();

		XMLReader xmlReader = saxParser.getXMLReader();
		xmlReader.setContentHandler(new MeSHXml2Tsv());
		xmlReader.parse(filename);
	}
	
	// Prepare the output file
	public void startDocument() throws SAXException {
		try{
	        	output = new PrintWriter(outputFile, "UTF-8");
		}catch(Exception e){
			e.printStackTrace();
		}
    	}

	// Close the output file
    	public void endDocument() throws SAXException {
		
		output.close();
        }    
	
	// Manages what to do when a new elements appear. qName is the name of the label.
	public void startElement(String namespaceURI, String localName,  String qName,  Attributes atts) throws SAXException {
		if(qName.equals("DescriptorRecord")){
			descriptor = new Descriptor();		
		}
		if(qName.equals("DescriptorName") && depth == 2){
			builder = new StringBuilder(); 
		}
		if(qName.equals("DescriptorUI") && depth == 2 ){
			builder = new StringBuilder();
		}
		if(qName.equals("TreeNumber") && depth == 3){
			builder = new StringBuilder();
		}

		//collectdata=true
		
		depth++;
	}
	
	// Manages what to do when an element is closed
	public void endElement(String uri, String localName, String qName) throws SAXException{
		if(qName.equals("DescriptorRecord")){
			output.println(descriptor.toTabSeparatedLine());
		}
		if(qName.equals("DescriptorName") && depth == 3){
			descriptor.setDescriptorName(builder.toString()); 
		}
		if(qName.equals("DescriptorUI") && depth == 3){
			descriptor.setDescriptorUI(builder.toString().substring(1));
		}
		if(qName.equals("TreeNumber") && depth == 4){
			descriptor.setTreeNumber(builder.toString());
		}
		
		depth--;
	
	}

	public void characters(char[] chars, int start, int length) throws SAXException{
		builder.append(new String(chars, start, length));
	}


}

class Descriptor {
	String descriptorName;
	String descriptorUI;
	List<String> treeNumbers;
	
	public Descriptor(){
		descriptorName = "";
		descriptorUI = "";
		treeNumbers = new ArrayList<String>();
	}

	public String toTabSeparatedLine(){
		String res = descriptorName + "\t" + descriptorUI;
		for(String treeNumber: treeNumbers){
			res += "\t" + treeNumber;
		}
		return res;
	}
	
	public void setDescriptorName(String descriptorName){
		this.descriptorName = descriptorName;	
	}
	
	public void setDescriptorUI(String descriptorUI){
		this.descriptorUI = descriptorUI;	
	}
	
	public void setTreeNumber(String treeNumber){
		this.treeNumbers.add(treeNumber);	
	}
}


