#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <AS3.h>
#include "hooHacks.h"
#include "stream_encoder.h"

#pragma mark -
#pragma mark Actionscript example

static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

#define READSIZE 1024

/* Woah these are so incredibly useful! Use a bytearray as a FILE */

/* Does a FILE * read against a ByteArray */
static int readByteArray(void *cookie, char *dst, int size) {
	return AS3_ByteArray_readBytes(dst, (AS3_Val)cookie, size);
}

/* Does a FILE * write against a ByteArray */
static int writeByteArray(void *cookie, const char *src, int size) {
	return AS3_ByteArray_writeBytes((AS3_Val)cookie, (char *)src, size);
}

/* Does a FILE * lseek against a ByteArray */
static fpos_t seekByteArray(void *cookie, fpos_t offs, int whence) {
	return AS3_ByteArray_seek((AS3_Val)cookie, offs, whence);
}

/* Does a FILE * close against a ByteArray */
static int closeByteArray(void * cookie) {
	AS3_Val zero = AS3_Int(0);
    
	/* just reset the position */
	AS3_SetS((AS3_Val)cookie, "position", zero);
	AS3_Release(zero);
	return 0;
}

static unsigned total_samples = 0; /* can use a 32-bit number due to WAVE size limitations */
static FLAC__byte buffer[READSIZE/*samples*/ * 2/*bytes_per_sample*/ * 2/*channels*/]; /* we read the WAVE data into here */
static FLAC__int32 pcm[READSIZE/*samples*/ * 2/*channels*/];


