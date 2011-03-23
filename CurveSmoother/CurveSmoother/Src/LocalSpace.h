//
//  LocalSpace.h
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface LocalSpace : NSObject {
    
    CGPoint *position;              // How to manipulate position, say reset ?
    
//    Vector3 forward;
//    Vector3 side;
//    Vector3 up;
//    static Vector3 component = new Vector3();
    
}

@property (assign) CGPoint *position;

- (void)setToIdentity;

@end
