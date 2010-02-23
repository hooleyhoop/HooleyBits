//
//  GridLayer.m
//  MidiInLoop
//
//  Created by steve hooley on 15/09/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "GridLayer.h"

static CGColorRef colColor;
static float colComponent = 0.0;

@implementation GridLayer

- (id)init {
	
	self=[super init];
	if(self){
		
		colColor = CGColorCreateGenericRGB( 1.0, 0.0, 1.0, 1.0 );
		CGColorRef backgroundColor = CGColorCreateGenericRGB( 0.2, 1.0, 0.2, 1.0 );
		self.backgroundColor = backgroundColor;
		CGColorRelease( backgroundColor );

		self.borderWidth = 1.33;
		self.shadowOffset = CGSizeMake( 3, -2 );
		self.shadowOpacity = 0.25;
				
		_addColTimer = [[NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(addColumn) userInfo:nil repeats:YES] retain];		
	}
	return self;
}

- (void)dealloc {

	[super dealloc];
}

- (void)addColumn {
	
	CALayer* colLayer = [CALayer layer];
	colLayer.anchorPoint = CGPointMake( 1.0, 0.0 );
	CGColorRef borderCol = CGColorCreateGenericRGB( colComponent, colComponent, colComponent, 1.0 );
	colLayer.backgroundColor = borderCol;
	self.borderWidth = 1.33;
	colLayer.borderColor = borderCol;
	CGColorRelease( borderCol );
	colComponent = colComponent +0.1;
	colLayer.name = @"itemLayer";

	if([[self sublayers] count]>0){
		CALayer *previousLayer = [[self sublayers] lastObject];
		CGRect bnds = previousLayer.bounds;
		CGPoint pt = previousLayer.position;
		pt.x = previousLayer.position.x + bnds.size.width;
		colLayer.position = pt;
		bnds.size.width = 0;
		colLayer.bounds = bnds;
	}
//	[colLayer setHidden:YES];
	colLayer.opacity = 0.0;
	[self addSublayer:colLayer];
	_numberOfCols = _numberOfCols + 1;

//	[colLayer setNeedsDisplay];
}

- (CGSize)preferredSizeOfLayer:(CALayer *)layer {
	return CGSizeMake(100,100);
}

- (void)invalidateLayoutOfLayer:(CALayer *)layer {
	// NSLog(@"Invalidate 2 %@", [layer valueForKey:@"name"] );
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {

	float animDuration = 0.2f;
	[CATransaction begin];
	[CATransaction setValue: [NSNumber numberWithFloat:animDuration] forKey: kCATransactionAnimationDuration];

	CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; // kCAMediaTimingFunctionLinear, kCAMediaTimingFunctionEaseInEaseOut
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
	animation.duration = animDuration;
	animation.timingFunction = timing;	
	animation.removedOnCompletion = YES;

	CGRect parentFrame = layer.frame;
	float widthOfItem = parentFrame.size.width/_numberOfCols;
	
	CALayer *eachLayer;
	NSArray *subLyrs = [layer sublayers];
	for( int i=0; i<[subLyrs count]; i++ )
	{
		eachLayer = [subLyrs objectAtIndex:i];
		CABasicAnimation *animationToAdd = animation;
		float finalX = widthOfItem*i+3;
		float finalY = 0;
		float finalWidth = widthOfItem-6;
		float finalHeight = parentFrame.size.height;

		if(eachLayer.opacity==0.0f){
			
			/* fade up the new layer */
			CABasicAnimation *isHiddenAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
			isHiddenAnimation.duration = animDuration;
			isHiddenAnimation.timingFunction = timing;	
			isHiddenAnimation.removedOnCompletion = YES;
			isHiddenAnimation.fromValue = [NSNumber numberWithFloat:0.0];
			[eachLayer addAnimation:isHiddenAnimation forKey:@"opacity"];
			eachLayer.opacity = 1.0f;
			
			/* custom animation for the initial position */
			CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"bounds"];
			animation2.duration = animDuration;
			animation2.timingFunction = timing;	
			animation2.removedOnCompletion = YES;
			animation2.fromValue = [NSValue valueWithRect:NSMakeRect( finalX+finalWidth, finalY, 0, finalHeight )];
			animationToAdd = animation2;
			
			/* for the custom animation to work we need to move the anchor pt */
			CABasicAnimation *anchorAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
			anchorAnimation.duration = animDuration;
			anchorAnimation.timingFunction = timing;	
			anchorAnimation.removedOnCompletion = YES;
			anchorAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(1.0f, 0.0f)];
			[eachLayer addAnimation:anchorAnimation forKey:@"anchorPoint"];
		} else {
			eachLayer.anchorPoint = CGPointMake( 0.0, 0.0 );
		}
		[eachLayer addAnimation:animationToAdd forKey:@"frame"];

		eachLayer.frame = CGRectMake( finalX, finalY, finalWidth, finalHeight );
	}
	[CATransaction commit];
}

@end
