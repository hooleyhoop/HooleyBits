//
//  MusicDocument.h
//  Music Editor
//
//  Created by Konstantine Prevas on 5/3/06.
//  Copyright Konstantine Prevas 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
@class Song;


@interface MusicDocument : NSDocument {
    
	Song *_song;
}

@property (retain) Song *song;

@end
