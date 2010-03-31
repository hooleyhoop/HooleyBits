//
//  NeckViewControl.m
//  MidiInLoop
//
//  Created by steve hooley on 13/09/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NeckViewControl.h"
#import "NeckView.h"
#import <FScript/FScript.h>
#import "AGMsgFilter.h"

@implementation NeckViewControl

@synthesize neckView = _neckView;


- (void)awakeFromNib {
    
	/* load FScript */
//[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];
    
    [AGMsgFilter setNeckViewController:self];
}

- (void)noteOnSrting:(int)string fret:(int)pos withVelocity:(int)vel {
    
}

@end
