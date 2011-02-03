/*
 *  HooHelper.c
 *  HooFlac
 *
 *  Created by Steven Hooley on 03/02/2011.
 *  Copyright 2011 Tinsal Parks. All rights reserved.
 *
 */

#include "HooHelper.h"
#include <mach/mach.h>

void hooFileLogFunction( FILE *logFile, const char *message, ...) {
    
    va_list args;
    va_start( args, message ); 
    vfprintf( logFile, message, args );
    va_end(args);
}

