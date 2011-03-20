#import "ftmisc.h"
#import "ftimage.h"
#import "ftraster.h"
#import "FreetypeTestShapes.h"
#include "HoboMaths.h"
#include "TestUtils.h"



//#include "malloc.h"
//#include <fstream>


//
// Some freetype definitions ripped to get this to work. Maybe there's some way to include these instead?
//

//putback typedef struct FT_MemoryRec_* FT_Memory; typedef void* 
//putback (*FT_Alloc_Func)(FT_Memory memory,
//putback 				 long size); typedef void 
//putback (*FT_Free_Func)(FT_Memory memory,
//putback 				void* block); typedef void* 
//putback (*FT_Realloc_Func)(FT_Memory memory,
//putback 				   long cur_size,
//putback 				   long new_size,
//putback 				   void* block); struct FT_MemoryRec_ {
//putback 	void* user;
//putback 	FT_Alloc_Func alloc;
//putback 	FT_Free_Func free;
//putback 	FT_Realloc_Func realloc;
//putback };

//putbackvoid* MY_Alloc_Func(FT_Memory memory,
//putback                    long size)
//putback{
//putback	return malloc(size);
//putback}

//putbackvoid MY_Free_Func(FT_Memory memory,
//putback                  void *block)
//putback{
//putback	free(block);
//putback}

//putbackvoid* MY_Realloc_Func(FT_Memory memory,
//putback                      long cur_size,
//putback                      long new_size,
//putback                      void* block)
//putback{
//putback	return realloc(block, new_size);
//putback}



//FT_Memory mem;
FT_Error Err;


@interface FreeTypeTest : SenTestCase {
@private
}

@end

@implementation FreeTypeTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {    
    [super tearDown];
}

- (void)testCoordConversion {
  
    float x, y;    
    polarDegreesToCart( 100, 90, &x, &y );
    NSLog(@"%f %f", x, y);
    
    polarDegreesToCart( 100, 180, &x, &y );
    NSLog(@"%f %f", x, y);
    
    float r, theta;
    cartToPolarDegress(x,y,&r,&theta);
    NSLog(@"%f %f", r, theta);
    
}

struct FT_Bitmap_ *makeBitmap() {
    
    struct FT_Bitmap_ *bitmap = calloc(1,sizeof(struct FT_Bitmap_));
    
	const int width = 400;
	const int rows = 400;
	const int pitch = ((width + 15) >> 4) << 1; // one row including padding    
    unsigned char *buffer = calloc(1, width*pitch); // ??
	bitmap->buffer = buffer;
	bitmap->width = width;
	bitmap->rows = rows;
	bitmap->pitch = pitch;
	//if aa bitmap.num_grays = 256;
	bitmap->pixel_mode = FT_PIXEL_MODE_MONO; // FT_PIXEL_MODE_GRAY  FT_PIXEL_MODE_MONO
    // not used - bitmap.palette = 0;
    // not used - bitmap.palette_mode = 0;
    return bitmap;
}

void releaseBitmap( struct FT_Bitmap_ *bitmap ) {
    
    bitmap->width = 0;
	bitmap->rows = 0;
	bitmap->pitch = 0;
    free(bitmap->buffer);
    free(bitmap);
}

struct FT_Raster_Params_ *makeParams( struct FT_Outline_ *outline, struct FT_Bitmap_ *bitmap ) {
    
    struct FT_Raster_Params_ *params = calloc(1, sizeof(struct FT_Raster_Params_));
	params->source = outline;
	params->target = bitmap;
	params->flags = FT_RASTER_FLAG_DEFAULT; // @FT_RASTER_FLAG_AA, @FT_RASTER_FLAG_DIRECT
    params->user = (void *)0xffffffc0;	// data passed to the callback        
    return params;
}

void releaseParams( struct FT_Raster_Params_ *params ) {
    free(params);
}

- (void)test_timeComplexRender {
    
    struct FT_Outline_ *complexOutLine = makeSegmentedCirclePoly();
    struct FT_Bitmap_ *bitmap = makeBitmap();
	struct FT_Raster_Params_ *params = makeParams( complexOutLine, bitmap );

	// Allocate a chunk of mem for the render pool. Shared - Optional, reccomended for efficiency
	const int kRenderPoolSize = 1024 * 1024;
	unsigned char *renderPool = calloc( 1, kRenderPoolSize );
    
	// Initialize the rasterer and get it to render into the bitmap.
	struct FT_RasterRec_ *raster;
    
    double startTime = sys_getrealtime();
    double time = 0;
    static int profileCount = 0;
    while(time<3.0)
    {
        Err = ft_standard_raster.raster_new( NULL, &raster );        
        ft_standard_raster.raster_reset( raster, renderPool, kRenderPoolSize );
        Err = ft_standard_raster.raster_render( raster, params );
        if (Err != 0) {
            printf("Encountered error %d rendering fourth glyph\n", Err);
            exit(1);
        }        
        time = sys_getrealtime()-startTime;
        profileCount++;
    }
    // Compare this result with
    NSLog(@"in three seconds %i times", profileCount);
    
    unsigned char *eightBitBuffer = calloc(1,400*400); // 16 bit align this? maybe later
    for(int j=0; j<400; j++){
        for(int i=0; i<50; i++){
            unsigned char c = params->target->buffer[j*50+i];
            for (int k=0; k<8; k++){
                int b = ((c >> k) & 1);
                int address = j*400+(i*8)+7-k; // this swaps byte order, possible endian issue!
                if(b)
                    eightBitBuffer[address] = 255;
            }
        }
    }
    
    FILE *fp;
    fp = fopen( "/Users/shooley/Desktop/cout_mono_test2.raw", "wb" );
    fwrite( eightBitBuffer, 1, 400*400, fp );
    fclose(fp);
    
    free(eightBitBuffer);


    releaseParams(params);
    releaseBitmap(bitmap);
    freeSpaceForShape( complexOutLine );
    
    ft_standard_raster.raster_done(raster);
    
}

