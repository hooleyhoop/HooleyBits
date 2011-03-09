#import "ftmisc.h"
#import "ftimage.h"
#import "ftraster.h"

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

void PopulatePointsRegular( FT_Vector *Points, char *Tags, int scale ) {

    /* Populate the regular glyph Points array */
    if (scale == 72) {
		Points[0].x = 252;
		Points[0].y = 0;
		Points[1].x = 252;
		Points[1].y = 25;
		Points[2].x = 0;
		Points[2].y = 25;
		Points[3].x = 0;
		Points[3].y = 0;
    }
	
    if (scale == 96) {
		Points[0].x = 344;
		Points[0].y = 42;
		Points[1].x = 344;
		Points[1].y = 76;
		Points[2].x = 0;
		Points[2].y = 76;
		Points[3].x = 0;
		Points[3].y = 42;
    }
	
	// bit 0 = on curve or not
	// if bit 0==0, ie. is off curve, ie, is control pt, bit 1=third-order Bézier arc control point if set (postscript), and a second-order control point if unset (truetype). 
    // If bit~2 is set, bits 5-7 contain the drop-out mode
	// Bits 3 and~4 are reserved for internal purposes
	Tags[0] = 1; 
    Tags[1] = 1;
    Tags[2] = 1;
    Tags[3] = 1;
}


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

struct FT_Outline_ *_allocSpaceForShape( int numberOfContours, int numberOfPts ) {
    
    struct FT_Outline_ *outline = calloc( 1, sizeof(struct FT_Outline_) );
    struct  FT_Vector_ *pts = calloc( numberOfPts, sizeof(struct  FT_Vector_) );
    char *ptTags = calloc( numberOfContours, 1 );
    short *contours = calloc( numberOfContours, sizeof(short) );
    // fill in pts
    // fill in tags
    // fill in contours
    outline->points = pts;
    outline->tags = ptTags;
    outline->contours = contours;
    outline->n_contours = numberOfContours;
    outline->n_points = numberOfPts;
    outline->flags = 0;
    return outline;
}

void _freeSpaceForShape( struct FT_Outline_ *outline ) {
    
    free( outline->points ); outline->points = NULL;
    free( outline->tags ); outline->tags = NULL;
    free( outline->contours ); outline->contours = NULL;
    outline->n_contours = 0;
    outline->n_points = 0;
    free(outline);
}

void cartToPolar( float x, float y, float *r, float *theta ) {
    *r = sqrt(x*x+y*y);
    *theta = atan2(y,x);
}

void polarToCart( float r, float theta, float *x, float *y ) {
    *x = r * cos(theta);
    *y = r * sin(theta);
}

// you need to release the poly
struct FT_Outline_ *makePoly() {
    
    int contourCount = 1;
    int lineSegments = 4;
    int ptCount = lineSegments-1; // assuming auto closed    
    struct FT_Outline_ *complexOutLine = _allocSpaceForShape( contourCount, ptCount );
    
    // fill in some points - for a closed shape
    complexOutLine->contours[0] = ptCount-1;
    float angle = 360.0f/lineSegments;
    
    float rad = 100.0f;
    float centrex = 200, centrey = 200;
    
    // for 4 sections, add start, assuming contour is automatically closed, so we miss off the last point
    // ie n pts gives n+1 sections (assuming it is closed automatically - verify this)
    for( int i=0; i<lineSegments; i++ ) {
        float theta = i*angle;
        float x, y;
        polarToCart( rad, theta, &x, &y );
        NSLog(@"x>%f, y>%f",x,y);
		complexOutLine->points[i].x = x+centrex;
		complexOutLine->points[i].y = y+centrey;
        complexOutLine->tags[i] = 1;
    }
    return complexOutLine;
}

struct FT_Bitmap_ *makeBitmap() {
    
    struct FT_Bitmap_ *bitmap = calloc(1,sizeof(struct FT_Bitmap_));
    
