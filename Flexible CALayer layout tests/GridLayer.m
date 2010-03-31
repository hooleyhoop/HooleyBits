//
//  GridLayer.m
//  Flexible CALayer layout tests
//
//  Created by steve hooley on 20/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "GridLayer.h"
#import "CustomCALayerManager.h"


@implementation GridLayer

- (id)init {
	
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
	
	[super dealloc];
}

- (void)lightOn:(BOOL)flag row:(int)row column:(int)col {

	//-- should have 12 sublayers.. fretlayers
	NSAssert( [[self sublayers] count]==12, @"did we change something?");
	HooleyLayer *fretLayer = [[self sublayers] objectAtIndex:col];
	
	//-- fretlayer has 6 childeren
	NSAssert( [[fretLayer sublayers] count]==6, @"did we change something?");
	HooleyLayer *positionLayer = [[fretLayer sublayers] objectAtIndex:row];
	
	if(flag)
		[positionLayer turnOn];
	else
		[positionLayer turnOff];
}

- (void)setUpGrid {

	self.backgroundColor = CGColorCreateGenericRGB( 0, 0, 0, 1.0 );

	[self setValue:@"proportionalHeight" forKey:@"layerCustomResizeType"];

	// This in theory disabled animations for these properties - does the delagate still get sent actionForLayer?
	NSDictionary *disabledAnimation = [NSDictionary dictionaryWithObjectsAndKeys: [NSNull null], @"bounds", [NSNull null], @"position", [NSNull null], @"cornerRadius", nil]; 
	self.actions = disabledAnimation;
	
	CGColorRef fretColor = CGColorCreateGenericRGB( 1, 1, 1, 0.5 ); // leaking?
	CGColorRef stringColor = CGColorCreateGenericRGB( 1, 1, 1, 0.6 ); // leaking?

 //   CGRect gridFrame = self.frame;
    CGRect gridBounds = self.bounds;

	CGFloat neckBorder = gridBounds.size.height / 16.0;
	CGFloat desiredWidth = gridBounds.size.width - (neckBorder*2);
	CGFloat desiredHeight = gridBounds.size.height - (neckBorder*2);
	CGFloat fretWireWidth = neckBorder / 0.76;
	
	CGFloat totalWidthOfRow = desiredWidth - (11*fretWireWidth);

	float fretWidth = totalWidthOfRow/12.0;
	float fretHeight = desiredHeight;

	float x=neckBorder, y=neckBorder;

	HooleyLayer* fretLayer;
	
	for(int i=0; i<12; i++){

		fretLayer = [HooleyLayer layer];

		fretLayer.delegate = self.delegate;
		[fretLayer setValue:@"myCustomLayerTypeName" forKey:@"layerCustomResizeType"];
		fretLayer.name = [NSString stringWithFormat:@"fret-%i", i];
		[fretLayer setLayoutManager: self.layoutManager];
		[fretLayer sizeToUnitSize: CGSizeMake( fretWidth, fretHeight) of: gridBounds];
		[fretLayer cornerRadiusToUnitRadius:fretWidth/10.0 of: gridBounds];
		fretLayer.anchorPoint = CGPointMake( 0.0, 0.0 );
		fretLayer.backgroundColor = fretColor;
		// fretLayer.shadowOffset = CGSizeMake( 3, -3 );
		// fretLayer.shadowOpacity = 0.6;
		[fretLayer positionToUnitPosition: CGPointMake( x, y ) of: gridBounds];
		fretLayer.actions = disabledAnimation;	

		CGRect fretBounds = fretLayer.bounds;

		HooleyLayer* fingerPositionLayer;
		CGFloat stringYpos = fretBounds.size.height/7.0;
		for(int j=0; j<6; j++){
			
			fingerPositionLayer = [HooleyLayer layer];
			fingerPositionLayer.delegate = self.delegate;
			[fingerPositionLayer setValue:@"myCustomLayerTypeName" forKey:@"layerCustomResizeType"];
			fingerPositionLayer.name = [NSString stringWithFormat:@"fret-%i-string-%i", i, j];
			[fingerPositionLayer setLayoutManager: self.layoutManager];
			CGFloat fingerPosWidth = fretBounds.size.width/1.2;
			CGFloat fingerPosHeight = fretBounds.size.height/12.0;
			[fingerPositionLayer sizeToUnitSize: CGSizeMake( fingerPosWidth, fingerPosHeight) of: fretBounds];
			[fingerPositionLayer cornerRadiusToUnitRadius: fingerPosHeight/2 of: fretBounds];
			// fingerPositionLayer.anchorPoint = CGPointMake( 0.0, 0.0 );
			fingerPositionLayer.backgroundColor = stringColor;
			[fingerPositionLayer positionToUnitPosition: CGPointMake( fretBounds.size.width/2.0, stringYpos ) of: fretBounds];
			fingerPositionLayer.actions = disabledAnimation;	
			
			[fretLayer addSublayer: fingerPositionLayer];
			stringYpos = stringYpos +  fretBounds.size.height/7.0;
		}
		
		[self addSublayer: fretLayer];
		x = x + fretWireWidth + fretWidth;
	}
	
	
//	//-- layer 1
//	HooleyLayer* topLeft		= [HooleyLayer layer];
//    topLeft.delegate			= self;
//    topLeft.name				= @"topLeft";
//	x							= midX-edgePadding-fretSize;
//	float y						=  midY+edgePadding;
//	
//	[topLeft setValue:@"myCustomLayerTypeName" forKey:@"layerCustomResizeType"]; 
//	
//	[topLeft sizeToUnitSize: CGSizeMake(10, 10) of: viewFrame];
//    [topLeft cornerRadiusToUnitRadius:2.0 of: viewFrame];
//	
//    topLeft.anchorPoint = CGPointMake( 0.0, 0.0 );
//	[topLeft positionToUnitPosition: CGPointMake( 0, 0 ) of: viewFrame];
//	
//	//   topLeft.autoresizingMask = (kCALayerWidthSizable | kCALayerHeightSizable);
//	//	[topLeft addConstraint: [CAConstraint constraintWithAttribute: kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX scale:0.5 offset:20]];
//	//	[topLeft addConstraint: [CAConstraint constraintWithAttribute: kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX scale:0.9 offset:0]];
//	
//    topLeft.backgroundColor  = CGColorCreateGenericRGB( 1, 0, 0, 0.8 );
//	
//	//    topLeft.contentsGravity  = kCAGravityCenter;
//    topLeft.shadowOffset     = CGSizeMake( 3, -3 );
//    topLeft.shadowOpacity    = 0.6;
//	
//	//-- layer 2
//	HooleyLayer* topRight			= [HooleyLayer layer];
//    topRight.delegate			= self;
//    topRight.name				= @"topRight";
//	x							= midX+edgePadding;
//	y							= midY+edgePadding;
//	
//	[topRight sizeToUnitSize: CGSizeMake(fretSize,fretSize) of: viewFrame];
//    topRight.cornerRadius		= 12.0;
//    topRight.anchorPoint      = CGPointMake( 0.0, 0.0 );
//	[topRight positionToUnitPosition: CGPointMake( x, y ) of: viewFrame];
//	
//	//    topRight.autoresizingMask = (kCALayerWidthSizable | kCALayerHeightSizable);
//    topRight.backgroundColor  = bgColor;
//	//    topRight.contentsGravity  = kCAGravityCenter;
//    topRight.shadowOffset     = CGSizeMake( 3, -3 );
//    topRight.shadowOpacity    = 0.6;
//	
//	//-- layer 3
//	HooleyLayer* bottomLeft			= [HooleyLayer layer];
//    bottomLeft.delegate			= self;
//    bottomLeft.name				= @"bottomLeft";
//	x							= midX-edgePadding-fretSize;
//	y							= midY-edgePadding-fretSize;
//	
//	[bottomLeft sizeToUnitSize: CGSizeMake(fretSize,fretSize) of: viewFrame];
//    bottomLeft.cornerRadius		= 12.0;
//    bottomLeft.anchorPoint      = CGPointMake( 0.0, 0.0 );
//	[bottomLeft positionToUnitPosition: CGPointMake( x, y ) of: viewFrame];
//	
//	//    bottomLeft.autoresizingMask = (kCALayerWidthSizable | kCALayerHeightSizable);
//    bottomLeft.backgroundColor  = bgColor;
//	//    bottomLeft.contentsGravity  = kCAGravityCenter;
//    bottomLeft.shadowOffset     = CGSizeMake( 3, -3 );
//    bottomLeft.shadowOpacity    = 0.6;
//	
//	//-- layer 4
//	HooleyLayer* bottomRight		= [HooleyLayer layer];
//    bottomRight.delegate			= self;
//    bottomRight.name				= @"bottomRight";
//	x								= midX+edgePadding;
//	y								= midY-edgePadding-fretSize;
//	[bottomRight sizeToUnitSize: CGSizeMake(fretSize,fretSize) of: viewFrame];
//	
//    bottomRight.cornerRadius		= 12.0;
//    bottomRight.anchorPoint			= CGPointMake( 0.0, 0.0 );
//	[bottomRight positionToUnitPosition: CGPointMake( x, y ) of: viewFrame];
//	
//	//    bottomRight.autoresizingMask = (kCALayerWidthSizable | kCALayerHeightSizable);
//	//	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX scale:0.5 offset:leftMargin]];
//	
//    bottomRight.backgroundColor		= bgColor;
//	//    bottomRight.contentsGravity  = kCAGravityCenter;
//    bottomRight.shadowOffset		= CGSizeMake( 3, -3 );
//    bottomRight.shadowOpacity		= 0.6;
	
	
	// sub-sub layer
//	HooleyLayer* subLayer			= [HooleyLayer layer];
//    subLayer.delegate				= self;
//    subLayer.name					= @"subLayer";
//	x								= 20;
//	y								= 20;
//	[subLayer sizeToUnitSize: CGSizeMake(20,20) of: bottomRight.frame];
//	
//    subLayer.cornerRadius			= 2.0;
//    subLayer.anchorPoint			= CGPointMake( 0.0, 0.0 );
//	[subLayer positionToUnitPosition: CGPointMake( x, y ) of: bottomRight.frame];
//    subLayer.backgroundColor		= CGColorCreateGenericRGB( 0, 0, 0.5, 0.8 );
//	[bottomRight addSublayer: subLayer];
//	
//	[fretLayer addSublayer: topLeft];
	
	//    [mainLayer addSublayer: topRight];
	//    [mainLayer addSublayer: bottomLeft];
	//    [mainLayer addSublayer: bottomRight];
	
	//	[contentContainer layoutSublayers];
	//	[contentContainer layoutIfNeeded]; 
	
}

@end
