//
//  GraphicEqView.m
//  iPhoneFFT
//
//  Created by Steven Hooley on 27/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "GraphicEqView.h"
#import <QuartzCore/QuartzCore.h>

#define NUMBER_OF_BARS 9

#pragma mark  -
// A layer with no magical implicit animations
@interface ExplicitLayer : CALayer
@end
@implementation ExplicitLayer
- (id < CAAction >)actionForKey:(NSString *)aKey {
	return nil;
}
@end

#pragma mark -
@interface GraphicEqView()
- (void)updateForNewLayout;
@end

@implementation GraphicEqView

- (id)initWithCoder:(NSCoder*)coder {

    self = [super initWithCoder:coder];
    if (self) {
		
		srand((int)[NSDate timeIntervalSinceReferenceDate]);

		/* setup spectrograph bars */
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		const float colVals[4] = { 255.0f/255.0f, 0/255.0f, 0/255.0f, 1.0};
		CGColorRef greyColor = CGColorCreate(colorSpace, colVals);
		
		_bars = [[NSMutableArray alloc] init];
		// build the bar layers
		for( NSUInteger i=0; i<NUMBER_OF_BARS; i++ ){
			ExplicitLayer *barLayer = [ExplicitLayer layer];
			[_bars addObject: barLayer];
			
			barLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
			barLayer.backgroundColor = greyColor;
			[barLayer setValue:[NSNumber numberWithInt:i] forKey:@"animationFunction"];
			[barLayer setValue:[NSNumber numberWithInt:i] forKey:@"filterFunction"];
			barLayer.opacity = 1.0f;
			[self.layer addSublayer:barLayer];
		}
		CGColorSpaceRelease(colorSpace);
		CGColorRelease(greyColor);
		
		[self updateForNewLayout];
		
		_animationTimer = [NSTimer scheduledTimerWithTimeInterval:1/18.0 target:self selector:@selector(animationStep) userInfo:nil repeats:YES];		
    }
    return self;
}

- (void)updateForNewLayout {

	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat scale = width/320;
	CGFloat xPos = scale*16.0;
	CGFloat yPos = scale*88.0;
	CGFloat spectraWidth = scale*288;
	CGFloat spectraHeight = scale*264;
	CGFloat barWidth = spectraWidth / NUMBER_OF_BARS;
	NSUInteger i=0;
	for( CALayer *bar in _bars ) {
		bar.bounds = CGRectMake( 0.0f, 0.0f, barWidth, spectraHeight);
		bar.position = CGPointMake( xPos + (i++)*barWidth, yPos );
	}
	_maxBarHeight = spectraHeight;
}

- (void)setFrame:(CGRect)frame {

	[super setFrame:frame];
	[self updateForNewLayout];
}


static CGFloat barHeightFunction( UInt8 functionIndex, CGFloat currentLevel ) {

	const CGFloat powerLevels[] = {1.0, 0.5, 0.4, 0.3, 0.2, 0.3, 0.4, 0.5, 1.0};
	CGFloat newHeight;
	
	if(currentLevel<0.01)
		newHeight = currentLevel;
	else
		newHeight = powf(currentLevel, powerLevels[functionIndex]);
	
	NSCAssert( newHeight>=0 && newHeight<=1.0, @"doh!");
	return newHeight;
}

static CGFloat constrainFunction( CGFloat newHeight, CGFloat leftHeight, CGFloat rightHeight ) {
	
	CGFloat maxHeight = leftHeight>rightHeight ? leftHeight : rightHeight;
	CGFloat minHeight = leftHeight<rightHeight ? leftHeight : rightHeight;
	CGFloat centreHeight = minHeight + (maxHeight-minHeight)/2.0f;
	
	CGFloat distFromCentre = centreHeight - newHeight;
	newHeight = newHeight + distFromCentre /3.0f;
	return newHeight;
}

