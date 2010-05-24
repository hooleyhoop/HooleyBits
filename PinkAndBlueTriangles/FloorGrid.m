//
//  FloorGrid.m
//  PinkAndBlueTriangles
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FloorGrid.h"
#import "GridCell.h"
#import "PBCamera.h"
#import "Engine.h"
#import <OpenGL/CGLMacro.h>
#import <OpenGL/gl.h>

// GLOBAL
extern CGLContextObj cgl_ctx; // defined in the view

@interface FloorGrid (Private)

- (BOOL)testEdges:(NSRect)edges againstClip:(NSRect)bounds cellSize:(int)unitSize;;
- (void)drawBackingQuad;

@end

/*
 *
*/
@implementation FloorGrid

#pragma mark -
#pragma mark class methods

#pragma mark init methods


- (id)init {

	return [self initWithSize:500 divisions:10];
}

- (id)initWithSize:(int)aValue divisions:(int)divs {
	
	self = [super init];
	if(self) 
	{
		_rows = divs; 
		_columns = divs;
		[self setBoundsSize:aValue];
		[self setCellSz: (unsigned)(aValue/divs)];
			
		/* 2d array form top to bottom, left-to-right */
		_rowArray = [[NSMutableArray arrayWithCapacity: _rows] retain];
		srandom(time(NULL));
		
		_engine = [[Engine alloc] init];
		
		[self remakeGrid];
	}
	return self;
}

- (void)dealloc {

	[_engine release];
	[_rowArray release];

	[super dealloc];
}

