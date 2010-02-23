//
//  TimeSignature.h
//  Music Editor
//
//  Created by Konstantine Prevas on 6/24/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TimeSignature : NSObject {
    
	int top;
	int bottom;
}

+ (id)timeSignatureWithTop:(int)top bottom:(int)bottom;

- (id)initWithTop:(int)top bottom:(int)bottom;

- (TimeSignature *)getTimeSignatureAfterMeasures:(int)numMeasures;

//-(int)getTop;
//-(int)getBottom;
- (float)getMeasureDuration;

//-(int)getSecondTop;
//-(int)getSecondBottom;
//
//+(NSArray *)asNSNumberArray:(id)sig;
//+(id)fromNSNumberArray:(NSArray *)array;
//
//-(void)addToLilypondString:(NSMutableString *)string;
//- (void)addToMusicXMLString:(NSMutableString *)string;
//
//- (Class)getViewClass;
//- (Class)getControllerClass;

@end
