//
//  ViewController.m
//  CALayerLayout
//
//  Created by steve hooley on 14/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CALayerRootView.h"
#import "HooleyLayer.h"
#import "CustomCALayerManager.h"
#import "GridLayer.h"
#import <FScript/FScript.h>

//Explicit Animations
//CABasicAnimation *animation = [CABasicAnimation animation];
//[animation setToValue:[NSNumber numberWithBool:NO]];
//
//CABasicAnimation *animation = [CABasicAnimation animation];
//[animation setRemovedOnCompletion:NO];
//[animation setFillMode:kCAFillModeForwards];
//[animation setDelegate:self];
//
//- (void)animationDidStop:(CABasicAnimation *)theAnimation finished:(BOOL)flag
//{
//	CALayer *layer = [testView layer];
//	NSString *path = [theAnimation keyPath];
//	[layer setValue:[theAnimation toValue] forKeyPath:path];
//	[layer removeAnimationForKey:path];
//}

@implementation ViewController

#warning gravity is where the layer will sit when its bounds are lrger than parent layer - a bit like overflow
- (id)init {
	
    self = [super init];
    if (self) {
		_myCustomLayoutManager = [[CustomCALayerManager alloc] init];
		_onLayers = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc {
	
	[_onLayers release];
	[_myCustomLayoutManager release];
	[super dealloc];
}

- (void)awakeFromNib {

	/* load FScript */
	[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];
	
	[_rootView configureMainView];
	
    CALayer* mainLayer = _rootView.layer;
	[mainLayer setLayoutManager: _myCustomLayoutManager];
	[mainLayer setValue:@"mainLayer" forKey:@"name"];

	CGRect parentBounds = mainLayer.bounds;

	// bounds x, y are always zero (unlike frame) so his just take width/2
	CGFloat midX = CGRectGetMidX( parentBounds );
    CGFloat midY = CGRectGetMidY( parentBounds );
	
	GridLayer *gridLayer = [GridLayer layer];

	[gridLayer setLayoutManager: _myCustomLayoutManager];

	CGFloat desiredWidth = parentBounds.size.width * 0.8;
	CGFloat desiredHeight = desiredWidth / 12.0;
	[gridLayer sizeToUnitSize: CGSizeMake(desiredWidth, desiredHeight) of:parentBounds];	
	[gridLayer positionToUnitPosition: CGPointMake( midX, midY ) of: parentBounds];
	[gridLayer setValue:@"gridLayer" forKey:@"name"];
	[gridLayer setDelegate:self];
	[gridLayer setUpGrid];
	
	[mainLayer addSublayer: gridLayer];
	[gridLayer lightOn:YES row:2 column:2];
	
    // causes the layer content to be drawn in -drawRect:
    [mainLayer setNeedsDisplay];	
}

- (void)hitLayer:(HooleyLayer *)aLayer {
	
	BOOL alreadyOn = [_onLayers containsObject:aLayer];
	if(alreadyOn==NO){
		
		[_onLayers makeObjectsPerformSelector:@selector(turnOff)];
		[_onLayers removeAllObjects];
		[aLayer turnOn];
		[_onLayers addObject:aLayer];
	}
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
	
//	NSString *name = [layer valueForKey:@"name"];
//	NSLog(@"EVent is %@ on layer %@", event, name);

//	if ([event isEqualToString:@"bounds"] && [[layer valueForKey:@"layerCustomResizeType"] isEqualToString:@"myCustomLayerTypeName"]  ) 
//	{ 
//		// disable animation for new layers being added to container layer 
//		return (id<CAAction>)[NSNull null]; 
//	} else if ([event isEqualToString:@"position"] && [[layer valueForKey:@"layerCustomResizeType"] isEqualToString:@"myCustomLayerTypeName"] ) {
//		return (id<CAAction>)[NSNull null]; 
//	}
	
	// for everything else, use default animation. note that 
	// nil means "default animation" in this case, not "no animation". 
	return nil; 
} 


@end