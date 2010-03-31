//
//  RSSReader.m
//  RSSGrabber
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "RSSReader.h"
#import "Logger.h"


@implementation RSSReader


-(id)initWithURL:(NSURL*)newUrl delegate:(id)aDelegate
{
	if (![super init])
	{
		[self release];
		return nil;
	}

	[self setURL:newUrl];
	delegate = aDelegate;
	dispatcherLock = [[NSLock alloc] init];
	
	return self;
}

-(id)initWithDelegate:(id)aDelegate
{
	return [self initWithURL:nil delegate:aDelegate];
}

-(void)dealloc
{
	[self closeConnection];
	[url release];
	[xmlElements release];
	[xmlDictionary release];
	[receivedData release];
	[dispatcherLock release];
	[super dealloc];
}


-(NSString*)description
{
	return [NSString stringWithFormat:@"%@\n===\n%@",url,[self xmlDictionary]];
}

-(NSDictionary*)xmlDictionary
{
	return xmlDictionary;
}


-(void)setURL:(NSURL*)newUrl
{
	if (url == newUrl)
		return;
		
	[url release];
	url = [newUrl retain];
}

-(void)setDictionaryContents:(NSDictionary*)dictionary
{
	if (dictionary == xmlDictionary)
		return;
		
	[xmlDictionary release];
	xmlDictionary = [dictionary retain];
}

-(void)setErrorMessage:(NSString*)error
{
	[self setDictionaryContents:[NSDictionary dictionaryWithObject:error forKey:@"Error"]];
	[delegate readerWasUpdated:self];
	[[Logger sharedLogger] logXMLError:error];
}

-(void)parseData:(NSData*)urlData
{
	NSStringEncoding encoding = NSUTF8StringEncoding;
	NSString* stringRep = [[NSString alloc] initWithData:urlData encoding:encoding];
	[stringRep release];
	
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:urlData];
	if (!parser)
	{
		[self setErrorMessage:[NSString stringWithFormat:@"Couldn't create XML parser from %@", url]];
		return;
	}

	[parser setDelegate:self];
	
	[parser parse];
	
	[parser release];
	
	[delegate readerWasUpdated:self];
}

-(void)dispatchRequest:(NSURLRequest*)request
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	if (downloadConnection != nil)
	{
		NSLog(@"Connection is already busy.  Why are we here?");
	}
	else
	{
		downloadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
		BOOL finished = NO;
		//Cycle the runloop a few times.  Eventually, connectionDidFinishLoading: will set downloadConnection to nil,
		// at which point we're done and can exit this thread.
		do
		{
			[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
			finished = (downloadConnection == nil);
		} while (!finished);
	}
		
	[dispatcherLock lock];
	dispatcherIsBusy = NO;
	[dispatcherLock unlock];
	
	[pool release];
}

-(void)requestData
{
	[self setDictionaryContents:nil];
	
	if ([url isFileURL])
	{
		NSData* urlData = [NSData dataWithContentsOfURL:url];
		
		if (!urlData)
		{
			[self setErrorMessage:[NSString stringWithFormat:@"No file at %@", url]];
			return;
		}
		[self parseData:urlData];
	}
	else
	{
		[dispatcherLock lock];		
		if (dispatcherIsBusy)
		{
			[dispatcherLock unlock];
			return; 
		}
		[dispatcherLock unlock];
		
		//Specify the url connections manually, otherwise we get stuck with stupid 60 second timeouts
		NSURLRequest* downloadRequest = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData/*NSURLRequestUseProtocolCachePolicy*/ timeoutInterval:10] autorelease];
		if (![NSURLConnection canHandleRequest:downloadRequest])
		{
			[self setErrorMessage:[NSString stringWithFormat:@"URL %@ isn't valid", url]];
			return;
		}
		
		[receivedData release];
		receivedData = [[NSMutableData alloc] init];
		
		//For quicktime, we need the request to be dispatched on a new runloop or the replies will get lost.
		[dispatcherLock lock];
		dispatcherIsBusy = YES;
		[dispatcherLock unlock];
		[NSThread detachNewThreadSelector:@selector(dispatchRequest:) toTarget:self withObject:downloadRequest];
	}
}

-(void)closeConnection
{
	[downloadConnection cancel];
	[downloadConnection release];
	downloadConnection = nil;
}


#pragma mark Delegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self setErrorMessage:[error localizedDescription]];
	[self closeConnection];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([(NSHTTPURLResponse*)response statusCode] == 404)
	{
		[self setErrorMessage:[NSString stringWithFormat:@"%@ doesn't exist", url]];
		[self closeConnection];	
	}	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if ([receivedData length]==0)
	{
		[self setErrorMessage:[NSString stringWithFormat:@"Nothing downloaded for %@", url]];
	}
	else
	{
		[self parseData:[[receivedData copy] autorelease]];
	}
		
	[self closeConnection];
}

@end
