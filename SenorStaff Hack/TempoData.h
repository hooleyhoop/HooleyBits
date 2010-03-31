//
//  TempoData.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/2/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//@class StaffHorizontalRulerComponent;
@class Song;

@interface TempoData : NSObject { //<NSCoding> {
    
	float _tempo;
//	IBOutlet StaffHorizontalRulerComponent *tempoPanel;
//	IBOutlet NSTextField *tempoText;
    Song *_song;
}

- (float)tempo;
- (void)setTempo:(float)tempo;

//- (BOOL) empty;

- (id)initWithTempo:(float)tempo withSong:(Song *)song;
- (id)initEmptyWithSong:(Song *)song;

//- (NSView *)tempoPanel;
//- (void) removePanel;
//
//- (IBAction)tempoChanged:(id)sender;

@end