void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data) {
	(void)encoder, (void)client_data;
	fprintf( stderr, "wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, total_samples, frames_written, total_frames_estimate);
}

static FLAC__StreamEncoderWriteStatus FLACStreamEncoderWriteCallback(const FLAC__StreamEncoder *ASncoder, const FLAC__byte ABuffer[], size_t ABytes, unsigned ABamples, unsigned ACurrentFrame, void *clientData) {

    AS3_Val *destinationByteArrayPtr = clientData;
    
    AS3_Trace(*destinationByteArrayPtr);
	int result = AS3_ByteArray_writeBytes( *destinationByteArrayPtr, (char *)ABuffer, ABytes );
    
    AS3_Val pos = AS3_GetS( *destinationByteArrayPtr, "position" );    
    fprintf( stderr, "WRITE %i bytes callback result=%i Pos now %i \n", ABytes, result, AS3_IntValue(pos) );

    int ii;
    for(ii=0;ii<ABytes;ii++){
        int val = (int)ABuffer[ii];
        if( val!=0 )
            fprintf( stderr, "Jimmyny\n"  );
    }
    
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
    
    AS3_Val *destinationByteArrayPtr = clientData;

    fprintf( stderr, "SEEK callback -- %i\n", (int)AAbsoluteByteOffset );
    
	if( AS3_ByteArray_seek( *destinationByteArrayPtr, (int)AAbsoluteByteOffset, SEEK_SET ) < 0)
		return FLAC__STREAM_ENCODER_SEEK_STATUS_ERROR;

    return FLAC__STREAM_ENCODER_SEEK_STATUS_OK;
}

static FLAC__StreamEncoderTellStatus FLACStreamEncoderTellCallback(const FLAC__StreamEncoder *AEncoder, FLAC__uint64 *AAbsoluteByteOffset, void *clientData) {
    
    AS3_Val *destinationByteArrayPtr = clientData;

//	__int64 Pos;
//	if((Pos = _ftelli64(AOwner->FCFile)) < 0) {
//		return FLAC__STREAM_ENCODER_TELL_STATUS_ERROR;
//	} else {
//		*AAbsoluteByteOffset = (FLAC__uint64)Pos;
    
    AS3_Val pos = AS3_GetS( *destinationByteArrayPtr, "position" );
    *AAbsoluteByteOffset = (FLAC__uint64)AS3_IntValue(pos);

    return FLAC__STREAM_ENCODER_TELL_STATUS_OK;
//	}
}

static AS3_Val encode( void *self, AS3_Val args ) {

    // get Args
    AS3_Val wavData_arg = AS3_Undefined();
    AS3_Val dstData_arg = AS3_Undefined();
    AS3_ArrayValue( args, "AS3ValType, AS3ValType", &wavData_arg, &dstData_arg );

    AS3_Val lengthOfByteArray = AS3_GetS( wavData_arg, "length" );
    AS3_Trace( lengthOfByteArray );
    int len = AS3_IntValue( lengthOfByteArray );
    int success = fprintf( stderr, "length is %d\n", len );
    AS3_Release( lengthOfByteArray );

    AS3_Val lengthOfByteArray2 = AS3_GetS( dstData_arg, "length" );
    AS3_Trace( lengthOfByteArray2 );
    int len2 = AS3_IntValue( lengthOfByteArray2 );
    int success2 = fprintf( stderr, "length is %d\n", len2 );
    AS3_Release( lengthOfByteArray2 );
    
    // not strictly nessasary - get rid of later
    // fprintf( stderr, "about to read bytes" );
    
    // FLAC__byte wavData[len];
    // int result = AS3_ByteArray_readBytes( wavData, wavData_arg, len );
    // fprintf( stderr, "i have read you fucking wav bytes" );
    
    /* Flac Stuff  */

	FLAC__bool ok = true;
	FLAC__StreamEncoder *encoder = 0;
	FLAC__StreamEncoderInitStatus init_status;
    //	FLAC__StreamMetadata *metadata[2];
    //	FLAC__StreamMetadata_VorbisComment_Entry entry;
//NOFILE	FILE *fin;
	unsigned sample_rate = 0;
	unsigned channels = 0;
	unsigned bps = 0;

//NOFILE    char *inputFilename = "/recording.wav";
//NOFILE    char *outputFilename = "/Users/shooley/Desktop/recording.flac";


	/* read wav header and validate it */
    if( len<44)
        success = fprintf( stderr, "Header too short!\n" );

    FLAC__byte headerData[44];
    int result = AS3_ByteArray_readBytes( headerData, wavData_arg, 44 );
    
    if( memcmp( headerData, "RIFF", 4 )!=0 )
        success = fprintf( stderr, "Header cant find RIFF!\n" );

    fprintf( stderr, "we passed all tests" );

//    if( memcmp(wavData+8, "WAVEfmt \020\000\000\000\001\000\002\000", 16)!=0 )
//        success = fprintf( stderr, "Header cant find WAVEfmt!\n" );
//
//    if( memcmp(wavData+32, "\004\000\020\000data", 8)!=0 )
//        success = fprintf( stderr, "Header cant find dataLength!\n" );

//    if(
       //HOO_EDIT fread(buffer, 1, 44, fin) != 44 ||
//       len <44 ||
//       memcmp(wavData, "RIFF", 4) ||
//       memcmp(wavData+8, "WAVEfmt \020\000\000\000\001\000\002\000", 16) ||
//       memcmp(wavData+32, "\004\000\020\000data", 8)
//    ) {
//        success = fprintf( stderr, "ERROR: invalid/unsupported WAVE file, only 16bps stereo WAVE in canonical form allowed\n");
//        //		fclose(fin);
//       return AS3_Undefined();
//    } else {
//        success = fprintf( stderr, "Header ok!\n" );
//    }

	sample_rate = ((((((unsigned)headerData[27] << 8) | headerData[26]) << 8) | headerData[25]) << 8) | headerData[24];
	channels = 1;
	bps = 16;
    
    // why is this divided by 4?
	// total_samples = (((((((unsigned)wavData[43] << 8) | wavData[42]) << 8) | wavData[41]) << 8) | wavData[40]) / 4;
	total_samples = (((((((unsigned)headerData[43] << 8) | headerData[42]) << 8) | headerData[41]) << 8) | headerData[40]) / 2;

    success = fprintf( stderr, "sample rate=%d, tatalSamples=%d!\n", sample_rate, total_samples );

	/* allocate the encoder */
    if((encoder = FLAC__stream_encoder_new()) == NULL) {
        fprintf(stderr, "ERROR: allocating encoder\n");
//        fclose(fin);
        return AS3_Undefined();
    }

    // NB remember that total sample is wrong
    ok &= FLAC__stream_encoder_set_verify( encoder, false );
    ok &= FLAC__stream_encoder_set_compression_level( encoder, 8 );
    ok &= FLAC__stream_encoder_set_channels( encoder, channels );
    ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, bps );
    ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
    
//    ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples );

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

  
    // Create the output ByteArray
 //   AS3_Val flash_utils_namespace = AS3_String("flash.utils");
 //   AS3_Val byteArray_property = AS3_String("ByteArray");
    
 //   AS3_Val ByteArray_class = AS3_NSGet( flash_utils_namespace, byteArray_property );
 //   AS3_Trace( flash_utils_namespace );
 //   AS3_Trace( ByteArray_class );
 //   AS3_Val params = AS3_Array( "" );
    AS3_Val destinationByteArray = dstData_arg; // AS3_New( ByteArray_class, params );
    
//    AS3_Release(ByteArray_class);
//    AS3_Release(flash_utils_namespace); 
//    FILE *outFilePtr = funopen( (void *)destinationByteArray, readByteArray, writeByteArray, seekByteArray, closeByteArray );

    result = fprintf(stderr, "Are we ok? %d\n", ok );

	/* initialize encoder */
    if(ok) {

        // init_status = FLAC__stream_encoder_init_file( encoder, NULL, NULL, NULL );
        
        // Hoo: use the FILE version instead
       //  init_status = FLAC__stream_encoder_init_FILE( encoder, outFilePtr, progress_callback, NULL );

        init_status = FLAC__stream_encoder_init_stream( encoder, FLACStreamEncoderWriteCallback, FLACStreamEncoderSeekCallback, FLACStreamEncoderTellCallback, NULL, (void *)&destinationByteArray );
        
        if( init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
            result = fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
            ok = false;
        }
    }

	/* read blocks of samples from WAVE file and feed to encoder */
    size_t startPos = 44;

    if(ok) {
        size_t left = (size_t)total_samples;
        while( ok && left )
        {
            size_t need = (left>READSIZE? (size_t)READSIZE : (size_t)left);
            
            // fill our buffer
            AS3_ByteArray_seek( wavData_arg, startPos, SEEK_SET );
            AS3_ByteArray_readBytes( buffer, wavData_arg, len3 );

//                if( fread(buffer, channels*(bps/8), need, fin) != need ) {
//                    fprintf(stderr, "ERROR: reading from WAVE file\n");
//                    ok = false;
//                } else {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
            size_t i;
            
            if( (need*channels) > (READSIZE*2) )
                fprintf(stderr, "ERROR: How did this happen? pcm buffer isnt big enough\n");
            
            for( i=0; i<need*channels; i++ )
            {
                /* inefficient but simple and works on big- or little-endian machines */
//bishop                    size_t index1 = startPos + 2*i+1;                    
//bishop                    size_t index2 = startPos + 2*i;
                    
//bishop                    FLAC__byte byte1 = wavData[index1];
//bishop                    FLAC__byte byte2 = wavData[index2];

//bishop                    FLAC__int16 byte1Extended = byte1;
//bishop                    byte1Extended = (byte1Extended << 8);
//bishop                    FLAC__int16 byte2Extended = byte2;
//bishop                    FLAC__int16 totalVal = ( byte1Extended | byte2Extended );
                    
//bishop                    result = fprintf(stderr, "Input PCM %i (b1=%i, b2=%i)\n", (int)totalVal, (int)byte1, (int)byte2 );
                    
//bishop                    pcm[i] = (FLAC__int32)totalVal;
//bishop                }
                /* feed samples to encoder */
//bishop                ok = FLAC__stream_encoder_process_interleaved( encoder, pcm, need);
                        ok = FLAC__stream_encoder_process( encoder, const FLAC__int32 * const buffer[], need );

            
                // leak!
//bishop                AS3_Val lengthOfByteArray = AS3_GetS( destinationByteArray, "length" );
//bishop                AS3_Trace( lengthOfByteArray );
            
                startPos = startPos+need;
//egad      }
                left -= need;
        }
    }

    ok &= FLAC__stream_encoder_finish( encoder );

    result = fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
    result = fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);

	/* now that encoding is finished, the metadata can be freed */
    //	FLAC__metadata_object_delete(metadata[0]);
    //	FLAC__metadata_object_delete(metadata[1]);

    FLAC__stream_encoder_delete(encoder);
//NOT_YET	fclose(fin);
//    fclose( outFilePtr );

    success = fprintf( stderr, "finished processing\n" );

    // int i;
    // for( i=0; i<len; i++ ){
    // printf(">> reading byte %d\n", dst[i] );
    //    dst[i] += 10;
    // }
    
    // if(arg==NULL)
// else
// printf( "we have something at least!\n" );

    // AS3_Malloced_Str whatType = AS3_TypeOf( data_arg );
//    AS3_Val length_property = AS3_String("length");
    // AS3_Val dataLength = AS3_GetS( &data_arg, length_property );
 //   AS3_Release(length_property);

 //   printf("Hello %s!\n", whatType );

//    AS3_Trace( argsLength );

    // double operand1 = 0.0;
    // double operand2 = 0.0;
    // AS3_ArrayValue( args, "DoubleType, DoubleType", &operand1, &operand2 );

    // AS3_Malloced_Str what = AS3_TypeOf( args );
    // AS3_Trace( what );

//    char *val = NULL;
//	AS3_ArrayValue( args, "StrType", &val );

 //   AS3_Val length = AS3_GetS( byteArray, length_property );

    AS3_Val lengthOfByteArray3 = AS3_GetS( destinationByteArray, "length" );
    int len3 = AS3_IntValue( lengthOfByteArray3 );
    unsigned char buffer[len3];
    AS3_ByteArray_seek( destinationByteArray, 0, SEEK_SET );
    AS3_ByteArray_readBytes( buffer, destinationByteArray, len3 );
    int ii;
    int nonZeroByteCount = 0;
    for(ii=0;ii<len3;ii++){
        int val = (int)buffer[ii];
        if( val!=0 ){
            success = fprintf( stderr, "Mutaha Fucker %i \n", val  );
            nonZeroByteCount++;
        }
    }
    success = fprintf( stderr, "Non Zero byte count %i \n", nonZeroByteCount  );
    
//    printf( "Before FlYield\n" );
 //   flyield();
//    printf( "After FlYield\n" );

    // return a value
    return AS3_Int(69);
    
   //  return destinationByteArray;
}

