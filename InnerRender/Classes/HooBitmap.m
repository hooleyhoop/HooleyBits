//
//  HooBitmap.m
//  InnerRender
//
//  Created by Steven Hooley on 14/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import "HooBitmap.h"


@implementation HooBitmap

- (id)initWithWidth:(int)width height:(int)height {
    
    self = [super init];
    if (self) {
        pxwidth = width;
        pxheight = height;
        const int pitch_mono = (width + 7) >> 3;        
        buffer = calloc(1, width*pitch_mono);
    }
    
    return self;
}

- (void)dealloc {
    
    free(buffer);
    
    [super dealloc];
}

@end

//    const int width = 400;
//    const int rows = 400;
//    const int pitch = ((width + 15) >> 4) << 1; // one row including padding    
//    bitmap->buffer = buffer;
//    bitmap->width = width;
//    bitmap->rows = rows;
//    bitmap->pitch = pitch;
//    //if aa bitmap.num_grays = 256;
//    bitmap->pixel_mode = FT_PIXEL_MODE_MONO; // FT_PIXEL_MODE_GRAY  FT_PIXEL_MODE_MONO
//    // not used - bitmap.palette = 0;
//    // not used - bitmap.palette_mode = 0;

