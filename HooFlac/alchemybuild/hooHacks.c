
#include "hooHacks.h"
#include <stdarg.h>

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

//uint32_t ByteSwap_32(uint32_t Value) {
////#if defined(__llvm__) || \
////(__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 3)) && !defined(__ICC)
////    return __builtin_bswap32(Value);
////#elif defined(_MSC_VER) && !defined(_DEBUG)
////    return _byteswap_ulong(Value);
////#else
//    uint32_t Byte0 = Value & 0x000000FF;
//    uint32_t Byte1 = Value & 0x0000FF00;
//    uint32_t Byte2 = Value & 0x00FF0000;
//    uint32_t Byte3 = Value & 0xFF000000;
//    return (Byte0 << 24) | (Byte1 << 8) | (Byte2 >> 8) | (Byte3 >> 24);
////#endif
//}
unsigned long HooByteSwap (unsigned long nLongNumber) {
    return (((nLongNumber&0x000000FF)<<24)+((nLongNumber&0x0000FF00)<<8)+ ((nLongNumber&0x00FF0000)>>8)+((nLongNumber&0xFF000000)>>24));
}

long lrintf(float f)
{
    /* Implements the default IEEE 754-1985 rounding mode */
    long * fp = (void *)&f;
    int sign = (*fp) >> 31;
    int exponent = 23 + 0x7f - (((*fp) >> 23) & 0xff);
    unsigned int fraction = ((*fp) & 0x7fffff) | 0x800000;
    long result = fraction >> exponent;
    -- exponent;
    if (fraction & (1 << exponent)) { // fraction >= 0.5
        if (!(fraction & ~(-1 << exponent))) // fraction == 0.5
            if (!(result & 1)) // result is even
                return sign ? -result : result;
        ++ result;
    }
    return sign ? -result : result;
}

void hooFileLogFunction( FILE *logFile, const char *message, ...) {
    
    va_list args;
    va_start( args, message ); 
    vfprintf( logFile, message, args );
    va_end(args);
}


