//
//  DyldTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#include <mach-o/dyld.h>


@implementation DyldTests

_dyld_get_image_vmaddr_slide()

lets work out where everything is loaded

-- get everyimage

-- make sure every image is loaded?

// Dont forget we can get dyld to log api calls and library loads
DYLD_BIND_AT_LAUNCH
DYLD_PRINT_APIS
DYLD_PRINT_SEGMENTS
DYLD_PRINT_BINDINGS
@end
