
#ifndef FLAC__PRIVATE__BITMATH_H
#define FLAC__PRIVATE__BITMATH_H

#include "ordinals.h"

unsigned FLAC__bitmath_ilog2(FLAC__uint32 v);
//unsigned FLAC__bitmath_ilog2_wide(FLAC__uint64 v);
unsigned FLAC__bitmath_silog2(int v);
unsigned FLAC__bitmath_silog2_wide(FLAC__int64 v);

#endif
