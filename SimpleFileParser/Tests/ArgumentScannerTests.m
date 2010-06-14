//
//  ArgumentScannerTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "ArgumentScanner.h"
#import "TokenArray.h"
#import "Argument.h"

@interface ArgumentScannerTests : SenTestCase {
	
}

@end


@implementation ArgumentScannerTests

+ (NSArray *)testData {
	NSArray *allTests = [NSArray arrayWithObjects:
	 @"*0x004fb883(%ebx,%eax,4)",						 
	 @"(%bx,%si),%al",						 
	 @"(%eax,%eax,2),%eax",						 
	 @"(%edi,%ebx),%esi",						 
	 @"*0x00000080(%eax)",						 
	 @"*0x004fb883(%ebx,%eax,4)",						 
	 @"*0x009d19be(%ebx)",						 
	 @"*0x00baa400(,%edx,4)",						 
	 @"*0x00bc97f4(,%eax,4)",						 
	 @"*0x01023eec",						 
	 @"*0xf4(%ebp)",						 
	 @"*0xfffff4f4(%ebp)",						 
	 @"%al,0xffffff2b(%ebp)",						 
	 @"%cl,0xffff4085(%ecx)",						 
	 @"%dl,0x0000009a(%eax)",						 
	 @"%eax,0x0000025c(%edx)",						 
	 @"%edx,0xfffff630(%ebp)",						 
	 @"$0x09249249,0x0c(%ebp)",						 
	 @"$0x4e,%eax",						 
	 @"$0xffffeca0,%esi",						 
	 @"$0xffffffff,0x00000244(%edx)",						 
	 @"0x000000bc(%edx)",						 
	 @"0x00b97a3f(%ecx),%eax",						 
	 @"0x00f35d04(%eax),%esi",						 
	 @"0x0123e904,%eax",						 
	 @"0x012417ec",						 
	 @"0x05(%ecx),%edx",						 
	 @"0x100b9a53a",						 
	 @"0x30000002,%eax",						 
	 @"0x48(%esi)",						 
	 @"0x60(%edi),%xmm0",						 
	 @"0x60(%edx),%edx",						 
	 @"0xfe2ce6e0(%edi,%eax),%edi",						 
	 @"0xff,",						 
	 @"0xff(%esi,%edi,8),%ecx",						 
	 @"0xff(%esi,%esi),%esi",						 
	 @"0xff(%esi),%edx",						 
	 @"0xffffff68(%ebp,%ecx,8),%xmm0",						 
	 @"0xffffff7c(%ebp),%ax",						 
	 @"0xffffff7f(%ebp)",						 
	 @"0xffffff7f(%ebp),%al",						 
	 @"0xffffff7f(%ebp),%eax",						 
	 @"0xfffffff0(,%eax,8),%eax",						 
	 @"0xffffff7c(%ebp,%ecx,4),%eax",						 
	 @"0xffffff7c(%ebp,%eax,4)",						 
	 @"%eax,%es:(%eax)",						 
	 nil];
	return allTests;
}

- (void)testScanArguments2 {
	
	TokenArray *tkns1 = [TokenArray tokensWithString:@"%eax,%es:(%eax)"];
	[tkns1 secondPass];
	ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tkns1];
	NSUInteger argumentCount = [scanner count];
	STAssertTrue( argumentCount==2, @"eek");
	STAssertTrue( [[[scanner argumentAtIndex:0] output] isEqualToString:@"rgstr:eax"], @"%@", [[scanner argumentAtIndex:0] output] );
	STAssertTrue( [[[scanner argumentAtIndex:1] output] isEqualToString:@"rgstr:es : ( rgstr:eax )"], @"%@", [[scanner argumentAtIndex:1] output]);
}

- (void)testScanArguments {
	
	NSArray *testData = [ArgumentScannerTests testData];
	for( NSString *each in testData ) 
	{
		TokenArray *tkns = [TokenArray tokensWithString:each];
		[tkns secondPass];
		ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tkns];
		NSUInteger argumentCount = [scanner count];
		for( NSUInteger i=0; i<argumentCount; i++) {
			Argument *arg = [scanner argumentAtIndex:0];
			NSLog(@"%@", arg);
		}
	}
}

@end