// Render a shape and dump it out as a raw image 
// http://www.freetype.org/freetype2/docs/tutorial/example3.cpp
- (void)test_firstAttemptAtFreetype {

    struct FT_Outline_ *simpleOutLine = makeSimplePoly();
    
	const int widthPx = 400;
	const int rows = 400;
    
	const int pitch_sixteenBitAligned = ((widthPx + 15) >> 4) << 1; // one row bytes including padding - 50

    // 1 bit per pixel.
    const int pitch_mono = (widthPx + 7) >> 3;
    
    // 8 bits per pixel; must be a multiple of four. -- this doesnt work?
    const int pitch_gray = (widthPx + 3) & -4;
    
    const int chosenPitch = pitch_mono;
    
//    for(int i=0; i<400; i++){
//        const int pitch = ((i + 15) >> 4) << 1;
//        const int pitch_mono = (i + 7) >> 3;
//        const int p2 = (widthPx + 3) & -4;
//        
//        NSLog(@"%i %i %i", pitch, pitch_mono, p2);
//    }
    
	// Set up a bitmap
	struct FT_Bitmap_ *bitmap = makeBitmap();
    
	// Set up the raster params (these seem to be the only two checked).
	struct FT_Raster_Params_ params;
	memset( &params, 0, sizeof(params) );
	params.source = simpleOutLine;
	params.target = bitmap;
	params.flags = FT_RASTER_FLAG_DEFAULT; // @FT_RASTER_FLAG_AA, @FT_RASTER_FLAG_DIRECT, use @FT_RASTER_FLAG_AA for greyscale
    //params.user = (void *)0xffffffc0;	// data passed to the callback
	
	// if @FT_RASTER_FLAG_DIRECT is set (AA mode only) - you have to set these, otherwise dont bother
	// gray_spans = span_rendering_fuction
    // params.clip_box.xMin = 519;
    // params.clip_box.xMax = 8125;
    // params.clip_box.yMin = 8125;
    // params.clip_box.yMax = 64;
	
	
	// Allocate a chunk of mem for the render pool. Shared - Optional, reccomended for efficiency
	const int kRenderPoolSize = 1024 * 1024;
	unsigned char *renderPool = calloc( 1, kRenderPoolSize );

	// Initialize the rasterer and get it to render into the bitmap.
	struct FT_RasterRec_ *raster;
	Err = ft_standard_raster.raster_new( NULL, &raster );
	ft_standard_raster.raster_reset( raster, renderPool, kRenderPoolSize );
	Err = ft_standard_raster.raster_render( raster, &params );

	if (Err != 0) {
		printf("Encountered error %d rendering fourth glyph\n", Err);
		exit(1);
    }
   	
    //fputs("STATE: +com.sample-cyan-error\n", stderr);

    // Dump out the raw image data (in PBM format).
    //putback std::ofstream out("out.pbm", std::ios::binary);
    //putback out << "P4 " << width << " " << rows << "\n";
    //putback out.write((const char *)bitmap.buffer, width * pitch); 
    
    // the buffer is single bit, try converting to 8bit so we can load in photoshop
    
    // the image may be 5 bits wide, say. That is we need to know how many bytes to iterate over
    unsigned char *eightBitBuffer = calloc(1,400*400); // 16 bit align this? maybe later
 
    // i dont know if the padding is at the end of the line or between bytes
    int incompleteRowBytes = widthPx/8; // there are some pixels in the next byte
//    int ignoredPixels = widthPx - (incompleteRowBytes*8);
//    for(int j=0; j<400*50; j++){
//        unsigned char c = oneBitBuffer[j];
//        if(c>0)
//            NSLog(@"really? %i", c);        
//    }
//    
    for(int j=0; j<rows; j++){
        for(int i=0; i<50; i++){
            unsigned char c = bitmap->buffer[j*50+i];
            for (int k=0; k<8; k++){
                int b = ((c >> k) & 1);
                int address = j*400+(i*8)+7-k; // this swaps byte order, possible endian issue!
                if(b)
                    eightBitBuffer[address] = 255;
            }
        }
    }
 //   [0000][0000][0000][1100] 14 out of 16
        
    //-- is it bits or bytes?
    FILE *fp;
    fp = fopen( "/Users/shooley/Desktop/cout_mono_test1.raw", "wb" );
    fwrite( eightBitBuffer, 1, 400*400, fp );
    fclose(fp);

    free(eightBitBuffer);
    freeSpaceForShape(simpleOutLine);
    releaseBitmap(bitmap);

    // write(STDERR_FILENO, buffer, 400);

    ft_standard_raster.raster_done(raster);
}

@end