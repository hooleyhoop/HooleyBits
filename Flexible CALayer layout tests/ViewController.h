//
//  ViewController.h
//  CALayerLayout
//
//  Created by steve hooley on 14/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CALayerRootView, HooleyLayer, CustomCALayerManager;
@interface ViewController : NSObject {

	IBOutlet CALayerRootView	*_rootView;
	NSMutableArray				*_onLayers;
	CustomCALayerManager		*_myCustomLayoutManager;

}

- (void)hitLayer:(HooleyLayer *)aLayer;

@end
