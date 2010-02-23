// (C) best before/Anatol Ulrich

#import "connectionhandler.h"

@interface BBIConnectionHandler (private)
- (void) _saveData;
@end

@implementation BBIConnectionHandler : NSObject

- (id) initWithPatch:(BBImageDownloader*) thePatch request:(NSURLRequest*) request{
	if (![super init])
		return nil;
		
	patch = thePatch;
	
	receivedData = [[NSMutableData alloc] init];
	
	//_request = request;
	return self;
}

-(void)dealloc
{
	[receivedData release];
//	NSLog(@"Cancelling connection %@", connection);
//	[connection cancel];
//	[connection release];
	[super dealloc];
}
//
//-(void)setConnection:(NSURLConnection*)newConnection
//{
//	[connection autorelease];
//	connection = [newConnection retain];
//	NSLog(@"New connection %@", connection);
//}


// cancel redirects
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	[connection cancel];
	return nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
 
    // it can be called multiple times, for example in the case of a 
    // redirect, so each time we reset the data.
    [receivedData setLength:0];
	
	// store the response to put it into the cache later
	//_response = response;
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{	
    // release the data object
    [receivedData release];
	receivedData = nil;
 
    // inform the user
    NSLog(@"Connection failed, Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	// network failure - set failure flag and empty image
	[patch setNetworkFailStatus:TRUE];
	[patch setImage:nil fromConnection:connection];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    // NSLog(@"done - Received %d bytes of data",[receivedData length]);
	// successful download means the network is alright
	[patch setNetworkFailStatus:FALSE];
	
	// write data to disk
	[self _saveData];
	
	// store response in cache - does not seem to help against the ~96k file size limit, so I'm leaving it out
	/*
	NSCachedURLResponse* cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:_response data:receivedData];
	NSURLCache* cache = [NSURLCache sharedURLCache];
	NSLog(@"is this the right cache? %d", [cache memoryCapacity]);
	[cache storeCachedResponse:cachedResponse forRequest:_request];
	*/
	
	// data to image
	NSImage* newImage = [[NSImage alloc] initWithData:receivedData];
 	[patch setImage:newImage fromConnection:connection];
	[newImage release];
	
    [patch stateUpdated];
    // release the data object
    [receivedData release];
	receivedData = nil;
}

- (void) _saveData {
	// TODO: exception handling
	NSURL* target = [patch downloadLocation];
	if (target != nil) {
		[receivedData writeToURL: target atomically:NO];
	}
}

@end