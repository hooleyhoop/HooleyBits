
#ifndef FLAC__PRIVATE__LPC_H
#define FLAC__PRIVATE__LPC_H


#include "float.h"
#include "format.h"

/*
 *	FLAC__lpc_window_data()
 *	--------------------------------------------------------------------
 *	Applies the given window to the data.
 *  OPT: asm implementation
 *
 *	IN in[0,data_len-1]
 *	IN window[0,data_len-1]
 *	OUT out[0,lag-1]
 *	IN data_len
 */
void FLAC__lpc_window_data(const FLAC__int32 in[], const FLAC__real window[], FLAC__real out[], unsigned data_len);

/*
 *	FLAC__lpc_compute_autocorrelation()
 *	--------------------------------------------------------------------
 *	Compute the autocorrelation for lags between 0 and lag-1.
 *	Assumes data[] outside of [0,data_len-1] == 0.
 *	Asserts that lag > 0.
 *
 *	IN data[0,data_len-1]
 *	IN data_len
 *	IN 0 < lag <= data_len
 *	OUT autoc[0,lag-1]
 */
void FLAC__lpc_compute_autocorrelation(const FLAC__real data[], unsigned data_len, unsigned lag, FLAC__real autoc[]);

/*
 *	FLAC__lpc_compute_lp_coefficients()
 *	--------------------------------------------------------------------
 *	Computes LP coefficients for orders 1..max_order.
 *	Do not call if autoc[0] == 0.0.  This means the signal is zero
 *	and there is no point in calculating a predictor.
 *
 *	IN autoc[0,max_order]                      autocorrelation values
 *	IN 0 < max_order <= FLAC__MAX_LPC_ORDER    max LP order to compute
 *	OUT lp_coeff[0,max_order-1][0,max_order-1] LP coefficients for each order
 *	*** IMPORTANT:
 *	*** lp_coeff[0,max_order-1][max_order,FLAC__MAX_LPC_ORDER-1] are untouched
 *	OUT error[0,max_order-1]                   error for each order (more
 *	                                           specifically, the variance of
 *	                                           the error signal times # of
 *	                                           samples in the signal)
 *
 *	Example: if max_order is 9, the LP coefficients for order 9 will be
 *	         in lp_coeff[8][0,8], the LP coefficients for order 8 will be
 *			 in lp_coeff[7][0,7], etc.
 */
void FLAC__lpc_compute_lp_coefficients(const FLAC__real autoc[], unsigned *max_order, FLAC__real lp_coeff[][FLAC__MAX_LPC_ORDER], FLAC__double error[]);

/*
 *	FLAC__lpc_quantize_coefficients()
 *	--------------------------------------------------------------------
 *	Quantizes the LP coefficients.  NOTE: precision + bits_per_sample
 *	must be less than 32 (sizeof(FLAC__int32)*8).
 *
 *	IN lp_coeff[0,order-1]    LP coefficients
 *	IN order                  LP order
 *	IN FLAC__MIN_QLP_COEFF_PRECISION < precision
 *	                          desired precision (in bits, including sign
 *	                          bit) of largest coefficient
 *	OUT qlp_coeff[0,order-1]  quantized coefficients
 *	OUT shift                 # of bits to shift right to get approximated
 *	                          LP coefficients.  NOTE: could be negative.
 *	RETURN 0 => quantization OK
 *	       1 => coefficients require too much shifting for *shift to
 *              fit in the LPC subframe header.  'shift' is unset.
 *         2 => coefficients are all zero, which is bad.  'shift' is
 *              unset.
 */
int FLAC__lpc_quantize_coefficients(const FLAC__real lp_coeff[], unsigned order, unsigned precision, FLAC__int32 qlp_coeff[], int *shift);

/*
 *	FLAC__lpc_compute_residual_from_qlp_coefficients()
 *	--------------------------------------------------------------------
 *	Compute the residual signal obtained from sutracting the predicted
 *	signal from the original.
 *
 *	IN data[-order,data_len-1] original signal (NOTE THE INDICES!)
 *	IN data_len                length of original signal
 *	IN qlp_coeff[0,order-1]    quantized LP coefficients
 *	IN order > 0               LP order
 *	IN lp_quantization         quantization of LP coefficients in bits
 *	OUT residual[0,data_len-1] residual signal
 */
void FLAC__lpc_compute_residual_from_qlp_coefficients(const FLAC__int32 *data, unsigned data_len, const FLAC__int32 qlp_coeff[], unsigned order, int lp_quantization, FLAC__int32 residual[]);
void FLAC__lpc_compute_residual_from_qlp_coefficients_wide(const FLAC__int32 *data, unsigned data_len, const FLAC__int32 qlp_coeff[], unsigned order, int lp_quantization, FLAC__int32 residual[]);

/*
 *	FLAC__lpc_restore_signal()
 *	--------------------------------------------------------------------
 *	Restore the original signal by summing the residual and the
 *	predictor.
 *
 *	IN residual[0,data_len-1]  residual signal
 *	IN data_len                length of original signal
 *	IN qlp_coeff[0,order-1]    quantized LP coefficients
 *	IN order > 0               LP order
 *	IN lp_quantization         quantization of LP coefficients in bits
 *	*** IMPORTANT: the caller must pass in the historical samples:
 *	IN  data[-order,-1]        previously-reconstructed historical samples
 *	OUT data[0,data_len-1]     original signal
 */
void FLAC__lpc_restore_signal(const FLAC__int32 residual[], unsigned data_len, const FLAC__int32 qlp_coeff[], unsigned order, int lp_quantization, FLAC__int32 data[]);
void FLAC__lpc_restore_signal_wide(const FLAC__int32 residual[], unsigned data_len, const FLAC__int32 qlp_coeff[], unsigned order, int lp_quantization, FLAC__int32 data[]);

/*
 *	FLAC__lpc_compute_expected_bits_per_residual_sample()
 *	--------------------------------------------------------------------
 *	Compute the expected number of bits per residual signal sample
 *	based on the LP error (which is related to the residual variance).
 *
 *	IN lpc_error >= 0.0   error returned from calculating LP coefficients
 *	IN total_samples > 0  # of samples in residual signal
 *	RETURN                expected bits per sample
 */
FLAC__double FLAC__lpc_compute_expected_bits_per_residual_sample(FLAC__double lpc_error, unsigned total_samples);
FLAC__double FLAC__lpc_compute_expected_bits_per_residual_sample_with_error_scale(FLAC__double lpc_error, FLAC__double error_scale);

/*
 *	FLAC__lpc_compute_best_order()
 *	--------------------------------------------------------------------
 *	Compute the best order from the array of signal errors returned
 *	during coefficient computation.
 *
 *	IN lpc_error[0,max_order-1] >= 0.0  error returned from calculating LP coefficients
 *	IN max_order > 0                    max LP order
 *	IN total_samples > 0                # of samples in residual signal
 *	IN overhead_bits_per_order          # of bits overhead for each increased LP order
 *	                                    (includes warmup sample size and quantized LP coefficient)
 *	RETURN [1,max_order]                best order
 */
unsigned FLAC__lpc_compute_best_order(const FLAC__double lpc_error[], unsigned max_order, unsigned total_samples, unsigned overhead_bits_per_order);

#endif
