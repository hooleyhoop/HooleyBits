//
//  HooBitmap.h
//  InnerRender
//
//  Created by Steven Hooley on 14/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HooBitmap : NSObject {
@public
    unsigned char *buffer;
    int pxwidth, pxheight;
}
- (id)initWithWidth:(int)width height:(int)height;
@end
