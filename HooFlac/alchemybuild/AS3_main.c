#include <AS3.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>

#include "hooHacks.h"
#include "stream_encoder.h"

AS3_Val gg_lib = NULL;

#pragma mark -
#pragma mark Actionscript example

// static void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data);

#define READSIZE 1024
static int _begun = 0, _complete = 0;;
FILE *_logFile;
FILE *_flacFile;

FLAC__int16 int16( FLAC__byte *data, int offset ) {
	FLAC__int16 val = ((( data[offset+1]) << 8) | data[offset] );
	return val;
}

FLAC__int32 int32( FLAC__byte *data, int offset ) {
	FLAC__int32 val = (((((((unsigned)data[offset+3] << 8) | data[offset+2]) << 8) | data[offset+1]) << 8) | data[offset] );
	return val;
}

static int64_t gettime(void) {
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return (int64_t)tv.tv_sec * 1000000 + tv.tv_usec;
}

/* Woah these are so incredibly useful! Use a bytearray as a FILE */

/* Does a FILE * read against a ByteArray */
static int readByteArray( void *cookie, char *dst, int size ) {
	return AS3_ByteArray_readBytes(dst, (AS3_Val)cookie, size);
}

/* Does a FILE * write against a ByteArray */
static int writeByteArray( void *cookie, const char *src, int size ) {
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


// void progress_callback(const FLAC__StreamEncoder *encoder, FLAC__uint64 bytes_written, FLAC__uint64 samples_written, unsigned frames_written, unsigned total_frames_estimate, void *client_data) {
//	(void)encoder, (void)client_data;
//	fprintf( stderr, "wrote %llu bytes, %llu/%u samples, %u/%u frames\n", bytes_written, samples_written, total_samples, frames_written, total_frames_estimate);
// }

static FLAC__StreamEncoderWriteStatus FLACStreamEncoderWriteCallback(const FLAC__StreamEncoder *ASncoder, const FLAC__byte ABuffer[], size_t ABytes, unsigned ABamples, unsigned ACurrentFrame, void *clientData) {

    
    if (_begun )
	{

        static int writeCount=0;
        hooFileLog( "WRITE FIRST BATCH\n" );
        if( writeCount++ > 3 ){
//            _complete=1;
//            return FLAC__STREAM_ENCODER_WRITE_STATUS_OK;            
        }
        
    }
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
    AS3_Release(pos);
    return FLAC__STREAM_ENCODER_TELL_STATUS_OK;
//	}
}

/* Oh god i have fucked this up havent i*/
// there is no way it is going to let me malloc a 100mb buffer in one go
//unsigned char *_outBuffer;
//int _outBufferSize;
//AS3_Val _outBuffer;

static AS3_Val initByteArray( void *self, AS3_Val args ) {
    
//	AS3_ArrayValue( args, "IntType", &_outBufferSize );
//	//Allocate buffer of size "bufferSize"
//    _outBuffer = malloc( _outBufferSize );
//	//return pointer to the location in memory
//	return AS3_Ptr(_outBuffer);
//    
//    AS3_Val flash_utils_namespace = AS3_String("flash.utils");
//    AS3_Val ByteArray_class = AS3_NSGetS(flash_utils_namespace, "ByteArray");
//    AS3_Val emptyParams = AS3_Array("");    
//    _outBuffer = AS3_New(ByteArray_class, emptyParams);
//    AS3_Release(flash_utils_namespace);
//    AS3_Release(ByteArray_class);
//    AS3_Release(emptyParams);
//    
//    // AS3_Release(byteArray);
//    return AS3_Ptr(_outBuffer);
	return AS3_Int(0);        
}

static AS3_Val clearByteArray( void *self, AS3_Val args ) {

//	free(_outBuffer);
//    _outBuffer = NULL;
//    AS3_Val emptyParams = AS3_Array("");    
//    AS3_CallS( "clear", _outBuffer, emptyParams);
//    AS3_Release(_outBuffer);
//    AS3_Release(emptyParams);    
	return AS3_Int(0);    
}

static AS3_Val testTheFunk( void *self, AS3_Val args ) {
    
    AS3_Val funkData_arg = NULL;    
    AS3_ArrayValue( args, "AS3ValType", &funkData_arg );
    
    AS3_Val lengthOfFunkByteArray = AS3_GetS( funkData_arg, "length" );
    fprintf( stderr, "funk length is %d\n", AS3_IntValue( lengthOfFunkByteArray ) );

    AS3_Val zero = AS3_Int(0);
	AS3_SetS( funkData_arg, "position", zero );
	AS3_Release(zero);

    // a single float obviously has length 4
    FLAC__byte in_buffer[4];
    int readSuccess = AS3_ByteArray_readBytes( in_buffer, funkData_arg, 4 );
    if( readSuccess != 4 ){
        fprintf( stderr, "ERROR: reading from Funk file\n" );
        exit(0);
    }
    fprintf( stderr, "%0x %0x %0x %0x \n", in_buffer[0], in_buffer[1], in_buffer[2], in_buffer[3] );
    int32_t convertedVal = in_buffer[0]<<24 & 0xff000000 | in_buffer[1]<<16 & 0x00ff0000 | (in_buffer[2]<<8  & 0x0000ff00) | in_buffer[3];
    float *convertedVal_ptr = (float *)&convertedVal;
    fprintf( stderr, "Woo %f \n", *convertedVal_ptr );
    
    FLAC__int16 pcmValue = (*convertedVal_ptr) * 0x7fff;
    fprintf( stderr, "What the pcm? %d \n", pcmValue );

    char *fakeInput = (char *)&pcmValue;
    FLAC__int32 whatIsThisValue = (FLAC__int32)(((FLAC__int16)(FLAC__int8)fakeInput[2*0+1] << 8) | (FLAC__int16)fakeInput[2*0]);
    fprintf( stderr, "Soooo, what does this line do? %d \n", whatIsThisValue );
    
    AS3_Release( lengthOfFunkByteArray );
    AS3_Release( funkData_arg );
    
	return AS3_Int(0);    
}

static AS3_Val encodeRawData( void *self, AS3_Val args ) {

    int64_t time_start = gettime();
    
    // get Actionscript Args
    AS3_Val flacData_arg = NULL;    
    AS3_Val logFile_arg = NULL;
    char *fileName;
    AS3_ArrayValue( args, "StrType, AS3ValType, AS3ValType", &fileName, &flacData_arg, &logFile_arg );
    
    // This technique is read only - thats just the way it is
    FILE *rawDatfile = fopen( fileName, "rb" );    // rb = read-binary
	int result = fseek( rawDatfile, 0, SEEK_END );
    if(result==-1){
        fprintf( stderr, "FAILED to seek in rawDatfile\n" );
        exit(0);
    }
    
	long rawDatfileSize = ftell( rawDatfile );
	rewind( rawDatfile );
    
	// Open the ByteArray for logData as a file so we can write to it
    _logFile = funopen( (void *)logFile_arg, readByteArray, writeByteArray, seekByteArray, closeByteArray );
    if( _logFile==NULL ){
        fprintf( stderr, "FAILED to open logfile\n" );        
        exit(0);
    }
	
    /* Flac Stuff  */
    /* The incoming wav data must be little-endian */
	// 1) Audio Data In
    FLAC__bool ok = true;
    FLAC__StreamEncoder *encoder = 0;
    FLAC__StreamEncoderInitStatus init_status;
    unsigned sample_rate = 44100;
    unsigned pcm_bps = 16;
    unsigned raw_bps = 32;    
    unsigned channelCount = 1;

    // remember, raw data is 32 bit floats
    int raw_bytesPerSample = raw_bps/8;
    int pcm_bytesPerSample = pcm_bps/8;
    unsigned absolute_total_samples = rawDatfileSize / raw_bytesPerSample;
    unsigned total_samples_per_channel = absolute_total_samples / channelCount;
    
	/* allocate the encoder */
    if( (encoder = FLAC__stream_encoder_new())== NULL ) {
        fprintf(stderr, "ERROR: allocating encoder\n");
        fclose(rawDatfile);
        fclose(_logFile);
        exit(0);
    }
    
	// ok &= FLAC__stream_encoder_set_verify(encoder, true);
    ok &= FLAC__stream_encoder_set_compression_level( encoder, 5 );
    ok &= FLAC__stream_encoder_set_channels( encoder, channelCount );
    ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, pcm_bps );
    ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
    ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples_per_channel );
    
	/* initialize encoder */
    if(ok) {
        init_status = FLAC__stream_encoder_init_stream( encoder, FLACStreamEncoderWriteCallback, FLACStreamEncoderSeekCallback, FLACStreamEncoderTellCallback, NULL, (void *)&flacData_arg );
        if( init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
            result = fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
            ok = false;
        }
    }
    
    int in_bufferSize = READSIZE * raw_bytesPerSample * channelCount;
    FLAC__byte *in_buffer = calloc( sizeof(FLAC__byte), in_bufferSize );  /* we read the WAVE data into here */
    
    int pcm_buffer_size = READSIZE /*samples*/ * channelCount;       // 1024 ints
    FLAC__int32  *restrict pcm = calloc( sizeof(FLAC__int32), pcm_buffer_size );
    
	/* read blocks of samples from WAVE file and feed to encoder */
    if(ok)
    {
        size_t left = (size_t)total_samples_per_channel;
        while( ok && left && _complete==0 )
        {
            size_t samples_needed = (left>READSIZE? (size_t)READSIZE : (size_t)left);
            size_t raw_bytes_needed = samples_needed * raw_bytesPerSample;
            
            // AS3_Val currentPos = AS3_GetS( wavData_arg, "position" );
            // float percentage = (left*1.0/total_samples_per_channel) *100;
            // fprintf( stderr, "%f About to READ FROM %i -- %i \n", percentage, (int)ftell(rawDatfile), raw_bytes_needed );
            
            // int readSuccess = AS3_ByteArray_readBytes( in_buffer, wavData_arg, raw_bytes_needed );
            size_t readSuccess = fread( in_buffer, 1, raw_bytes_needed, rawDatfile );
            
            if( readSuccess!= raw_bytes_needed ) {
                fprintf(stderr, "ERROR: reading from WAVE file\n");
                ok = false;
            }
            else {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */                
                int limitIndex = samples_needed*channelCount;
            
                for( size_t i=0; i<limitIndex; i++ )
                {
                    int inPos = i*4;
                    int32_t convertedVal = in_buffer[inPos]<<24 & 0xff000000 | in_buffer[inPos+1]<<16 & 0x00ff0000 | (in_buffer[inPos+2]<<8  & 0x0000ff00) | in_buffer[inPos+3];
                    float *convertedVal_ptr = (float *)&convertedVal;                    
                                        
                    // Multiply the float by max 16 bit int
                    FLAC__int16 pcmValue = (*convertedVal_ptr) * 0x7fff;    
                    pcm[i] = pcmValue;
                }
                /* feed samples to encoder */
                // ok = FLAC__stream_encoder_process_interleaved( encoder, pcm, need);
                FLAC__int32 **arrayOfArrays = &pcm;
                ok = FLAC__stream_encoder_process( encoder, arrayOfArrays, samples_needed );
            }
            left -= samples_needed;
            
            // Experiment with the async shit why not
            static int yieldCount = 0;
            if(yieldCount%100==0){
                //fprintf( stderr, "flyield flyield \n" );                
                flyield();
                // %10 =  2min 59 secs
                // %50  = 2min 06 secs
                // %100  = 1min 55 secs
                // %1000 = 1min 46 secs
            }
            yieldCount++;
        }
    }
    
    ok &= FLAC__stream_encoder_finish( encoder );
    
    result = fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
    result = fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);
    
    AS3_Val lengthOfFlac = AS3_GetS( flacData_arg, "length" );
    int lengthOfDataWritten = AS3_IntValue( lengthOfFlac );
    AS3_ReleaseX( lengthOfFlac );
    
    /*
     * Cleanup
     */
    
    FLAC__stream_encoder_delete(encoder);
    
    free(in_buffer);
    free(pcm);
    
    AS3_Val msg = AS3_String("Did not crash");
    AS3_Trace(msg);
    AS3_ReleaseX( msg );
    
    fclose( rawDatfile );
    fclose( _logFile );    
    
    AS3_ReleaseX( flacData_arg );    
    AS3_ReleaseX( logFile_arg );
    AS3_ReleaseX( args );
    
    int64_t duration = gettime() - time_start;
    fprintf( stderr, "finished processing %0.2f s\n", (double)duration/1000000.0 );
    
    return AS3_Int( lengthOfDataWritten );
}


