//
//  SHAEKeyframeParse.h
//  SHExtras
//
//  Created by Steven Hooley on 25/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@interface SHAEKeyframeParse : QCPatch {

		int numOutPorts;
		NSMutableDictionary* outPorts;
		
		int aeCompWidth;
		int aeCompHeight;
		NSAttributedString* keyFrameDataString;
		
		int interpolation;
		
//QCNumberPort* inputValue2;
//QCNumberPort* output1;
}

- (int)aeCompWidth;
- (void)setAeCompWidth:(int)value;

- (int)aeCompHeight;
- (void)setAeCompHeight:(int)value;

- (NSAttributedString *)keyFrameDataString;
- (void)setKeyFrameDataString:(NSAttributedString *)value;


@end
