//
//  MemorySectionIndexStructure.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

// !Make knowlege concrete by making a struct or class

// The indexes that represent a memory block 
struct MemSectionIndexes {
    char *start;
    uint64 length;
};

// constructor
struct MemSectionIndexes * new_MemSectionIndexes( char *start, uint64 length );

#pragma mark - stuff to help splitting a section

// The result of splitting one memory block with another
// The result might be 1, 2, or 3 memory blocks, at least one of which will be 'the Splitter'
struct SplitDataResultIndexes {
    int numberOfMemSectionIndexes;
    int indexOfSplitter;
    struct MemSectionIndexes memSectionIndexes[kVariableLengthArray];
};

// constructor
struct SplitDataResultIndexes * new_SplitDataResultIndexes( int numberOfSections );
struct SplitDataResultIndexes * splitMemSectionIndexes( struct MemSectionIndexes *data, struct MemSectionIndexes *line );