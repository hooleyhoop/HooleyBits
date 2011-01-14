
#ifndef FLAC__PRIVATE__FLOAT_H
#define FLAC__PRIVATE__FLOAT_H

#include "ordinals.h"

/*
 * These typedefs make it easier to ensure that integer versions of
 * the library really only contain integer operations.  All the code
 * in libFLAC should use FLAC__float and FLAC__double in place of
 * float and double, and be protected by checks of the macro
 * FLAC__INTEGER_ONLY_LIBRARY.
 *
 * FLAC__real is the basic floating point type used in LPC analysis.
 */

typedef double FLAC__double;
typedef float FLAC__float;
/*
 * WATCHOUT: changing FLAC__real will change the signatures of many
 * functions that have assembly language equivalents and break them.
 */
typedef float FLAC__real;


#endif
