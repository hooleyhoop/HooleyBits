//
//  NeckViewControl.h
//  MidiInLoop
//
//  Created by steve hooley on 13/09/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NeckView;

@interface NeckViewControl : NSObject {

    IBOutlet NeckView    *_neckView;
}

@property (assign) NeckView *neckView;

- (void)noteOnSrting:(int)string fret:(int)pos withVelocity:(int)vel;

@end
