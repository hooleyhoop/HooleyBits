//
//  SHFlickrDownloader.m
//  SHExtras
//
//  Created by Steven Hooley on 17/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHFlickrDownloader.h"
// #import "OFDemoAPIKey.h"
#define	flickrKey					@"6466789a8c499453eb2cb0788f178667"
#define	SharedSecret				@"f7668af795ecf467"
#define	kQCPlugIn_Name				@"SHFlickrDownloader"
#define	kQCPlugIn_Description		@"Get Flickr photos"

/*
 * SHFlickrDownloader
*/
@implementation SHFlickrDownloader


//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	
	context = [[OFFlickrContext contextWithAPIKey:flickrKey sharedSecret:SharedSecret] retain];
	invoc = [[OFFlickrInvocation invocationWithContext:context delegate:self] retain];
	[self setLastLookUpString:@""];
	_lookUpIsBusy = NO;
	[outputReady setBooleanValue:NO];
	_lastInputMaxReturn = -999;
	
	return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc 
{
	[context release];
	[invoc release];
	[self setLastLookUpString:nil];
	
	context = nil;
	invoc = nil;
    [super dealloc];
}	
// 0:0 - GREEN	-- executes when asked, and an input has changed
// 0:1 - GREEN	-- executes when asked
// 0:2 - GREEN	-- executes when asked, and an input has changed

// 1:0 - PINK	-- executes when input changes, when added to the stage
// 1:1 - PINK	-- executes a lot
// 1:2 - PINK	-- executes when inputs changed

// 2:0 - BLUE	-- executes slowly when asked
// 2:1 - BLUE	-- executes slowly when asked
// 2:2 - BLUE	-- executes when something changes and we have been asked

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
// - allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

@end

/*
 * SHFlickrDownloader
*/
@implementation SHFlickrDownloader (Execution)

//=========================================================== 
// - executionMode:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	// state.. input hasnt changed.. -- not in lookup -- do not to do anything
	// state.. input has changed.. not in lookup -- need to lookup
	// state.. input has changed.. in lookup -- need to scrap lookup and do new lookop
	NSLog(@"SHFlickrDownloader.m: execute");

	/* has the search string changed? */
	if([inputSearchString stringValue]!=_lastLookUpString)
	{
		if(_lookUpIsBusy)
		{
			/* cancel current lookup */
			NSLog(@"SHFlickrDownloader.m: ERROR trying to start a new search while old is in progress!");
		}
		
		/* start a new lookup */
		[self startSearch:self];
		return YES;
		// return NO;
	}
	
	/* has the number of values to return changed? */
	if([inputMaxReturn indexValue]!=_lastInputMaxReturn)
	{
		_lastInputMaxReturn = [inputMaxReturn indexValue];
	//	[self updateOutputList];
	}
	return YES;
}

//=========================================================== 
// - startSearch:
//=========================================================== 
- (void)startSearch:(id)sender
{
	NSLog(@"SHFlickrDownloader.m: starting a new search!");

	// we convert the search string into percent-escaped string
	NSString *srchstr = [[inputSearchString stringValue] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];	
	if ([srchstr isEqualToString:@""]) 
		return;
	// [progressIndicator startAnimation:self];
	[outputReady setBooleanValue:NO];
	[self setLastLookUpString:[inputSearchString stringValue]];
	_lookUpIsBusy = YES;
	[invoc flickr_photos_search:nil text:srchstr selector:@selector(handleSearch:errorCode:data:)];
}

//=========================================================== 
// - handleSearch:
//=========================================================== 
- (void)handleSearch:(id)userinfo errorCode:(int)errorcode data:(id)data
{
	// [progressIndicator stopAnimation:self];
	
	// error handler
	if (errorcode) {
		NSString *title = [NSString stringWithFormat:@"%@ (code %d)", 
			errorcode < 0 ? @"Connection error" : @"Flickr Error", errorcode];
		// NSRunAlertPanel(title, [data description], @"Start a new search", nil, nil);
		NSLog(@"ERROR: %@, %@",title, [data description]);
		return;
	}

	id outputArray = [NSMutableArray arrayWithCapacity:[inputMaxReturn indexValue]];
	
	// get our photos
	NSArray *photos = [[data flickrDictionaryFromDocument] valueForKeyPath:@"photos.photo"];
	// NSMutableString *code = [NSMutableString string];

	if ([photos isKindOfClass:[NSArray class]]) {
		unsigned i, c = [photos count];		
		for (i = 0; i < c; i++) {
			// now we combine the photos
			NSString *url=[context photoURLFromDictionary:[photos objectAtIndex:i] size:@"o" type:nil];
			// [code appendString:[NSString stringWithFormat:@"<img src=\"%@\" />", url]];
			[outputArray addObject:url];
		}
	}
	else {
		// [code appendString:@"No photos found!"];
		NSLog(@"ERROR! No Photos found!");
	}
	[outputStructure setValue:outputArray];
	[outputReady setBooleanValue:YES];
	
	_lookUpIsBusy = NO;
}

//=========================================================== 
// - setLastLookUpString:
//=========================================================== 
- (void) setLastLookUpString:(NSString*) aString {
    //NSLog(@"in -setAbsolutePath:, old value of _absolutePath: %@, changed to: %@", _absolutePath, anAbsolutePath);
    if (_lastLookUpString != aString) {
        [aString retain];
        [_lastLookUpString release];
        _lastLookUpString = aString;
    }
}

@end
