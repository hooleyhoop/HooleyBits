//
//  HooRenderTest.m
//  InnerRender
//
//  Created by Steven Hooley on 13/03/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "HooPolygon.h"
#import "HooBitmap.h"
#import "PolygonRasterizer.h"
#import "TestUtils.h"

@interface HooRenderTest : SenTestCase {
@private
    
}

@end


@implementation HooRenderTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {    
    [super tearDown];
}

/*
 * This is a mirror of the freetype test
*/
- (void)test_timeComplexRender {
    
    HooPolygon *complexOutLine = [HooPolygon complexTestPoly];
    HooBitmap *bitmap = [[HooBitmap alloc] initWithWidth:400 height:400];
    PolygonRasterizer *rasterizer = [[PolygonRasterizer alloc] init];

    double startTime = sys_getrealtime();
    double time = 0;
    static int profileCount = 0;
    while(time<3.0)
    {
        [rasterizer reset];
        [rasterizer render:complexOutLine into:bitmap];
        
        time = sys_getrealtime()-startTime;
        profileCount++;
    }
    // Compare this result with
    NSLog(@"in three seconds HOORENDER: %i times", profileCount); // 24216
    
    unsigned char *eightBitBuffer = calloc(1,400*400); // 16 bit align this? maybe later
    for(int j=0; j<400; j++){
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
    
    FILE *fp;
    fp = fopen( "/Users/shooley/Desktop/cout_mono_test3.raw", "wb" );
    fwrite( eightBitBuffer, 1, 400*400, fp );
    fclose(fp);
    
    free(eightBitBuffer);

    [bitmap release];
    [rasterizer release];
}


@end
