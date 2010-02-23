File: readme.txt

Abstract: readme file for the ScriptingDefinitions sample

Version: 1.0

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved. 



This sample contains two scripting definition (sdef) files:

- Sketch.sdef: the scripting interface for Sketch (available separately in /Developer/Examples/AppKit).  In Tiger, this file may be added to the Sketch application to drive its scriptability, in place of its existing scriptSuite and scriptTerminology files.


- Skeleton.sdef: a starting point for the scripting interface of an application.  It contains definitions for the Standard Suite and the Standard Text Suite that you can include in your application's .sdef file.  Functionality for these suites is supplied by Cocoa Scripting.



Use XInclude in Mac OS X 10.5 and later for the Standard Suite

In Mac OS X 10.4 it was common practice to include the complete definition for the Standard Suite in an application's .sdef file.  In Mac OS X 10.5 a new mechanism is in place that allows you to include the Standard Suite in your .sdef using a mechanism similar to the #include preprocessor directive in C: namely, XInclude.  For backwards compatibility with Mac OS X 10.4, you may continue to include the complete definitions for the Standard Suite in your .sdef file, but for Mac OS X 10.5 the XInclude technique described below is recommended.


When adding scripting to an application, the first step is to add a new .sdef file that includes the Standard Suite to your Xcode project.  Usually, this file will have the same name as your application.  For example, if your application is named 'ScriptingExample', then you would call your .sdef file 'ScriptingExample.sdef'.  When you begin, the contents of that file should be an empty dictionary that includes the standard AppleScript suite as follows:


<dictionary xmlns:xi="http://www.w3.org/2003/XInclude">

	<xi:include href="file:///System/Library/ScriptingDefinitions/CocoaStandard.sdef" xpointer="xpointer(/dictionary/suite)"/>

		<!-- add your own suite definitions here -->

</dictionary>


The important parts of this definition are as follows:

1. The 'xi' namespace declaration in the opening dictionary element declares that enclosed elements using the 'xi' namespace will follow conventions defined by the XInclude standard.  This will allow us to include the standard definitions.

2. The 'xi:include' element includes the Standard Suite in the .sdef.



The Standard Text Suite

Applications using the Standard Text Suite will have to copy the definition for the Standard Text Suite into their .sdef file.  At the time of this writing, this definition is not available on the system in a file that you can reference using an XInclude.  Most applications will not need to use the Standard Text Suite unless they support scriptable rich text content and they are using Cocoa's model for rich text handling.



Related Samples

The following samples have been upgraded to use the XInclude technique for including the Standard Suite.  Please refer to them for an example of how to use XInclude.

SimpleScripting
	http://developer.apple.com/samplecode/SimpleScripting/
	
SimpleScriptingProperties
	http://developer.apple.com/samplecode/SimpleScriptingProperties/
	
SimpleScriptingObjects
	http://developer.apple.com/samplecode/SimpleScriptingObjects/
	
SimpleScriptingVerbs
	http://developer.apple.com/samplecode/SimpleScriptingVerbs/

NOTE: this suite of samples is structured as an incremental tutorial with concepts illustrated in one sample leading to the next in the order they are listed above.