static AS3_Val encodeWavData( void *self, AS3_Val args ) {

    int64_t time_start = gettime();

    // get Actionscript Args
    AS3_Val flacData_arg = NULL;    
    AS3_Val logFile_arg = NULL;
    char * fileName;
    
    AS3_ArrayValue( args, "StrType, AS3ValType, AS3ValType", &fileName, &flacData_arg, &logFile_arg );

    // This method is read only - thats just the way it is
    FILE *wavDatfile = fopen( fileName, "rb" );    // rb = read-binary
	int result = fseek( wavDatfile, 0, SEEK_END );
    if(result==-1){
        fprintf( stderr, "FAILED to seek in wavDatfile\n" );
        exit(0);
    }

	long wavDatfileSize = ftell( wavDatfile );
	rewind( wavDatfile );
    
    // Open flacData as a FILE - why?
//    _flacFile = funopen( (void *)flacData_arg, readByteArray, writeByteArray, seekByteArray, closeByteArray );
//    if( _flacFile==NULL ){
//        fprintf( stderr, "FAILED to open _flacFile\n" );        
//        exit(0);
//    }
    
	// Open the ByteArray for logData as a file so we can write to it
    _logFile = funopen( (void *)logFile_arg, readByteArray, writeByteArray, seekByteArray, closeByteArray );
    if( _logFile==NULL ){
        fprintf( stderr, "FAILED to open logfile\n" );        
        exit(0);
    }
	
//    AS3_Val lengthOfByteArray1 = AS3_GetS( logFile_arg, "length" );
//    int logFileLen = AS3_IntValue( lengthOfByteArray1 );
//    fprintf( stderr, "src length is %d, logFile length is %d\n", (int)wavDatfileSize, (int)logFileLen );
//    AS3_Release( lengthOfByteArray1 );
    
    // -- need to write some values into output and verify
//    fprintf( _logFile, "HelloWorld - eek, remove this when verified it has worked\n" );

    /* Flac Stuff  */
    /* The incoming wav data must be little-endian */
	// 1) Audio Data In
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
    if( wavDatfileSize<44 ) {
        fprintf( stderr, "ERROR: Header too short - cant be a wav!\n" );
        exit(0);
    }

    // The first 18 bytes of a wav is always the same. Byte 19 contains the name of the next (arbitrary) chunk. Byte 20 the length of said chunk.
    int headerStartSize = 20;
    FLAC__byte header_start[headerStartSize];
    int chunkPos = 0;
    int filePos = 0;    

    // int result = AS3_ByteArray_readBytes( header_start, wavData_arg, headerStartSize );
    result = fread( header_start, 1, headerStartSize, wavDatfile );
    if( result!=headerStartSize ) {
        fprintf( stderr, "ERROR: reading header\n" );        
        exit(0);
    }
    filePos+= headerStartSize;    
    
    if( memcmp( header_start, "RIFF", 4 )!=0 ) {
        fprintf( stderr, "Header cant find RIFF!\n" );
        exit(0);        
    }
    chunkPos +=4;	    
    
    FLAC__int32 fileLength = int32( header_start, chunkPos ) +8; // The eight is the RIFF 8909909 that proceeded this line
    chunkPos +=4;    

    if( memcmp( header_start+chunkPos, "WAVE", 4)!=0 ) {
        fprintf(stderr, "ERROR: Invalid file?\n" );
        exit(0);		
    }
	
    // ok so far! The next 4 bytes are the name of the next chunk, the next 4 bytes the length of the following chunk
    chunkPos +=4;		
    FLAC__int32 chunkName = int32( header_start, chunkPos );
    
    chunkPos +=4;	
    FLAC__int32 chunkLengthBytes = int32( header_start, chunkPos );

    
	// Read all chunks
    int exitLoop = 0;
    while( !exitLoop )
    {
        // check exit conditions
        if( memcmp( (void *)&chunkName, "data", 4)==0 )
            break;
    
        // --untested exit condition (remaining bytes==0)
    
        // copy the chunk and process it (includes the beggining of the next as well)
        int chunkLengthAndNextChunkNameAndLength = chunkLengthBytes+8;
        FLAC__byte chunkData[chunkLengthAndNextChunkNameAndLength];
    
        // int result = AS3_ByteArray_readBytes( chunkData, wavData_arg, chunkLengthAndNextChunkNameAndLength );
        result = fread( chunkData, 1, chunkLengthAndNextChunkNameAndLength, wavDatfile );
        if( result!=chunkLengthAndNextChunkNameAndLength ) {
            fprintf( stderr, "ERROR: reading header\n" );        
            exit(0);
        }        
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
        fclose(wavDatfile);
        fclose(_logFile);
        exit(0);
    }
    
	// ok &= FLAC__stream_encoder_set_verify(encoder, true);
    ok &= FLAC__stream_encoder_set_compression_level( encoder, 5 );
    ok &= FLAC__stream_encoder_set_channels( encoder, channelCount );
    ok &= FLAC__stream_encoder_set_bits_per_sample( encoder, bps );
    ok &= FLAC__stream_encoder_set_sample_rate( encoder, sample_rate );
    ok &= FLAC__stream_encoder_set_total_samples_estimate( encoder, total_samples_per_channel );
    
	/* initialize encoder */
    if(ok) {
        init_status = FLAC__stream_encoder_init_stream( encoder, FLACStreamEncoderWriteCallback, FLACStreamEncoderSeekCallback, FLACStreamEncoderTellCallback, NULL, (void *)&flacData_arg );
        if( init_status != FLAC__STREAM_ENCODER_INIT_STATUS_OK ) {
            result = fprintf(stderr, "ERROR: initializing encoder: %s\n", FLAC__StreamEncoderInitStatusString[init_status]);
            ok = false;
        }
    }
    
    int raw_bytesPerSample = bps/8;
    int in_bufferSize = READSIZE * raw_bytesPerSample * channelCount;   // 2048 bytes
    FLAC__byte *in_buffer = calloc( sizeof(FLAC__byte), in_bufferSize );  /* we read the WAVE data into here */
    
    int pcm_buffer_size = READSIZE/*samples*/ * channelCount;       // 1024 ints
    FLAC__int32 *pcm = calloc( sizeof(FLAC__int32), pcm_buffer_size );
    
    // -- do this mutha fucka
    // // sprintf( (char *)_outBuffer, testString, NULL );
    // char *testString = "Hip Hip Hooray";
	// AS3_ByteArray_writeBytes( flacData_arg, testString, strlen(testString)+1 );
    // int lengthOfDataWritten = strlen(testString)+1;

	/* read blocks of samples from WAVE file and feed to encoder */
    if(ok)
    {
        size_t left = (size_t)total_samples_per_channel;
        while( ok && left && _complete==0 )
        {
            size_t samples_needed = (left>READSIZE? (size_t)READSIZE : (size_t)left);
            size_t raw_bytes_needed = samples_needed * raw_bytesPerSample;
            
            // AS3_Val currentPos = AS3_GetS( wavData_arg, "position" );
            float percentage = (left*1.0/total_samples_per_channel) *100;
            fprintf( stderr, "%f About to READ FROM %i -- %i \n", percentage, (int)ftell(wavDatfile), raw_bytes_needed );
            
            size_t readSuccess = fread( in_buffer, 1, raw_bytes_needed, wavDatfile );
            filePos += raw_bytes_needed;
            if( readSuccess!= raw_bytes_needed ) {
                fprintf(stderr, "ERROR: reading from WAVE file\n");
                ok = false;
            }
            else {
                /* convert the packed little-endian 16-bit PCM samples from WAVE into an interleaved FLAC__int32 buffer for libFLAC */                
                int limitIndex = samples_needed * channelCount;
                // int max_read_index = 2*limitIndex+1;
    
                for( size_t i=0; i<limitIndex; i++ )
                {
                    static int printLimit = 0;
                    if(printLimit<20){
                        printLimit++;
                        fprintf(stderr, "Byte[0]=%d, Byte[1]=%d \n", in_buffer[2*i], in_buffer[2*i+1] );
                    }
                    
                    /* inefficient but simple and works on big- or little-endian machines */
                    pcm[i] = (FLAC__int32)(((FLAC__int16)(FLAC__int8)in_buffer[2*i+1] << 8) | (FLAC__int16)in_buffer[2*i]);
                }
                /* feed samples to encoder */
                // ok = FLAC__stream_encoder_process_interleaved( encoder, pcm, samples_needed);
                FLAC__int32 **arrayOfArrays = &pcm;
    
    //                FLAC__int32 aaaaaaa = (FLAC__int16)in_buffer[2*512];
    //                FLAC__int32 bbbbbbb = (FLAC__int8)in_buffer[2*512+1];
    //                fprintf( stderr, "10 INTEGER SIGNAL VALIDITY TEST %i %i \n", aaaaaaa, bbbbbbb );  
                _begun = 1;
                ok = FLAC__stream_encoder_process( encoder, arrayOfArrays, samples_needed );
            }
            left -= samples_needed;
    
            // Experiment with the async shit why not
            static int yieldCount = 0;
            if(yieldCount%100==0){
                //fprintf( stderr, "flyield flyield \n" );                
                flyield();
                // %10 =  2min 59 secs
                // %50  = 2min 06 secs
                // %100  = 1min 55 secs
                // %1000 = 1min 46 secs
            }
            yieldCount++;
        }
    }
    
    ok &= FLAC__stream_encoder_finish( encoder );
    
    result = fprintf(stderr, "encoding: %s\n", ok? "succeeded" : "FAILED");
    result = fprintf(stderr, "   state: %s\n", FLAC__StreamEncoderStateString[FLAC__stream_encoder_get_state(encoder)]);
        
    AS3_Val lengthOfFlac = AS3_GetS( flacData_arg, "length" );
    int lengthOfDataWritten = AS3_IntValue( lengthOfFlac );
    AS3_ReleaseX( lengthOfFlac );
    
    /*
     * Cleanup
    */

    FLAC__stream_encoder_delete(encoder);
    
    free(in_buffer);
    free(pcm);
    
    AS3_Val msg = AS3_String("Did not crash");
    AS3_Trace(msg);
    AS3_ReleaseX( msg );
    
    fclose( wavDatfile );
    fclose( _logFile );
//    fclose( _flacFile );

    
    AS3_ReleaseX( flacData_arg );    
    AS3_ReleaseX( logFile_arg );
    AS3_ReleaseX( args );
    
    int64_t duration = gettime() - time_start;
    fprintf( stderr, "finished processing %0.2f s\n", (double)duration/1000000.0 );

    return AS3_Int( lengthOfDataWritten );
}


//Method exposed to ActionScript
//Takes a String and echos it
static AS3_Val echo( void *self, AS3_Val args ) {

    fprintf( stderr, "Hello Flash!\n");

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

void gg_reg(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_Function(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}

void gg_reg_async(AS3_Val lib, const char *name, AS3_ThunkProc p) {
	AS3_Val fun = AS3_FunctionAsync(NULL, p);
	AS3_SetS(lib, name, fun);
	AS3_Release(fun);
}

int main( ) {
    
    /* Setup actionscript */
	gg_lib = AS3_Object("");

    gg_reg_async( gg_lib, "encodeWavData", encodeWavData );
    gg_reg_async( gg_lib, "encodeRawData", encodeRawData );
    
    gg_reg( gg_lib, "echo", echo);    
    gg_reg( gg_lib, "initByteArray", initByteArray );
    gg_reg( gg_lib, "clearByteArray", clearByteArray );
    gg_reg( gg_lib, "testTheFunk", testTheFunk );

	// notify that we initialized -- THIS DOES NOT RETURN!
	AS3_LibInit( gg_lib );
    
    return 1;
}

