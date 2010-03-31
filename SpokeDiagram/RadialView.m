//
//  RadialView.m
//  SpokeDiagram
//
//  Created by steve hooley on 20/10/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import "RadialView.h"
#import "SpokeDiagram_AppDelegate.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180.0 )


@implementation RadialView

- (id)initWithFrame:(NSRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
        numberOfColums = 18;
        minValue = 10.0f;
        maxValue = 40.0f;
    }
    return self;
}

- (void)relayout:(NSArray *)value {

	// reset tensions
    for(int i=0;i<numberOfColums;i++){
        driveSideTensions[i] = 0.0;
        nonDriveSideTension[i] = 0.0;
		driveSideAdjustments[i] = -1;
		nonDriveSideAdjustments[i] = -1;
    }
	// which spokes were adjusted? we need to make sure appDelegate sets this before it triggers the KVO for the readings
	NSArray *adjustedSpokes = [[[NSApplication sharedApplication] delegate] currentAdjustments];
    for(NSManagedObject *ob in adjustedSpokes)
	{
		int spoke = [[ob valueForKey:@"spoke"] intValue];
		NSString *kind = [ob valueForKey:@"kind"];
        NSString *side = [ob valueForKey:@"side"];
        if([side isEqualToString:@"Non-Drive"])
            nonDriveSideAdjustments[spoke-1] = [kind isEqualToString:@"Tighter"];
        else
            driveSideAdjustments[spoke-1] = [kind isEqualToString:@"Tighter"];
	}
	for(NSManagedObject *ob in value)
	{
		int spoke = [[ob valueForKey:@"spoke"] intValue];
        float tension = [[ob valueForKey:@"tension"] floatValue];
        NSString *side = [ob valueForKey:@"side"];
        if([side isEqualToString:@"Non-Drive"])
            nonDriveSideTension[spoke-1] = tension;
        else
            driveSideTensions[spoke-1] = tension;
    }
    [self setNeedsDisplay:YES];
}

- (void)drawTitleWithMode:(int)mode {
	
    NSRect bounds = self.bounds;

	if(mode==0){
		NSAttributedString *numberStr = [[[NSAttributedString alloc] initWithString: @"Drive side"] autorelease];
		[numberStr drawAtPoint:NSMakePoint(10, bounds.size.height-25)];
	}
	else if(mode==1){
		NSAttributedString *numberStr = [[[NSAttributedString alloc] initWithString:@"Non-Drive side"] autorelease];
		[numberStr drawAtPoint:NSMakePoint(10, bounds.size.height-25)];
	}
	else if(mode==2){
		NSAttributedString *numberStr1 = [[[NSAttributedString alloc] initWithString: @"Drive side"] autorelease];
		[numberStr1 drawAtPoint:NSMakePoint(10, bounds.size.height-25)];
		
		NSAttributedString *numberStr2 = [[[NSAttributedString alloc] initWithString:@"Non-Drive side"] autorelease];
		[numberStr2 drawAtPoint:NSMakePoint((bounds.size.width/2.0)+10, bounds.size.height-25)];
	}
}

