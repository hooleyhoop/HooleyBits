//
//  SHPhotoshopImport.m
//  SHExtras
//
//  Created by Steven Hooley on 20/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHPhotoshopImport.h"
#import "SHPhotoshopImportUI.h"
#import "SHPhotoshopFileStuff.h"

/*
 *
*/
@implementation SHPhotoshopImport

#pragma mark class methods
//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode {
	return 0;
}

//=========================================================== 
// - timeMode:
//=========================================================== 
+ (int)timeMode {
	return 0;
}

//=========================================================== 
// - inspectorClassWithIdentifier:
//=========================================================== 
+ (Class)inspectorClassWithIdentifier:(id)fp8 {
	return [SHPhotoshopImportUI class];
}

//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	_currentPort=0;
	_outImagePorts = [[NSMutableArray arrayWithCapacity:3] retain];
	_outPosPorts = [[NSMutableArray arrayWithCapacity:3] retain];
	
	/* add inputs */
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: [QCStringPort class], @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name",@"inputURL", @"description",@"local filepath to photoshop file", nil], @"attributes", nil];
	_inputURLPort = [[self createInputPortWithArguments:arguments forKey:@"inputURL"] retain];
	
	arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: [QCBooleanPort class], @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name",@"embedImages", @"description",@"embed the images in the quartz file", nil], @"attributes", nil];
	_embedImagesPort = [[self createInputPortWithArguments:arguments forKey:@"embedImages"] retain];

	arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: [QCBooleanPort class], @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name",@"cropLayers", @"description",@"crop the layers to their actual size", nil], @"attributes", nil];
	_cropLayersPort = [[self createInputPortWithArguments:arguments forKey:@"cropLayers"] retain];
	
	/* add outputs */
	arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: [QCStringPort class], @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name",@"currentURL", @"description",@"the file we are actually using at the moment", nil], @"attributes", nil];
	_currentURLPort= [[self createOutputPortWithArguments:arguments forKey:@"currentURL"] retain];
	
	/* observer the inputport so we know if the user has edited the value from the inspector */
	[_inputURLPort addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];

	return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc 
{
	[_outImagePorts release];
	[_outPosPorts release];
	[_inputURLPort release];
	[_currentURLPort release];
	[_embedImagesPort release];
	[_cropLayersPort release];
	
	_outPosPorts = nil;
	_cropLayersPort = nil;
	_embedImagesPort = nil;
	_inputURLPort = nil;
	_currentURLPort = nil;
	_outImagePorts = nil;
	[super dealloc];
}


#pragma mark notifications
//=========================================================== 
// - observeValueForKeyPath: ofObject change context
//=========================================================== 
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"SHPhotoshopImport: CurrentNodeGroup Changed !!!!!!!!!!!!!!!!!!!!! %@", keyPath);
	if ([keyPath isEqual:@"value"])
	{
		// could it be a relative URL?
		NSString *fullPath, *enteredpath = [_inputURLPort stringValue];
		
		// CFURLRef newUrl = CFURLCreateWithFileSystemPath( kCFAllocatorDefault, [_inputURLPort stringValue], kCFURLPOSIXPathStyle, NO );
		NSURL* newUrl = [NSURL fileURLWithPath:enteredpath];
		if([[NSFileManager defaultManager] fileExistsAtPath:[newUrl path]]==YES)
		{
			fullPath = enteredpath;
		} else {
			/* find the path of our quartz file */
			NSDocument* doc; 
			NSArray* allWindows = [[NSApplication sharedApplication] windows];
			NSEnumerator *enumerator1 = [allWindows objectEnumerator];
			id window;
			while ((window = [enumerator1 nextObject])) {
				doc = [window document];
				if(doc) break;
			}
			if(doc){
				NSString* fName = [doc fileName];
				if(fName){
					fullPath = [[fName stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
					fullPath = [fullPath stringByAppendingString:enteredpath];
					newUrl = [NSURL fileURLWithPath:fullPath];
				}
			}
		}
		NSLog(@"SHPhotoshopImport: new url is %@", newUrl);
		[self setURL:newUrl];
	}
}

#pragma mark action methods
//=========================================================== 
// - execute
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	NSLog(@"photoshop import executing!");
	return YES;
}

