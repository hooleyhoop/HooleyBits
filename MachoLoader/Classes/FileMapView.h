//
//  FileMapView.h
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileMapView : NSView {

	NSMutableArray *_beziers;
	CGFloat _ypos;
	NSUInteger _totalSize;
}

+ (FileMapView *)sharedMapView;

- (void)setTotalBoundsWithSize:(NSUInteger)size label:(NSString *)labelString;
- (void)addRegionAtOffset:(NSUInteger)offset withSize:(NSUInteger)size label:(NSString *)labelString;

@end