- (void)drawCircleWithMode:(int)mode bounds:(NSRect)wheelBnds {
	
	NSPoint centrePt = NSMakePoint(NSMidX(wheelBnds), NSMidY(wheelBnds));
	float determiningHeight = wheelBnds.size.width<wheelBnds.size.height? wheelBnds.size.width : wheelBnds.size.height;
	float radius = (determiningHeight/ 2.0)*0.915;
	float numberPosY = (determiningHeight/ 2.0)*0.95;
	NSPoint p1 = NSMakePoint(centrePt.x, centrePt.y+radius);
	NSPoint numberPos = NSMakePoint(centrePt.x, centrePt.y+numberPosY);
    NSColor *barColour = nil;
    float minLine=maxValue, maxLine=minValue;
	float anglr_rad1, anglr_rad2; // these are the angles of the 2 pts on the circumference of the pie-wedge
	NSPoint circumferencePt1, circumferencePt2;
	
	float *tensions;
	int *adjustments;
	if(mode==0){
		tensions = driveSideTensions;
		adjustments = driveSideAdjustments;
	}
	else if(mode==1){
		tensions = nonDriveSideTension;
		adjustments = nonDriveSideAdjustments;
	}

    for(int i=0; i<numberOfColums; i++)
	{
		// rotate the point CLOCKWISE
		// find the 2 circumference points
		anglr_rad1 = RADIANS((360.0/numberOfColums) * i *-1.0); //-1 is for clockwise
		anglr_rad2 = RADIANS((360.0/numberOfColums) * (i+1) *-1.0);
		
		float rotate1X = centrePt.x + ( cosf(anglr_rad1) * (p1.x - centrePt.x) - sinf(anglr_rad1) * (p1.y - centrePt.y) );
		float rotate1Y = centrePt.y + ( sinf(anglr_rad1) * (p1.x - centrePt.x) + cosf(anglr_rad1) * (p1.y - centrePt.y) );
		float rotate2X = centrePt.x + ( cosf(anglr_rad2) * (p1.x - centrePt.x) - sinf(anglr_rad2) * (p1.y - centrePt.y) );
		float rotate2Y = centrePt.y + ( sinf(anglr_rad2) * (p1.x - centrePt.x) + cosf(anglr_rad2) * (p1.y - centrePt.y) );
		circumferencePt1 = NSMakePoint(rotate1X, rotate1Y);
		circumferencePt2 = NSMakePoint(rotate2X, rotate2Y);
		
        float tension = tensions[i];
    	BOOL adjustment = adjustments[i];
		
        if(tension>0.0)
        {
            float col = i/(numberOfColums *2.0)+0.2;
            barColour = [NSColor colorWithCalibratedRed:col green:col blue:col alpha:1.0];
			
            // These are the points not on the circumference
            float barHeightPercent = (tension-minValue) / (maxValue-minValue);
            if(barHeightPercent<0){
                barHeightPercent=0.1f;
                barColour = [NSColor redColor];
            }
            if(barHeightPercent>1.0){
                barHeightPercent = 1.0f;
                barColour = [NSColor redColor];
            }
            float barHeightPx = barHeightPercent*radius;
            float distFromOrigin = radius-barHeightPx;
			
            // store the max and min values
            if(barHeightPx>maxLine)
                maxLine = barHeightPx;
            
            if(barHeightPx<minLine)
                minLine = barHeightPx;
            
            NSPoint topOfBarPoint = NSMakePoint(centrePt.x, centrePt.y+distFromOrigin);
            
            float rotate3X = centrePt.x + ( cosf(anglr_rad1) * (topOfBarPoint.x - centrePt.x) - sinf(anglr_rad1) * (topOfBarPoint.y - centrePt.y) );
            float rotate3Y = centrePt.y + ( sinf(anglr_rad1) * (topOfBarPoint.x - centrePt.x) + cosf(anglr_rad1) * (topOfBarPoint.y - centrePt.y) );
            float rotate4X = centrePt.x + ( cosf(anglr_rad2) * (topOfBarPoint.x - centrePt.x) - sinf(anglr_rad2) * (topOfBarPoint.y - centrePt.y) );
            float rotate4Y = centrePt.y + ( sinf(anglr_rad2) * (topOfBarPoint.x - centrePt.x) + cosf(anglr_rad2) * (topOfBarPoint.y - centrePt.y) );
            
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:circumferencePt1];
            [path lineToPoint:circumferencePt2];
            [path lineToPoint:NSMakePoint(rotate4X, rotate4Y)];
            [path lineToPoint:NSMakePoint(rotate3X, rotate3Y)];
            [path closePath];
            
            [barColour set];
            [path fill];
        }
		
		// Draw on the tensioned spoke..
		if(adjustment!=-1){
			NSPoint middleCircumferencePt = NSMakePoint( (circumferencePt2.x-circumferencePt1.x)/2.0 + circumferencePt1.x, (circumferencePt2.y-circumferencePt1.y)/2.0 + circumferencePt1.y );
            NSBezierPath *path = [NSBezierPath bezierPath];
            [path moveToPoint:middleCircumferencePt];
            [path lineToPoint:centrePt];
			
			NSColor *spokeColor = adjustment==1 ? [NSColor orangeColor] : [NSColor greenColor];
			[spokeColor set];
			[path stroke];
		}
		
		// draw on the number
		float numberAngle = (anglr_rad2-anglr_rad1)/2.0 + anglr_rad1;
		float numberX = centrePt.x + ( cosf(numberAngle) * (numberPos.x - centrePt.x) - sinf(numberAngle) * (numberPos.y - centrePt.y) );
		float numberY = centrePt.y + ( sinf(numberAngle) * (numberPos.x - centrePt.x) + cosf(numberAngle) * (numberPos.y - centrePt.y) );
		NSString *thisSpokeIndex = [[NSNumber numberWithInt:i+1] stringValue];
		NSAttributedString *numberStr = [[[NSAttributedString alloc] initWithString:thisSpokeIndex] autorelease];
		[[NSColor grayColor] set];
		[numberStr drawAtPoint:NSMakePoint(numberX-8, numberY-5)];
	}
    
    // draw circles
    [[NSColor lightGrayColor] set];
    NSBezierPath *circumfrence = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centrePt.x-radius, centrePt.y-radius, radius*2., radius*2.)];
    [circumfrence stroke];
	
    float circleDistPercent = (26.0-minValue) / (maxValue-minValue);
    float circleDistPx = circleDistPercent*radius;
    float distFromOrigin = radius-circleDistPx;
    NSBezierPath *guideCircle1 = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centrePt.x-distFromOrigin, centrePt.y-distFromOrigin, distFromOrigin*2., distFromOrigin*2.)];
    [guideCircle1 stroke];
    
    circleDistPercent = (21.0-minValue) / (maxValue-minValue);
    circleDistPx = circleDistPercent*radius;
    distFromOrigin = radius-circleDistPx;
    
    NSBezierPath *guideCircle2 = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centrePt.x-distFromOrigin, centrePt.y-distFromOrigin, distFromOrigin*2., distFromOrigin*2.)];
    [guideCircle2 stroke];
    
    // max and min circles
    if(minLine!=maxValue){
        [[NSColor blueColor] set];
        distFromOrigin = radius-minLine;
        NSBezierPath *minCircle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centrePt.x-distFromOrigin, centrePt.y-distFromOrigin, distFromOrigin*2., distFromOrigin*2.)];
        [minCircle stroke];
    }
    if(maxLine!=minValue){
        [[NSColor redColor] set];
        distFromOrigin = radius-maxLine;
        NSBezierPath *maxCircle = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect( centrePt.x-distFromOrigin, centrePt.y-distFromOrigin, distFromOrigin*2., distFromOrigin*2.)];
        [maxCircle stroke];
    }
}

