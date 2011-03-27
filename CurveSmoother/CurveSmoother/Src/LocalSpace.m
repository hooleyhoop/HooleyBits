//
//  LocalSpace.m
//  CurveSmoother
//
//  Created by Steven Hooley on 20/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "LocalSpace.h"
#import <x86intrin.h>
#include "2DVectorOps.h"

@implementation LocalSpace

@synthesize position;

//        component = new Vector3();

- (id)init {
    self = [super init];
    if (self) {
        [self setToIdentity];
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

//public LocalSpace(Vector3 paramVector3)
//{
//    setToIdentity();
//    this.position = paramVector3;
//}

- (void)setToIdentity {
    position = CGPointMake(0, 0);
//    this.forward = new Vector3(0.0F, 0.0F, 1.0F);
//    this.side = new Vector3(1.0F, 0.0F, 0.0F);
//    this.up = new Vector3(0.0F, 1.0F, 0.0F);
}

//public void globalizePosition(Vector3 paramVector31, Vector3 paramVector32)
//{
//    synchronized (component)
//    {
//        globalizeDirection(paramVector31, paramVector32);
//        paramVector32.setSum(paramVector32, this.position);
//        
//        return;
//    }
//}
//
//public void globalizeDirection(Vector3 paramVector31, Vector3 paramVector32)
//{
//    synchronized (component)
//    {
//        paramVector32.setScale(paramVector31.x, this.side);
//        component.setScale(paramVector31.y, this.up);
//        paramVector32.setSum(paramVector32, component);
//        component.setScale(paramVector31.z, this.forward);
//        paramVector32.setSum(paramVector32, component);
//        
//        return;
//    }
//}
//
//public void localizePosition(Vector3 paramVector31, Vector3 paramVector32)
//{
//    synchronized (component)
//    {
//        component = setDiff(paramVector31, this.position);
//        paramVector32.set(component.dot(this.side), component.dot(this.up), component.dot(this.forward));
//        
//        return;
//    }
//}

@end
