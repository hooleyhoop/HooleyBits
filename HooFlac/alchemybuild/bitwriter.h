
#ifndef FLAC__PRIVATE__BITWRITER_H
#define FLAC__PRIVATE__BITWRITER_H

#include <stdio.h> /* for FILE */
#include "ordinals.h"

/*
 * opaque structure definition
 */
struct FLAC__BitWriter;
typedef struct FLAC__BitWriter FLAC__BitWriter;

/*
 * construction, deletion, initialization, etc functions
 */
FLAC__BitWriter *FLAC__bitwriter_new(void);
void FLAC__bitwriter_delete(FLAC__BitWriter *bw);
FLAC__bool FLAC__bitwriter_init(FLAC__BitWriter *bw);
void FLAC__bitwriter_free(FLAC__BitWriter *bw); /* does not 'free(buffer)' */
void FLAC__bitwriter_clear(FLAC__BitWriter *bw);
//void FLAC__bitwriter_dump(const FLAC__BitWriter *bw, FILE *out);

/*
 * CRC functions
 *
 * non-const *bw because they have to cal FLAC__bitwriter_get_buffer()
 */
FLAC__bool FLAC__bitwriter_get_write_crc16(FLAC__BitWriter *bw, FLAC__uint16 *crc);
FLAC__bool FLAC__bitwriter_get_write_crc8(FLAC__BitWriter *bw, FLAC__byte *crc);

/*
 * info functions
 */
FLAC__bool FLAC__bitwriter_is_byte_aligned(const FLAC__BitWriter *bw);
unsigned FLAC__bitwriter_get_input_bits_unconsumed(const FLAC__BitWriter *bw); /* can be called anytime, returns total # of bits unconsumed */

/*
 * direct buffer access
 *
 * there may be no calls on the bitwriter between get and release.
 * the bitwriter continues to own the returned buffer.
 * before get, bitwriter MUST be byte aligned: check with FLAC__bitwriter_is_byte_aligned()
 */
FLAC__bool FLAC__bitwriter_get_buffer(FLAC__BitWriter *bw, const FLAC__byte **buffer, size_t *bytes);
void FLAC__bitwriter_release_buffer(FLAC__BitWriter *bw);

/*
 * write functions
 */
FLAC__bool FLAC__bitwriter_write_zeroes(FLAC__BitWriter *bw, unsigned bits);
FLAC__bool FLAC__bitwriter_write_raw_uint32(FLAC__BitWriter *bw, FLAC__uint32 val, unsigned bits);
FLAC__bool FLAC__bitwriter_write_raw_int32(FLAC__BitWriter *bw, FLAC__int32 val, unsigned bits);
FLAC__bool FLAC__bitwriter_write_raw_uint64(FLAC__BitWriter *bw, FLAC__uint64 val, unsigned bits);
FLAC__bool FLAC__bitwriter_write_raw_uint32_little_endian(FLAC__BitWriter *bw, FLAC__uint32 val); /*only for bits=32*/
FLAC__bool FLAC__bitwriter_write_byte_block(FLAC__BitWriter *bw, const FLAC__byte vals[], unsigned nvals);
FLAC__bool FLAC__bitwriter_write_unary_unsigned(FLAC__BitWriter *bw, unsigned val);
//unsigned FLAC__bitwriter_rice_bits(FLAC__int32 val, unsigned parameter);

FLAC__bool FLAC__bitwriter_write_rice_signed(FLAC__BitWriter *bw, FLAC__int32 val, unsigned parameter);
FLAC__bool FLAC__bitwriter_write_rice_signed_block(FLAC__BitWriter *bw, const FLAC__int32 *vals, unsigned nvals, unsigned parameter);

FLAC__bool FLAC__bitwriter_write_utf8_uint32(FLAC__BitWriter *bw, FLAC__uint32 val);
FLAC__bool FLAC__bitwriter_write_utf8_uint64(FLAC__BitWriter *bw, FLAC__uint64 val);
FLAC__bool FLAC__bitwriter_zero_pad_to_byte_boundary(FLAC__BitWriter *bw);

#endif