- (void)drawMode:(int)currentMode {
	
    NSRect bounds = self.bounds;
	[self drawTitleWithMode:currentMode];
	
	if(currentMode==0){
		[self drawCircleWithMode:0 bounds:bounds];
	}
	else if(currentMode==1){
		[self drawCircleWithMode:1 bounds:bounds];
	}
	else if(currentMode==2){
		[self drawCircleWithMode:0 bounds:NSMakeRect(0,0,bounds.size.width/2.0,bounds.size.height)];
		[self drawCircleWithMode:1 bounds:NSMakeRect(bounds.size.width/2.0,0,bounds.size.width/2.0, bounds.size.height)];
	}
}

- (void)drawRect:(NSRect)rect {
	
	[[NSColor whiteColor] set];
    NSRect bounds = self.bounds;
	NSRectFill(bounds);

	int currentMode = [[[NSApplication sharedApplication] delegate] currentDisplayMode]; // 0=Drive, 1=NonDrive, 2=Both
	[self drawMode:currentMode];	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)observedObject change:(NSDictionary *)change context:(void *)vcontext {
	
	NSString *context = (NSString *)vcontext;
	if(context==nil)
		[NSException raise:@"MUST SUPPLY A CONTEXT" format:@"MUST SUPPLY A CONTEXT"];
    
    if( [context isEqualToString:@"SpokeDiagram_AppDelegate"] )
	{
        if( [keyPath isEqualToString:@"currentSpokes"] )
        {
            // id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
            // BOOL oldValueNullOrNil = [oldValue isEqual:[NSNull null]] || oldValue==nil;
            id newValue = [change objectForKey:NSKeyValueChangeNewKey];
            BOOL newValueNullOrNil = [newValue isEqual:[NSNull null]] || newValue==nil;
            // id changeKind = [change objectForKey:NSKeyValueChangeKindKey];
            // id changeIndexes = [change objectForKey:NSKeyValueChangeIndexesKey]; //  NSKeyValueChangeInsertion, NSKeyValueChangeRemoval, or NSKeyValueChangeReplacement, 
            if(newValueNullOrNil==NO)
                [self relayout:(NSArray *)newValue];

			return;
		} else if([keyPath isEqualToString:@"currentAdjustments"]) {
			return;
		}
	}
	[super observeValueForKeyPath:keyPath ofObject:observedObject change:change context:vcontext];
}

@end
