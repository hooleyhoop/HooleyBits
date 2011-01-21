
#define FT_CONFIG_STANDARD_LIBRARY_H  <stdlib.h>
#include <math.h>

#include "ftmisc.h"
#include "ftimage.h"

extern const FT_Raster_Funcs ft_standard_raster;

void DrawBitmap(const FT_Bitmap *bitmap)
{
    int y, x;
    unsigned char *ptr, shift, mod;

    for (y=0;y<bitmap->rows;y++){
	ptr = bitmap->buffer + (y * bitmap->pitch) - 1;
	for(x=0;x<bitmap->width;x++){
	    if (x % 8 == 0)
		ptr++;
	    mod = x % 8;
	    shift = pow((double)2, (double)7 - mod);
	    if(*ptr & shift)
		printf("X");
	    else
		printf("_");
	}
	printf("\n");
    }
}

PopulatePointsRegular(FT_Vector *Points, char *Tags, int scale)
{
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

PopulatePointsInverted(FT_Vector *Points, char *Tags, int scale)
{
    /* Populate the inverted glyph Points array */
    if (scale == 72) {
	Points[0].x = 252;
	Points[0].y = 64;
	Points[1].x = 252;
	Points[1].y = 39;
	Points[2].x = 0;
	Points[2].y = 39;
	Points[3].x = 0;
	Points[3].y = 64;
    }

    if (scale == 96) {
	Points[0].x = 344;
	Points[0].y = 86;
	Points[1].x = 344;
	Points[1].y = 52;
	Points[2].x = 0;
	Points[2].y = 52;
	Points[3].x = 0;
	Points[3].y = 86;
    }

    Tags[0] = 1;
    Tags[1] = 1;
    Tags[2] = 1;
    Tags[3] = 1;
}

int main(int argc, char *argv[], char *envp[])
{
    FT_Error Err;
    struct FT_RasterRec_ raster;
    FT_Bitmap bitmap;
    struct FT_Raster_Params_ params;
    unsigned char buffer[1024];
    unsigned char pool[16*1024];

    FT_Outline RegularOutline;
    FT_Vector RegularPoints[4];
    char RegularTags[4];
    short RegularContours[1];

    FT_Outline InvertedOutline;
    FT_Vector InvertedPoints[4];
    char InvertedTags[4];
    short InvertedContours[1];

    struct FT_Outline_ RegularOutline96;
    FT_Vector RegularPoints96[4];
    char RegularTags96[4];
    short RegularContours96[1];

    FT_Outline InvertedOutline96;
    FT_Vector InvertedPoints96[4];
    char InvertedTags96[4];
    short InvertedContours96[1];

    /* Initialise a few structures for safety */
    memset(&RegularOutline, 0x00, sizeof(FT_Outline));
    memset(&InvertedOutline, 0x00, sizeof(FT_Outline));
    memset(&RegularOutline96, 0x00, sizeof(FT_Outline));
    memset(&InvertedOutline96, 0x00, sizeof(FT_Outline));
    memset(&params, 0x00, sizeof(FT_Raster_Params));

    /* Initialise the raster structure */
    Err = ft_standard_raster.raster_new(NULL, &raster);

    /* Populate the regular glyph bitmap structure */
    /* This is common to both the regular and inverted glyphs */
    bitmap.buffer = (unsigned char *)&buffer;
    bitmap.palette = 0;
    bitmap.palette_mode = 0;
    bitmap.pitch = 2;
    bitmap.pixel_mode = 1;
    bitmap.rows = 1;
    bitmap.width = 4;


    /* Render the regular glyph */
    PopulatePointsRegular((FT_Vector *)&RegularPoints, (char *)&RegularTags, 72);
    RegularContours[0] = 3;

    /* Populate the regular glyph Outline structure */
    RegularOutline.n_contours = 1;
    RegularOutline.n_points = 4;
    RegularOutline.flags = 0x104;
    RegularOutline.tags = (char *)&RegularTags;
    RegularOutline.contours = (short *)&RegularContours;
    RegularOutline.points = (FT_Vector *)&RegularPoints;

    /* And finally populate the regular gyph params structure */
    params.source = &RegularOutline;
    params.target = &bitmap;
    params.user = (void *)0xffffffc0;
    params.clip_box.xMin = 519;
    params.clip_box.xMax = 8125;
    params.clip_box.yMin = 8125;
    params.clip_box.yMax = 64;

    /* Clear the bitmap buffer before starting */
    memset(&buffer, 0x00, 1024);
    /* At last, render the regular glyph */
    ft_standard_raster.raster_reset(raster, pool, 16*1024);
    Err = ft_standard_raster.raster_render(raster, &params);

    if (Err != 0) {
	printf("Encountered error %d rendering first glyph\n", Err);
	exit(1);
    }
    printf("\nFirst glyph bitmap (regular 72 dpi)\n");
    DrawBitmap(params.target);


    /* Render the inverted glyph */
    PopulatePointsInverted((FT_Vector *)&InvertedPoints, (char *)&InvertedTags, 72);
    InvertedContours[0] = 3;

    /* Populate the inverted glyph Outline structure */
    InvertedOutline.n_contours = 1;
    InvertedOutline.n_points = 4;
    InvertedOutline.flags = 0x104;
    InvertedOutline.tags = (char *)&InvertedTags;
    InvertedOutline.contours = (short *)&InvertedContours;
    InvertedOutline.points = (FT_Vector *)&InvertedPoints;

    /* And finally populate the inverted gyph params structure */
    memset(&params, sizeof(FT_Raster_Params), 0x00);
    params.source = &InvertedOutline;
    params.target = &bitmap;
    params.user = (void *)0x40;
    params.clip_box.xMin = 518;
    params.clip_box.xMax = 8125;
    params.clip_box.yMin = 8125;
    params.clip_box.yMax = 64;

    /* Clear the bitmap buffer before starting */
    memset(&buffer, 0x00, 1024);
    /* At last, render the inverted glyph */
    ft_standard_raster.raster_reset(raster, pool, 16*1024);
    Err = ft_standard_raster.raster_render(raster, &params);

    if (Err != 0) {
	printf("Encountered error %d rendering second glyph\n", Err);
	exit(1);
    }
    printf("\nSecond glyph bitmap (inverted 72 dpi)\n");
    DrawBitmap(params.target);


    /* Now repeat the glyphs, this time at 96 dpi */
    /* Populate the glyph bitmap structure for 96 dpi */
    bitmap.buffer = (unsigned char *)&buffer;
    bitmap.palette = 0;
    bitmap.palette_mode = 0;
    bitmap.pitch = 2;
    bitmap.pixel_mode = 1;
    bitmap.rows = 2;
    bitmap.width = 6;

    /* Populate the regular glyph Points array */
    PopulatePointsInverted((FT_Vector *)&RegularPoints96, (char *)&RegularTags96, 96);
    RegularContours96[0] = 3;

    /* Populate the inverted glyph Outline structure */
    RegularOutline96.n_contours = 1;
    RegularOutline96.n_points = 4;
    RegularOutline96.flags = 0x104;
    RegularOutline96.tags = (char *)&RegularTags96;
    RegularOutline96.contours = (short *)&RegularContours96;
    RegularOutline96.points = (FT_Vector *)&RegularPoints96;

    /* And finally populate the inverted gyph params structure */
    memset(&params, sizeof(FT_Raster_Params), 0x00);
    params.source = &RegularOutline96;
    params.target = &bitmap;
    params.user = (void *)0x56;
    params.clip_box.xMin = 518;
    params.clip_box.xMax = 10875;
    params.clip_box.yMin = 10875;
    params.clip_box.yMax = 86;

    /* Clear the bitmap buffer before starting */
    memset(&buffer, 0x00, 1024);
    /* At last, render the inverted glyph */
    ft_standard_raster.raster_reset(raster, pool, 16*1024);
    Err = ft_standard_raster.raster_render(raster, &params);

    if (Err != 0) {
	printf("Encountered error %d rendering third glyph\n", Err);
	exit(1);
    }
    printf("\nThird glyph bitmap (regular 96 dpi)\n");
    DrawBitmap(params.target);


    /* Populate the inverted glyph Points array */
    PopulatePointsInverted((FT_Vector *)&InvertedPoints96, (char *)&InvertedTags96, 96);
    InvertedContours96[0] = 3;

    /* Populate the inverted glyph Outline structure */
    InvertedOutline96.n_contours = 1;
    InvertedOutline96.n_points = 4;
    InvertedOutline96.flags = 0x104;
    InvertedOutline96.tags = (char *)&InvertedTags96;
    InvertedOutline96.contours = (short *)&InvertedContours96;
    InvertedOutline96.points = (FT_Vector *)&InvertedPoints96;

    /* And finally populate the inverted gyph params structure */
    memset(&params, sizeof(FT_Raster_Params), 0x00);
    params.source = &InvertedOutline96;
    params.target = &bitmap;
    params.user = (void *)0x56;
    params.clip_box.xMin = 519;
    params.clip_box.xMax = 10875;
    params.clip_box.yMin = 10875;
    params.clip_box.yMax = 86;

    /* Clear the bitmap buffer before starting */
    memset(&buffer, 0x00, 1024);
    /* At last, render the inverted glyph */
    ft_standard_raster.raster_reset(raster, pool, 16*1024);
    Err = ft_standard_raster.raster_render(raster, &params);

    if (Err != 0) {
	printf("Encountered error %d rendering fourth glyph\n", Err);
	exit(1);
    }
    printf("\nFourth glyph bitmap (inverted 96 dpi)\n");
    DrawBitmap(params.target);
}
