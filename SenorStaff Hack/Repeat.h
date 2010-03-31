//
//  Repeat.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/12/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Song;

@interface Repeat : NSObject {
	Song *song;
	int startMeasure, endMeasure, numRepeats;

	IBOutlet NSView *countPanel;
	IBOutlet NSTextField *countText;
	IBOutlet NSStepper *countStep;
}

- (id) initWithSong:(Song *)_song;

- (int) startMeasure;
- (int) endMeasure;
- (int) numRepeats;

- (void) setStartMeasure:(int)_startMeasure;
- (void) setEndMeasure:(int)_endMeasure;
- (void) setNumRepeats:(int)_numRepeats;

- (BOOL)isShowingCountPanel;
- (NSView *)getCountPanel;
- (void)updateCountPanel;

- (IBAction)countChanged:(id)sender;
- (IBAction)countClose:(id)sender;

@end