static CGFloat lowPassFilterFunction( UInt8 functionIndex, CGFloat currentHeight, CGFloat newHeight ) {
	
	const CGFloat lowerLimit = 0.1;
	const CGFloat upperLimit = 0.7;
	const int stepIncrements[] = {1,2,3,4,4,5,4,3,2};
	CGFloat step = (upperLimit-lowerLimit)/(NUMBER_OF_BARS-1.0f);
	// 0.1 is very smooth
	// 0.5 is pretty normal
	// 0.95 is responsives
	CGFloat filterSize = lowerLimit + step*stepIncrements[functionIndex];
	
	return filterSize * newHeight + (1.0-filterSize) * currentHeight;
}

#define RandFlt(min, max) (min + (max - min) * rand() / (float) RAND_MAX)

- (void)animationStep {

//	Float32 audioLevels[2], audioPeakLevels[2];
	// Just discount any chance of stereo recording for now
	Float32 audioLevel, audioPeakLevel;
//	if (audioSource) {
//		[audioSource getAudioLevels:audioLevels peakLevels:audioPeakLevels];
//		audioLevel=audioLevels[0];
//		audioPeakLevel=audioPeakLevels[0];
//	} else {
		audioLevel=RandFlt(0.0, 1.0);
		audioPeakLevel=0.6;
//	}
	
	static int cycleCount = 0;
	
	// every 30 frames cycle 1 to the right
	cycleCount++;
	if(cycleCount==30){
		
		int chosenbar1 = random() % NUMBER_OF_BARS;
		int chosenbar2 = random() % NUMBER_OF_BARS;
		// lets leave the middle bar where it is at the mo
		if(chosenbar1!=4){
			CALayer *barLayer1 = [_bars objectAtIndex:chosenbar1];
			int randomFilterFunction = random() % NUMBER_OF_BARS;
			[barLayer1 setValue:[NSNumber numberWithInt:randomFilterFunction] forKey:@"filterFunction"];
		}
		if(chosenbar2<3 || chosenbar2>5){
			CALayer *barLayer2 = [_bars objectAtIndex:chosenbar2];
			int randomAnimationFunction = random() % NUMBER_OF_BARS;
			[barLayer2 setValue:[NSNumber numberWithInt:randomAnimationFunction] forKey:@"animationFunction"];
		}
		cycleCount = 0;
	}
	
	
	for( int i=0; i<NUMBER_OF_BARS; i++ )
	{
		CALayer *barLayer = [_bars objectAtIndex:i];
		int leftLayerIndex = (i-1)<0 ? NUMBER_OF_BARS-1 : (i-1);
		int rightLayerIndex = (i+1)==NUMBER_OF_BARS ? 0 : i+1;
		CALayer *leftLayer = [_bars objectAtIndex:leftLayerIndex];
		CALayer *rightLayer = [_bars objectAtIndex:rightLayerIndex];
		
		int animationFunction = [[barLayer valueForKey:@"animationFunction"] intValue];
		int filterFunction = [[barLayer valueForKey:@"filterFunction"] intValue];
		
		CGRect currentBounds = barLayer.bounds;
		CGFloat currentHeight = currentBounds.size.height;
		CGFloat newHeight = barHeightFunction( animationFunction, audioLevel );
		/* switch it round so bar is the negative space from the top */
		newHeight = _maxBarHeight*(1.0 - newHeight);
		
		CGFloat filteredHeight = lowPassFilterFunction( filterFunction, currentHeight, newHeight );
		
		/* lets not constrain the middle bars */
		if(i<3 || i>5)
		{
			CGFloat leftHeight = leftLayer.bounds.size.height;
			CGFloat rightHeight = rightLayer.bounds.size.height;
			CGFloat constrainedHeight = constrainFunction( filteredHeight, leftHeight, rightHeight );
			filteredHeight = constrainedHeight;
		}
		currentBounds.size.height = filteredHeight;
		barLayer.bounds = currentBounds;
		

	}
}

@end
