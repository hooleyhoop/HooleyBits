
#include <math.h>
#include <string.h>
#include "bitmath.h"
#include "fixed.h"
#include "assert.h"
#include "hooHacks.h"

#ifndef M_LN2
/* math.h in VC++ doesn't seem to have this (how Microsoft is that?) */
#error cunt
#define M_LN2 0.69314718055994530942
#endif

#ifdef min
#undef min
#endif
#define min(x,y) ((x) < (y)? (x) : (y))

#ifdef local_abs
#undef local_abs
#endif
#define local_abs(x) ((unsigned)((x)<0? -(x) : (x)))


unsigned FLAC__fixed_compute_best_predictor(const FLAC__int32 data[], unsigned data_len, FLAC__float residual_bits_per_sample[FLAC__MAX_FIXED_ORDER+1])
{
    static int printLimit = 0;
 
	FLAC__int32 last_error_0 = data[-1];
	FLAC__int32 last_error_1 = data[-1] - data[-2];
	FLAC__int32 last_error_2 = last_error_1 - (data[-2] - data[-3]);
	FLAC__int32 last_error_3 = last_error_2 - (data[-2] - 2*data[-3] + data[-4]);
	FLAC__int32 error, save;
	FLAC__uint32 total_error_0 = 0, total_error_1 = 0, total_error_2 = 0, total_error_3 = 0, total_error_4 = 0;
	unsigned i, order;

	for(i = 0; i < data_len; i++) {
		error  = data[i]     ; total_error_0 += local_abs(error);                      save = error;
		error -= last_error_0; total_error_1 += local_abs(error); last_error_0 = save; save = error;
		error -= last_error_1; total_error_2 += local_abs(error); last_error_1 = save; save = error;
		error -= last_error_2; total_error_3 += local_abs(error); last_error_2 = save; save = error;
		error -= last_error_3; total_error_4 += local_abs(error); last_error_3 = save;
	}

	if(total_error_0 < min(min(min(total_error_1, total_error_2), total_error_3), total_error_4))
		order = 0;
	else if(total_error_1 < min(min(total_error_2, total_error_3), total_error_4))
		order = 1;
	else if(total_error_2 < min(total_error_3, total_error_4))
		order = 2;
	else if(total_error_3 < total_error_4)
		order = 3;
	else
		order = 4;

	/* Estimate the expected number of bits per residual signal sample. */
	/* 'total_error*' is linearly related to the variance of the residual */
	/* signal, so we use it directly to compute E(|x|) */
	FLAC__ASSERT(data_len > 0 || total_error_0 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_1 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_2 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_3 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_4 == 0);

	residual_bits_per_sample[0] = (FLAC__float)((total_error_0 > 0) ? log(M_LN2 * (FLAC__double)total_error_0 / (FLAC__double)data_len) / M_LN2 : 0.0);
	residual_bits_per_sample[1] = (FLAC__float)((total_error_1 > 0) ? log(M_LN2 * (FLAC__double)total_error_1 / (FLAC__double)data_len) / M_LN2 : 0.0);
	residual_bits_per_sample[2] = (FLAC__float)((total_error_2 > 0) ? log(M_LN2 * (FLAC__double)total_error_2 / (FLAC__double)data_len) / M_LN2 : 0.0);
	residual_bits_per_sample[3] = (FLAC__float)((total_error_3 > 0) ? log(M_LN2 * (FLAC__double)total_error_3 / (FLAC__double)data_len) / M_LN2 : 0.0);
	residual_bits_per_sample[4] = (FLAC__float)((total_error_4 > 0) ? log(M_LN2 * (FLAC__double)total_error_4 / (FLAC__double)data_len) / M_LN2 : 0.0);

    // FAIL
    if( printLimit<20 ) {
        fprintf( stderr, "%i) residual_bits_per_sample = %f %f %f %f %f \n", printLimit, residual_bits_per_sample[0], residual_bits_per_sample[1], residual_bits_per_sample[2], residual_bits_per_sample[3], residual_bits_per_sample[4] );
        printLimit++;
    }
    
	return order;
}

