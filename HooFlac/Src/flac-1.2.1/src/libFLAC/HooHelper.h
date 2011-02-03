/*
 *  HooHelper.h
 *  HooFlac
 *
 *  Created by Steven Hooley on 03/02/2011.
 *  Copyright 2011 Tinsal Parks. All rights reserved.
 *
 */
#ifndef HOO_HELPER
#define HOO_HELPER

#include <stdio.h>

void hooFileLogFunction( FILE *logFile, const char *message, ...);
//#define hooFileLog(message,...) hooFileLogFunction( _logFile, message, ##__VA_ARGS__)
#define hooFileLog(ignore, ...)((void) 0)

#endif
