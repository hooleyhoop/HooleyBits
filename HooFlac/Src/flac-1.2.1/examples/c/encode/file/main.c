/* example_c_encode_file - Simple FLAC file encoder using libFLAC
 * Copyright (C) 2007  Josh Coalson
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

/*
 * This example shows how to use libFLAC to encode a WAVE file to a FLAC
 * file.  It only supports 16-bit stereo files in canonical WAVE format.
 *
 * Complete API documentation can be found at:
 *   http://flac.sourceforge.net/api/
 */
#include "HooHelper.h"
#include "assert.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stream_encoder.h"
#include "stream_decoder.h"

FLAC__StreamDecoderWriteStatus write_callback(const FLAC__StreamDecoder *decoder, const FLAC__Frame *frame, const FLAC__int32 * const buffer[], void *client_data);
void metadata_callback(const FLAC__StreamDecoder *decoder, const FLAC__StreamMetadata *metadata, void *client_data);
void error_callback(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data);

static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

static int _ab_offset = 0;
static int _begun = 0;
FILE *_logFile;

static FLAC__StreamEncoderWriteStatus FLACStreamEncoderWriteCallback(const FLAC__StreamEncoder *ASncoder, const FLAC__byte ABuffer[], size_t ABytes, unsigned ABamples, unsigned ACurrentFrame, void *clientData) {
    
 //   AS3_Val *destinationByteArrayPtr = clientData;
    
//	int result = AS3_ByteArray_writeBytes( *destinationByteArrayPtr, (char *)ABuffer, ABytes );
    
 //   AS3_Val pos = AS3_GetS( *destinationByteArrayPtr, "position" );    
//    fprintf( stderr, "WRITE %i bytes callback result=%i Pos now %i \n", ABytes, result, AS3_IntValue(pos) );
    if (_begun )
	{
        static int writeCount=0;
        hooFileLog( "WRITE FIRST BATCH\n", NULL );
        if( writeCount++ == 4 ){
            // exit(0);
        }
		for(int ii=0; ii<ABytes; ii++ ){
		//        int val = (int)ABuffer[ii];
		//        if( val!=0 ){
		//            nonZeroBytes++;
		//            fprintf( stderr, "%i nonZeroBytes Jimmyny\n", nonZeroBytes  );
		//        }
		}
	}
    static int nonZeroBytes = 0;

    _ab_offset+=ABytes;
    
    //	fwrite(ABuffer, sizeof(FLAC__byte), ABytes, AOwner->FCFile);
    //	if(ferror(AOwner->FCFile))
    //		return FLAC__STREAM_ENCODER_WRITE_STATUS_FATAL_ERROR;
    //	else
    
    
    //    int i;
    //    fprintf( stderr, "WRITE callback %i Bytes \n", (int)ABytes );
    //    
    //    for(i=0; i<10; i++)
    //        fprintf( stderr, "WRITE callback %i \n", (int)ABuffer[i] );
    
    return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;
}

static FLAC__StreamEncoderSeekStatus FLACStreamEncoderSeekCallback(const FLAC__StreamEncoder *AEncoder, FLAC__uint64 AAbsoluteByteOffset, void *clientData) {
    
//   AS3_Val *destinationByteArrayPtr = clientData;
    
    fprintf( stderr, "SEEK callback -- %i\n", (int)AAbsoluteByteOffset );
    _ab_offset = (int)AAbsoluteByteOffset;
	
//	if( AS3_ByteArray_seek( *destinationByteArrayPtr, (int)AAbsoluteByteOffset, SEEK_SET ) < 0)
//		return FLAC__STREAM_ENCODER_SEEK_STATUS_ERROR;
    
    return FLAC__STREAM_ENCODER_SEEK_STATUS_OK;
}

