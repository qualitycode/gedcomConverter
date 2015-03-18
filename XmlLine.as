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