- (void)remakeGrid {

	unsigned currentRows, currentCols;
	currentRows = [_rowArray count];
	currentCols = (currentRows > 0) ? [[_rowArray objectAtIndex:0] count] : 0;
	if(currentRows<_rows){
		// add new rows
		while(currentRows<_rows){
			NSMutableArray* columnArray = [NSMutableArray arrayWithCapacity: _columns];
			[_rowArray addObject:columnArray];
			currentRows++;
		}
	}
	else if(currentRows>_rows){
		// delete rows
		while(currentRows>_rows){
			[_rowArray removeLastObject];
			currentRows--;
		}
	}
	if(currentCols<_columns){
		// add new _columns
		unsigned i;
		for(i=0; i<_rows; i++){
			NSMutableArray* columnArray = [_rowArray objectAtIndex:i];
			unsigned colCount = [columnArray count];
			while(colCount<_columns){
				GridCell* cell = [[[GridCell alloc] init] autorelease];
				[columnArray addObject:cell];
				colCount++;
			}
		}
	}
	else if(currentCols>_columns){
		// delete _columns
		unsigned i;
		for(i=0; i<_rows; i++){
			NSMutableArray* columnArray = [_rowArray objectAtIndex:i];
			unsigned colCount = [columnArray count];
			while(colCount>_columns){
				[columnArray removeLastObject];
				colCount--;
			}
		}		
	}
	
	// reset anchor
	_translation = NSMakePoint(0,0);
	_anchorIndex = NSMakePoint(_rows/2, _columns/2);
	NSLog(@"anchor index is (%i, %i) out of %i, %i", (int)_anchorIndex.x, (int)_anchorIndex.y, (int)_rows, (int)_columns);
	
    _startTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

//=========================================================== 
// - drawCells: fromPt: atSize:
//=========================================================== 
- (void)drawCells:(NSMutableArray *)rowsToDraw fromPt:(NSPoint)topLeftPoint atSize:(float)size {

	unsigned i, j;
//	float width = _columns*_cellSz;
//	float height = _rows*_cellSz;
//	topLeftPoint.y = topLeftPoint.y-height;
	for(i=0; i<_rows; i++){
		for(j=0; j<_columns; j++){
			// draw a sq
			float ypos = topLeftPoint.y - i*size;
			float xpos = topLeftPoint.x + j*size;
			
			// fill cell
			GridCell* cell = [[rowsToDraw objectAtIndex:i] objectAtIndex:j];
			[cell drawAtPoint:NSMakePoint(xpos+size/2.0, ypos-size/2.0) cellSize:size];
		}
	}
}

- (void)drawGLCells:(NSMutableArray *)rowsToDraw atSize:(float)size withCamera:(PBCamera *)camera {
	
	NSUInteger i, j;

	NSPoint distToAnchorFromTopLeft = NSMakePoint(_anchorIndex.x*_cellSz, _anchorIndex.y*_cellSz);
	NSPoint topLeftPoint = NSMakePoint(-distToAnchorFromTopLeft.x, -distToAnchorFromTopLeft.y);
	C3DTFrustum f = [camera OPENGLViewFrustum];
	
	int currentRow;
	for( i=0; i<_rows; i++ )
	{
		currentRow = i;
	//	currentRow = _rows-1-i;
		float ypos = topLeftPoint.y + i*size + (size/2.0);
//		NSLog(@"Row:%i, pos %f", currentRow, ypos );
		for(j=0; j<_columns; j++)
		{
	
			// draw a sq
			float xpos = topLeftPoint.x + j*size + (size/2.0);
			C3DTVector p = {{ xpos, ypos, 0, 1}};
			_C3DTSpheroid s = {p,_cellSz};
			
			int visibleFlag = isSphereInFrustum( f, s );
			// NSLog(@"visible is %i", visibleFlag);
			/* Grid layout (as seen on screen

			[0,0] [0,1] [0,2]
			[1,0] [1,1] [1,2] 
			[2,0] [2,1] [2,2]

			ie. [0,0] is at the BOTTOM! (we are using opengl coords, doh!)
			*/
			
			// fill cell
		//	[cell setRed:0];
		//	[cell setGreen:currentRow/10.0];
		//	[cell setBlue:currentRow/10.0];
			GridCell* cell = [[rowsToDraw objectAtIndex:currentRow] objectAtIndex:j];
			if(visibleFlag){
				[cell setVisible:YES];
				[cell useAtPoint:NSMakePoint(xpos, ypos) cellSize:size row:currentRow col:j];
			} else {
				[cell setVisible:NO];
			}
		}
	}
//	NSLog(@"finished drawing");
}

#pragma mark action methods
- (void)increaseAnchorX{
	_anchorIndex.x = _anchorIndex.x+1;
}
- (void)decreaseAnchorX{
	_anchorIndex.x = _anchorIndex.x-1;
}
- (void)increaseAnchorY{
	_anchorIndex.y = _anchorIndex.y+1;
}
- (void)decreaseAnchorY{
	_anchorIndex.y = _anchorIndex.y-1;
}

//=========================================================== 
// - moveForward
//=========================================================== 
- (void)moveForwardAtTime:(double)time
{
//	NSLog(@"Moving forward at time %f", (float)time);
	// have an angle and forward velocity
	
	// move in that dirction, check bounds etc
	
	// then rotate so facing forwards
	
	// then draw
	
	_translation.y = _translation.y - (time*8.0); // + equals up
//	_translation.x = _translation.x - (time*8.0);

	// test grid edges against bounds - shrink or grow appropriately
	float width = _columns*_cellSz;
	float height = _rows*_cellSz;
	NSPoint distToAnchorFromTopLeft = NSMakePoint(_anchorIndex.x*_cellSz, _anchorIndex.y*_cellSz);
	NSPoint topLeftPoint = NSMakePoint(_translation.x-distToAnchorFromTopLeft.x, _translation.y-distToAnchorFromTopLeft.y);

	/* (0, 0) is Center of screen */
	NSRect clipBounds = NSMakeRect( -(_boundsSize/2.0), -(_boundsSize/2.0), _boundsSize, _boundsSize ); // clipping is fixed around the origin
	NSRect gridBounds = NSMakeRect( topLeftPoint.x, topLeftPoint.y, width, height);
	BOOL didChangeBounds = [self testEdges:gridBounds againstClip:clipBounds cellSize:_cellSz];
	didChangeBounds;
}

//=========================================================== 
// - testEdges: againstClip:
//=========================================================== 
- (BOOL)testEdges:(NSRect)edges againstClip:(NSRect)bounds cellSize:(int)unitSize
{
	BOOL modified = NO;
	
	/* Remember top edge is bottom of screen! */
	// bottom edge inside bounds
	if(edges.origin.y+edges.size.height < bounds.origin.y+bounds.size.height)
	{
		[self addRow_bottom];
		NSLog(@"addRow_bottom");
		modified = YES;
	// bottom edge outside bounds +
	} else if(edges.origin.y+edges.size.height > bounds.origin.y+bounds.size.height+unitSize)
	{
		[self removeRow_bottom];
		NSLog(@"removeRow_bottom");
		modified = YES;
	}
	// top edge inside bounds
	if(edges.origin.y > bounds.origin.y)
	{
		NSLog(@"addRow_top");
		[self addRow_top];
		modified = YES;
	// top edge outside bounds +
	} else if(edges.origin.y < (bounds.origin.y-unitSize))
	{
		NSLog(@"removeRow_top");
		[self removeRow_top];
		modified = YES;
	}	
	
	// left edge inside bounds
	if(edges.origin.x > bounds.origin.x){
		NSLog(@"add left");
		[self addColumn_left];
		modified = YES;
	// left edge outside bounds +
	} else if(edges.origin.x < bounds.origin.x-unitSize*1.5){
		NSLog(@"remove left");
		[self removeColumn_left];
		modified = YES;
	}
	// right edge inside bounds
	if(edges.origin.x+edges.size.width < bounds.origin.x+ bounds.size.width){
		NSLog(@"add right");
		[self addColumn_right];
		modified = YES;
	// right edge outside bounds +
	} else if(edges.origin.x+edges.size.width > bounds.origin.x+ bounds.size.width+unitSize*1.5){
		NSLog(@"remove right");
		[self removeColumn_right];
		modified = YES;
	}	
	return modified;
}

//=========================================================== 
// - drawAtPoint:
//=========================================================== 
- (void)drawAtPoint:(NSPoint)p 
{		
//	NSPoint distToBottomRightFromAnchor = NSMakePoint((_columns-_anchorIndex.x)*_cellSz, (_rows-_anchorIndex.y)*_cellSz); // just distance, ie positive
//	NSPoint topLeftPointFromAnchor = NSMakePoint(-distToAnchorFromTopLeft.x, -distToAnchorFromTopLeft.y);
//	NSPoint bottomRightPointFromAnchor = NSMakePoint(distToBottomRightFromAnchor.x, distToBottomRightFromAnchor.y);
//	NSPoint bottomLeftPointFromAnchor = NSMakePoint(bottomRightPointFromAnchor.x-width, bottomRightPointFromAnchor.y);
	

	NSPoint distToAnchorFromTopLeft = NSMakePoint(_anchorIndex.x*_cellSz, (_rows-_anchorIndex.y)*_cellSz);
	NSPoint translatedAnchor = NSMakePoint( p.x+_translation.x, -p.y-_translation.y);
	NSPoint topLeftPoint = NSMakePoint(translatedAnchor.x-distToAnchorFromTopLeft.x, translatedAnchor.y-distToAnchorFromTopLeft.y);

	float width = _columns*_cellSz;
	float height = _rows*_cellSz;
	NSPoint position = NSMakePoint( topLeftPoint.x, topLeftPoint.y+height);  // top left pt after translation
	

	NSRect gridBounds = NSMakeRect( topLeftPoint.x, topLeftPoint.y, width, height);

	/* draw top left squares */
	[self drawCells:_rowArray fromPt:position atSize:_cellSz];
	
	// stroke grid bounds
	[[NSColor yellowColor] set];
	NSFrameRect( gridBounds );
	
	// draw on anchor point
	[[NSColor blackColor] set];
	NSRectFill( NSMakeRect( translatedAnchor.x-5, translatedAnchor.y-5, 10, 10) );
	[[NSColor whiteColor] set];
	NSFrameRect( NSMakeRect(translatedAnchor.x-5, translatedAnchor.y-5, 10, 10) );
	NSFrameRect( NSMakeRect(p.x-2, p.x-2, 4, 4) );

	// draw clipping bounds
	[[NSColor whiteColor] set];

	[[NSColor cyanColor] set];
	NSRect clipBounds = NSMakeRect( p.x-(_boundsSize/2.0), p.x-(_boundsSize/2.0), _boundsSize, _boundsSize ); // clipping is fixed around the origin

	NSFrameRect( clipBounds );
	
	
	// draw the camera
	[[NSColor yellowColor] set];

	C3DTVector campos = [[PBCamera camera] pos];
	C3DTVector lookAt = [[PBCamera camera] lookAt];

	NSRectFill( NSMakeRect( p.x-campos.cartesian.x-15, p.y-campos.cartesian.y-15, 30, 30) );
	NSRectFill( NSMakeRect( p.x-lookAt.cartesian.x-8, p.y-lookAt.cartesian.y-8, 16, 16) );

}


- (void)useWith:(PBCamera *)camera atTime:(double)time {

	[self drawBackingQuad];
//	double lastTime = _time;
	_time = time; // _startTime;
	
// 	NSLog(@"fps is %f", 1.0/(_time-lastTime));
	
	/* Sets up the view matrix, clipping frustum, etc. These have only changed if we have moved the camera */
	[camera useWith:self atTime:_time];

	float width = _columns*_cellSz;
	float height = _rows*_cellSz;
//	float widthOverTwo = width*0.5;
//	float heightOverTwo = height*0.5;
	
	/* (0, 0) is centre of the screen. Positive y origin is top left, if that makes sense - ie. positive y is down  */
	NSPoint distToAnchorFromTopLeft = NSMakePoint(_anchorIndex.x*_cellSz, _anchorIndex.y*_cellSz);
//	NSPoint distToBottomRightFromAnchor = NSMakePoint((_columns-_anchorIndex.x)*_cellSz, (_rows-_anchorIndex.y)*_cellSz); // just distance, ie positive

	NSPoint topLeftPointFromAnchor = NSMakePoint(-distToAnchorFromTopLeft.x, -distToAnchorFromTopLeft.y);
//	NSPoint bottomRightPointFromAnchor = NSMakePoint(distToBottomRightFromAnchor.x, distToBottomRightFromAnchor.y);
//	NSPoint bottomLeftPointFromAnchor = NSMakePoint(bottomRightPointFromAnchor.x-width, bottomRightPointFromAnchor.y);

//	NSPoint position = NSMakePoint( _translation.x+distToAnchorFromTopLeft.x, _translation.y+distToAnchorFromTopLeft.y); 

// glCallList(_displayListId);
// glDisable(GL_COLOR_MATERIAL);
// glEnable(GL_TEXTURE_RECTANGLE_EXT);	
// glEnable(GL_BLEND);
// NSLog(@"geometry width is %f", _width);


	
	glPushMatrix();
	
//	float rotx = 180;
//	float roty = 0;
//	float rotz = 0;
//	glRotatef(rotx, 1.0f, 0.0f, 0.0f);
//	glRotatef(roty, 0.0f, 1.0f, 0.0f);
//	glRotatef(rotz, 0.0f, 0.0f, 1.0f);
			
	glTranslatef(_translation.x, _translation.y, 0.0); // (+10, +10) will move it up and right

	/* should we do this every time ? */
	[camera calcFrustumEquations];
	
//	we are getting clipped alot by the top and bottom planes.. somehow the frustum
//	isn't exactly what we are seeing..
	
	
	/* Draw the background footprint of the grid. Counter Clockwise from bottom left */
	glColor3f(1.0, 1.0, 1.0f);
	glPolygonMode(GL_FRONT, GL_FILL);
	glBegin(GL_QUADS);
		glVertex3f( topLeftPointFromAnchor.x, topLeftPointFromAnchor.y, 0.);
		glVertex3f(	topLeftPointFromAnchor.x+width, topLeftPointFromAnchor.y, 0.);
		glVertex3f( topLeftPointFromAnchor.x+width, topLeftPointFromAnchor.y+height, 0.);
		glVertex3f( topLeftPointFromAnchor.x, topLeftPointFromAnchor.y+height, 0.);
	glEnd();

	/* draw squares */
	[self drawGLCells:_rowArray atSize:_cellSz withCamera:camera];

	// draw on anchor point
	glColor3f(0.0, 0.0, 0.0f);
	glBegin(GL_QUADS);
		glVertex3f( -5.0, -5.0, 0.);
		glVertex3f(	5.0, -5.0, 0.);
		glVertex3f( 5.0, 5.0, 0.);
		glVertex3f( -5.0, 5.0, 0.);
	glEnd();
	glColor3f(1.0, 1.0, 1.0f);
	glPolygonMode(GL_FRONT, GL_LINE);
	glBegin(GL_QUADS);
		glVertex3f( -5.0, -5.0, 0.);
		glVertex3f(	5.0, -5.0, 0.);
		glVertex3f( 5.0, 5.0, 0.);
		glVertex3f( -5.0, 5.0, 0.);
	glEnd();
	
	glPopMatrix();

	// draw clipping bounds
	glColor3f(0.0, 1.0, 1.0f);
	
	float halfSize = _boundsSize/2.0f;
	glBegin(GL_QUADS);
		glVertex3f( -halfSize-5, halfSize+5, 0.f);	// top left
		glVertex3f(	-halfSize-5, -halfSize-5, 0.f);	// bottom left
		glVertex3f( halfSize+5 , -halfSize-5, 0.f);
		glVertex3f( halfSize+5, halfSize+5, 0.f);
	glEnd();



}

- (void)drawBackingQuad
{
	glColor3f(0.5f, 0.5f, 0.5f);
	glPolygonMode(GL_FRONT, GL_FILL);
	glBegin(GL_QUADS);
		glVertex3f( -1000.0f, 1000.0f, 0.0f);	// top left
		glVertex3f( -1000.0f, -1000.0f, 0.0f);	// bottom left
		glVertex3f( 1000.0f, -1000.0f, 0.0f);
		glVertex3f( 1000.0f, 1000.0f, 0.0f);
	glEnd();		
}

static float val = 0.0f;

- (void)addRow_top {
	NSMutableArray* newRow = [NSMutableArray arrayWithCapacity: _columns];
	unsigned j;
	for(j=0; j<_columns; j++){
//		GridCell* cell = [[[GridCell alloc] initWithColourR:1.0 g:val b:0.0] autorelease]
		GridCell* cell = [[[GridCell alloc] init] autorelease];
		val = val+0.1;
		[newRow addObject:cell];
	}
	val = 0.0;

//	[_rowArray addObject:newRow];
	[_rowArray insertObject:newRow atIndex:0];

	_rows++;
	[self decreaseAnchorY];
	_translation.y = _translation.y-_cellSz;	// translation moves towards top
}


- (void)addRow_bottom {

	NSMutableArray* newRow = [NSMutableArray arrayWithCapacity: _columns];
	unsigned j;
	for(j=0; j<_columns; j++){
//		GridCell* cell = [[[GridCell alloc] initWithColourR:1.0 g:val b:0.0] autorelease];
		GridCell* cell = [[[GridCell alloc] init] autorelease];

		val = val+0.1;
		[newRow addObject:cell];
	}
	val = 0.0;
//	[_rowArray insertObject:newRow atIndex:0];
	[_rowArray addObject:newRow];

	_rows++;
//	[self increaseAnchorY];
	_translation.y = _translation.y+_cellSz;
}


- (void)addColumn_left {

	unsigned i;
	for(i=0; i<_rows; i++){
		NSMutableArray* thisRow = [_rowArray objectAtIndex: i];
		GridCell* cell = [[[GridCell alloc] init] autorelease];
		[thisRow insertObject:cell atIndex:0];
	}
	_translation.x = _translation.x-_cellSz;
	_columns++;
}

- (void)addColumn_right {

	unsigned i;
	for(i=0; i<_rows; i++){
		NSMutableArray* thisRow = [_rowArray objectAtIndex: i];
		GridCell* cell = [[[GridCell alloc] init] autorelease];
		[thisRow addObject:cell];
	}
	[self increaseAnchorX];
	_translation.x = _translation.x+_cellSz;
	_columns++;
}

- (void)removeRow_top {

	if(_rows>1){
//		[_rowArray removeLastObject]; // remember - 0,0 is top left of screen
		[_rowArray removeObjectAtIndex:0];

		_rows--;
	}
}


- (void)removeRow_bottom {
	
	if(_rows>1){
//		[_rowArray removeObjectAtIndex:0];
		[_rowArray removeLastObject]; // remember - 0,0 is top left of screen
		_rows--;
		[self increaseAnchorY];
	}
}

- (void)removeColumn_left {

	if(_columns>1){
		unsigned i;
		for(i=0; i<_rows; i++){
			NSMutableArray* thisRow = [_rowArray objectAtIndex: i];
			[thisRow removeObjectAtIndex:0];
		}
		[self decreaseAnchorX];
		_columns--;
	}
}

- (void)removeColumn_right {
	
	if(_columns>1){
		unsigned i;
		for(i=0; i<_rows; i++){
			NSMutableArray* thisRow = [_rowArray objectAtIndex: i];
			[thisRow removeLastObject];
		}
		_columns--;
	}
}


#pragma mark accessor methods
- (unsigned)rows { return _rows; }
- (void)setRows:(unsigned)value {
	if(_rows!=value){
		NSNotification *n = [NSNotification notificationWithName:@"gridWillChange" object:self userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification: n];
		_rows = value;
		[self remakeGrid];
		n = [NSNotification notificationWithName:@"gridDidlChange" object:self userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification: n];
	}
}

- (unsigned)columns { return _columns; }
- (void)setColumns:(unsigned)value {
	if(_columns!=value){
		NSNotification *n = [NSNotification notificationWithName:@"gridWillChange" object:self userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification: n];
		_columns = value;
		[self remakeGrid];
		n = [NSNotification notificationWithName:@"gridDidlChange" object:self userInfo:nil];
		[[NSNotificationCenter defaultCenter] postNotification: n];
	}
}

- (unsigned)boundsSize { return _boundsSize; }
- (void)setBoundsSize:(unsigned)value {
	if(_boundsSize!=value){
		_boundsSize = value;
		// how many cells fit to bounds?
		[self setRows:(_boundsSize/_cellSz)];
		[self setColumns:(_boundsSize/_cellSz)];
	}
}

- (unsigned)cellSz { return _cellSz; }
- (void)setCellSz:(unsigned)value {
	if(_cellSz!=value){
		_cellSz = value;
		// how many cells fit to bounds?
		[self setRows:(_boundsSize/_cellSz)];
		[self setColumns:(_boundsSize/_cellSz)];
	}
}
	
- (float)xVelocity { return _xVelocity; }
- (void)setXVelocity:(float)value {
	if(_xVelocity!=value){
		_xVelocity = value;
	}
}

- (float)yVelocity { return _yVelocity; }
- (void)setYVelocity:(float)value {
	if(_yVelocity!=value){
		_yVelocity = value;
	}
}

- (NSArray *)rowArray
{
	return _rowArray;
}
@end
