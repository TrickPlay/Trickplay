package com.trickplay.gameservice.xmpp.client;

import java.io.StringReader;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.xmlpull.mxp1.MXParser;
import org.xmlpull.v1.XmlPullParser;

public class ReadWriteCDATA {

	public static void main(String[] args) {
		
		Element root = DocumentHelper.createElement("root");
		root.addAttribute("gameId", "http://jabber.org/protocol/mug");
		root.add(DocumentHelper.createCDATA("<junk><hello>blah=234</hello></junk>"));
		Document doc = DocumentHelper.createDocument(root);
		
		System.out.println(doc.asXML());
		
		String encodedStr = doc.asXML();
		
		 try {
			 MXParser parser = new MXParser();
			 parser.setInput(new StringReader(encodedStr));
		        
			 while (true) {
		         int event = parser.next();
		         if (event == XmlPullParser.START_TAG) {
		             if (parser.getName().equals("root")) {
		            	 System.out.println("root element attribute gameId:"+parser.getAttributeValue("", "gameId"));
		            	 System.out.println("root element contents:"+parser.nextText()+" gameId=");
		             }
		         }
		         else if (event == XmlPullParser.END_TAG) {
		             System.out.println("End tag");
		         }
		         else if (event == XmlPullParser.START_DOCUMENT) {
		             System.out.println("Start document");
		         }
		         else if (event == XmlPullParser.TEXT) {
		             System.out.println("Text");
		         }
		         else if (event == XmlPullParser.CDSECT) {
		             System.out.println("CDATA Section");
		         }
		         else if (event == XmlPullParser.COMMENT) {
		             System.out.println("Comment");
		         }
		         else if (event == XmlPullParser.DOCDECL) {
		             System.out.println("Document type declaration");
		         }
		         else if (event == XmlPullParser.ENTITY_REF) {
		             System.out.println("Entity Reference");
		         }
		         else if (event == XmlPullParser.IGNORABLE_WHITESPACE) {
		             System.out.println("Ignorable white space");
		         }
		         else if (event == XmlPullParser.PROCESSING_INSTRUCTION) {
		             System.out.println("Processing Instruction");
		         }
		         else if (event == XmlPullParser.END_DOCUMENT) {
		             System.out.println("End Document");
		             break;
		         }
		      }   
		 
		 } catch (Exception ex) {
			 ex.printStackTrace();
		 }
	}
	
}
