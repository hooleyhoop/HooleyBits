//
//  ContiguousMemoryBlockStore.m
//  MachoLoader
//
//  Created by Steven Hooley on 30/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import "ContiguousMemoryBlockStore.h"
#import "SHMemoryBlock.h"
#import "TPdata.h"
#import "TPLine.h"
#import "MemorySectionIndexStructure.h"

@implementation ContiguousMemoryBlockStore

//NB this doesnt save the data at the mo - just the pointers into it
- (id)initWithRawData:(char *)data start:(char *)memAddr length:(uint64)len {
    
    self = [super init];
    if(self){
        TPData *listHead = [[[TPData alloc] initWithStart:memAddr length:len] autorelease];
        [self insertMemoryBlock:listHead];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (uint64)contiguousLength {
    return [self lastAddress]-[self startAddress]+1;
}

- (BOOL)containsAddress:(char *)address {
    return address >= [self startAddress] && address<=[self lastAddress];
}

// just a test, if we cant just split the data in half we arent going to get anywhere
//- (void)simpleTemporarySplitAtAddress:(char *)splitLoc {
//    
//    // 0 1 2 3 4   5 6 7 8 9
//    int indexOfBlockToSplit = 0;
//    
//    SHMemoryBlock *ob1 = [self memoryBlockAtIndex:indexOfBlockToSplit];
//    NSAssert( [ob1 containsAddress:(char *)splitLoc], nil );
//    
//    struct SplitData result = [ob1 splitAtAddress:splitLoc];
//    
//    [self replaceItemAtIndex:indexOfBlockToSplit with:result.blk1, result.blk2, nil];    
//}

// we already have the data object and the line by this points
- (void)splitData:(SHMemoryBlock *)dataBlk atIndex:(int)ind withLine:(TPLine *)line {
    
    id resultsOfSplit[3] = {nil,nil,nil};
    
    struct SplitDataResultIndexes *indexesAfterSplit = splitMemSectionIndexes( dataBlk->_sizeAndPoisition, line->_sizeAndPoisition );
    
    if(indexesAfterSplit->numberOfMemSectionIndexes>1) {
        struct SplitData result1 = [dataBlk splitAtAddress:indexesAfterSplit->memSectionIndexes[1].start];
        resultsOfSplit[0] = result1.blk1;
        resultsOfSplit[1] = result1.blk2;
    }
    if(indexesAfterSplit->numberOfMemSectionIndexes>2) {
        struct SplitData result2 = [resultsOfSplit[1] splitAtAddress:indexesAfterSplit->memSectionIndexes[2].start];
        resultsOfSplit[1] = result2.blk1;
        resultsOfSplit[2] = result2.blk2;        
    }    
    resultsOfSplit[indexesAfterSplit->indexOfSplitter] = line;
    
    [self replaceItemAtIndex:ind with:resultsOfSplit[0], resultsOfSplit[1], resultsOfSplit[2], nil];    
    
    free(indexesAfterSplit);
}


- (enum datatype)getItemAtAddress:(char *)address item:(id *)ptr {
    
    SHMemoryBlock *bl = [self blockForAddress:address];
    *ptr = bl;
    if([bl isKindOfClass:[TPData class]])
        return datatype_DATA;
    if([bl isKindOfClass:[TPLine class]])
        return datatype_LINE;
    return datatype_ERROR;
}

@end
