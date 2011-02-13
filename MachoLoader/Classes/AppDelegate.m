//
//  AppDelegate.m
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "MachoLoader.h"
#import "DisassemblyChecker.h"
#import "GenericTimer.h"
#import "FunctionEnumerator.h"
#import "DissasemblyProcessor.h"
#import "SimpleTracer.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    [[NSApp mainMenu] addItem:[[[NSClassFromString(@"FScriptMenuItem") alloc] init] autorelease]];

    SimpleTracer *tracer = [[SimpleTracer alloc] init];
    [tracer trace:"/Applications/6-386.app/Contents/MacOS/6-386"];
//    [tracer trace:"/Users/shooley/Desktop/Organ/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug32/CommandLineApp"];
    return;

	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];

	NSArray *paths = [NSArray arrayWithObjects:
					  
					
//					  [[NSBundle mainBundle] executablePath],
					  
					  /* frameworks - lets build this dynamically, eh? */
//					  @"/System/Library/Frameworks/Accelerate.framework/Accelerate",
//					  @"/System/Library/Frameworks/AddressBook.framework/AddressBook",
//					  @"/System/Library/Frameworks/AGL.framework/AGL",
//					  @"/System/Library/Frameworks/AppKit.framework/AppKit",
//					  @"/System/Library/Frameworks/AppKitScripting.framework/AppKitScripting",
//					  @"/System/Library/Frameworks/AppleScriptKit.framework/AppleScriptKit",
//					  @"/System/Library/Frameworks/AppleScriptObjC.framework/AppleScriptObjC",
//					  @"/System/Library/Frameworks/AppleShareClientCore.framework/AppleShareClientCore",
//					  @"/System/Library/Frameworks/AppleTalk.framework/AppleTalk",
//					  @"/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices",
//					  @"/System/Library/Frameworks/AudioToolbox.framework/AudioToolbox",
//					  @"/System/Library/Frameworks/AudioUnit.framework/AudioUnit",
//					  @"/System/Library/Frameworks/Automator.framework/Automator",
//					  @"/System/Library/Frameworks/CalendarStore.framework/CalendarStore",
//					  @"/System/Library/Frameworks/Carbon.framework/Carbon",
//					  @"/System/Library/Frameworks/Cocoa.framework/Cocoa",
//					  @"/System/Library/Frameworks/Collaboration.framework/Collaboration",
//					  @"/System/Library/Frameworks/CoreAudio.framework/CoreAudio",
//					  @"/System/Library/Frameworks/CoreAudioKit.framework/CoreAudioKit",
//					  @"/System/Library/Frameworks/CoreData.framework/CoreData",
//					  @"/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation",
//					  @"/System/Library/Frameworks/CoreLocation.framework/CoreLocation",
//					  @"/System/Library/Frameworks/CoreMIDI.framework/CoreMIDI",
//					  @"/System/Library/Frameworks/CoreMIDIServer.framework/CoreMIDIServer",
//					  @"/System/Library/Frameworks/CoreServices.framework/CoreServices",
//					  @"/System/Library/Frameworks/CoreVideo.framework/CoreVideo",
//					  @"/System/Library/Frameworks/CoreWLAN.framework/CoreWLAN",
//					  @"/System/Library/Frameworks/DirectoryService.framework/DirectoryService",
//					  @"/System/Library/Frameworks/DiscRecording.framework/DiscRecording",
//					  @"/System/Library/Frameworks/DiscRecordingUI.framework/DiscRecordingUI",
//					  @"/System/Library/Frameworks/DiskArbitration.framework/DiskArbitration",
//					  @"/System/Library/Frameworks/DrawSprocket.framework/DrawSprocket",
//					  @"/System/Library/Frameworks/DVComponentGlue.framework/DVComponentGlue",
//					  @"/System/Library/Frameworks/DVDPlayback.framework/DVDPlayback",
//					  @"/System/Library/Frameworks/ExceptionHandling.framework/ExceptionHandling",
//					  @"/System/Library/Frameworks/ForceFeedback.framework/ForceFeedback",
//					  @"/System/Library/Frameworks/Foundation.framework/Foundation",
//					  @"/System/Library/Frameworks/FWAUserLib.framework/FWAUserLib",
//					  @"/System/Library/Frameworks/GLUT.framework/GLUT",
//					  @"/System/Library/Frameworks/ICADevices.framework/ICADevices",
//					  @"/System/Library/Frameworks/ImageCaptureCore.framework/ImageCaptureCore",
//					  @"/System/Library/Frameworks/IMCore.framework/IMCore",
//					  @"/System/Library/Frameworks/InputMethodKit.framework/InputMethodKit",
//					  @"/System/Library/Frameworks/InstallerPlugins.framework/InstallerPlugins",
//					  @"/System/Library/Frameworks/InstantMessage.framework/InstantMessage",
//					  @"/System/Library/Frameworks/IOBluetooth.framework/IOBluetooth",
//					  @"/System/Library/Frameworks/IOBluetoothUI.framework/IOBluetoothUI",
//					  @"/System/Library/Frameworks/IOKit.framework/IOKit",
//					  @"/System/Library/Frameworks/IOSurface.framework/IOSurface",
//					  @"/System/Library/Frameworks/JavaEmbedding.framework/JavaEmbedding",
//					  @"/System/Library/Frameworks/JavaFrameEmbedding.framework/JavaFrameEmbedding",
//					  @"/System/Library/Frameworks/JavaScriptCore.framework/JavaScriptCore",
//					  @"/System/Library/Frameworks/JavaVM.framework/JavaVM",
//					  @"/System/Library/Frameworks/Kerberos.framework/Kerberos",
//					  @"/System/Library/Frameworks/LatentSemanticMapping.framework/LatentSemanticMapping",
//					  @"/System/Library/Frameworks/LDAP.framework/LDAP",
					  
					  @"/Applications/iTunes.app/Contents/MacOS/iTunes_thin",
					  
//					  @"/Applications/6-386.app/Contents/MacOS/6-386",
//					  @"/Applications/Adobe Lightroom 3.app/Contents/MacOS/Adobe Lightroomx86_64",
//					  @"/Applications/Adobe After Effects CS5/Adobe After Effects CS5.app/Contents/MacOS/After Effects",
//					  @"/Library/Frameworks/Houdini.framework/Versions/11.0.469/Houdini",
					  nil];

	for( NSString *each in paths )
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:each])
		{
						
//aa			MachoLoader *ml = [[MachoLoader alloc] initWithPath:each];
//aa			[ml readFile];
			
//aa			DisassemblyChecker *dc = [[DisassemblyChecker alloc] initWithPath:each isFAT:ml->_binaryIsFAT];
//aa			BOOL success = [dc openOTOOL];
//aa			if(!success)
//aa				[NSException raise:@"Failed to open OTOOL" format:@""];

//aa			[ml disassembleWithChecker:dc];
			
//aa			success = [dc close];
//aa			if(!success)
//aa				[NSException raise:@"Failed to close OTOOL" format:@""];
			
			// Wooah! otool reader hijacks standard out?
			NSLog(@"Fin!");
			
//putback later			DissasemblyProcessor *dProcessor = [[DissasemblyProcessor alloc] initWithFunctionEnumerator:[ml functionEnumerator]];
//putback later			[dProcessor processApp];
//putback later			[dProcessor release];
		
//aa			[dc release];
//aa			[ml release];
		}
	}

	[readTimer close];  // 7.1 secs -- 6.7 secs  // 6.2

}

@end
