//
//  HooAudioStreamer.h
//  ActorKitTest
//
//  Created by steve hooley on 18/06/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HooAudioStreamer : NSObject {

	NSURL *_url;
}

- (id)initWithURL:(NSURL *)newURL;
- (void)start;
- (void)stop;

@end
