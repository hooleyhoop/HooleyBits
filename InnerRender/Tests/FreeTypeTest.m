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
	
    Tags[0] = 1;
    Tags[1] = 1;
    Tags[2] = 1;
    Tags[3] = 1;
}


FT_Memory mem;
FT_Error Err;



//
// Render a shape and dump it out as a raw image 
int mainTest() {
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

    outline.n_contours = 1;
    outline.n_points = 4;
	outline.flags = 0; //0x104 ?
    outline.tags = (char *)&RegularTags;
    outline.contours = (short *)&RegularContours;
    outline.points = (FT_Vector *)&RegularPoints;
	
	const int width = 400;
	const int rows = 400;
	const int pitch = ((width + 15) >> 4) << 1;

	// Set up a bitmap
	struct FT_Bitmap_ bitmap;
    unsigned char buffer[width * pitch];
	bitmap.buffer = buffer;
	memset(bitmap.buffer, 0, width * pitch);
	bitmap.width = width;
	bitmap.rows = rows;
	bitmap.pitch = pitch;
	bitmap.pixel_mode = FT_PIXEL_MODE_MONO;
    bitmap.palette = 0;
    bitmap.palette_mode = 0;

	// Set up the raster params (these seem to be the only two checked).
	struct FT_Raster_Params_ params;
	memset( &params, 0, sizeof(params) );
	params.source = &outline;
	params.target = &bitmap;
    params.user = (void *)0xffffffc0;
    params.clip_box.xMin = 519;
    params.clip_box.xMax = 8125;
    params.clip_box.yMin = 8125;
    params.clip_box.yMax = 64;
	
	
	// Allocate a chunk of mem for the render pool.
	const int kRenderPoolSize = 1024 * 1024;
	unsigned char *renderPool = calloc( 1, kRenderPoolSize );

	// Initialize the rasterer and get it to render into the bitmap.
	struct FT_RasterRec_ *raster;
	Err = ft_standard_raster.raster_new( mem, &raster );
	ft_standard_raster.raster_reset( raster, renderPool, kRenderPoolSize );
	Err = ft_standard_raster.raster_render( raster, &params );

	if (Err != 0) {
		printf("Encountered error %d rendering fourth glyph\n", Err);
		exit(1);
    }
	// Dump out the raw image data (in PBM format).
//putback std::ofstream out("out.pbm", std::ios::binary);
//putback out << "P4 " << width << " " << rows << "\n";
//putback out.write((const char *)bitmap.buffer, width * pitch);

	return 0;
}