package com{



	//**************************************************************
	// this contains the members of the XmlLine object, used when populating xml file from gedcom file
	public dynamic class XmlLine extends Object {


		public var lineNumber:String;
		public var xref:String;
		public  var tag:String;
		public var pointer:String;
		public var line_value:String;


		public function XmlLine(  lineNumberx:String=null, xrefx:String=null,tagx:String=null,  pointerx:String=null,  line_valuex:String=null                        ) {

			lineNumber=lineNumberx;
			xref=xrefx;
			tag=tagx;
			pointer=pointerx;
			line_value=line_valuex;
		}
	}
}