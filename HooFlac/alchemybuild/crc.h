
#ifndef FLAC__PRIVATE__CRC_H
#define FLAC__PRIVATE__CRC_H

#include "ordinals.h"

/* 8 bit CRC generator, MSB shifted first
** polynomial = x^8 + x^2 + x^1 + x^0
** init = 0
*/
extern FLAC__byte const FLAC__crc8_table[256];
#define FLAC__CRC8_UPDATE(data, crc) (crc) = FLAC__crc8_table[(crc) ^ (data)];
void FLAC__crc8_update(const FLAC__byte data, FLAC__uint8 *crc);
void FLAC__crc8_update_block(const FLAC__byte *data, unsigned len, FLAC__uint8 *crc);
FLAC__uint8 FLAC__crc8(const FLAC__byte *data, unsigned len);

/* 16 bit CRC generator, MSB shifted first
** polynomial = x^16 + x^15 + x^2 + x^0
** init = 0
*/
extern unsigned FLAC__crc16_table[256];

#define FLAC__CRC16_UPDATE(data, crc) (((((crc)<<8) & 0xffff) ^ FLAC__crc16_table[((crc)>>8) ^ (data)]))
/* this alternate may be faster on some systems/compilers */


unsigned FLAC__crc16(const FLAC__byte *data, unsigned len);

#endif
