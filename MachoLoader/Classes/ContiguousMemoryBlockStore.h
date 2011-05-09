//
//  ContiguousMemoryBlockStore.h
//  MachoLoader
//
//  Created by Steven Hooley on 30/04/2011.
//  Copyright 2011 uk.co.stevehooley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MemoryBlockStore.h"

@class SHMemoryBlock, TPLine;

enum datatype {
    datatype_LINE,
    datatype_DATA,
    datatype_ERROR
};


@interface ContiguousMemoryBlockStore : MemoryBlockStore {
@private
    
}

- (id)initWithRawData:(char *)data start:(char *)memAddr length:(uint64)len;
    
- (uint64)contiguousLength;

- (BOOL)containsAddress:(char *)address;

- (void)splitData:(SHMemoryBlock *)dataBlk atIndex:(int)ind withLine:(TPLine *)line;

- (enum datatype)getItemAtAddress:(char *)address item:(id *)ptr;
  
@end