	const int width = 400;
	const int rows = 400;
	const int pitch = ((width + 15) >> 4) << 1; // one row including padding    
    unsigned char *buffer = calloc(1, width*pitch);
	bitmap->buffer = buffer;
	bitmap->width = width;
	bitmap->rows = rows;
	bitmap->pitch = pitch;
	//if aa bitmap.num_grays = 256;
	bitmap->pixel_mode = FT_PIXEL_MODE_MONO; // FT_PIXEL_MODE_GRAY
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

void spawnWindowWithImage( CGImageRef img ){
    
   // NSRect frame = NSMakeRect(0, 0, CGImageGetWidth(img), CGImageGetHeight(img));
   // NSWindow *newWindow = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
   // [newWindow makeKeyAndOrderFront:nil];
    
    NSImage *im = [[NSImage alloc] initWithCGImage:img size:CGSizeZero];
    NSData *tiff = [im TIFFRepresentation];
    BOOL result = [tiff writeToFile:@"/testStuff.tif" atomically:NO];
    NSLog(@"boo %i", result);
}

- (void)test_timeComplexRender {
    
    struct FT_Outline_ *complexOutLine = makePoly();
    struct FT_Bitmap_ *bitmap = makeBitmap();
	struct FT_Raster_Params_ *params = makeParams( complexOutLine, bitmap );

	// Allocate a chunk of mem for the render pool. Shared - Optional, reccomended for efficiency
	const int kRenderPoolSize = 1024 * 1024;
	unsigned char *renderPool = calloc( 1, kRenderPoolSize );
    
	// Initialize the rasterer and get it to render into the bitmap.
	struct FT_RasterRec_ *raster;
	Err = ft_standard_raster.raster_new( NULL, &raster );
	ft_standard_raster.raster_reset( raster, renderPool, kRenderPoolSize );
	Err = ft_standard_raster.raster_render( raster, params );
    
	if (Err != 0) {
		printf("Encountered error %d rendering fourth glyph\n", Err);
		exit(1);
    }
    
    // to cgImage
    int actualDataLength = 400*400;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData( NULL, bitmap->buffer, actualDataLength, NULL);
    
	CGFloat scaledGlyph1Width = 400;
	CGFloat scaledGlyph1Height = 400;
	size_t bitsPerComponent = 8;
	size_t componentsPerPixel = 1;
	size_t bitsPerPixel = bitsPerComponent * componentsPerPixel;
	size_t bytesPerRow = ( scaledGlyph1Width * bitsPerPixel + 7)/8;	
	size_t dataLength = bytesPerRow * scaledGlyph1Height;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateWithName( kCGColorSpaceModelMonochrome );
	CGBitmapInfo bitmapInfo = kCGImageAlphaNone;

	CGImageRef cgImage = CGImageCreate( 
                                       scaledGlyph1Width, 
                                       scaledGlyph1Height, 
                                       bitsPerComponent, 
                                       bitsPerPixel, 
                                       bytesPerRow, 
                                       colorspace, 
                                       bitmapInfo, 
                                       dataProvider, 
                                       NULL, 
                                       false, 
                                       kCGRenderingIntentDefault );

    spawnWindowWithImage(cgImage);
    sleep(100);
    
	CGImageRelease( cgImage );    
	CGDataProviderRelease(dataProvider);

    releaseParams(params);
    releaseBitmap(bitmap);
    _freeSpaceForShape( complexOutLine );
}

// Render a shape and dump it out as a raw image 
- (void)test_firstAttemptAtFreetype {
// Set up the memory management to use malloc and free
//putback FT_MemoryRec_mem = new FT_MemoryRec_;
//putback mem->alloc = MY_Alloc_Func;
//putback mem->free = MY_Free_Func;
//putback mem->realloc = MY_Realloc_Func;

    // Build an outline manually
    struct FT_Outline_ outline;
    FT_Vector RegularPoints[4];
    char RegularTags[4];
    short RegularContours[1];	

	PopulatePointsRegular((FT_Vector *)&RegularPoints, (char *)&RegularTags, 72);
    RegularContours[0] = 3;

    outline.n_contours = 1; // number of shapes, ie uppercase B has 3 contours
    outline.n_points = 4;
	outline.flags = 0; //0x104 ? // FT_OUTLINE_OWNER, FT_OUTLINE_EVEN_ODD_FILL (only smooth rasterizer), FT_OUTLINE_REVERSE_FILL, FT_OUTLINE_HIGH_PRECISION, FT_OUTLINE_SINGLE_PASS, etc
    outline.tags = (char *)&RegularTags;
    outline.contours = (short *)&RegularContours; // shape 0 is pt 0 to contour[0], shape 1 is the next pt to contour[1]
    outline.points = (FT_Vector *)&RegularPoints;
	
	const int width = 400;
	const int rows = 400;
	const int pitch = ((width + 15) >> 4) << 1; // one row including padding

	// Set up a bitmap
	struct FT_Bitmap_ bitmap;
    unsigned char buffer[width * pitch];
	bitmap.buffer = buffer;
	memset( bitmap.buffer, 0, width * pitch );
	bitmap.width = width;
	bitmap.rows = rows;
	bitmap.pitch = pitch;
	//if aa bitmap.num_grays = 256;
	bitmap.pixel_mode = FT_PIXEL_MODE_MONO; // FT_PIXEL_MODE_GRAY
	
    // not used - bitmap.palette = 0;
    // not used - bitmap.palette_mode = 0;

	// Set up the raster params (these seem to be the only two checked).
	struct FT_Raster_Params_ params;
	memset( &params, 0, sizeof(params) );
	params.source = &outline;
	params.target = &bitmap;
	params.flags = FT_RASTER_FLAG_DEFAULT; // @FT_RASTER_FLAG_AA, @FT_RASTER_FLAG_DIRECT
    params.user = (void *)0xffffffc0;	// data passed to the callback
	
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
    
    ft_standard_raster.raster_done(raster);
	// Dump out the raw image data (in PBM format).
//putback std::ofstream out("out.pbm", std::ios::binary);
//putback out << "P4 " << width << " " << rows << "\n";
//putback out.write((const char *)bitmap.buffer, width * pitch);

}

@end