//
//  SpectraView.m
//  AudioQueueFilePlayer
//
//  Created by steve hooley on 04/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "SpectraView.h"
#import "AudioQueueFilePlayerAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpectraView

@synthesize animationInterval;

- (id)initWithCoder:(NSCoder*)coder
{
	if((self = [super initWithCoder:coder]))
	{
		animationInterval = 0.0f;
		
		// build the bar layers
		for( int i=0; i<NUMBER_OF_BARS; i++ ){
			bars[i] = [[CALayer layer] retain];
		}
	}	
	return self;
}

- (void)dealloc {
	
	[self stopAnimation];
	for( int i=0; i<NUMBER_OF_BARS; i++ ){
		CALayer *barLayer = bars[i];
		[barLayer release];
	}
    [super dealloc];
}

- (void)awakeFromNib {
	
}

static Float32 barWidth = 28;
static Float32 barHeight = 262.0;

- (void)setupLayers {
	
	CGColorRef col1 = CGColorCreateGenericRGB( 230.0f/255.0f, 227.0f/255.0f, 223.0f/255.0f, 1.0f);
	
	CALayer *rootLayer = self.layer;
	NSAssert(rootLayer, @"wha?");
	
	// lets add a solid background
	CALayer *baffleLayer = [CALayer layer];
	baffleLayer.anchorPoint = CGPointMake(0.0f, 1.0f);
	baffleLayer.bounds = CGRectMake( 0.0f, 0.0f, 320.0f, 367.0f );
	baffleLayer.position = CGPointMake( 0, self.frame.size.height-49);
	UIImage *myImage = [UIImage imageNamed:@"recording_backgraound.png"];
	baffleLayer.contents = (id)myImage.CGImage;
	[rootLayer insertSublayer:baffleLayer atIndex:0];
	

	CALayer *spectoBackgroundLayer = [CALayer layer];
	spectoBackgroundLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
	spectoBackgroundLayer.bounds = CGRectMake( 0.0f, 0.0f, 296.0f, 272.0f );
	spectoBackgroundLayer.position = CGPointMake( 11, 125 );
	UIImage *myImage2 = [UIImage imageNamed:@"colourfill.png"];
	spectoBackgroundLayer.contents = (id)myImage2.CGImage;
	[rootLayer addSublayer:spectoBackgroundLayer];
	
	barWidth = 286.0f         / NUMBER_OF_BARS;
	
	/* setup spectrograph bars */
	CGFloat xPos = 17;
	CGFloat yPos = 130;
	
	for( int i=0; i<NUMBER_OF_BARS; i++ )
	{
		CALayer *barLayer = bars[i];
		barLayer.delegate = self;
		barLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
		barLayer.bounds = CGRectMake( 0.0f, 0.0f, barWidth, 0 );
		barLayer.backgroundColor = col1;
		barLayer.position = CGPointMake( xPos + i*barWidth, yPos );
		[rootLayer addSublayer:barLayer];
		[barLayer setValue:[NSNumber numberWithInt:i] forKey:@"animationFunction"];
		[barLayer setValue:[NSNumber numberWithInt:i] forKey:@"filterFunction"];
	}
	
	// baffle goes infront
	[rootLayer addSublayer:baffleLayer];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

CGFloat barHeightFunction( UInt8 functionIndex, CGFloat currentHeight, CGFloat currentLevel, CGFloat peakLevel ) {
	
	CGFloat newHeight=0.0f;
	
	if(currentLevel<0.01)
		newHeight = barHeight * currentLevel;
	else {
	/* calculate a new height based on currentLevel or peakLevel or both */
	switch (functionIndex) {
		case 0:
			newHeight = barHeight * currentLevel;
			break;
		case 1:
			newHeight = barHeight * powf(currentLevel, 0.5f);
			break;
		case 2:
			newHeight = barHeight * powf(currentLevel, 0.4f);
			break;
		case 3:
			newHeight = barHeight * powf(currentLevel, 0.3f); // sqrt(audioPeakLevel) is powf(audioLevel, 0.5) -- 0.1 is more extreme
			break;
		case 4:
			/* This is the middle bar */
			newHeight = barHeight * powf(currentLevel, 0.2); // emphasise smaller values with a curve

			break;
		case 5:
			newHeight = barHeight * powf(currentLevel, 0.3f); // sqrt(audioPeakLevel) is powf(audioLevel, 0.5) -- 0.1 is more extreme
			break;
		case 6:
			newHeight = barHeight * powf(currentLevel, 0.4f); // sqrt(audioPeakLevel) is powf(audioLevel, 0.5) -- try putting different values in for different curves
			break;
		case 7:
			newHeight = barHeight * powf(currentLevel, 0.5f);
			break;
		case 8:
			newHeight = barHeight * currentLevel;
			break;
		default:
			[NSException raise:@"should we get here?" format:@"yay"];
	}
	}
	NSCAssert( newHeight>0 && newHeight<=barHeight, @"doh!");
	
	/* switch it round so bar sis the negatisve space from the top */
	newHeight = barHeight - newHeight;
	
	return newHeight;
}

CGFloat lowPassFilterFunction( UInt8 functionIndex, CGFloat currentHeight, CGFloat newHeight ) {
	
	CGFloat filterSize=0.95f, filteredHeight=0.0f;
	static CGFloat lowerLimit = 0.1;
	static CGFloat upperLimit = 0.7;
	CGFloat step = (upperLimit-lowerLimit)/(NUMBER_OF_BARS-1.0f);
	// 0.1 is very smooth
	// 0.5 is pretty normal
	// 0.95 is responsives
	
	// lower number is smoother
	
	/* calculate a new height based on currentLevel or peakLevel or both */
	switch (functionIndex) {
		case 0:
			filterSize = lowerLimit + 1*step;
			break;
		case 1:
			filterSize = lowerLimit + 2*step;
			break;
		case 2:
			filterSize = lowerLimit + 3*step;
			break;
		case 3:
			filterSize = lowerLimit + 4*step;
			break;
		case 4:
			/* middle bar - quite responsive */
			filterSize = lowerLimit + 5*step;
			break;
		case 5:
			filterSize = lowerLimit + 5*step;
			break;
		case 6:
			filterSize = lowerLimit + 4*step;
			break;
		case 7:
			filterSize = lowerLimit + 3*step;
			break;
		case 8:
			filterSize = lowerLimit + 2*step;
			//NSCAssert( filterSize==upperLimit, @"doh");
			break;
		default:
			[NSException raise:@"should we get here?" format:@"yay"];
	}
	filteredHeight = filterSize * newHeight + (1.0f-filterSize) * currentHeight;
	return filteredHeight;
}


CGFloat constrainFunction( CGFloat newHeight, CGFloat leftHeight, CGFloat rightHeight ) {
	
	CGFloat maxHeight = leftHeight>rightHeight ? leftHeight : rightHeight;
	CGFloat minHeight = leftHeight<rightHeight ? leftHeight : rightHeight;
	CGFloat centreHeight = minHeight + (maxHeight-minHeight)/2.0f;
	
	CGFloat distFromCentre = centreHeight - newHeight;
	newHeight = newHeight + distFromCentre /3.0f;
	return newHeight;
}

- (void)animationStep
{
	Float32 audioLevel, audioPeakLevel;
	[(AudioQueueFilePlayerAppDelegate *)[[UIApplication sharedApplication] delegate] getAudioLevel:&audioLevel peakLevel:&audioPeakLevel];

	static int cycleCount = 0;
	
	// every 20 frames cycle 1 to the right
	cycleCount++;
	if(cycleCount==30){
		
		int chosenbar1 = (int)((float)random() / RAND_MAX * NUMBER_OF_BARS);
		int chosenbar2 = (int)((float)random() / RAND_MAX * NUMBER_OF_BARS);
		NSAssert(chosenbar2>=0 && chosenbar2<NUMBER_OF_BARS, @"fucked up random choice thing");
		// lets leave the middle bar where it is at the mo
		if(chosenbar1!=4){
			CALayer *barLayer1 = bars[chosenbar1];
			int randomFilterFunction = (int)((float)random() / RAND_MAX * NUMBER_OF_BARS);
			[barLayer1 setValue:[NSNumber numberWithInt:randomFilterFunction] forKey:@"filterFunction"];
		}
		if(chosenbar2!=3 || chosenbar2!=4 || chosenbar2!=5){
			CALayer *barLayer2 = bars[chosenbar2];
			int randomAnimationFunction = (int)((float)random() / RAND_MAX * NUMBER_OF_BARS);
			[barLayer2 setValue:[NSNumber numberWithInt:randomAnimationFunction] forKey:@"animationFunction"];
		}
		cycleCount = 0;
	}
	
	
	for( int i=0; i<NUMBER_OF_BARS; i++ )
	{
		CALayer *barLayer = bars[i];
		int leftLayerIndex = (i-1)<0 ? NUMBER_OF_BARS-1 : (i-1);
		int rightLayerIndex = (i+1)==NUMBER_OF_BARS ? 0 : i+1;
		CALayer *leftLayer = bars[leftLayerIndex];
		CALayer *rightLayer = bars[rightLayerIndex];
		
		int animationFunction = [[barLayer valueForKey:@"animationFunction"] intValue];
		int filterFunction = [[barLayer valueForKey:@"filterFunction"] intValue];
		
		CGRect currentBounds = barLayer.bounds;
		CGFloat currentHeight = currentBounds.size.height;
		CGFloat newHeight = barHeightFunction( animationFunction, currentHeight, audioLevel, audioPeakLevel );
		
		CGFloat filteredHeight = lowPassFilterFunction( filterFunction, currentHeight, newHeight );
		
		/* lets not constrain the middle bar */
		if(i!=3 || i!=4 || i!=5)
		{
			CGFloat leftHeight = leftLayer.bounds.size.height;
			CGFloat rightHeight = rightLayer.bounds.size.height;
			CGFloat constrainedHight = constrainFunction( filteredHeight, leftHeight, rightHeight );
			filteredHeight = constrainedHight;
		}
		currentBounds.size.height = filteredHeight;
		barLayer.bounds = currentBounds;
	}
	//	NSLog(@" -- ");
}

- (void)startAnimation
{	
	[animationTimer invalidate];
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(animationStep) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}

- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	if(animationTimer)
	{
		[self stopAnimation];
		[self startAnimation];
	}
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey :(NSString *)key
{
	return (id)[NSNull null];
}

@end
