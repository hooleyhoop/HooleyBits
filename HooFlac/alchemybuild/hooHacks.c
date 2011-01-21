
#include "hooHacks.h"

void * custom_memmove( void * destination, const void * source, size_t num ) {
    void *result;
     __asm__("%0 memmove(%1, %2, %3)\n" : "=r"(result) : "r"(destination), "r"(source), "r"(num));
    return result;
}

void * custom_memcpy ( void * destination, const void * source, size_t num ) {
    void *result;
     __asm__("%0 memcpy(%1, %2, %3)\n" : "=r"(result) : "r"(destination), "r"(source), "r"(num));
    return result;
}

void * custom_memset ( void * ptr, int value, size_t num ) {
    void *result;
    __asm__("%0 memset(%1, %2, %3)\n" : "=r"(result) : "r"(ptr), "r"(value), "r"(num));
    return result;
}