static FLAC__StreamEncoderTellStatus FLACStreamEncoderTellCallback(const FLAC__StreamEncoder *AEncoder, FLAC__uint64 *AAbsoluteByteOffset, void *clientData) {
    
 //   AS3_Val *destinationByteArrayPtr = clientData;
    
    //	__int64 Pos;
    //	if((Pos = _ftelli64(AOwner->FCFile)) < 0) {
    //		return FLAC__STREAM_ENCODER_TELL_STATUS_ERROR;
    //	} else {
    //		*AAbsoluteByteOffset = (FLAC__uint64)Pos;
    
//    AS3_Val pos = AS3_GetS( *destinationByteArrayPtr, "position" );
    *AAbsoluteByteOffset = (FLAC__uint64)_ab_offset;
    
    return FLAC__STREAM_ENCODER_TELL_STATUS_OK;
    //	}
}





#define READSIZE 1024

FLAC__int16 int16( FLAC__byte *data, int offset ) {
	FLAC__int16 val = ((( data[offset+1]) << 8) | data[offset] );
	return val;
}

FLAC__int32 int32( FLAC__byte *data, int offset ) {
	FLAC__int32 val = (((((((unsigned)data[offset+3] << 8) | data[offset+2]) << 8) | data[offset+1]) << 8) | data[offset] );
	return val;
}

int main(int argc, char *argv[])
{
    int magicVal = 66;    
    fprintf( stderr, "arggg val=%0x --- swapped val=%0x \n", (int)magicVal, ntohl(magicVal) );
    
	FLAC__bool ok = true;
	FLAC__StreamEncoder *encoder = 0;
	FLAC__StreamEncoderInitStatus encoder_init_status;

	FILE *fin;
	unsigned sample_rate = 0;
	unsigned bps = 0;
	unsigned compressionCode = 0;
	unsigned channelCount = 0;
	unsigned averageBytesPerSecond = 0;
	unsigned blockAlign = 0;
	
    const char *wavInputFilename = "/Users/shooley/Desktop/recording_mono.wav";
    const char *flacOutputFilename = "/Users/shooley/Desktop/recording_mono.flac";
    const char *logFilename = "/Users/shooley/Desktop/log_flac.txt";

	_logFile = fopen( logFilename, "w" );
	if( _logFile==NULL ) {
		printf("Error opening %s for writing. Program terminated.", logFilename );
		abort();
	}
		

	

	
	
//	if(argc != 3) {
//		return 1;
//	}

	if( (fin=fopen(wavInputFilename, "rb") )==NULL ) {
		fprintf(stderr, "ERROR: opening %s for input\n", wavInputFilename);
		return 1;
	}

	/* read wav header and validate it */
	
	// The first bit of a wav is always the same
	FLAC__byte header_start[20];
	int chunkPos = 0;	
	fread( header_start, 1, 20, fin );
	int filePos = 20;
	
	if( memcmp( header_start, "RIFF", 4)!=0 ) {
		fprintf(stderr, "ERROR: Invalid file?\n" );
		return 1;		
	}
	chunkPos +=4;	
	FLAC__int32 fileLength = int32( header_start, chunkPos ) +8; // The eight is the RIFF 8909909 that proceeded this line
	
	chunkPos +=4;		
	if( memcmp( header_start+chunkPos, "WAVE", 4)!=0 ) {
		fprintf(stderr, "ERROR: Invalid file?\n" );
		return 1;		
	}
	
	// ok so far! The next 4 bytes are the name of the next chunk, the next 4 bytes the length of the following chunk
	chunkPos +=4;		
	FLAC__int32 chunkName = int32( header_start, chunkPos );
	
	chunkPos +=4;	
	FLAC__int32 chunkLengthBytes = int32( header_start, chunkPos );
	
	// Read all chunks
	int exitLoop = 0;
	while( !exitLoop ){
		
		// check exit conditions
		if( memcmp( (void *)&chunkName, "data", 4)==0 )
			break;
		
		// -exit condition (remaining bytes==0)

		// copy the chunk and process it
		int chunkLengthAndNextChunkNameAndLength = chunkLengthBytes+8;
		FLAC__byte chunkData[chunkLengthAndNextChunkNameAndLength];
		
		fread( chunkData, 1, chunkLengthAndNextChunkNameAndLength, fin );
		filePos+=chunkLengthAndNextChunkNameAndLength;
		
		chunkPos = 0;

		if( memcmp( (void *)&chunkName, "fmt ", 4)==0 ) {
	
			compressionCode = int16( chunkData, chunkPos );
				chunkPos +=2;
			channelCount = int16( chunkData, chunkPos );
				chunkPos +=2;			
			sample_rate = int32( chunkData, chunkPos );
				chunkPos +=4;			
			averageBytesPerSecond = int32( chunkData, chunkPos );
				chunkPos +=4;			
			blockAlign = int16( chunkData, chunkPos );
				chunkPos +=2;			
			bps = int16( chunkData, chunkPos );
				chunkPos +=2;			
		}
		
		else if( memcmp( (void *)&chunkName, "LIST", 4)==0 ) {
			// -- move to the end
			chunkPos += chunkLengthBytes;
		}
		
		// setup next loop
		chunkName = int32( chunkData, chunkPos );
		chunkPos +=4;	
		chunkLengthBytes = int32( chunkData, chunkPos );
	}

	// we have reached the data section
    
    // remember - each input sample is 16 bits long.. sooo
    unsigned absolute_total_samples = chunkLengthBytes / 2;
   	unsigned total_samples_per_channel = absolute_total_samples / channelCount;

	/* allocate the encoder */
	if( (encoder = FLAC__stream_encoder_new())== NULL ) {
		fprintf(stderr, "ERROR: allocating encoder\n");
		fclose(fin);
		return 1;
	}

    int assertTest = 0;
    FLAC__ASSERT(assertTest);

	//ok &= FLAC__stream_encoder_set_verify(encoder, true);
	ok &= FLAC__stream_encoder_set_compression_level( encoder, 5 );
	ok &= FLAC__stream_encoder_set_channels( encoder, channelCount );
	ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, bps );
	ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
	ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples_per_channel );

	/* now add some metadata; we'll add some tags and a padding block */
