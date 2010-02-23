//
//  BBEmbedFontsPatch.m
//  SHExtras
//
//  Created by Steven Hooley on 31/01/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBEmbedFontsPatch.h"

/*
 *
*/
@implementation BBEmbedFontsPatch


//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode {
	return 3;
}

//=========================================================== 
// - timeMode:
//=========================================================== 
+ (int)timeMode {
	return 0;
}

//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL) allowsSubpatches {
	return FALSE;
}

//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;

	NSMutableArray* allBundledFonts = [self loadFonts];
	NSEnumerator *enumerator1 = [allBundledFonts objectEnumerator];
	NSFont* aFont;
	while ((aFont = [enumerator1 nextObject])) 
	{
		[self addFontOutputPort:aFont];
	}
	return self;
}

//=========================================================== 
// - setup:
//=========================================================== 
- (id) setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	[super setup:fp8];
	return fp8;
}

//=========================================================== 
// - addOutputPort:
//=========================================================== 
- (void) addFontOutputPort:(NSFont*)aFont
{
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: [QCStringPort class], @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name", [aFont displayName], @"description", [aFont fontName], nil], @"attributes", nil];
	QCStringPort* port = [self createOutputPortWithArguments:arguments forKey:[aFont displayName]];
	// [outPorts addObject:port];
	[port setStringValue:[aFont fontName]];
}

//=========================================================== 
// - loadFonts:
//=========================================================== 
- (NSMutableArray *) loadFonts;
{ 
	NSMutableArray *myfonts = [[NSMutableArray alloc]init]; 

	NSBundle * bundle = [NSBundle bundleForClass: [self class]];
	NSString *fontsFolder = [[bundle resourcePath] stringByAppendingPathComponent:@"Fonts"];
	if (fontsFolder) 
	{
		NSURL *fontsURL = [NSURL fileURLWithPath:fontsFolder];
		if(fontsURL)
		{
			ATSFontContainerRef container=nil; 
			NSFont *f=nil; 
			CFStringRef fontName=NULL; 
			FSRef fsRef; 
			FSSpec fsSpec; 
			FSCatalogInfo catinfo; 
			// int osstatus = FSPathMakeRef((const UInt8*)[path UTF8String], &fsRef, NULL); 
			(void)CFURLGetFSRef((CFURLRef)fontsURL, &fsRef);
			OSStatus osstatus = FSGetCatalogInfo(&fsRef,kFSCatInfoNone,&catinfo,NULL,&fsSpec,NULL); 
			
			osstatus = ATSFontActivateFromFileSpecification ( &fsSpec, kATSFontContextLocal, kATSFontFormatUnspecified, NULL, kATSOptionFlagsDefault, &container); 
			if (osstatus != noErr) 
			{ 
				//NSLog(@"Got error %d loading %@!!!",osstatus,path); } 

			} else { 
				int fntcount; 
				ItemCount count; 
				//ByteCount bcount; 
				osstatus = ATSFontFindFromContainer( container, kATSOptionFlagsDefault, 0, NULL, &count); 
				ATSFontRef *ioArray=(ATSFontRef *)malloc(count * sizeof(ATSFontRef)); 
				osstatus = ATSFontFindFromContainer( container, kATSOptionFlagsDefault, count, ioArray,&count); 
				for (fntcount=0; fntcount < count ; fntcount++ ) 
				{ 
					osstatus = ATSFontGetName (ioArray[fntcount], kATSOptionFlagsDefault, &fontName); 

					if (fontName) f = [NSFont fontWithName:(NSString*)fontName size:24]; if ( f != nil ) 
					{ 
						[myfonts addObject:f]; 
					} 
				} 

				// NSNumber *contno=[NSNumber numberWithInt:container]; 
				// [containerarr addObject:contno]; //containerarr array is used during deactivation 
			} 
		}
	}
	return myfonts; 
} 




#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	// NSLog(@"BBInterpolationPatch: %@ executing at time %f", [self description], (float)compositionTime);
	
	/* all i know..
	[inputNumber didChangeValue] will cause this patch to execute, but nothing further down the chain if the value hasn't really changed
	doing this on the outport port has no effect
	[outputNumber setDoubleValue:xxx] will cause everything below in the chain to be updated but only if xxx is a different value
	[self _setNeedsExecution] will cause us to executed, but not the chain if no values have changed
	
//	[inputNumber setDoubleValue:[inputNumber doubleValue]+1];

	[outputNumber setDoubleValue:[inputNumber doubleValue]];
//	outputNumber updated
//	outputNumber wasUpdated

	/* returning no causes an exception */
	// [outputValue setDoubleValue: [_envelope evalAtTime:compositionTime]];

	return YES;
}



#pragma mark accessor methods



@end
