

#ifndef FLAC__PRIVATE__MEMORY_H
#define FLAC__PRIVATE__MEMORY_H

#include <stdlib.h> /* for size_t */

#include "float.h"
#include "ordinals.h" /* for FLAC__bool */

/* Returns the unaligned address returned by malloc.
 * Use free() on this address to deallocate.
 */
void *FLAC__memory_alloc_aligned(size_t bytes, void **aligned_address);
FLAC__bool FLAC__memory_alloc_aligned_int32_array(unsigned elements, FLAC__int32 **unaligned_pointer, FLAC__int32 **aligned_pointer);
//FLAC__bool FLAC__memory_alloc_aligned_uint32_array(unsigned elements, FLAC__uint32 **unaligned_pointer, FLAC__uint32 **aligned_pointer);
FLAC__bool FLAC__memory_alloc_aligned_uint64_array(unsigned elements, FLAC__uint64 **unaligned_pointer, FLAC__uint64 **aligned_pointer);
FLAC__bool FLAC__memory_alloc_aligned_unsigned_array(unsigned elements, unsigned **unaligned_pointer, unsigned **aligned_pointer);
FLAC__bool FLAC__memory_alloc_aligned_real_array(unsigned elements, FLAC__real **unaligned_pointer, FLAC__real **aligned_pointer);

#endif
