//
//  Unsafe Image Loader.h
//  BBExtras
//
//  Created by Jonathan del Strother on 01/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@interface BBImageLoader : QCImageDownloader {
	NSString* priorURL;
}

@end