//Method exposed to ActionScript
//Takes a String and echos it
static AS3_Val echo( void *self, AS3_Val args ) {

    int success = fprintf( stderr, "Hello Flash!\n");

	//initialize string to null
	char *val = NULL;

	//parse the arguments. Expect 1.
	//pass in val to hold the first argument, which
	//should be a string
	AS3_ArrayValue( args, "StrType", &val );

	//if no argument is specified
	if( val==NULL ) {
		char* nullString = "null";
		//return the string "null"
		return AS3_String(nullString);
	}
	//otherwise, return the string that was passed in
	return AS3_String(val);
}

#pragma mark -
#pragma mark Flac Stuff

int main( )
{

    /* Setup actionscript */

	//define the methods exposed to ActionScript
	//typed as an ActionScript Function instance
	AS3_Val echoMethod = AS3_Function( NULL, echo );

    // async function
    AS3_Val encodeMethod = AS3_Function( NULL, encode );

	// construct an object that holds references to the functions
	AS3_Val result = AS3_Object( "echo: AS3ValType, encode: AS3ValType",
                                    echoMethod,
                                    encodeMethod
                                );


	// Release
	AS3_Release( echoMethod );
    AS3_Release( encodeMethod );

	// notify that we initialized -- THIS DOES NOT RETURN!
	AS3_LibInit( result );

    return 0;
}

