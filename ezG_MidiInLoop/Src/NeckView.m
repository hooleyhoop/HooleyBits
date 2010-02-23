//
//  NeckView.m
//  MidiInLoop
//
//  Created by steve hooley on 13/09/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NeckView.h"
#import "GridLayer.h"
#import <QuartzCore/QuartzCore.h>


@implementation NeckView

- (id)initWithFrame:(NSRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

- (void)awakeFromNib {

	self.wantsLayer = YES;

	self.layer = [CALayer layer];
	CALayer* mainLayer = self.layer;
	//	mainLayer.delegate = self;
	CGColorRef backgroundColor = CGColorCreateGenericRGB( 1, 0.0, 0.0, 0.5 );
	mainLayer.backgroundColor = backgroundColor;
	CGColorRelease( backgroundColor );
	
	_gridLayer = [GridLayer layer];
	[_gridLayer setValue:@"gridLayer" forKey:@"name"];
//	[_gridLayer setDelegate:self];
	_gridLayer.anchorPoint = CGPointMake(0,0);
	//_gridLayer.frame = CGRectMake (10,10,100,100);
	
	CGColorRef borderCol = CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0 );
	mainLayer.borderColor = borderCol;
	CGColorRelease( borderCol );
	
	mainLayer.borderWidth = 10;
	
	mainLayer.layoutManager = self;
	_gridLayer.layoutManager = _gridLayer;
	
	[mainLayer addSublayer: _gridLayer];
	
	[mainLayer setNeedsLayout];
	[mainLayer layoutIfNeeded];
	
	[mainLayer setNeedsDisplay];
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	
	if ([self inLiveResize]==NO){
		[[NSColor redColor] set];
		NSRectFill(rect);	
	} else {
		
	}
}

- (CGSize)preferredSizeOfLayer:(CALayer *)layer {
	if([layer.name isEqualToString:@"gridLayer"])
		return CGSizeMake(self.frame.size.width-48, 16);
	return layer.bounds.size;
}

- (void)invalidateLayoutOfLayer:(CALayer *)layer {
	// NSLog(@"Invalidate 1 %@", [layer valueForKey:@"name"] );
}

/* Called when the sublayers of 'layer' may need rearranging (e.g. if
 * something changed size). The receiver is responsible for changing
 * the frame of each sublayer that needs a new layout. */

- (void)layoutSublayersOfLayer:(CALayer *)layer {
	
	// NSString *name = [layer valueForKey:@"name"];
	// NSLog(@"layout sublayers of %@", name);
	CALayer *eachLayer;
	NSArray *subLyrs = [layer sublayers];
	for( int i=0; i<[subLyrs count]; i++ )
	{
		eachLayer = [subLyrs objectAtIndex:i];
		NSString *eachName = [eachLayer valueForKey:@"name"];
		if([eachName isEqualToString:@"gridLayer"])
		{
			CGRect bnds = eachLayer.bounds;
			bnds.size = [self preferredSizeOfLayer:eachLayer];
			eachLayer.bounds = bnds;
			eachLayer.position = CGPointMake(24, 24);
			[eachLayer setNeedsDisplay];
		}
	}
	[layer setNeedsDisplay];
}

- (void)resizeSubLayersOf:(CALayer *)lyr {
	
	CALayer *eachLayer;
	id subLyrs = [lyr sublayers];
	for( eachLayer in subLyrs ){
		[eachLayer setNeedsLayout];
	}
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	[self resizeSubLayersOf: self.layer];	
}

@end
