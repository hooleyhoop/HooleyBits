//
//  SimpleNote.h
//  SenorStaff Hack
//
//  Created by Steven Hooley on 6/21/09.
//  Copyright 2009 Bestbefore. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Simple note doesn't have a duration
@interface SimpleNote : NSObject <NSCoding> {

	CGFloat _pitch, _velocity;
}

@property (readonly) CGFloat pitch, velocity;

+ (SimpleNote *)noteWithPitch:(CGFloat)c1 velocity:(CGFloat)c2;

- (id)initWithPitch:(CGFloat)c1 velocity:(CGFloat)c2;

@end