//=========================================================== 
// - addImage: atPoint:
//=========================================================== 
- (void) addImage:(id)image atPoint:(NSArray*)aPt
{
	// NSLog(@"SHPhotoshopImport: adding image.. %@", image);
	/* reuse ports.. */
	id imagePort, posPort;
	int count = [_outImagePorts count];
	if(_currentPort>=count)
	{
		imagePort = [self addOutputPort:[QCGLImagePort class] description:@"an image"];
		[_outImagePorts addObject:imagePort];
		if([_cropLayersPort booleanValue]==YES)
		{
			posPort = [self addOutputPort:[QCStructurePort class] description:@"image position"];
			[_outPosPorts addObject:posPort];
		}
		_currentPort = [_outImagePorts count]; /* this should be the same unless something ahas gone wrong, but what the hell */
	} else {
		imagePort = [_outImagePorts objectAtIndex:_currentPort];
		if([_cropLayersPort booleanValue]==YES)
			posPort = [_outPosPorts objectAtIndex:_currentPort];
	}
	[imagePort setValue:image];
	if([_cropLayersPort booleanValue]==YES)
		[posPort setValue:[NSDictionary dictionaryWithObjects:aPt forKeys:[NSArray arrayWithObjects:@"x",@"y",nil]]];

	_currentPort++;
}

//=========================================================== 
// - addOutputPort
//=========================================================== 
- (id) addOutputPort:(Class)aClass description:(NSString*)aDesc
{
	NSString* name;
	int count = [_outImagePorts count];
	if(aClass==[QCGLImagePort class])
		name = [NSString stringWithFormat:@"layer_%i", count];
	else if(aClass==[QCStructurePort class])
		name = [NSString stringWithFormat:@"position_%i", count-1];
	
	NSDictionary* arguments = [NSMutableDictionary dictionaryWithObjectsAndKeys: aClass, @"class", [NSDictionary dictionaryWithObjectsAndKeys: @"name", name, @"description", aDesc, nil], @"attributes", nil];
	id port = [self createOutputPortWithArguments:arguments forKey:name];
	return port;
}

//=========================================================== 
// - removeOutputPort:
//=========================================================== 
- (void) removeOutputPort 
{
	if ([_outImagePorts count] < 1) return;
	id imPort = [_outImagePorts lastObject];
	[self deleteOutputPortForKey:[self keyForPort:imPort]];
	[_outImagePorts removeLastObject];

	if([_cropLayersPort booleanValue]==YES)
	{
		id posPort = [_outPosPorts lastObject];
		[self deleteOutputPortForKey:[self keyForPort:posPort]];
		[_outPosPorts removeLastObject];
	}
}


#pragma mark accessor methods
//=========================================================== 
// - setURL
//=========================================================== 
- (void) setURL:(NSURL*)url
{
	NSLog(@"import URL %@", url);
	BOOL directoryFlag;
	if([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&directoryFlag] && directoryFlag==NO)
	// see if the url is valid photoshop file
	{
		// see if file or directory
		NSLog(@"import path %@", [url path]);

		_currentPort=0;
		[SHPhotoshopFileStuff openImageURL:url patch:self shouldCrop:[_cropLayersPort booleanValue]];
		
		// if there are more ports than loaded remove them.
		int i, count = [_outImagePorts count];
		for(i=_currentPort;i<count;i++)
		{
			[self removeOutputPort];
		}
		[self _setNeedsExecution];
		[_inputURLPort setStringValue:[url path]]; // infinite loop?
		[_currentURLPort setStringValue:[url path]];
		
		/* set the preview image in the inspector */
		SHPhotoshopImportUI* gui = [[self nodeActorForView:nil] inspectorForPatch:self];
		NSImage* previewImage = [[[NSImage alloc] initByReferencingFile:[url path]] autorelease];
		[gui setImageViewContent:previewImage];
		
	} else {
		// file not found...
	}
}


