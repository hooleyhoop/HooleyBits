//
//  TempoData.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/2/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TempoData.h"
// #import "StaffHorizontalRulerComponent.h"

@implementation TempoData

- (float)tempo {
	return _tempo;
}

- (void)setTempo:(float)tempo {
    
	[[[_song undoManager] prepareWithInvocationTarget:self] setTempo:_tempo];
	_tempo = tempo;
	if(_tempo == 0)
        _tempo = -1;
//	[self refreshTempo];
}

//- (BOOL) empty{
//	return tempo < 0;
//}

- (id)initWithTempo:(float)tempo withSong:(Song *)song {
    
	if((self = [super init])){
		_song = song;
		_tempo = tempo;
	}
	return self;
}

- (id)initEmptyWithSong:(Song *)song {
    
	if((self = [super init])){
		_song = song;
		_tempo = -1;
	}
	return self;
}

//- (NSView *)tempoPanel{
//	return tempoPanel;
//}

//- (void)refreshTempo { 
//	if(tempo > 0){
//		[tempoText setFloatValue:tempo];
//		[tempoPanel setShouldFade:NO];
//		[tempoPanel setHidden:NO];
//	} else{
//		[tempoText setStringValue:@""];
//		[tempoPanel setShouldFade:YES];
//	}
//}

//- (void) removePanel{
//	[tempoPanel removeFromSuperview];
//}
//
//- (IBAction)tempoChanged:(id)sender{
//	[[song undoManager] setActionName:@"changing tempo"];
//	[self setTempo:[sender floatValue]];
//}
//
//- (void)encodeWithCoder:(NSCoder *)coder{
//	[coder encodeObject:song forKey:@"song"];
//	[coder encodeFloat:tempo forKey:@"tempo"];
//}
//
//- (id)initWithCoder:(NSCoder *)coder{
//	if(self = [super init]){
//		song = [coder decodeObjectForKey:@"song"];
//		[self setTempo:[coder decodeFloatForKey:@"tempo"]];
//	}
//	return self;
//}

@end
