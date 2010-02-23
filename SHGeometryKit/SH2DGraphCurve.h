//
//  SH2DGraphCurve.h
//  SHGeometryKit
//
//  Created by Steven Hooley on 04/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SH2DGraphCurve : NSObject {

}


 -(void) insertPt:(G3DTuple2d*)pt;
 
/* important new way - only really works on a graph tho */
/* this is basically like find roots */
/* if it goes through x more than once what do you do? */
here
- (float) getUForX:(float)x error:(float)e;
- (float) getUForY:(float)x error:(float)e;

@end
