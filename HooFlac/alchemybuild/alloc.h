
#ifndef FLAC__SHARE__ALLOC_H
#define FLAC__SHARE__ALLOC_H

/* WATCHOUT: for c++ you may have to #define __STDC_LIMIT_MACROS 1 real early
 * before #including this file,  otherwise SIZE_MAX might not be defined
 */

#include <limits.h> /* for SIZE_MAX */
#include <stdint.h> /* for SIZE_MAX in case limits.h didn't get it */
#include <stdlib.h> /* for size_t, malloc(), etc */


#define FLaC__INLINE

/* avoid malloc()ing 0 bytes, see:
 * https://www.securecoding.cert.org/confluence/display/seccode/MEM04-A.+Do+not+make+assumptions+about+the+result+of+allocating+0+bytes?focusedCommentId=5407003
*/
static FLaC__INLINE void *safe_malloc_(size_t size)
{
	/* malloc(0) is undefined; FLAC src convention is to always allocate */
	if(!size)
		size++;
	return malloc(size);
}

static FLaC__INLINE void *safe_calloc_(size_t nmemb, size_t size)
{
	if(!nmemb || !size)
		return malloc(1); /* malloc(0) is undefined; FLAC src convention is to always allocate */
	return calloc(nmemb, size);
}

/*@@@@ there's probably a better way to prevent overflows when allocating untrusted sums but this works for now */

static FLaC__INLINE void *safe_malloc_add_2op_(size_t size1, size_t size2)
{
	size2 += size1;
	if(size2 < size1)
		return 0;
	return safe_malloc_(size2);
}

//static FLaC__INLINE void *safe_malloc_add_3op_(size_t size1, size_t size2, size_t size3)
//{
//	size2 += size1;
//	if(size2 < size1)
//		return 0;
//	size3 += size2;
//	if(size3 < size2)
//		return 0;
//	return safe_malloc_(size3);
//}

//static FLaC__INLINE void *safe_malloc_add_4op_(size_t size1, size_t size2, size_t size3, size_t size4)
//{
//	size2 += size1;
//	if(size2 < size1)
//		return 0;
//	size3 += size2;
//	if(size3 < size2)
//		return 0;
//	size4 += size3;
//	if(size4 < size3)
//		return 0;
//	return safe_malloc_(size4);
//}

static FLaC__INLINE void *safe_malloc_mul_2op_(size_t size1, size_t size2)
{
	if(!size1 || !size2)
		return malloc(1); /* malloc(0) is undefined; FLAC src convention is to always allocate */
	if(size1 > SIZE_MAX / size2)
		return 0;
	return malloc(size1*size2);
}


//static FLaC__INLINE void *safe_malloc_mul_3op_(size_t size1, size_t size2, size_t size3)
//{
//	if(!size1 || !size2 || !size3)
//		return malloc(1); /* malloc(0) is undefined; FLAC src convention is to always allocate */
//	if(size1 > SIZE_MAX / size2)
//		return 0;
//	size1 *= size2;
//	if(size1 > SIZE_MAX / size3)
//		return 0;
//	return malloc(size1*size3);
//}

/* size1*size2 + size3 */
//static FLaC__INLINE void *safe_malloc_mul2add_(size_t size1, size_t size2, size_t size3)
//{
//	if(!size1 || !size2)
//		return safe_malloc_(size3);
//	if(size1 > SIZE_MAX / size2)
//		return 0;
//	return safe_malloc_add_2op_(size1*size2, size3);
//}

/* size1 * (size2 + size3) */
static FLaC__INLINE void *safe_malloc_muladd2_(size_t size1, size_t size2, size_t size3)
{
	if(!size1 || (!size2 && !size3))
		return malloc(1); /* malloc(0) is undefined; FLAC src convention is to always allocate */
	size2 += size3;
	if(size2 < size3)
		return 0;
	return safe_malloc_mul_2op_(size1, size2);
}

//static FLaC__INLINE void *safe_realloc_add_2op_(void *ptr, size_t size1, size_t size2)
//{
//	size2 += size1;
//	if(size2 < size1)
//		return 0;
//	return realloc(ptr, size2);
//}

//static FLaC__INLINE void *safe_realloc_add_3op_(void *ptr, size_t size1, size_t size2, size_t size3)
//{
//	size2 += size1;
//	if(size2 < size1)
//		return 0;
//	size3 += size2;
//	if(size3 < size2)
//		return 0;
//	return realloc(ptr, size3);
//}

//static FLaC__INLINE void *safe_realloc_add_4op_(void *ptr, size_t size1, size_t size2, size_t size3, size_t size4)
//{
//	size2 += size1;
//	if(size2 < size1)
//		return 0;
//	size3 += size2;
//	if(size3 < size2)
//		return 0;
//	size4 += size3;
//	if(size4 < size3)
//		return 0;
//	return realloc(ptr, size4);
//}

static FLaC__INLINE void *safe_realloc_mul_2op_(void *ptr, size_t size1, size_t size2)
{
	if(!size1 || !size2)
		return realloc(ptr, 0); /* preserve POSIX realloc(ptr, 0) semantics */
	if(size1 > SIZE_MAX / size2)
		return 0;
	return realloc(ptr, size1*size2);
}

/* size1 * (size2 + size3) */
//static FLaC__INLINE void *safe_realloc_muladd2_(void *ptr, size_t size1, size_t size2, size_t size3)
//{
//	if(!size1 || (!size2 && !size3))
//		return realloc(ptr, 0); /* preserve POSIX realloc(ptr, 0) semantics */
//	size2 += size3;
//	if(size2 < size3)
//		return 0;
//	return safe_realloc_mul_2op_(ptr, size1, size2);
//}

#endif
