//
//  MemorySectionIndexStructureTest.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "MemorySectionIndexStructure.h"


@interface MemorySectionIndexStructureTest : SenTestCase {
@private
    
}

@end

@implementation MemorySectionIndexStructureTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {    
    [super tearDown];
}

struct SplitDataResultIndexes * split( struct MemSectionIndexes *data, struct MemSectionIndexes *line ) {

    char *starts[3];
    uint64 lengths[3];
    
    struct SplitDataResultIndexes *result;
    
    char *line_firstByte = line->start;
    char *line_lastByte = line_firstByte + line->length-1;

    char *data_firstByte = data->start;
    char *data_lastByte = data_firstByte+data->length-1;
        
    NSCAssert( line_firstByte >= data_firstByte, nil );
    NSCAssert( line_lastByte <= data_lastByte, nil );

    int secCount = 0;
    if( line_firstByte>data_firstByte ) {
        starts[secCount] = data_firstByte;
        lengths[secCount] = line_firstByte-data_firstByte;
        secCount++;
    }
        
    starts[secCount] = line_firstByte;
    lengths[secCount] = line->length;
    int indexOfSplitter = secCount;
    secCount++;

    if( line_lastByte < data_lastByte ) {
        starts[secCount]  = line_lastByte+1;
        lengths[secCount] = data_lastByte - line_lastByte;
        secCount++;        
    }

    result = new_SplitDataResultIndexes( secCount );
    result->indexOfSplitter = indexOfSplitter;
    for(int i=0; i<secCount; i++){
        result->memSectionIndexes[i].start = starts[i];
        result->memSectionIndexes[i].length = lengths[i];
    }
    
    return result;
}

- (void)testSplitDataWithLine {

    // given data starting at 0 and 10 long what happns when you split it with a line 
    // starting at 0 1 long?
    struct MemSectionIndexes *data1 = new_MemSectionIndexes( 0, 10 );
    struct MemSectionIndexes *line1 = new_MemSectionIndexes( 0, 1 );

    struct SplitDataResultIndexes *result = split( data1, line1 );
    STAssertTrue( result->numberOfMemSectionIndexes==2, nil );
    STAssertTrue( result->indexOfSplitter==0, nil );
    STAssertTrue( result->memSectionIndexes[0].start==0, nil );
    STAssertTrue( result->memSectionIndexes[0].length==1, nil );
    STAssertTrue( result->memSectionIndexes[1].start==(char *)1, nil );
    STAssertTrue( result->memSectionIndexes[1].length==9, nil );    
    
    free(data1);
    free(line1);
    free(result);

    // a line in the middle
    data1 = new_MemSectionIndexes( 0, 10 );
    line1 = new_MemSectionIndexes( (char *)1, 1 );
    
    result = split( data1, line1 );
    STAssertTrue( result->numberOfMemSectionIndexes==3, nil );
    STAssertTrue( result->indexOfSplitter==1, nil );
    STAssertTrue( result->memSectionIndexes[0].start==0, nil );
    STAssertTrue( result->memSectionIndexes[0].length==1, nil );
    STAssertTrue( result->memSectionIndexes[1].start==(char *)1, nil );
    STAssertTrue( result->memSectionIndexes[1].length==1, nil ); 
    STAssertTrue( result->memSectionIndexes[2].start==(char *)2, nil );
    STAssertTrue( result->memSectionIndexes[2].length==8, nil );     

    free(data1);
    free(line1);
    free(result);
    
    // a line the full size of the data    
    data1 = new_MemSectionIndexes( 0, 10 );
    line1 = new_MemSectionIndexes( 0, 10 );
    result = split( data1, line1 );
    STAssertTrue( result->numberOfMemSectionIndexes==1, nil );
    STAssertTrue( result->indexOfSplitter==0, nil );
    STAssertTrue( result->memSectionIndexes[0].start==0, nil );
    STAssertTrue( result->memSectionIndexes[0].length==10, nil );
    free(data1);
    free(line1);
    free(result);
   
    // a line at the end   
    data1 = new_MemSectionIndexes( 0, 10 );
    line1 = new_MemSectionIndexes( (char *)8, 2 );
    result = split( data1, line1 );
    STAssertTrue( result->numberOfMemSectionIndexes==2, nil );
    STAssertTrue( result->indexOfSplitter==1, nil );
    STAssertTrue( result->memSectionIndexes[0].start==0, nil );
    STAssertTrue( result->memSectionIndexes[0].length==8, nil );
    STAssertTrue( result->memSectionIndexes[1].start==(char *)8, nil );
    STAssertTrue( result->memSectionIndexes[1].length==2, nil ); 

    free(data1);
    free(line1);
    free(result);    
}


@end
