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

FLAC__int16 int16( FLAC__byte *data, int offset ) {
	FLAC__int16 val = ((( data[offset+1]) << 8) | data[offset] );
	return val;
}

FLAC__int32 int32( FLAC__byte *data, int offset ) {
	FLAC__int32 val = (((((((unsigned)data[offset+3] << 8) | data[offset+2]) << 8) | data[offset+1]) << 8) | data[offset] );
	return val;
}

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


void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data) {
//	(void)encoder, (void)client_data;
//	fprintf( stderr, "wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, total_samples, frames_written, total_frames_estimate);
}

static FLAC__StreamEncoderWriteStatus FLACStreamEncoderWriteCallback(const FLAC__StreamEncoder *ASncoder, const FLAC__byte ABuffer[], size_t ABytes, unsigned ABamples, unsigned ACurrentFrame, void *clientData) {

    AS3_Val *destinationByteArrayPtr = clientData;
    
   // AS3_Trace(*destinationByteArrayPtr);
	int result = AS3_ByteArray_writeBytes( *destinationByteArrayPtr, (char *)ABuffer, ABytes );
    
//    AS3_Val pos = AS3_GetS( *destinationByteArrayPtr, "position" );    
//    fprintf( stderr, "WRITE %i bytes callback result=%i Pos now %i \n", ABytes, result, AS3_IntValue(pos) );

//    static int nonZeroBytes = 0;
//    int ii;
//    for(ii=0;ii<ABytes;ii++){
//        int val = (int)ABuffer[ii];
//        if( val!=0 ){
//            nonZeroBytes++;            
//            fprintf( stderr, "%i nonZeroBytes Jimmyny\n", nonZeroBytes  );
//        }
//    }
    
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

//    fprintf( stderr, "SEEK callback -- %i\n", (int)AAbsoluteByteOffset );
    
    // TODO: 
    // Not sure if AS3_Int() and other stuff like it leaks.. find out!
    int offset = AAbsoluteByteOffset;
    AS3_SetS( *destinationByteArrayPtr, "position", AS3_Int(offset) );
    
//	if( AS3_ByteArray_seek( *destinationByteArrayPtr, (int)AAbsoluteByteOffset, SEEK_SET ) < 0)
//		return FLAC__STREAM_ENCODER_SEEK_STATUS_ERROR;

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
//    fprintf( stderr, "TELL callback -- %i\n", AS3_IntValue(pos) );
    
    return FLAC__STREAM_ENCODER_TELL_STATUS_OK;
//	}
}