unsigned FLAC__fixed_compute_best_predictor_wide( const FLAC__int32 data[], uint32_t data_len, FLAC__float residual_bits_per_sample[FLAC__MAX_FIXED_ORDER+1])
{
    FLAC__int32 last_error_0 = data[-1];
	FLAC__int32 last_error_1 = data[-1] - data[-2];
	FLAC__int32 last_error_2 = last_error_1 - (data[-2] - data[-3]);
	FLAC__int32 last_error_3 = last_error_2 - (data[-2] - 2*data[-3] + data[-4]);
	FLAC__int32 error, save;
	/* total_error_* are 64-bits to avoid overflow when encoding
	 * erratic signals when the bits-per-sample and blocksize are
	 * large.
	 */
    unsigned total_error_0 = 0, total_error_1 = 0, total_error_2 = 0, total_error_3 = 0, total_error_4 = 0;
    unsigned i, order;

	for(i = 0; i < data_len; i++) {
		error  = data[i]     ; total_error_0 += local_abs(error);                      save = error;
		error -= last_error_0; total_error_1 += local_abs(error); last_error_0 = save; save = error;
		error -= last_error_1; total_error_2 += local_abs(error); last_error_1 = save; save = error;
		error -= last_error_2; total_error_3 += local_abs(error); last_error_2 = save; save = error;
		error -= last_error_3; total_error_4 += local_abs(error); last_error_3 = save;
	}

	if(total_error_0 < min(min(min(total_error_1, total_error_2), total_error_3), total_error_4))
		order = 0;
	else if(total_error_1 < min(min(total_error_2, total_error_3), total_error_4))
		order = 1;
	else if(total_error_2 < min(total_error_3, total_error_4))
		order = 2;
	else if(total_error_3 < total_error_4)
		order = 3;
	else
		order = 4;

	/* Estimate the expected number of bits per residual signal sample. */
	/* 'total_error*' is linearly related to the variance of the residual */
	/* signal, so we use it directly to compute E(|x|) */
	FLAC__ASSERT(data_len > 0 || total_error_0 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_1 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_2 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_3 == 0);
	FLAC__ASSERT(data_len > 0 || total_error_4 == 0);

//    float t3 = total_error_0 / data_len;
//    float t1 =1 * t3;   
 //   float t2 = t1;
  //  residual_bits_per_sample[0] = (FLAC__float)((total_error_0 > 0) ? t2 : 0.0);

//    if( total_error_0 > 0 )
//        residual_bits_per_sample[0] = t2;
//    else
 //       residual_bits_per_sample[0] = 0.0f;
	residual_bits_per_sample[0] = (FLAC__float)((total_error_0 > 0) ? log(M_LN2 * (FLAC__double)total_error_0 / (FLAC__double)data_len) / M_LN2 : 0.0);
        
    residual_bits_per_sample[1] = (FLAC__float)((total_error_1 > 0) ? log(M_LN2 * (FLAC__double)total_error_1 / (FLAC__double)data_len) / M_LN2 : 0.0);
    residual_bits_per_sample[2] = (FLAC__float)((total_error_2 > 0) ? log(M_LN2 * (FLAC__double)total_error_2 / (FLAC__double)data_len) / M_LN2 : 0.0);
    residual_bits_per_sample[3] = (FLAC__float)((total_error_3 > 0) ? log(M_LN2 * (FLAC__double)total_error_3 / (FLAC__double)data_len) / M_LN2 : 0.0);
    residual_bits_per_sample[4] = (FLAC__float)((total_error_4 > 0) ? log(M_LN2 * (FLAC__double)total_error_4 / (FLAC__double)data_len) / M_LN2 : 0.0);

	return order;
}

void FLAC__fixed_compute_residual(const FLAC__int32 data[], unsigned data_len, unsigned order, FLAC__int32 residual[])
{
	const int idata_len = (int)data_len;
	int i;
    static int printLimit=0;

    if( printLimit<20 ) {
        fprintf( stderr, "%i) FLAC__fixed_compute_residual order = %i \n", printLimit, order );
        printLimit++;
    }
    
	switch(order) {
		case 0:
			FLAC__ASSERT(sizeof(residual[0]) == sizeof(data[0]));
			memcpy(residual, data, sizeof(residual[0])*data_len);
			break;
		case 1:
			for(i = 0; i < idata_len; i++)
				residual[i] = data[i] - data[i-1];
            if( printLimit<20 ) {
                fprintf( stderr, "%i) residual[0]=%i, residual[2]=%i, residual[4]=%i, \n", printLimit, residual[0], residual[2], residual[4] );
                printLimit++;
            }   
            
			break;
		case 2:
			for(i = 0; i < idata_len; i++){
				residual[i] = data[i] - data[i-1];
            }
          
			break;
		case 3:
			for(i = 0; i < idata_len; i++)
				residual[i] = data[i] - (((data[i-1]-data[i-2])<<1) + (data[i-1]-data[i-2])) - data[i-3];

			break;
		case 4:
			for(i = 0; i < idata_len; i++)
				residual[i] = data[i] - ((data[i-1]+data[i-3])<<2) + ((data[i-2]<<2) + (data[i-2]<<1)) + data[i-4];

			break;
		default:
			FLAC__ASSERT(0);
	}
}

void FLAC__fixed_restore_signal(const FLAC__int32 residual[], unsigned data_len, unsigned order, FLAC__int32 data[])
{
	int i, idata_len = (int)data_len;

	switch(order) {
		case 0:
			FLAC__ASSERT(sizeof(residual[0]) == sizeof(data[0]));
			memcpy(data, residual, sizeof(residual[0])*data_len);
			break;
		case 1:
			for(i = 0; i < idata_len; i++)
				data[i] = residual[i] + data[i-1];
			break;
		case 2:
			for(i = 0; i < idata_len; i++)
				data[i] = residual[i] + (data[i-1]<<1) - data[i-2];

			break;
		case 3:
			for(i = 0; i < idata_len; i++)
				data[i] = residual[i] + (((data[i-1]-data[i-2])<<1) + (data[i-1]-data[i-2])) + data[i-3];

			break;
		case 4:
			for(i = 0; i < idata_len; i++)
				data[i] = residual[i] + ((data[i-1]+data[i-3])<<2) - ((data[i-2]<<2) + (data[i-2]<<1)) - data[i-4];

			break;
		default:
			FLAC__ASSERT(0);
	}
}
