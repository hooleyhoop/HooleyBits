//
//  CodeBlockFactoryTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 01/07/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//
#import "CodeBlockFactory.h"
#import "CodeBlock.h"
#import "CodeBlockStore.h"

@interface CodeBlockFactoryTests : SenTestCase {
	
	CodeBlockFactory	*_fac;
	OCMockObject		*_mockStore;
}

@end


@implementation CodeBlockFactoryTests

- (void)setUp {
	
	_mockStore = MOCK(CodeBlockStore);
	_fac = [[CodeBlockFactory alloc] initWithStore:(id)_mockStore];
}

- (void)tearDown {
	[_fac release];
}

- (void)testNewCodeBlockWithName {
	// - (void)newCodeBlockWithName:(NSString *)funcName

	[[[_mockStore expect] andReturnUIntValue:0] blockCount];

	[_fac newCodeBlockWithName:@"steve"];
	STAssertTrue([_fac countOfCodeBlocks]==0, nil);
	[_mockStore verify];
	
	[[_mockStore expect] addCodeBlock:OCMOCK_ANY];
	[[[_mockStore expect] andReturnUIntValue:1] blockCount];

	[_fac addCodeLine:@"aaa"];
	STAssertTrue([_fac countOfCodeBlocks]==1, nil);
	[_mockStore verify];
	
	[_fac newCodeBlockWithName:@"dave"];
	[[[_mockStore expect] andReturnUIntValue:1] blockCount];
	STAssertTrue([_fac countOfCodeBlocks]==1, nil);
	[_mockStore verify];
	
	[[_mockStore expect] addCodeBlock:OCMOCK_ANY];
	[_fac addCodeLine:@"bbb"];
	[[[_mockStore expect] andReturnUIntValue:2] blockCount];
	STAssertTrue([_fac countOfCodeBlocks]==2, nil);
	[_mockStore verify];
}

- (void)testAddCodeLine {
	// - (void)addCodeLine:(NSString *)codeLine

	[[_mockStore stub] addCodeBlock:OCMOCK_ANY];

	[_fac newCodeBlockWithName:@"steve"];
	[_fac addCodeLine:@"aaa"];

	[_fac newCodeBlockWithName:@"dave"];
	[_fac addCodeLine:@"bbb"];

	OCMockObject *mockObject = MOCK(NSArray);

	[[[_mockStore expect] andReturn:mockObject] allBlocks];
	NSArray *allBlocks = [_fac allCodeBlocks];

	STAssertTrue( (id)mockObject==(id)allBlocks, @"fuck" );
	[_mockStore verify];
}

//@"start:"
//@"-(BOOL)[FilterComboBox textView:shouldChangeTextInRange:replacementString:]"
//@"-(void)[IdeasOrganiserBitmapButton setEnabled:]"
//@"+(void)[IdeasOrganiserBitmapButton fake:]"



@end
