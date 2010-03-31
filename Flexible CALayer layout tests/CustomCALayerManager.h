//
//  CustomCALayerManager.h
//  Flexible CALayer layout tests
//
//  Created by steve hooley on 19/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface CustomCALayerManager : NSObject {

}

/* Called when the preferred size of 'layer' may have changed. The
 * receiver is responsible for recomputing the preferred size and
 * returning it. */

- (CGSize)preferredSizeOfLayer:(CALayer *)layer;

/* Called when the preferred size of 'layer' may have changed. The
 * receiver should invalidate any cached state. */

- (void)invalidateLayoutOfLayer:(CALayer *)layer;

/* Called when the sublayers of 'layer' may need rearranging (e.g. if
 * something changed size). The receiver is responsible for changing
 * the frame of each sublayer that needs a new layout. */

- (void)layoutSublayersOfLayer:(CALayer *)layer;

@end
