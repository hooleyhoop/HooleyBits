//
//  Layer_key.h
//  iphonePlay
//
//  Created by steve hooley on 17/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Layer_Base.h"

@class HooleyTouchEvent;


@interface Layer_key : Layer_Base {

	NSString *_state;
	HooleyTouchEvent *_touch;
	NSString *_text;
}

@property (copy) NSString *state;
@property (retain) HooleyTouchEvent *touch;
@property (retain) NSString *text;

@end
