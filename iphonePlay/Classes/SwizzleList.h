//
//  SwizzleList.h
//  iphonePlay
//
//  Created by steve hooley on 13/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SwizzleList : NSObject {

}

// This is called from the real app and the test app
+ (void)setupSwizzles;
+ (void)tearDownSwizzles;

@end
