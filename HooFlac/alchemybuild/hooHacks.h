#ifndef HOO_HACKS_H
#define HOO_HACKS_H

#include <stdio.h>
void * custom_memmove( void * destination, const void * source, size_t num );
void * custom_memcpy ( void * destination, const void * source, size_t num );
void * custom_memset ( void * ptr, int value, size_t num );

#define memmove custom_memmove
#define memcpy custom_memcpy
#define memset custom_memset

#endif
