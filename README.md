# GEDCOM Converter

This project will convert GEDCOM genealogy files to JSON and XML using Javascript and Actionscript.

I wrote this as part of a project called [slidetrip.com](http://slidetrip.com), which takes a gedcom file and generates an on-line presentation, 
connected to a virtual earth.  This was written in actionscript for FlashBuilder (AKA Adobe Flex).  The output is XML.

It works nicely, but now I need to re-write this in Javascript and output this to JSON.

This will take any version (maybe not GEDCOM X) of GEDCOM and convert it.

There are other GEDCOM parsers, but it was easier to make my own.

### The Core Function

The function that does the parsing and output is called loopGedWriteXML().  It is found in XmlLoad.as.  It is a recursive
function that traverses the gedcom file, using parseLine() to read a one line at a time.

### Memory Idea

Currently, this reads the whole GEDCOM file into memory.  A better way might be to stream it in and output to a file as
it is being converted, so that this could handle large GEDCOM files.



