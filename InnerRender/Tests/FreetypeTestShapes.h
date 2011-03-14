//
//  FreetypeTestShapes.h
//  InnerRender
//
//  Created by Steven Hooley on 14/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FreetypeTestShapes : NSObject {
@private
    
}

struct FT_Outline_ *allocSpaceForShape( int numberOfContours, int numberOfPts );
void freeSpaceForShape( struct FT_Outline_ *outline );

struct FT_Outline_ *makeSimplePoly();
struct FT_Outline_ *makeSegmentedCirclePoly();

@end
