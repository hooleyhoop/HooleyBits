//
//  RSSReader.h
//  RSSGrabber
//
//  Created by Jonathan del Strother on 01/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RSSReader : NSObject {
	id delegate;

	NSMutableArray* xmlElements;	//Stack of our WIP xml elements.
	
	NSDictionary* xmlDictionary;	//The complete xml as a dictionary
	
	NSURL* url;	//URL from which our XML was formed

	NSLock* dispatcherLock;
	BOOL dispatcherIsBusy;
	
	NSURLConnection* downloadConnection;
	NSMutableData* receivedData;
}
-(id)initWithURL:(NSURL*)newUrl delegate:(id)aDelegate;
-(id)initWithDelegate:(id)aDelegate;

-(NSDictionary*)xmlDictionary;
-(void)setURL:(NSURL*)newUrl;
-(void)requestData;

-(void)closeConnection;	//Make sure to call this when our delegate gets removed.  Can't rely on the release mechanism to do so for us.
@end


//Not very private here, but it needs to be visible for the other RSSReader categories.
@interface RSSReader (privateMethods)
-(void)setErrorMessage:(NSString*)error;
-(void)setDictionaryContents:(NSDictionary*)dictionary;
@end

@interface NSObject(RSSReader_Delegate)
-(void)readerWasUpdated:(RSSReader*)reader;
@end