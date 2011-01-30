
#include "memory.h"
#include "assert.h"
#include "alloc.h"
#include <assert.h>
#include <stdio.h>

extern FILE *_logFile;

void *FLAC__memory_alloc_aligned(size_t bytes, void **aligned_address)
{
	fprintf( _logFile, "FLAC__memory_alloc_aligned()\n" );

	void *x;

	FLAC__ASSERT(0 != aligned_address);


	/* align on 32-byte (256-bit) boundary */
	x = safe_malloc_add_2op_(bytes, /*+*/31);


		*aligned_address = (void*)(((FLAC__uint64)x + 31) & (FLAC__uint64)(-((FLAC__int64)32)));


	return x;
}

FLAC__bool FLAC__memory_alloc_aligned_int32_array(unsigned elements, FLAC__int32 **unaligned_pointer, FLAC__int32 **aligned_pointer)
{
	fprintf( _logFile, "FLAC__memory_alloc_aligned_int32_array()\n" );

	FLAC__int32 *pu; /* unaligned pointer */
	union { /* union needed to comply with C99 pointer aliasing rules */
		FLAC__int32 *pa; /* aligned pointer */
		void        *pv; /* aligned pointer alias */
	} u;

	FLAC__ASSERT(elements > 0);
	FLAC__ASSERT(0 != unaligned_pointer);
	FLAC__ASSERT(0 != aligned_pointer);
	FLAC__ASSERT(unaligned_pointer != aligned_pointer);

	if((size_t)elements > SIZE_MAX / sizeof(*pu)) /* overflow check */
		return false;

	pu = (FLAC__int32*)FLAC__memory_alloc_aligned(sizeof(*pu) * (size_t)elements, &u.pv);
	if(0 == pu) {
		return false;
	}
	else {
		if(*unaligned_pointer != 0)
			free(*unaligned_pointer);
		*unaligned_pointer = pu;
		*aligned_pointer = u.pa;
		return true;
	}
}

//FLAC__bool FLAC__memory_alloc_aligned_uint32_array(unsigned elements, FLAC__uint32 **unaligned_pointer, FLAC__uint32 **aligned_pointer)
//{
//	FLAC__uint32 *pu; /* unaligned pointer */
//	union { /* union needed to comply with C99 pointer aliasing rules */
//		FLAC__uint32 *pa; /* aligned pointer */
//		void         *pv; /* aligned pointer alias */
//	} u;
//
//	FLAC__ASSERT(elements > 0);
//	FLAC__ASSERT(0 != unaligned_pointer);
//	FLAC__ASSERT(0 != aligned_pointer);
//	FLAC__ASSERT(unaligned_pointer != aligned_pointer);
//
//	if((size_t)elements > SIZE_MAX / sizeof(*pu)) /* overflow check */
//		return false;
//
//	pu = (FLAC__uint32*)FLAC__memory_alloc_aligned(sizeof(*pu) * elements, &u.pv);
//	if(0 == pu) {
//		return false;
//	}
//	else {
//		if(*unaligned_pointer != 0)
//			free(*unaligned_pointer);
//		*unaligned_pointer = pu;
//		*aligned_pointer = u.pa;
//		return true;
//	}
//}

FLAC__bool FLAC__memory_alloc_aligned_uint64_array(unsigned elements, FLAC__uint64 **unaligned_pointer, FLAC__uint64 **aligned_pointer)
{
	fprintf( _logFile, "FLAC__memory_alloc_aligned_uint64_array()\n" );

	FLAC__uint64 *pu; /* unaligned pointer */
	union { /* union needed to comply with C99 pointer aliasing rules */
		FLAC__uint64 *pa; /* aligned pointer */
		void         *pv; /* aligned pointer alias */
	} u;

	FLAC__ASSERT(elements > 0);
	FLAC__ASSERT(0 != unaligned_pointer);
	FLAC__ASSERT(0 != aligned_pointer);
	FLAC__ASSERT(unaligned_pointer != aligned_pointer);

	if((size_t)elements > SIZE_MAX / sizeof(*pu)) /* overflow check */
		return false;

	pu = (FLAC__uint64*)FLAC__memory_alloc_aligned(sizeof(*pu) * elements, &u.pv);
	if(0 == pu) {
		return false;
	}
	else {
		if(*unaligned_pointer != 0)
			free(*unaligned_pointer);
		*unaligned_pointer = pu;
		*aligned_pointer = u.pa;
		return true;
	}
}

FLAC__bool FLAC__memory_alloc_aligned_unsigned_array(unsigned elements, unsigned **unaligned_pointer, unsigned **aligned_pointer)
{
	unsigned *pu; /* unaligned pointer */
	union { /* union needed to comply with C99 pointer aliasing rules */
		unsigned *pa; /* aligned pointer */
		void     *pv; /* aligned pointer alias */
	} u;

	FLAC__ASSERT(elements > 0);
	FLAC__ASSERT(0 != unaligned_pointer);
	FLAC__ASSERT(0 != aligned_pointer);
	FLAC__ASSERT(unaligned_pointer != aligned_pointer);

	if((size_t)elements > SIZE_MAX / sizeof(*pu)) /* overflow check */
		return false;

	pu = (unsigned*)FLAC__memory_alloc_aligned(sizeof(*pu) * elements, &u.pv);
	if(0 == pu) {
		return false;
	}
	else {
		if(*unaligned_pointer != 0)
			free(*unaligned_pointer);
		*unaligned_pointer = pu;
		*aligned_pointer = u.pa;
		return true;
	}
}

FLAC__bool FLAC__memory_alloc_aligned_real_array(unsigned elements, FLAC__real **unaligned_pointer, FLAC__real **aligned_pointer)
{
	fprintf( _logFile, "FLAC__memory_alloc_aligned_real_array()\n" );

	FLAC__real *pu; /* unaligned pointer */
	union { /* union needed to comply with C99 pointer aliasing rules */
		FLAC__real *pa; /* aligned pointer */
		void       *pv; /* aligned pointer alias */
	} u;

	FLAC__ASSERT(elements > 0);
	FLAC__ASSERT(0 != unaligned_pointer);
	FLAC__ASSERT(0 != aligned_pointer);
	FLAC__ASSERT(unaligned_pointer != aligned_pointer);

	if((size_t)elements > SIZE_MAX / sizeof(*pu)) /* overflow check */
		return false;

	pu = (FLAC__real*)FLAC__memory_alloc_aligned(sizeof(*pu) * elements, &u.pv);
	if(0 == pu) {
		return false;
	}
	else {
		if(*unaligned_pointer != 0)
			free(*unaligned_pointer);
		*unaligned_pointer = pu;
		*aligned_pointer = u.pa;
		return true;
	}
}
