//
//  SHPhotoshopFileStuff.h
//  SHExtras
//
//  Created by Steven Hooley on 23/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <Quicktime/Quicktime.h>

@class SHPhotoshopImport;

/*
 *
*/
@interface SHPhotoshopFileStuff : NSObject {

}

+ (void)openImageURL:(NSURL*)url patch:(SHPhotoshopImport*)aPatch shouldCrop:(BOOL)premultFlag;

+ (CIImage*)CIImageFromCGImageRef:(CGImageRef)aCGImageRef ;

+ (void) showUserData:(UserData*)aUserData importer:(GraphicsImportComponent*)aImporter;

@end
