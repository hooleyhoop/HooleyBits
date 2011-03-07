//
//  DrawingView.h
//  CurveSmoother
//
//  Created by Steven Hooley on 26/02/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DrawingView : NSView {
@private
    unsigned char *_buffer;
    CGImageRef _image;
    CGColorSpaceRef _colorSpace;
    CGDataProviderRef _provider;
    
    int *_pointList;
    int _pointListCount;
}

@end
