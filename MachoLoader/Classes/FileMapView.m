//
//  FileMapView.m
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "FileMapView.h"

static FileMapView *sharedMapView;

@implementation FileMapView

+ (FileMapView *)sharedMapView {
	return sharedMapView;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_beziers = [[NSMutableArray array] retain];
 //       [self addRegionWithSize:100 label:@"1- chicken"];
 //       [self addRegionWithSize:200 label:@"2- rabbit"];
 //       [self addRegionWithSize:300 label:@"3- cow"];
//        [self addRegionWithSize:100 label:@"4- sheep"];
	
		_ypos = 30;
		sharedMapView = self;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	for(NSBezierPath *eachPath in _beziers){
		[[NSColor colorWithDeviceRed: 1.0f green: 0.0f blue: 0.7f alpha: 0.8f] set];
		[eachPath fill];
	}
}

- (void)setTotalBoundsWithSize:(NSUInteger)size label:(NSString *)labelString {
	_totalSize = size;
	[self addRegionAtOffset:0 withSize:_totalSize label:labelString];
}

- (void)addRegionAtOffset:(NSUInteger)offset withSize:(NSUInteger)size label:(NSString *)labelString {

	CGFloat percentageSize = ((size*1.0)/_totalSize) *self.frame.size.width;
	CGFloat percentageOffset = ((offset*1.0)/_totalSize) *self.frame.size.width;

	NSUInteger numberOfRegions = [_beziers count];

	NSTextField *labelText = [[[NSTextField alloc] initWithFrame:NSMakeRect(10+percentageOffset, _ypos, 200, 33)] autorelease];
	[labelText setStringValue:labelString];
	[labelText setBackgroundColor:[NSColor clearColor]];
	[labelText setBezeled:NO];
	[labelText setBordered:NO];
	[labelText setDrawsBackground:NO];
	[labelText setSelectable:NO];
	[labelText setFont:[NSFont labelFontOfSize:9]];
	[self addSubview:labelText];

	_ypos = _ypos+10;
	
	[[NSColor colorWithDeviceRed: 1.0f green: 0.0f blue: 0.7f alpha: 0.8f] set];
	NSBezierPath *linePath = [NSBezierPath bezierPathWithRect:NSMakeRect(10+percentageOffset, _ypos, percentageSize, 5)];
	[_beziers addObject:linePath];
	
	_ypos = _ypos+10;
}

- (BOOL)isFlipped {
	return YES;
}

@end
