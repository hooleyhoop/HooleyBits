//
//  ImageWindow.h
//  TypeSetter
//
//  Created by steve hooley on 09/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class CrudeImageWrapper;

@interface ImageWindow : NSWindow {

}

+ (ImageWindow *)showImage:(CrudeImageWrapper *)imgArg;

@end
