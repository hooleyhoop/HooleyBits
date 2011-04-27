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