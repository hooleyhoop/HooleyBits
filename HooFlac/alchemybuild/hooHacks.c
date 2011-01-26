
#include "hooHacks.h"

//void * custom_memmove( void * destination, const void * source, size_t num ) {
//    void *result;
//     __asm__("%0 memmove(%1, %2, %3)\n" : "=r"(result) : "r"(destination), "r"(source), "r"(num));
//    return result;
//}
//
//void * custom_memcpy ( void * destination, const void * source, size_t num ) {
//    void *result;
//     __asm__("%0 memcpy(%1, %2, %3)\n" : "=r"(result) : "r"(destination), "r"(source), "r"(num));
//    return result;
//}
//
//void * custom_memset ( void * ptr, int value, size_t num ) {
//    void *result;
//    __asm__("%0 memset(%1, %2, %3)\n" : "=r"(result) : "r"(ptr), "r"(value), "r"(num));
//    return result;
//}

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