

#ifndef FLAC__PRIVATE__WINDOW_H
#define FLAC__PRIVATE__WINDOW_H
#include "float.h"
#include "format.h"

#ifndef FLAC__INTEGER_ONLY_LIBRARY

/*
 *	FLAC__window_*()
 *	--------------------------------------------------------------------
 *	Calculates window coefficients according to different apodization
 *	functions.
 *
 *	OUT window[0,L-1]
 *	IN L (number of points in window)
 */
void FLAC__window_bartlett(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_bartlett_hann(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_blackman(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_blackman_harris_4term_92db_sidelobe(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_connes(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_flattop(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_gauss(FLAC__real *window, const FLAC__int32 L, const FLAC__real stddev); /* 0.0 < stddev <= 0.5 */
void FLAC__window_hamming(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_hann(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_kaiser_bessel(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_nuttall(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_rectangle(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_triangle(FLAC__real *window, const FLAC__int32 L);
void FLAC__window_tukey(FLAC__real *window, const FLAC__int32 L, const FLAC__real p);
void FLAC__window_welch(FLAC__real *window, const FLAC__int32 L);

#endif /* !defined FLAC__INTEGER_ONLY_LIBRARY */

#endif
