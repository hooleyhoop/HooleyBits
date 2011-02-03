
#ifndef FLAC__PRIVATE__BITREADER_H
#define FLAC__PRIVATE__BITREADER_H

#include <stdio.h> /* for FILE */
#include "ordinals.h"
#include "cpu.h"

/*
 * opaque structure definition
 */
struct FLAC__BitReader;
typedef struct FLAC__BitReader FLAC__BitReader;

typedef FLAC__bool (*FLAC__BitReaderReadCallback)(FLAC__byte buffer[], size_t *bytes, void *client_data);

/*
 * construction, deletion, initialization, etc functions
 */
FLAC__BitReader *FLAC__bitreader_new(void);
void FLAC__bitreader_delete(FLAC__BitReader *br);
FLAC__bool FLAC__bitreader_init(FLAC__BitReader *br, FLAC__CPUInfo cpu, FLAC__BitReaderReadCallback rcb, void *cd);
void FLAC__bitreader_free(FLAC__BitReader *br); /* does not 'free(br)' */
FLAC__bool FLAC__bitreader_clear(FLAC__BitReader *br);
//void FLAC__bitreader_dump(const FLAC__BitReader *br, FILE *out);

/*
 * CRC functions
 */
void FLAC__bitreader_reset_read_crc16(FLAC__BitReader *br, FLAC__uint16 seed);
FLAC__uint16 FLAC__bitreader_get_read_crc16(FLAC__BitReader *br);

/*
 * info functions
 */
FLAC__bool FLAC__bitreader_is_consumed_byte_aligned(const FLAC__BitReader *br);
unsigned FLAC__bitreader_bits_left_for_byte_alignment(const FLAC__BitReader *br);
unsigned FLAC__bitreader_get_input_bits_unconsumed(const FLAC__BitReader *br);

/*
 * read functions
 */

FLAC__bool FLAC__bitreader_read_raw_uint32(FLAC__BitReader *br, FLAC__uint32 *val, unsigned bits);
FLAC__bool FLAC__bitreader_read_raw_int32(FLAC__BitReader *br, FLAC__int32 *val, unsigned bits);
FLAC__bool FLAC__bitreader_read_raw_uint64(FLAC__BitReader *br, FLAC__uint64 *val, unsigned bits);
FLAC__bool FLAC__bitreader_read_uint32_little_endian(FLAC__BitReader *br, FLAC__uint32 *val); /*only for bits=32*/
FLAC__bool FLAC__bitreader_skip_bits_no_crc(FLAC__BitReader *br, unsigned bits); /* WATCHOUT: does not CRC the skipped data! */ /*@@@@ add to unit tests */
FLAC__bool FLAC__bitreader_skip_byte_block_aligned_no_crc(FLAC__BitReader *br, unsigned nvals); /* WATCHOUT: does not CRC the read data! */
FLAC__bool FLAC__bitreader_read_byte_block_aligned_no_crc(FLAC__BitReader *br, FLAC__byte *val, unsigned nvals); /* WATCHOUT: does not CRC the read data! */
FLAC__bool FLAC__bitreader_read_unary_unsigned(FLAC__BitReader *br, unsigned *val);
FLAC__bool FLAC__bitreader_read_rice_signed(FLAC__BitReader *br, int *val, unsigned parameter);
FLAC__bool FLAC__bitreader_read_rice_signed_block(FLAC__BitReader *br, int vals[], unsigned nvals, unsigned parameter);

FLAC__bool FLAC__bitreader_read_utf8_uint32(FLAC__BitReader *br, FLAC__uint32 *val, FLAC__byte *raw, unsigned *rawlen);
FLAC__bool FLAC__bitreader_read_utf8_uint64(FLAC__BitReader *br, FLAC__uint64 *val, FLAC__byte *raw, unsigned *rawlen);

FLAC__bool bitreader_read_from_client_(FLAC__BitReader *br);
#endif
