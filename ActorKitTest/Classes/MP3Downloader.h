//
//  MP3Downloader.h
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MP3Downloader : NSObject {

	BOOL _streamShouldFinish;
}

- (oneway void)downloadURL:(NSURL *)anURL;

@end
