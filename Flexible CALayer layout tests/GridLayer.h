//
//  GridLayer.h
//  Flexible CALayer layout tests
//
//  Created by steve hooley on 20/08/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HooleyLayer.h"

@class CustomCALayerManager;

@interface GridLayer : HooleyLayer {


}


- (void)setUpGrid;
- (void)lightOn:(BOOL)flag row:(int)row column:(int)col;

@end
