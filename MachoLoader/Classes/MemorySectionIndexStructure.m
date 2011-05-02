//
//  MemorySectionIndexStructure.m
//  MachoLoader
//
//  Created by Steven Hooley on 16/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import "MemorySectionIndexStructure.h"

// constructor
struct MemSectionIndexes * new_MemSectionIndexes( char *start, uint64 length ) {

    struct MemSectionIndexes *obj;
    obj = malloc( sizeof *obj );
    obj->start = start;
    obj->length = length;
    return obj;
}

// constructor
struct SplitDataResultIndexes * new_SplitDataResultIndexes( int numberOfSections ) {
    
    NSCAssert( numberOfSections>0 && numberOfSections<=3, @"cock");
    
    struct SplitDataResultIndexes *list;
    list = malloc( sizeof *list + (numberOfSections-1) * sizeof list->memSectionIndexes[0]);
    list->numberOfMemSectionIndexes = numberOfSections;
    return list;
}

struct SplitDataResultIndexes * splitMemSectionIndexes( struct MemSectionIndexes *data, struct MemSectionIndexes *line ) {
    
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
