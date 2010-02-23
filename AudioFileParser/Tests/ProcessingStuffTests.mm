//
//  ProcessingStuffTests.mm
//  AudioFileParser
//
//  Created by Steven Hooley on 02/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "BufferStore.h"
#import "ProcessingStuff.h"

@interface ProcessingStuffTests : SenTestCase {
	
	ProcessingStuff *_processor;
}

@end

@implementation ProcessingStuffTests

- (void)setUp {
	_processor = [[ProcessingStuff alloc] init];
}

- (void)tearDown {
	[_processor release];
}

- (void)testProcessABufferStore {
		
}

@end
