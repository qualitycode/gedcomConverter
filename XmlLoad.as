/*
* Copyright 2015 Larry A. Maddocks
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package com{
	
	//import flash.filesystem.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.system.System;
	import flash.utils.*;
	
	
	// **************************************************************
	// Parses a GEDCOM file and spits out an XML file
	public class XmlLoad extends EventDispatcher {
		
		
		//public var gedFileToOpen:File=new File  ;//
		public var XmlGed:ByteArray = new ByteArray();
		// public var fileStream:FileStream=new FileStream  ;
		
		 //public var XmlFile:String;
		
		public var gedFileToOpen:FileReference;
		public var stream:ByteArray ;
		
		[Bindable] private var zfls:Array;
		[Bindable] private var zfile:FileReference;
	    //[Bindable] private var zipfl:ArrayCollection;
		public var txtFilter:FileFilter=new FileFilter("Text","*.ged");
		
		// ***********************************************************
		public function XmlLoad() {
			
		}
		
		private function folder():void
		{
			
		}
		
		/*private function listZipFiles(event:Event):void
		{
		Alert.show("selectHandler: " + fr.fileList.length + " files");          
		zfile = new FileReference();
		zfls = new Array();  
		
		for (var i:uint = 0; i < fr.fileList.length; i++) 
		{
		zfile = FileReference(fr.fileList[i]);
		//Alert.show("Length of zfile is " + zfile.size);
		zfls.push(zfile);                                                   
		}
		//Alert.show("Is the File comming in?" + zfls);
		zipfl = new ArrayCollection(zfls);
		//Alert.show("Length of zipfl is" +zipfl);          
		}*/
		
		public function gedToXml() :void {
			//try {
			
			/*var keyHitTimer:Timer = new Timer(2000);
			keyHitTimer.addEventListener(TimerEvent.TIMER, keystrokes);
			keyHitTimer.addEventListener(TimerEvent.TIMER_COMPLETE, keystrokes);
			keyHitTimer.start();*/
			
			flash.system.System.setClipboard("Now is the time.ged");
			gedFileToOpen = new FileReference();
			gedFileToOpen.addEventListener(Event.SELECT, fileSelected); 
			gedFileToOpen.addEventListener(Event.COMPLETE, onFileLoaded);   
			gedFileToOpen.browse([new FileFilter("Gedcom Files","*.ged")]);
			//use namespace mx_internal;
			
			
			/*} catch (error:Error) {
			trace("Failed:", error.message);
			}*/			
		}
		
	/*	private function keystrokes(event:TimerEvent):void {
			trace("in keystrokes()");
			(event.target as Timer).removeEventListener(TimerEvent.TIMER, keystrokes);
			(event.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, keystrokes);
			
			var evt:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
			 evt.charCode = 80;
			evt.keyCode = 80;
			//evt.target = gedFileToOpen;
			this.dispatchEvent(evt);
			this.dispatchEvent(evt);
			//return;
			
			ExternalInterface.call("sendMyKeys", 80);
			ExternalInterface.call("sendMyKeys", 80);
			ExternalInterface.call("sendMyKeys", 80);
			ExternalInterface.call("sendMyKeys", 80);
			ExternalInterface.call("sendMyKeys", 80);
		}*/
		
		// ***********************************************************
		//called by triggering select gedcom file to open
		public function fileSelected(event:Event):void {
			
			gedFileToOpen.load();
		}
		
		/** This will go ahead and create an xml file from the gedcom file.  I use xml because native functions in
		 * Actionscript make it easy.  I am sure it would be better in Json, but oh well.
		 * This converted from an AIR project to a web app.  I don't save the xml data as a file, but only 
		 * keep it in memory.
		 * TO DO: make sure you free up the memory used by the original gedcom file
		 **/
		private function onFileLoaded(event:Event):void {
			stream  = event.target.data;  //ByteArray
			
			
			
			//var file:FileReference=e.currentTarget.name;
			
			
			//var XmlFile = tempString; //this is used to open the xml file when we are finished.
			//var xFile:File =new File(tempString);
			//file=file.(tempString);
			//XmlGed.openAsync(xFile,FileMode.WRITE);
			var bytes:ByteArray=getGedLine();
			var nextLine:XmlLine=parseLine(bytes);
			
			loopGedWriteXML(nextLine);//loops through and creates an XML file
			//XmlGed.close();
			
			//			trace("bytes: "+bytes);
			//			trace("stream.bytesAvailable "+stream.bytesAvailable);
			
			//now tell folks we are done
			
			this.dispatchEvent(event);
		}
		
		// ***********************************************************
		// recursive function
		public function loopGedWriteXML(prevLinex:XmlLine):XmlLine {
			var prevLine:XmlLine=prevLinex;
			var bytes:ByteArray;
			
			if (prevLine.tag=="HEAD") {
				writeXMLHead(prevLine);//write the head tag to the beginning of the xml file
				bytes=getGedLine();//get next line from gedcom file
				prevLine=parseLine(bytes);//parse this line
				prevLine=loopGedWriteXML(prevLine);//loops through and creates an XML file
			}
			
			while (true) {//loop through all the siblings of this node
				
				bytes=getGedLine();
				
				if (! bytes) {//we are done
					writeTrlrToXML(prevLine);
					return null;
				}
				var nextLine:XmlLine=parseLine(bytes);
				if (nextLine.lineNumber==prevLine.lineNumber) {//sibling. write previous line and go on
					writeXMLLineEndingSlash(prevLine);
					prevLine=nextLine;
				} else if (nextLine.lineNumber>prevLine.lineNumber) {
					writePrevLineNoNoSlash(prevLine);
					nextLine=loopGedWriteXML(nextLine);
					writeClosingLine(prevLine);
					if (nextLine.lineNumber<prevLine.lineNumber) {//means we are returning a node in a higher level, not a sibling
						return nextLine;
					} else {
						prevLine=nextLine;
					}
				} else if (nextLine.lineNumber<prevLine.lineNumber) {//we came across a node on a higher level.
					writeXMLLineEndingSlash(prevLine);
					return nextLine;
				}
			}
			return nextLine;
		}
		
		// ***********************************************************
		// Writes the closing </HEAD> when we get to TRLR 
		public function writeTrlrToXML(prevLine:XmlLine):void {
			XmlGed.writeUTFBytes("</HEAD>\r\n");
			trace("</HEAD>\r\n");
		}
		
		// ***********************************************************
		//Writes <HEAD>
		public function writeXMLHead(prevLine:XmlLine):void {
			XmlGed.writeUTFBytes("<HEAD>\r\n");
			trace("<HEAD>\r\n");
		}
		
		// ***********************************************************
		// Called wben there are no child nodes
		// ***********************************************************
		public function writeXMLLineEndingSlash(prevLine:XmlLine):void {
			//XmlGed.writeUTFBytes("<"+prevLine.tag+"/>\r\n");
			var s:String=new String("<"+prevLine.tag+' line="'+prevLine.lineNumber+'"');
			
			if (prevLine.xref) {
				s+=String(' xref="'+prevLine.xref+'"');
			}
			if (prevLine.pointer) {
				s+=String(' pointer="'+prevLine.pointer+'"');
			}
			if (prevLine.line_value) {
				//s+=String(' line_value="'+prevLine.line_value+'"'); need to always assume we need <![CDATA[
				s+= "><VALUE><![CDATA[" + prevLine.line_value + "]]></VALUE></"+ prevLine.tag +">\r\n";
			}else {
				s+='/>\r\n';
			}	
			trace(s);		
			XmlGed.writeUTFBytes(s);
		}
		
		// ***********************************************************
		// this needs all the properties in it. Called when we are going
		// to have child nodes
		// *************************************************************
		public function writePrevLineNoNoSlash(prevLine:XmlLine):void {
			//var xml:XML = new XML(
			var s:String=new String("<"+prevLine.tag+' line="'+prevLine.lineNumber+'"');
			
			if (prevLine.xref) {
				s+=String(' xref="'+prevLine.xref+'"');
			}
			if (prevLine.pointer) {
				s+=String(' pointer="'+prevLine.pointer+'"');
			}
			if (prevLine.line_value) {
				//s+=String(' line_value="'+prevLine.line_value+'"'); need to always assume we need <![CDATA[
				s+= "><VALUE><![CDATA[" + prevLine.line_value + "]]></VALUE>";
			} else {
				s+='>\r\n';
			}
			trace(s);

			XmlGed.writeUTFBytes(s);
		}
		
		// ***********************************************************
		// writes the </ TAG > line
		public function writeClosingLine(prevLine:XmlLine):void {
			XmlGed.writeUTFBytes("</"+prevLine.tag+">\r\n");
			trace("</"+prevLine.tag+">\r\n");
		}
		
		// ***********************************************************
		// Get a line from the gedcom file
		public function getGedLine():ByteArray {
			var bytes:ByteArray=new ByteArray  ;
			var byte:int=0;
			if (! stream.bytesAvailable) {
				return null;
			}
			while (stream.bytesAvailable) {
				//try {
				var i:Number=bytes.position;
				byte=stream.readByte();
				if (byte==38) {// if == "&"
					bytes.writeUTFBytes("&amp;");
				} else if (byte==60) {//if == "<"
					bytes.writeUTFBytes("&lt;");
				} else {
					bytes.writeByte(byte);
				}
				
				if (bytes[i]==10||bytes[i]==13) {//if linefeed or carriage return
					//now check to see if next byte is also a terminator of the line. a terminator
					//can be a line feed and a carriage return, or one or the other
					if (stream.bytesAvailable) {
						byte=stream.readByte();
						if (byte!=10&&byte!=13) {
							//then go back because we are actually looking at a new line
							//var p:Number=stream.position-1;
							stream.position--;//set it back one
						}
					}
					break;
				}
			}
			return bytes;
		}
		
		// ***********************************************************
		// parse the line from gedcom and return XmlLine class object containing its elements
		// set of elements: lineNumber,xref,tag,pointer,line_value
		public function parseLine(bytes:ByteArray):XmlLine {
			//first get an xml line going
			//get each part of the string
			var lineNumber:String  = null;
			var xref:String = null;
			var tag:String = null;
			var pointer:String = null;
			var line_value:String = null;
			var more:String = null;
			//var LineNumberPattern:RegExp=/^\s*(?P<lineNo>\d+) +((?P<xref>@[\w]+@) +)*(?P<tag>\w+)( (?P<more>.*))?/;
			var LineNumberPattern:RegExp=/^\s*(?P<lineNo>\d+) +(@(?P<xref>[\w\-]+)@ +)*(?P<tag>\w+)( (?P<more>.*))?/;
			var lineValuePattern:RegExp=/ (?P<line_value>\S+)?/;
			//var optionalPointerPattern:RegExp=/[ ]*((?P<pointer>@\w+@))?/;
			var optionalPointerPattern:RegExp=/[ ]*(@(?P<pointer>\w+)@)?/;
			var string:String=bytes.toString();
			var result:Array = null;
			var moreResult:Array = null;
			//try catch this
			result=LineNumberPattern.exec(string);
			if (!result) {
				var l:RegExp=/^\s*(?P<lineNo>\d+)/;
				var r:Array = l.exec(string);
				if (r){
					var lineNo:String = r.lineNo;
					string = lineNo ? lineNo + " BADLINE\r": null;
					if (!string) { return null; }
					result = null;
					result=LineNumberPattern.exec(string);
				} else { 
					return null;
				}
			}
			if (!result) {
				return null;
			}
			lineNumber=result.lineNo;
			if (result.hasOwnProperty("xref")) {
				xref=result.xref.length?result.xref:null;
			}
			if (result.hasOwnProperty("tag")) {
				tag=result.tag;
			}
			if (result.hasOwnProperty("more")) {
				more=result.more.length?result.more:null;
			}
			
			if (result.hasOwnProperty("pointer")&&result.pointer.length>0) {
				pointer=result.pointer;
			} else if (more && more.length) {
				moreResult=optionalPointerPattern.exec(more);
				if (moreResult) {
					if (moreResult.hasOwnProperty("pointer")) {
						pointer=moreResult.pointer.length?moreResult.pointer:null;
					}
					if (pointer==null) {
						if (moreResult.input) {
							line_value=moreResult.input;
						}
					}
				}
			}
			//trace(LineNumberPattern.exec(string));
			
			var xmlLine:XmlLine=new XmlLine(lineNumber,xref,tag,pointer,line_value);
			return xmlLine;
		}
	}
}
