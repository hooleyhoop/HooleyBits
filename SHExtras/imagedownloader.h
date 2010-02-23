// (C) best before/Anatol Ulrich

#import "QCClasses.h"
#import "Foundation/NSURL.h"
#import "Foundation/NSURLConnection.h"
#import "AppKit/NSImage.h"

@class BBIConnectionHandler;

@interface BBImageDownloader : QCPatch
{
    QCStringPort *inputUrl;
	QCGLImagePort *outputImage;
    QCBooleanPort *outputDone;
    QCBooleanPort *outputNetworkFailure;
    QCStringPort *outputBackupPath;
	@private
		NSImage* image;
		NSLock* imageLock;
		NSMutableString* urlToProcess;
		NSMutableArray* connections;
		BOOL downloadPending;
		BOOL emitDone;
		int fileCounter;		
}

// misc public methods
- (NSURL*) downloadLocation;
- (void) setNetworkFailStatus:(BOOL) status;
-(void)setImage:(NSImage*)newImage fromConnection:(NSURLConnection*)connection;

// private
- (void) _retrieve;
- (long) _bytesizeFromMBPort: (QCNumberPort*) port;


@end