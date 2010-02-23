// (C) best before/Anatol Ulrich

/* image downloader plus
	- actually emits a done signal even if cache is used
	- also writes images to configurable directory for offline usage
	- can detect network failure
*/
#import "imagedownloader.h"
#import "connectionhandler.h"
#include <unistd.h>

/* ports:
    QCStringPort *inputUrl;
	QCStringPort *inputSavePath;
    QCNumberPort *inputMemCacheSizeMB;
	QCNumberPort *inputDiskCacheSizeMB;
	QCGLImagePort *outputImage;
    QCBooleanPort *outputDone;
    QCBooleanPort *outputNetworkFailure;
*/

@implementation BBImageDownloader : QCPatch

static NSString* cacheDir = nil;

+ (int)executionMode
{
	return 3; // "I am a Generator"
}

+ (BOOL)allowsSubpatches
{
	return FALSE;
}

- (id)setup:(id)p
{
	if (cacheDir == nil)
	{
		NSString* millicentDir = [@"~/Library/Caches/Millicent/" stringByExpandingTildeInPath];
		BOOL isDir;
		BOOL error = false;
		if (![[NSFileManager defaultManager] fileExistsAtPath:millicentDir isDirectory:&isDir] || !isDir)
		{
			if (![[NSFileManager defaultManager] createDirectoryAtPath:millicentDir attributes:nil])
				error = true;
		}
		cacheDir = [[millicentDir stringByAppendingPathComponent:@"Images"] retain];
		if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir isDirectory:&isDir] || !isDir)
		{
			if (![[NSFileManager defaultManager] createDirectoryAtPath:cacheDir attributes:nil])
				error = true;
		}
		if (error)
			NSRunAlertPanel(@"Couldn't create directory",[NSString stringWithFormat:@"Couldn't create image cache directory at %@", cacheDir],@"OK",nil,nil);
	}
		

	// initialize variables
	urlToProcess = [[NSMutableString alloc] init];
	[urlToProcess setString:[inputUrl stringValue]];
	emitDone = FALSE;
	fileCounter = 0;
	
	connections = [[NSMutableArray alloc] init];
	
	[outputNetworkFailure setBooleanValue: FALSE];

	// setup shared cache
	long memCacheSizeBytes = 40*1024*1024;
	long diskCacheSizeBytes = 80*1024*1024;

	NSString* tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"BBImageDownloader"];
	NSURLCache* cache = [[NSURLCache alloc] initWithMemoryCapacity:memCacheSizeBytes diskCapacity:diskCacheSizeBytes diskPath:tempDir];
	[NSURLCache setSharedURLCache:cache];
	[cache release];
	
	imageLock = [[NSLock alloc] init];
	
	[outputBackupPath setStringValue:cacheDir];
	
	return p;
}

#import <OpenGL/gl.h>

- (BOOL)execute:(QCOpenGLContext*)openGLcontext time:(double)currentTime arguments:(id)args
{
	//NSConnection needs to be run in the right runloop.  Schedule it on the main thread:
	[self performSelectorOnMainThread:@selector(_retrieve) withObject:nil waitUntilDone:NO];
	
	if (emitDone) {
		[imageLock lock];
		[outputImage setValue:image];
		[imageLock unlock];
		[outputDone setBooleanValue:TRUE];
		emitDone = FALSE;
		[self performSelectorOnMainThread:@selector(makeStateUpdate) withObject:nil waitUntilDone:NO];
		return TRUE;	
	}
	[outputDone setBooleanValue:FALSE];
	return TRUE;
}


-(void)makeStateUpdate
{
	[self performSelector:@selector(stateUpdated) withObject:nil afterDelay:0.05];
}


-(void)dealloc {
	// release resources
	[image release];
	image = nil;
	[imageLock release];
	imageLock = nil;
	[urlToProcess release];
	urlToProcess = nil;
	NSLog(@"Image downloader : Dropping connections");
	nsenumerat(connections, connection)
	{
		[connection cancel];
	}
	[connections release];
	connections = nil;
	[super dealloc];
}

// download or fetch from cache
- (void) _retrieve
{
	// TODO: variable from [inputUrl stringValue]
	if ([urlToProcess isEqualToString:[inputUrl stringValue]]) {return;}
	NSURL* url = [NSURL URLWithString:[inputUrl stringValue]];
	
	// use 5 seconds as timeout interval - TODO: this does not seem to work?
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
	
	BOOL requestOkay = [NSURLConnection canHandleRequest:request];
	// bail out if the request can not be fulfilled anyway
	if (!requestOkay) {return;}
	
	[urlToProcess setString:[inputUrl stringValue]];
	
	NSCachedURLResponse* response = [[NSURLCache sharedURLCache] cachedResponseForRequest: request];

	if (response) {
		// cache hit somehow means the network is alright
		[outputNetworkFailure setBooleanValue:FALSE];
		NSImage* newImage = [[NSImage alloc] initWithData:[response data]];
		[self setImage:newImage fromConnection:nil];
		[newImage release];
	}
	else {
		BBIConnectionHandler* newConnectionHandler = [[BBIConnectionHandler alloc] initWithPatch:self request:request];
		NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:newConnectionHandler];	//Bizarrely, this retains its delegate.  Rely on that to keep our handler alive.
//		[newConnectionHandler setConnection:connection];
		[connections addObject:connection];
		[newConnectionHandler release];
		
		if (!connection) {
			NSLog(@"could not create a connection");
			// internet connection unavailable -> network failure
			[self setNetworkFailStatus:TRUE];
		}
	}
}


// read port value and convert from MBytes to bytes
- (long) _bytesizeFromMBPort: (QCNumberPort*) port {
	return lroundf([port doubleValue]*1024*1024);
}

// image setter
-(void)setImage:(NSImage*) newImage fromConnection:(NSURLConnection*)connection {
	[imageLock lock];
	// release old image, if any
	[image release];
	image = [newImage retain];
	// image setting indicates the download has finished or cache hit -> send done signal
	emitDone = TRUE;
	[self stateUpdated];
	[imageLock unlock];
	
	[connections removeObject:connection];
}

// network status setter

- (void) setNetworkFailStatus:(BOOL) status {
	[outputNetworkFailure setBooleanValue:status];
	[self stateUpdated];
}

- (void) replaceIn:(NSMutableString*) string src:(NSString*)src dst:(NSString*)dst
{
	[string replaceOccurrencesOfString:src withString:dst options:NSLiteralSearch range:NSMakeRange(0, [string length])];
}

- (NSURL*) downloadLocation {
	// create a unique filename - this clobbers the filesystem
	// NSURL* url = [NSURL URLWithString:[NSString stringWithFormat: @"file:///%@/%f_%d.jpg", [inputSavePath stringValue], CFAbsoluteTimeGetCurrent(), fileCounter]];
	// fileCounter += 1;
	
	// cowardly refuse to accept empty target directories
	
	// create a filename that is prone to overwriting
	NSURL* sourceUrl = [NSURL URLWithString:urlToProcess];
	[urlToProcess setString: [inputUrl stringValue]];
	
	NSMutableString* path = [[NSMutableString alloc] init];
	[path appendString:[sourceUrl host]];
	[path appendString:[sourceUrl path]];
	
	// TODO: I'd rather have a whitelist ...
	[self replaceIn: path src:@"/" dst:@"_"];
	[self replaceIn: path src:@"\\" dst:@""];
	
	NSURL* url = [NSURL fileURLWithPath: [cacheDir stringByAppendingPathComponent:path]];
	
	NSLog(@"Writing to %@", url);
	
	[path release];
	return url;
}

@end