//
//  MidiLoader.h
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/23/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SimpleSong;

@interface MidiLoader : NSObject {

	NSData *_midiData;
}

+ (MidiLoader *)midiLoader;
- (void)prepareDefaultFile;
- (void)addDataToSong:(SimpleSong *)aSong;

@end
