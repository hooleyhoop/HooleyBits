//
//  Layer_key.m
//  iphonePlay
//
//  Created by steve hooley on 17/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "Layer_key.h"
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@implementation Layer_key

@synthesize state=_state;
@synthesize touch=_touch;
@synthesize text=_text;

- (id)init {
	
	self = [super init];
	if(self){
		_state = [@"UP" retain];
	}
	return self;
}

- (void)dealloc {

	[_state release];
	[super dealloc];
}

- (void)drawInContext:(CGContextRef)context {
	
	[super drawInContext:context];
	
	CGRect bnds = CGContextGetClipBoundingBox(context);
	
	CGFloat frontFacePercentage = 0.8f;
	CGFloat newWith = bnds.size.width * frontFacePercentage;
	CGFloat newHeight = bnds.size.height * frontFacePercentage;
	
	CGFloat newXPos=bnds.origin.x+(1.0f-frontFacePercentage)*bnds.size.width;
	CGFloat newYPos=bnds.origin.y+(1.0f-frontFacePercentage)*bnds.size.height;
	CGFloat inset = 0.0f;
	CGFloat colVal = 0.75f;
	
	if([_state isEqual:@"UP"]){
		inset = 7.0f;		
	} else {
		// move the key if it is down
		newXPos=newXPos-3;
		newYPos=newYPos-3;
		colVal = 1.0f;
		inset = 2.0f;
	}
	
	// draw side1 of the key
//	CGContextMoveToPoint( context, 0,0);
//	CGContextAddLineToPoint( context, newXPos, newYPos);
//	CGContextAddLineToPoint( context, newXPos, newYPos+newHeight);
//	CGContextAddLineToPoint( context, 0, newHeight);
//	CGContextClosePath(context);
//	CGContextSetRGBFillColor( context, 0.5f,  0.5f,  0.5f, 1.0f );
//	CGContextFillPath(context);

	// draw side2 of the key
//	CGContextMoveToPoint( context, 0,0);
//	CGContextAddLineToPoint( context, newXPos, newYPos);
//	CGContextAddLineToPoint( context, newXPos+newWith, newYPos);
//	CGContextAddLineToPoint( context, newWith, 0);
//	CGContextClosePath(context);
//	CGContextSetRGBFillColor( context, 0.8f,  0.5f,  0.5f, 1.0f );
//	CGContextFillPath(context);
	
	// draw the top of the key
	CGRect insetRect = CGRectMake( newXPos, newYPos, newWith, newHeight);
	CGRect insetRect2 = CGRectInset(bnds, inset, inset);

	CGContextSetRGBFillColor( context, colVal,  colVal,  colVal, 1.0f );
//	CGContextFillRect(context, insetRect);
	
	// draw a circle
	CGContextFillEllipseInRect(context, insetRect2);
	
	
	// draw the text
	CGAffineTransform flip = CGAffineTransformMakeScale(1.0f, -1.0f);
	CGContextSetTextMatrix(context, flip);
	CGContextTranslateCTM(context, 2.0f, 11.0f);
	CGFloat yPos = 0;
	
	CGContextSelectFont(context, "HelveticaNeue", 11.f, kCGEncodingMacRoman);
	CGContextSetRGBFillColor( context, 0.5f,  0.5f,  0.5f, 1.0f );
	
	CGContextShowTextAtPoint(context, 0.0f, yPos, [_text UTF8String], [_text length]);
}


@end