//	if(ok) {
//		if(
//			(metadata[0] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_VORBIS_COMMENT)) == NULL ||
//			(metadata[1] = FLAC__metadata_object_new(FLAC__METADATA_TYPE_PADDING)) == NULL ||
//			/* there are many tag (vorbiscomment) functions but these are convenient for this particular use: */
//			!FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry, "ARTIST", "Some Artist") ||
//			!FLAC__metadata_object_vorbiscomment_append_comment(metadata[0], entry, /*copy=*/false) || /* copy=false: let metadata object take control of entry's allocated string */
//			!FLAC__metadata_object_vorbiscomment_entry_from_name_value_pair(&entry, "YEAR", "1984") ||
//			!FLAC__metadata_object_vorbiscomment_append_comment(metadata[0], entry, /*copy=*/false)
//		) {
//			fprintf(stderr, "ERROR: out of memory or tag error\n");
//			ok = false;
//		}
//
//		metadata[1]->length = 1234; /* set the padding length */
//
//		ok = FLAC__stream_encoder_set_metadata(encoder, metadata, 2);
//	}


    
    
	/* initialize encoder */
	if(ok) {
        encoder_init_status = FLAC__stream_encoder_init_file( encoder, flacOutputFilename, progress_callback, /*client_data=*/NULL );
  //stream out      encoder_init_status = FLAC__stream_encoder_init_stream( encoder, FLACStreamEncoderWriteCallback, FLACStreamEncoderSeekCallback, FLACStreamEncoderTellCallback, NULL, (void *)NULL );
        
		if( encoder_init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
			fprintf( stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[encoder_init_status]);
			ok = false;
		}
	}

	int bytesPerSample = bps/8;
    int in_bufferSize = READSIZE * bytesPerSample * channelCount;   // 2048 bytes
    FLAC__byte *in_buffer = calloc( sizeof(FLAC__byte), in_bufferSize );  /* we read the WAVE data into here */

    int pcm_buffer_size = READSIZE/*samples*/ * channelCount;       // 1024 ints
    FLAC__int32 *pcm = calloc( sizeof(FLAC__int32), pcm_buffer_size );
    
	/* read blocks of samples from WAVE file and feed to encoder */
	if(ok)
    {
		size_t left = (size_t)total_samples_per_channel;
		while( ok && left )
        {
			size_t need = (left>READSIZE? (size_t)READSIZE : (size_t)left);
			
            fprintf( stderr, "About to READ FROM %i -- %i \n", (int)ftell(fin), (int)(need*channelCount*bytesPerSample) );            
            size_t readSuccess = fread( in_buffer, channelCount*bytesPerSample, need, fin );
            
            filePos += need;
            
			if( readSuccess!= need ) {
				fprintf(stderr, "ERROR: reading from WAVE file\n");
				ok = false;
			}
			else {
				/* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
				size_t i;

                int limitIndex = need*channelCount;
                int max_read_index = 2*limitIndex+1;
                
                // go through buffer 2 bytes at a time converting to 16 bit sample (ie 2048 bytes becomes 1024 samples)
				for( i=0; i <limitIndex; i++ )
                {
					/* inefficient but simple and works on big- or little-endian machines */
                    
                    // we need 2 byte values for each 16bit input sample 
                    //FLAC__int8 byte1 = buffer[2*i+1];
                    //FLAC__int8 byte2 = buffer[2*i];
                    //FLAC__int16 inVal = (((FLAC__int16)(FLAC__int8)byte1 << 8) | (FLAC__int16)byte2);
                    //pcm[i] = (FLAC__int32)inVal;
                    
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)in_buffer[2*i+1] << 8) | (FLAC__int16)in_buffer[2*i]);
//                    fprintf( stderr, "11 INTEGER SIGNAL VALIDITY TEST %i %i \n", i, 2*i+1 );            
//PASS                    
//                    static int printLimit = 0;
//                    if( printLimit<20 ) {
//                        fprintf( stderr, "%i) inputSample %i \n", printLimit, pcm[i] );
//                        printLimit++;
//                    }	                      
				}
				/* feed samples to encoder */
                // ok = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
                
                FLAC__int32 **arrayOfArrays = &pcm;
                
                FLAC__int32 aaaaaaa = (FLAC__int16)in_buffer[2*512];
                FLAC__int32 bbbbbbb = (FLAC__int8)in_buffer[2*512+1];
