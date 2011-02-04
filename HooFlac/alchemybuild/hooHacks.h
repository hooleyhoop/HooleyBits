#ifndef HOO_HACKS_H
#define HOO_HACKS_H

#include <stdio.h>
#include <stdint.h>

void hooFileLogFunction( FILE *logFile, const char *message, ...);
//#define hooFileLog(message,...) hooFileLogFunction( _logFile, message, ##__VA_ARGS__)
#define hooFileLog(ignore, ...)((void) 0)

void * custom_memmove( void * destination, const void * source, size_t num );
void * custom_memcpy ( void * destination, const void * source, size_t num );
void * custom_memset ( void * ptr, int value, size_t num );


#define memmove custom_memmove
#define memcpy custom_memcpy
#define memset custom_memset
// uint32_t ByteSwap_32(uint32_t Value);

unsigned long HooByteSwap (unsigned long nLongNumber);
long lrintf(float f);

#endif