static AS3_Val encode( void *self, AS3_Val args ) {

    int magicVal = 66;
    fprintf( stderr, "val=%0x --- swapped val=%0x \n", (int)magicVal, HooByteSwap(magicVal) );

    // get Actionscript Args
    AS3_Val wavData_arg = AS3_Undefined();
    AS3_Val dstData_arg = AS3_Undefined();
    AS3_ArrayValue( args, "AS3ValType, AS3ValType", &wavData_arg, &dstData_arg );

    // The incoming wav data must be little-endian
    AS3_Val lengthOfByteArray1 = AS3_GetS( wavData_arg, "length" );
    AS3_Trace( lengthOfByteArray1 );
    int len = AS3_IntValue( lengthOfByteArray1 );
    int success = fprintf( stderr, "length is %d\n", len );
    AS3_Release( lengthOfByteArray1 );

    AS3_Val lengthOfByteArray2 = AS3_GetS( dstData_arg, "length" );
    AS3_Trace( lengthOfByteArray2 );
    int len2 = AS3_IntValue( lengthOfByteArray2 );
    int success2 = fprintf( stderr, "length is %d\n", len2 );
    AS3_Release( lengthOfByteArray2 );

    /* Flac Stuff  */

	FLAC__bool ok = true;
	FLAC__StreamEncoder *encoder = 0;
	FLAC__StreamEncoderInitStatus init_status;

	unsigned sample_rate = 0;
	unsigned bps = 0;
	unsigned compressionCode = 0;
	unsigned channelCount = 0;
	unsigned averageBytesPerSecond = 0;
	unsigned blockAlign = 0;

	/* read wav header and validate it */
    if( len<44)
        success = fprintf( stderr, "Header too short!\n" );

    // The first 18 bytes of a wav is always the same. Byte 19 contains the name of the next (arbitrary) chunk. Byte 20 the length of said chunk.
	FLAC__byte header_start[20];
	int chunkPos = 0;
    
	int filePos = 0;    
    AS3_ByteArray_seek( wavData_arg, filePos, SEEK_SET );    
    int result = AS3_ByteArray_readBytes( header_start, wavData_arg, 20 );
	filePos+= 20;    

    if( memcmp( header_start, "RIFF", 4 )!=0 )
        success = fprintf( stderr, "Header cant find RIFF!\n" );
	chunkPos +=4;	

    FLAC__int32 fileLength = int32( header_start, chunkPos ) +8; // The eight is the RIFF 8909909 that proceeded this line
	chunkPos +=4;
    
	if( memcmp( header_start+chunkPos, "WAVE", 4)!=0 ) {
		fprintf(stderr, "ERROR: Invalid file?\n" );
		return AS3_Undefined();		
	}
    
	// ok so far! The next 4 bytes are the name of the next chunk, the next 4 bytes the length of the following chunk
	chunkPos +=4;		
	FLAC__int32 chunkName = int32( header_start, chunkPos );
	
	chunkPos +=4;	
	FLAC__int32 chunkLengthBytes = int32( header_start, chunkPos );
    
	// Read all chunks
	int exitLoop = 0;
	while( !exitLoop ) {

        // check exit conditions
		if( memcmp( (void *)&chunkName, "data", 4)==0 )
			break;
        
		// --untested exit condition (remaining bytes==0)
        
		// copy the chunk and process it (includes the beggining of the next as well)
		int chunkLengthAndNextChunkNameAndLength = chunkLengthBytes+8;
		FLAC__byte chunkData[chunkLengthAndNextChunkNameAndLength];

        // AS3_ByteArray_seek( wavData_arg, filePos, SEEK_SET );      
      
        int result = AS3_ByteArray_readBytes( chunkData, wavData_arg, chunkLengthAndNextChunkNameAndLength );
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
//      clean up needed!  fclose(fin);
        return AS3_Undefined();
    }

	// ok &= FLAC__stream_encoder_set_verify(encoder, true);
	ok &= FLAC__stream_encoder_set_compression_level( encoder, 5 );
	ok &= FLAC__stream_encoder_set_channels( encoder, channelCount );
	ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, bps );
	ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
	ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples_per_channel );
    
	/* initialize encoder */
    if(ok) {
        // init_status = FLAC__stream_encoder_init_file( encoder, NULL, NULL, NULL );
        // init_status = FLAC__stream_encoder_init_FILE( encoder, outFilePtr, progress_callback, NULL );
        init_status = FLAC__stream_encoder_init_stream( encoder, FLACStreamEncoderWriteCallback, FLACStreamEncoderSeekCallback, FLACStreamEncoderTellCallback, NULL, (void *)&dstData_arg );
        if( init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
            result = fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
            ok = false;
        }
    }

	int bytesPerSample = bps/8;
    int in_bufferSize = READSIZE * bytesPerSample * channelCount;   // 2048 bytes
    FLAC__byte *in_buffer = calloc( sizeof(FLAC__byte), in_bufferSize );  /* we read the WAVE data into here */
    
    int pcm_buffer_size = READSIZE/*samples*/ * channelCount;       // 1024 ints
    FLAC__int32 *pcm = calloc( sizeof(FLAC__int32), pcm_buffer_size );
    
	/* read blocks of samples from WAVE file and feed to encoder */
    if(ok) {
        size_t left = (size_t)total_samples_per_channel;
        while( ok && left )
        {
            size_t need = (left>READSIZE? (size_t)READSIZE : (size_t)left);
            
            size_t alchemyCompensatedNeed = need*bytesPerSample;
            
            // fill our buffer
//            AS3_ByteArray_seek( wavData_arg, filePos, SEEK_SET );
            
            AS3_Val currentPos = AS3_GetS( wavData_arg, "position" );
            
            fprintf( stderr, "About to READ FROM %i -- %i \n", AS3_IntValue(currentPos), alchemyCompensatedNeed );            
            int readSuccess = AS3_ByteArray_readBytes( in_buffer, wavData_arg, alchemyCompensatedNeed );
//            fprintf( stderr, "copied %i bytes into buffer \n", need );
            
            
            filePos += alchemyCompensatedNeed;
			if( readSuccess!= alchemyCompensatedNeed ) {
				fprintf(stderr, "ERROR: reading from WAVE file\n");
				ok = false;
			}
			else {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */
                size_t i;
            
                int limitIndex = need*channelCount;
                int max_read_index = 2*limitIndex+1;
            
                for( i=0; i<limitIndex; i++ )
                {
                    /* inefficient but simple and works on big- or little-endian machines */
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)in_buffer[2*i+1] << 8) | (FLAC__int16)in_buffer[2*i]);

//PASS                    
//                    static int printLimit = 0;
//                    if( printLimit<20 ) {
//                        fprintf( stderr, "%i) inputSample %i \n", printLimit, pcm[i] );
//                        printLimit++;
//                    }	                    
                }
                /* feed samples to encoder */
                // ok = FLAC__stream_encoder_process_interleaved( encoder, pcm, need);
                FLAC__int32 **arrayOfArrays = &pcm;
                
//                FLAC__int32 aaaaaaa = (FLAC__int16)in_buffer[2*512];
//                FLAC__int32 bbbbbbb = (FLAC__int8)in_buffer[2*512+1];
//                fprintf( stderr, "10 INTEGER SIGNAL VALIDITY TEST %i %i \n", aaaaaaa, bbbbbbb );  
                // exit(0);
                
                ok = FLAC__stream_encoder_process( encoder, arrayOfArrays, need );
                
                // obviously temp
                // return AS3_Int(69);
            }
            left -= need;
        }
    }

    ok &= FLAC__stream_encoder_finish( encoder );

    result = fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
    result = fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);


    FLAC__stream_encoder_delete(encoder);
//NOT_YET	fclose(fin);
//    fclose( outFilePtr );
    free(in_buffer);
    free(pcm);
    
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

//    AS3_Val lengthOfByteArray3 = AS3_GetS( dstData_arg, "length" );
//    int len3 = AS3_IntValue( lengthOfByteArray3 );
//    unsigned char buffer[len3];
//    AS3_ByteArray_seek( dstData_arg, 0, SEEK_SET );
//    AS3_ByteArray_readBytes( buffer, dstData_arg, len3 );
//    int ii;
//    int nonZeroByteCount = 0;
//    for(ii=0;ii<len3;ii++){
//        int val = (int)buffer[ii];
//        if( val!=0 ){
//            success = fprintf( stderr, "Mutaha Fucker %i \n", val  );
//            nonZeroByteCount++;
//        }
//    }
//    success = fprintf( stderr, "Non Zero byte count %i \n", nonZeroByteCount  );
    
//    printf( "Before FlYield\n" );
 //   flyield();
//    printf( "After FlYield\n" );

    // return a value
    return AS3_Int(69);
    
   //  return dstData_arg;
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

