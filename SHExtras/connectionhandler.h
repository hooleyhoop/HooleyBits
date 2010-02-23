// (C) best before/Anatol Ulrich
#import "imagedownloader.h"

@interface BBIConnectionHandler : NSObject
{
	@private
		NSMutableData* receivedData;
		BBImageDownloader* patch;
		//NSURLResponse* _response;
		//NSURLRequest* _request;
}

// constructor
- (id)initWithPatch:(BBImageDownloader*) thePatch request:(NSURLRequest*) request;
//-(void)setConnection:(NSURLConnection*)newConnection;
@end
