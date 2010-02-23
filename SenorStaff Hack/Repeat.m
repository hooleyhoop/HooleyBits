//
//  Repeat.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 12/12/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "Repeat.h"


@implementation Repeat

- (id) initWithSong:(Song *)_song{
	if(self = [super init]){
		song = _song;
		startMeasure = -1;
		endMeasure = -1;
		numRepeats = 2;
	}
	return self;
}

- (NSUndoManager *) undoManager{
	return [song undoManager];
}

- (void)sendChangeNotification{
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"modelChanged" object:self]];
}

- (int) startMeasure{
	return startMeasure;
}

- (int) endMeasure{
	return endMeasure;
}

- (int) numRepeats{
	return numRepeats;
}

- (void) setStartMeasure:(int)_startMeasure{
	[[[self undoManager] prepareWithInvocationTarget:self] setStartMeasure:startMeasure];
	startMeasure = _startMeasure;
}

- (void) setEndMeasure:(int)_endMeasure{
	[[[self undoManager] prepareWithInvocationTarget:self] setEndMeasure:endMeasure];
	[self countClose:nil];
	endMeasure = _endMeasure;
}

- (void) setNumRepeats:(int)_numRepeats{
	[[[self undoManager] prepareWithInvocationTarget:self] setNumRepeats:numRepeats];
	numRepeats = _numRepeats;
	[self updateCountPanel];
}

- (BOOL)isShowingCountPanel{
	return countPanel != nil && ![countPanel isHidden];
}

- (NSView *)getCountPanel{
	if(countPanel == nil){
		[NSBundle loadNibNamed:@"RepeatCountPanel" owner:self];
		[countPanel setHidden:YES];
	}
	return countPanel;
}

- (void)updateCountPanel{
	[countStep setIntValue:numRepeats];
	[countText setIntValue:numRepeats];
}

- (IBAction)countChanged:(id)sender{
	[[self undoManager] setActionName:@"changing repeat count"];
	int value = [sender intValue];
	if(value < 2) value = 2;
	[countStep setIntValue:value];
	[countText setIntValue:value];
	[self setNumRepeats:value];
	[self sendChangeNotification];
}

- (IBAction)countClose:(id)sender{
	[countPanel setHidden:YES withFade:YES blocking:(sender != nil)];
	if([countPanel superview] != nil){
		[countPanel removeFromSuperview];
	}	
}

- (void)encodeWithCoder:(NSCoder *)coder{
	[coder encodeObject:song forKey:@"song"];
	[coder encodeInt:startMeasure forKey:@"startMeasure"];
	[coder encodeInt:endMeasure forKey:@"endMeasure"];
	[coder encodeInt:numRepeats forKey:@"numRepeats"];
}

- (id)initWithCoder:(NSCoder *)coder{
	song = [coder decodeObjectForKey:@"song"];
	[self setStartMeasure:[coder decodeIntForKey:@"startMeasure"]];
	[self setEndMeasure:[coder decodeIntForKey:@"endMeasure"]];
	[self setNumRepeats:[coder decodeIntForKey:@"numRepeats"]];
	return self;
}

@end