//                fprintf( stderr, "10 INTEGER SIGNAL VALIDITY TEST %i %i \n", aaaaaaa, bbbbbbb );            
                // exit(0);
                _begun = 1;
                ok = FLAC__stream_encoder_process( encoder, (int const *const *)arrayOfArrays, need );
                
			}
			left -= need;
		}
	}

	ok &= FLAC__stream_encoder_finish(encoder);

	fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
	fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);

	/* now that encoding is finished, the metadata can be freed */
//	FLAC__metadata_object_delete(metadata[0]);
//	FLAC__metadata_object_delete(metadata[1]);

	FLAC__stream_encoder_delete(encoder);
	fclose(fin);
	fclose( _logFile );
    free(in_buffer);
    free(pcm);
    
    /* 
     * 
     * 
     * 
     * ATTEMPT DECODE! 
     *
     *
     *
     *
     *
     */
	FILE *fout;
    const char *flacInputFileName = flacOutputFilename;
    const char *rawOutputFilename = "/Users/shooley/Desktop/recording_mono_raw.raw";

	if((fout = fopen( rawOutputFilename, "wb")) == NULL) {
		fprintf(stderr, "ERROR: opening %s for output\n", argv[2]);
		return 1;
	}
    
	FLAC__StreamDecoder *decoder = decoder = FLAC__stream_decoder_new();
	FLAC__StreamDecoderInitStatus decoder_init_status;
    
    (void)FLAC__stream_decoder_set_md5_checking(decoder, true);
	decoder_init_status = FLAC__stream_decoder_init_file(decoder, flacInputFileName, write_callback, metadata_callback, error_callback, /*client_data=*/fout);
	if(decoder_init_status != FLAC__STREAM_DECODER_INIT_STATUS_OK) {
		fprintf(stderr, "ERROR: initializing decoder: %s\n", FLAC__StreamDecoderInitStatusString[decoder_init_status]);
		ok = false;
	}    
    
	if(ok) {
		ok = FLAC__stream_decoder_process_until_end_of_stream(decoder);
		fprintf(stderr, "decoding: %s\n", ok? "succeeded" : "FAILED");
		fprintf(stderr, "   state: %s\n", FLAC__StreamDecoderStateString[FLAC__stream_decoder_get_state(decoder)]);
	}
    
	FLAC__stream_decoder_delete(decoder);
	fclose(fout);
    
	return 0;
}

