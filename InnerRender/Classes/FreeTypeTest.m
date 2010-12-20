/*
 *  anotherTest.c
 *  InnerRender
 *
 *  Created by Steven Hooley on 18/12/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

#include "anotherTest.h"

/*
 *  anotherTest.h
 *  InnerRender
 *
 *  Created by Steven Hooley on 18/12/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

#import "ftmisc.h"
#import "ftimage.h"
#import "ftraster.h"

//#include "malloc.h"
//#include <fstream>

//
// Define an acorn shape to test with
//
//putback struct Vec2
//putback {
//putback 	Vec2(float a, float b) : x(a), y(b) { }
	
//putback 	float x, y;
//putback };

//putback static Vec2 k_shape[] =
//putback { Vec2(-3, -18), Vec2(0, -12), Vec2(6, -10), Vec2(12, -6), Vec2(12, -4),
//putback 	Vec2(11, -4), Vec2(10, -5), Vec2(10, 1), Vec2(9, 6), Vec2(7, 10),
//putback 	Vec2(5, 12), Vec2(4, 15),Vec2(3, 14), Vec2(1, 13), Vec2(-1, 13),
//putback 	Vec2(-5, 11), Vec2(-8, 8), Vec2(-11, 2), Vec2(-11, -2), Vec2(-14, 0),
//putback 	Vec2(-14, -2), Vec2(-11, -7), Vec2(-9, -9), Vec2(-8, -9), Vec2(-5, -12),
//putback 	Vec2(-5, -14), Vec2(-7, -15), Vec2(-8, -14), Vec2(-9, -15), Vec2(-9, -17),
//putback 	Vec2(-7, -17), Vec2(-6, -18)
//putback };

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


FT_Memory mem;


//
// Render a shape and dump it out as a raw image 
int mainTest() {
// Set up the memory management to use malloc and free
//putback FT_MemoryRec_mem = new FT_MemoryRec_;
//putback mem->alloc = MY_Alloc_Func;
//putback mem->free = MY_Free_Func;
//putback mem->realloc = MY_Realloc_Func;

// Build an outline manually
//putback FT_Outline_ outline;
//putback outline.n_contours = 1;
//putback outline.n_points = sizeof (k_shape) / sizeof (Vec2);
//putback outline.points = new FT_Vector[outline.n_points];
//putback for (unsigned int i = 0; i < sizeof (k_shape) / sizeof (Vec2); ++i)
//putback {
//putback     FT_Vector v;
//putback     // offset it to fit in the image and scale it up 10 times
//putback     v.x = (20 + k_shape[i].x) * 10 * 64;
//putback     v.y = (20 + k_shape[i].y) * 10 * 64;
//putback     outline.points[i] = v;
//putback }
//putback outline.tags = new char[outline.n_points];
//putback for (int i = 0; i < outline.n_points; ++i)
//putback outline.tags[i] = 1;
//putback outline.contours = new short[outline.n_contours];
//putback outline.contours[0] = outline.n_points - 1;
//putback outline.flags = 0;

//putback const int width = 400;
//putback const int rows = 400;
//putback const int pitch = ((width + 15) >> 4) << 1;

// Set up a bitmap
//putback FT_Bitmap bmp;
//putback bmp.buffer = new unsigned char[width * pitch];
//putback memset(bmp.buffer, 0, width * pitch);
//putback bmp.width = width;
//putback bmp.rows = rows;
//putback bmp.pitch = pitch;
//putback bmp.pixel_mode = FT_PIXEL_MODE_MONO;

// Set up the raster params (these seem to be the only two checked).
//putback FT_Raster_Params params;
//putback memset(&params, 0, sizeof (params));
//putback params.source = &outline;
//putback params.target = &bmp;

// Allocate a chunk of mem for the render pool.
//putback const int kRenderPoolSize = 1024 * 1024;
//putback unsigned char *renderPool = new unsigned char[kRenderPoolSize];

// Initialize the rasterer and get it to render into the bitmap.
struct FT_RasterRec_ *raster;
ft_standard_raster.raster_new( mem, &raster );
//putback ft_standard_raster.raster_reset(raster, renderPool, kRenderPoolSize);
//putback ft_standard_raster.raster_render(raster, &params);

// Dump out the raw image data (in PBM format).
//putback std::ofstream out("out.pbm", std::ios::binary);
//putback out << "P4 " << width << " " << rows << "\n";
//putback out.write((const char *)bmp.buffer, width * pitch);

	return 0;
}