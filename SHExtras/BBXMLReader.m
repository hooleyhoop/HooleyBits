//
//  XMLPatch.m
//  QuartzXML
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "BBXMLReader.h"
#import "RSSReader.h"

@interface BBXMLReader (privateMethods)
-(void)updateXMLOutput;
@end

@implementation BBXMLReader
	
+ (int)executionMode
{
        // I have found the following execution modes:
        //  1 - Renderer, Environment - pink title bar
        //  2 - Source, Tool, Controller - blue title bar
        //  3 - Numeric, Modifier, Generator - green title bar
        return 2;
}
	
+ (BOOL)allowsSubpatches
{
        // If your patch is a parent patch, like 3D Transformation,
        // you will allow subpatches, otherwise FALSE.
	return FALSE;
}
	
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	
	[inputSelector setStringValue:@"qcport/item"];
	
	reader = [[RSSReader alloc] initWithDelegate:self];
	
	return self;
}
	
- (void)dealloc
{
	[reader closeConnection];
	[reader release];
	
	[url release];
	[selector release];
	
	[super dealloc];
}
	
- (id)setup:(id)fp8
{
	//One time setup, called for every patch at startup (whether or not it's in the rendering chain.)
	//Also called after reopening Viewer....
	needsRefresh = YES;		//QC loses the output value after closing the view, so need to refresh it here.
	return fp8;
}
	
- (BOOL)execute:(id)fp8 time:(double)fp12 arguments:(id)fp20
{
	// This is where the execution of your patch happens.
	// Everything in this method gets executed once
	// per 'clock cycle', which is available in fp12 (time).

	// fp8 is the QCOpenGLContext*.  Don't forget to set
	// it before you start drawing.  

	// Read/Write any ports in here too.
	
	if ([inputRefreshFeed booleanValue] || ![url isEqualToString:[inputURL stringValue]] || ![selector isEqualToString:[inputSelector stringValue]] || needsRefresh)
	{
		[url release];
		url = [[inputURL stringValue] retain];
		
		[selector release];
		selector = [[inputSelector stringValue] retain];
		
		forceArrays = [inputForceArrays booleanValue];
		
		[reader setURL:[NSURL URLWithString:url]];
		[reader requestData];
		[outputReady setBooleanValue:NO];
		needsRefresh = NO;
		
		[inputRefreshFeed setBooleanValue:NO];
	}

	return TRUE;
}


-(void)readerWasUpdated:(RSSReader*)aReader
{
	NSDictionary* rssDictionary = [aReader xmlDictionary];
	
	NSArray* selectors = [selector componentsSeparatedByString:@"/"];
	id outputDictionary = rssDictionary;
	NSEnumerator* selectorEnum = [selectors objectEnumerator];
	NSString* newSelector;
	while (newSelector = [selectorEnum nextObject])
	{
		if ([newSelector isEqualToString:@""])
			continue;
		if (![outputDictionary respondsToSelector:@selector(objectForKey:)])	//We might have a plain string here, rather than a dictionary.  Give up if we can't bury into the dictionary any further.
			break;
		outputDictionary = [outputDictionary objectForKey:newSelector];
	}
	
	if (!outputDictionary)	//We've probably hit an error.  Just output the entire dictionary.
	{
		outputDictionary = rssDictionary;
	}
	
	if (forceArrays)	//Wrap the object in an array if required
	{
		if (![outputDictionary isKindOfClass:[NSArray class]])
		{
			outputDictionary = [NSArray arrayWithObject:outputDictionary];
		}
	}

	[outputContent setValue:outputDictionary];
	[outputReady setBooleanValue:YES];
	
	
	[self stateUpdated];
}
	
@end