static FLAC__uint64 total_samples = 0;
static unsigned sample_rate = 0;
static unsigned channels = 0;
static unsigned bps = 0;

FLAC__StreamDecoderWriteStatus write_callback(const FLAC__StreamDecoder *decoder, const FLAC__Frame *frame, const FLAC__int32 * const buffer[], void *client_data) {

	FILE *f = (FILE*)client_data;
	const FLAC__uint32 total_size = (FLAC__uint32)(total_samples * channels * (bps/8));
	size_t i;
    
	(void)decoder;
    
	if(total_samples == 0) {
		fprintf(stderr, "ERROR: this example only works for FLAC files that have a total_samples count in STREAMINFO\n");
		return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
	}
	if(channels!=1 /*!= 2*/ || bps != 16) {
		fprintf(stderr, "ERROR: this example only supports 16bit mono streams\n");
		return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
	}
    
	/* write WAVE header before we write the first frame */
//	if(frame->header.number.sample_number == 0) {
//		if(
//           fwrite("RIFF", 1, 4, f) < 4 ||
//           !write_little_endian_uint32(f, total_size + 36) ||
//           fwrite("WAVEfmt ", 1, 8, f) < 8 ||
//           !write_little_endian_uint32(f, 16) ||
//           !write_little_endian_uint16(f, 1) ||
//           !write_little_endian_uint16(f, (FLAC__uint16)channels) ||
//           !write_little_endian_uint32(f, sample_rate) ||
//           !write_little_endian_uint32(f, sample_rate * channels * (bps/8)) ||
//           !write_little_endian_uint16(f, (FLAC__uint16)(channels * (bps/8))) || /* block align */
//           !write_little_endian_uint16(f, (FLAC__uint16)bps) ||
//           fwrite("data", 1, 4, f) < 4 ||
//           !write_little_endian_uint32(f, total_size)
//           ) {
//			fprintf(stderr, "ERROR: write error\n");
//			return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
//		}
//	}
    
	/* write decoded PCM samples */
	for(i = 0; i < frame->header.blocksize; i++) {
//		if(
//           !write_little_endian_int16(f, (FLAC__int16)buffer[0][i]) ||  /* left channel */
//           !write_little_endian_int16(f, (FLAC__int16)buffer[1][i])     /* right channel */
//           ) {
//			fprintf(stderr, "ERROR: write error\n");
//			return FLAC__STREAM_DECODER_WRITE_STATUS_ABORT;
//		}
	}
    
	return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

void metadata_callback(const FLAC__StreamDecoder *decoder, const FLAC__StreamMetadata *metadata, void *client_data) {
	(void)decoder, (void)client_data;
    
	/* print some stats */
	if(metadata->type == FLAC__METADATA_TYPE_STREAMINFO) {
		/* save for later */
		total_samples = metadata->data.stream_info.total_samples;
		sample_rate = metadata->data.stream_info.sample_rate;
		channels = metadata->data.stream_info.channels;
		bps = metadata->data.stream_info.bits_per_sample;
        
		fprintf(stderr, "sample rate    : %u Hz\n", sample_rate);
		fprintf(stderr, "channels       : %u\n", channels);
		fprintf(stderr, "bits per sample: %u\n", bps);
//#ifdef _MSC_VER
//		fprintf(stderr, "total samples  : %I64u\n", total_samples);
//#else
//		fprintf(stderr, "total samples  : %llu\n", total_samples);
//#endif
	}
}

void error_callback(const FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data)
{
	(void)decoder, (void)client_data;
    
	fprintf(stderr, "Got error callback: %s\n", FLAC__StreamDecoderErrorStatusString[status]);
}





void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data)
{
//	(void)encoder, (void)client_data;
//	 fprintf(stderr, "wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, total_samples, frames_written, total_frames_estimate);
}