//=========================================================== 
// - setState
//=========================================================== 
- (BOOL)setState:(id)state 
{
	[super setState: state];

	/* set inputs - except inputURL - inputURL overides embeded images */
	BOOL embedImagesPortValue = [[state valueForKey:@"embedImagesPort"] boolValue];
	BOOL cropLayersPortValue = [[state valueForKey:@"cropLayersPort"] boolValue];

	[_embedImagesPort setBooleanValue:embedImagesPortValue];
	[_cropLayersPort setBooleanValue:cropLayersPortValue];
	
	/* set outputs */

	/* restore saved image ports from quartz file */
	int i, count = [[state valueForKey:@"numberOfOutputs"] intValue];
	_currentPort=0;
	for(i=0;i<count;i++)
	{
		if([_embedImagesPort booleanValue]==YES)
		{
			/* unarchive the stored images */
			NSData* imageData = [state valueForKey:[NSString stringWithFormat:@"image%i", i]];
			NSData* positionData = [state valueForKey:[NSString stringWithFormat:@"position%i", i]];
			id unArchivedImage = [NSKeyedUnarchiver unarchiveObjectWithData:imageData];
			id unArchivedPosition = nil;
			if([_cropLayersPort booleanValue]==YES)
				unArchivedPosition = [NSKeyedUnarchiver unarchiveObjectWithData:positionData];
			[self addImage:unArchivedImage atPoint:unArchivedPosition];
		} else {
			/* just add empty image ports so that we dont lose our links */
			// maybe we are making a copy?
			NSNumber* xPos=[NSNumber numberWithInt:0];
			NSNumber* yPos=[NSNumber numberWithInt:0];
			[self addImage:nil atPoint:[NSArray arrayWithObjects:xPos,yPos, nil]];
		}
	}
	
	/* set inputURL */
	NSString* inputURLPortValue = [state valueForKey:@"inputURLPort"];
	_currentPort=0;

	[_inputURLPort setStringValue:inputURLPortValue];

	return TRUE;
}

//=========================================================== 
// - state
//=========================================================== 
// return the number of desired ports along with super's state so we can restore needed ports when reloading
- (id)state 
{
	/* we must fill out this for user added ports */
	NSMutableDictionary* state = [super state];

	/* inputs */
	[state setValue:[_inputURLPort stringValue] forKey:@"inputURLPort"];
	[state setValue:[NSNumber numberWithBool:[_embedImagesPort booleanValue]] forKey:@"embedImagesPort"];
	[state setValue:[NSNumber numberWithBool:[_cropLayersPort booleanValue]] forKey:@"cropLayersPort"];

	/* outputs */
	[state setValue:[NSNumber numberWithInt:[_outImagePorts count]] forKey:@"numberOfOutputs"];

	if([_embedImagesPort booleanValue]==YES)
	{
		/* restore embeded images from quartz file */
		int i, count=[_outImagePorts count]; 
		for(i=0;i<count;i++)
		{
			QCGLImagePort* aImagePort = [_outImagePorts objectAtIndex:i];
			// NSString *imageName = [[aPort attributes] valueForKey:@"name"];
			NSData *imageData = [NSKeyedArchiver archivedDataWithRootObject:[aImagePort imageValue]]; // QCGLCGImage
			// [state setValue:imageName forKey:[NSString stringWithFormat:@"imageName%i", i]];
			[state setValue:imageData forKey:[NSString stringWithFormat:@"image%i", i]];
			
			if([_cropLayersPort booleanValue]==YES)
			{
				QCStructurePort* aPosPort = [_outPosPorts objectAtIndex:i];
				NSData *positionData = [NSKeyedArchiver archivedDataWithRootObject:[aPosPort structureValue]]; // QCGLCGImage
				[state setValue:positionData forKey:[NSString stringWithFormat:@"position%i", i]];
			}
		}
	}	
	return state;
}


@end
