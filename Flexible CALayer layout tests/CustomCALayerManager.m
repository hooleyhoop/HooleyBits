//
//  CustomCALayerManager.m
//  Flexible CALayer layout tests
//
//  Created by steve hooley on 19/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "CustomCALayerManager.h"
#import "HooleyLayer.h"

@implementation CustomCALayerManager

/* Called when the preferred size of 'layer' may have changed. The
 * receiver is responsible for recomputing the preferred size and
 * returning it. */

- (CGSize)preferredSizeOfLayer:(CALayer *)layer {

	if( [layer isKindOfClass:[HooleyLayer class]] && [[layer valueForKey:@"layerCustomResizeType"] isEqualToString:@"proportionalHeight"]  ) 
	{ 
		// work out width from unit width
		HooleyLayer *hLayer = (HooleyLayer *)layer;
		CGSize sizeFromUnitSize = [hLayer sizeForParentFrame: layer.superlayer.bounds];

		// use this width & set height proportionally
		sizeFromUnitSize.height = hLayer.unitSize.height * (sizeFromUnitSize.width / hLayer.unitSize.width );
		return sizeFromUnitSize;
		
	} else if ([[layer valueForKey:@"layerCustomResizeType"] isEqualToString:@"myCustomLayerTypeName"]  ) 
	{ 
//		NSString *name = [layer valueForKey:@"name"];
//		NSLog(@"preferredSize %@", name);
	}
	return layer.bounds.size;
}

/* Called when the preferred size of 'layer' may have changed. The
 * receiver should invalidate any cached state. */

- (void)invalidateLayoutOfLayer:(CALayer *)layer {
	
	if ([[layer valueForKey:@"layerCustomResizeType"] isEqualToString:@"myCustomLayerTypeName"]  ) 
	{
//		NSString *name = [layer valueForKey:@"name"];
//		NSLog(@"Invalidate %@", name);
	}
}

/* Called when the sublayers of 'layer' may need rearranging (e.g. if
 * something changed size). The receiver is responsible for changing
 * the frame of each sublayer that needs a new layout. */

- (void)layoutSublayersOfLayer:(CALayer *)parentLayer {
	
//	NSString *name = [parentLayer valueForKey:@"name"];
	CGRect newSuperBounds = parentLayer.bounds;

	HooleyLayer *eachLayer;
	id subLyrs = [parentLayer sublayers];

	for( eachLayer in subLyrs )
	{
		if ([[eachLayer valueForKey:@"layerCustomResizeType"] isEqualToString:@"proportionalHeight"]  ) 
		{
			CGRect bnds = eachLayer.bounds;
			CGSize prefSiz = [self preferredSizeOfLayer: eachLayer];
			bnds.size = prefSiz;
			eachLayer.bounds = bnds;
			
			[eachLayer updatePositionForFrame: parentLayer.bounds];

		} else if ([[eachLayer valueForKey:@"layerCustomResizeType"] isEqualToString:@"myCustomLayerTypeName"]  ) 
		{ 
			
			// this is one way to do it - i dont think i would really need this ubit sizing stuff to do this tho
			/* stretch layers to fill */
			[eachLayer updatePositionForFrame: newSuperBounds];
			[eachLayer updateSizeForFrame: newSuperBounds];
			[eachLayer updateRadiusForFrame: newSuperBounds];	
		}
	}
}

@end
