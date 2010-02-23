//
//  PBView.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 11/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PBView.h"
#import "FloorGrid.h"

/*
 *
*/
@implementation PBView

#pragma mark -
#pragma mark class methods

#pragma mark init methods

//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[drawTimer release];
	drawTimer = nil;
	[super dealloc];
}

//=========================================================== 
// - awakeFromNib
//=========================================================== 
- (void)awakeFromNib
{
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
	[defaultCenter addObserver:self selector:@selector(viewDidResize:) name:NSViewFrameDidChangeNotification object:self];
	[defaultCenter addObserver:self selector:@selector(stop:) name:@"gridWillChange" object:self];
	[defaultCenter addObserver:self selector:@selector(start:) name:@"gridDidlChange" object:self];
}

#pragma mark notification methods
//=========================================================== 
// - viewDidResize:
//=========================================================== 
- (void)viewDidResize:(NSNotification *)note
{
    [self reshape];
	[self update];
	[self setTracking];
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - mouseMoved:
//=========================================================== 
- (void)mouseMoved:(NSEvent *)theEvent {
	mousePt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

// - (void)flagsChanged:(NSEvent *)theEvent


#pragma mark action methods
- (IBAction)stop:(id)sender
{
	[drawTimer invalidate];
	[drawTimer release];
	drawTimer = nil;
}

- (IBAction)start:(id)sender
{
	/* basic animation */
	if(!drawTimer)
		drawTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:nil repeats:YES] retain];
}

//=========================================================== 
// - update:
//=========================================================== 
- (void)update {
}

//=========================================================== 
// - reshape
//=========================================================== 
- (void)reshape {
}
- (BOOL)isFlipped
{
	return YES;
}

//=========================================================== 
// - drawRect:
//=========================================================== 
- (void)drawRect:(NSRect)rect {
	
	// draw on anchor point
	[[NSColor whiteColor] set];
	NSFrameRect(rect );
	[[NSColor grayColor] set];
	NSRectFill( rect );
			
	// translate (0,0) to centre of window
	// remember the current graphics state
    [[NSGraphicsContext currentContext] saveGraphicsState];
	
	NSAffineTransform* xform = [NSAffineTransform transform];
	[xform translateXBy:rect.size.width/2.0 yBy:rect.size.height/2.0];
	[xform scaleBy:0.5];
	[xform concat];
		
	[floorGrid drawAtPoint:NSMakePoint(0,0)];
	
    // leave the graphics state as you found it
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

//=========================================================== 
// - animate
//=========================================================== 
- (void)animate
{
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - setTracking
//=========================================================== 
- (void)setTracking
{
	[self removeTrackingRect:trackingRect];
	NSRect b = [self bounds];
	trackingRect = [self addTrackingRect:b owner:self userData:NULL assumeInside:NO];
}

#pragma mark accessor methods
//=========================================================== 
// - acceptsFirstResponder
//=========================================================== 
- (BOOL)acceptsFirstResponder {
	return YES;
}  

//=========================================================== 
// - floorGrid
//=========================================================== 
- (FloorGrid *)floorGrid {
	return floorGrid;
}

- (void)setFloorGrid:(FloorGrid *)value {
	if(value != floorGrid){
		[floorGrid release];
		floorGrid = [value retain];
	}
}

@end
