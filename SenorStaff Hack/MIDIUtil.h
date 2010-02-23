//
//  MIDIUtil.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 3/25/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
@class Song, SimpleSong;

@interface MIDIUtil : NSObject {

}

//+ (NSData *)writeSequenceToData:(MusicSequence)seq;

+ (void)parseMidiData:(NSData *)data intoSong:(SimpleSong *)song;

+ (void)readSong:(SimpleSong *)song fromMIDI:(NSData *)data;

@end
