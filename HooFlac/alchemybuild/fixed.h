
#ifndef FLAC__PRIVATE__FIXED_H
#define FLAC__PRIVATE__FIXED_H


#include "float.h"
#include "format.h"

/*
 *	FLAC__fixed_compute_best_predictor()
 *	--------------------------------------------------------------------
 *	Compute the best fixed predictor and the expected bits-per-sample
 *  of the residual signal for each order.  The _wide() version uses
 *  64-bit integers which is statistically necessary when bits-per-
 *  sample + log2(blocksize) > 30
 *
 *	IN data[0,data_len-1]
 *	IN data_len
 *	OUT residual_bits_per_sample[0,FLAC__MAX_FIXED_ORDER]
 */

unsigned FLAC__fixed_compute_best_predictor(const FLAC__int32 data[], unsigned data_len, FLAC__float residual_bits_per_sample[FLAC__MAX_FIXED_ORDER+1]);
unsigned FLAC__fixed_compute_best_predictor_wide(const FLAC__int32 data[], uint32_t data_len, FLAC__float residual_bits_per_sample[FLAC__MAX_FIXED_ORDER+1]);


/*
 *	FLAC__fixed_compute_residual()
 *	--------------------------------------------------------------------
 *	Compute the residual signal obtained from sutracting the predicted
 *	signal from the original.
 *
 *	IN data[-order,data_len-1]        original signal (NOTE THE INDICES!)
 *	IN data_len                       length of original signal
 *	IN order <= FLAC__MAX_FIXED_ORDER fixed-predictor order
 *	OUT residual[0,data_len-1]        residual signal
 */
void FLAC__fixed_compute_residual(const FLAC__int32 data[], unsigned data_len, unsigned order, FLAC__int32 residual[]);

/*
 *	FLAC__fixed_restore_signal()
 *	--------------------------------------------------------------------
 *	Restore the original signal by summing the residual and the
 *	predictor.
 *
 *	IN residual[0,data_len-1]         residual signal
 *	IN data_len                       length of original signal
 *	IN order <= FLAC__MAX_FIXED_ORDER fixed-predictor order
 *	*** IMPORTANT: the caller must pass in the historical samples:
 *	IN  data[-order,-1]               previously-reconstructed historical samples
 *	OUT data[0,data_len-1]            original signal
 */
void FLAC__fixed_restore_signal(const FLAC__int32 residual[], unsigned data_len, unsigned order, FLAC__int32 data[]);

#endif
