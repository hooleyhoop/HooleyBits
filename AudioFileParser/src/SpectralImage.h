//
//  SpectralImage.h
//  AudioFileParser
//
//  Created by steve hooley on 23/04/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SpectralImage : NSObject {

}
- (id)initWithSpectrum:(struct HooSpectralBufferList *)specList;
- (CGImageRef)imageRef;

@end
