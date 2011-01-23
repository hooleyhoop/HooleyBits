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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stream_encoder.h"

static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

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
	FLAC__bool ok = true;
	FLAC__StreamEncoder *encoder = 0;
	FLAC__StreamEncoderInitStatus init_status;

	FILE *fin;
	unsigned sample_rate = 0;
	unsigned bps = 0;
	unsigned compressionCode = 0;
	unsigned channelCount = 0;
	unsigned averageBytesPerSecond = 0;
	unsigned blockAlign = 0;
	
    char *inputFilename = "/recording_mono.wav";
    char *outputFilename = "/Users/shooley/Desktop/recording_mono.flac";
    
//	if(argc != 3) {
//		fprintf(stderr, "usage: %s infile.wav outfile.flac\n", inputFilename );
//		return 1;
//	}

	if( (fin=fopen(inputFilename, "rb") )==NULL ) {
		fprintf(stderr, "ERROR: opening %s for output\n", inputFilename);
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
	FLAC__int32 chunkLength = int32( header_start, chunkPos );
	
	// Read all chunks
	int exitLoop = 0;
	while( !exitLoop ){
		
		// check exit conditions
		if( memcmp( (void *)&chunkName, "data", 4)==0 )
			break;
		
		// -exit condition (remaining bytes==0)

		// copy the chunk and process it
		int chunkLengthAndNextChunkNameAndLength = chunkLength+8;
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
			chunkPos += chunkLength;
		}
		
		// setup next loop
		chunkName = int32( chunkData, chunkPos );
		chunkPos +=4;	
		chunkLength = int32( chunkData, chunkPos );
	}

	// we have reached the data section
	int bytesPerSample = bps/8;
	FLAC__byte buffer[READSIZE * bytesPerSample * channelCount]; /* we read the WAVE data into here */
	FLAC__int32 pcm[READSIZE/*samples*/ * channelCount];
   	unsigned total_samples = chunkLength / (2*channelCount);

	/* allocate the encoder */
	if((encoder = FLAC__stream_encoder_new()) == NULL) {
		fprintf(stderr, "ERROR: allocating encoder\n");
		fclose(fin);
		return 1;
	}

	//ok &= FLAC__stream_encoder_set_verify(encoder, true);
	ok &= FLAC__stream_encoder_set_compression_level( encoder, 5 );
	ok &= FLAC__stream_encoder_set_channels( encoder, channelCount );
	ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, bps );
	ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
	ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples );

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
		init_status = FLAC__stream_encoder_init_file( encoder, outputFilename, progress_callback, /*client_data=*/NULL );
		if(init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK) {
			fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
			ok = false;
		}
	}

	/* read blocks of samples from WAVE file and feed to encoder */
	if(ok) {
		size_t left = (size_t)total_samples;
		while(ok && left) {
			size_t need = (left>READSIZE? (size_t)READSIZE : (size_t)left);
			
			int amountToRead = channelCount*(bps/8);
			if( fread(buffer, amountToRead, need, fin) != need ) {
				filePos += amountToRead;
				fprintf(stderr, "ERROR: reading from WAVE file\n");
				ok = false;
			}
			else {
				/* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
				size_t i;
                
                if( (need*channelCount) > READSIZE*2 )
                    fprintf( stderr, "ERROR: why dont i know what is going on?\n" );
                    
				for(i = 0; i <need*channelCount; i++) {
					/* inefficient but simple and works on big- or little-endian machines */
                    
                    // we need 2 byte values for each 16bit input sample 
                    //FLAC__int8 byte1 = buffer[2*i+1];
                    //FLAC__int8 byte2 = buffer[2*i];
                    //FLAC__int16 inVal = (((FLAC__int16)(FLAC__int8)byte1 << 8) | (FLAC__int16)byte2);
                    //pcm[i] = (FLAC__int32)inVal;
                    
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)buffer[2*i+1] << 8) | (FLAC__int16)buffer[2*i]);
                    
				}
				/* feed samples to encoder */
                // ok = FLAC__stream_encoder_process_interleaved(encoder, pcm, need);
    
                FLAC__int32 *pcm_ptr = pcm;
                FLAC__int32 **pcm_ptr_ptr = &pcm_ptr;
    
                
                ok = FLAC__stream_encoder_process( encoder, pcm_ptr_ptr, need );
                
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

	return 0;
}

void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data)
{
//	(void)encoder, (void)client_data;
//	 fprintf(stderr, "wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, total_samples, frames_written, total_frames_estimate);
}
