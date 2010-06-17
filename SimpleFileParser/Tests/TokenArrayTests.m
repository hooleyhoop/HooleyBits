//
//  TokenArrayTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 10/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TokenArray.h"
#import "BasicToken.h"
#import <mach-o/dyld.h>
#import <mach-o/dyld_images.h>
// <dlfcn.h>.
#import <wchar.h>

@interface TokenArrayTests : SenTestCase {
	
}

@end


@implementation TokenArrayTests

+ (NSArray *)testData {
	NSArray *allTests = [NSArray arrayWithObjects:
						 @"*0x004fb883(%ebx,%eax,4)",
						 @"* decNm:0 lwrCC:x decNm:004 lwrCC:fb decNm:883 ( % lwrCC:ebx , % lwrCC:eax , decNm:4 )",
						 
						 @"(%bx,%si),%al",
						 @"( % lwrCC:bx , % lwrCC:si ) , % lwrCC:al",
						 
						 @"(%eax,%eax,2),%eax",
						 @"( % lwrCC:eax , % lwrCC:eax , decNm:2 ) , % lwrCC:eax",
						 
						 @"(%edi,%ebx),%esi",
						 @"( % lwrCC:edi , % lwrCC:ebx ) , % lwrCC:esi",
						 
						 @"*0x00000080(%eax)",
						 @"* decNm:0 lwrCC:x decNm:00000080 ( % lwrCC:eax )",
						 
						 @"*0x004fb883(%ebx,%eax,4)",
						 @"* decNm:0 lwrCC:x decNm:004 lwrCC:fb decNm:883 ( % lwrCC:ebx , % lwrCC:eax , decNm:4 )",
						 
						 @"*0x009d19be(%ebx)",
						 @"* decNm:0 lwrCC:x decNm:009 lwrCC:d decNm:19 lwrCC:be ( % lwrCC:ebx )",
						 
						 @"*0x00baa400(,%edx,4)",
						 @"* decNm:0 lwrCC:x decNm:00 lwrCC:baa decNm:400 ( , % lwrCC:edx , decNm:4 )",
						 
						 @"*0x00bc97f4(,%eax,4)",
						 @"* decNm:0 lwrCC:x decNm:00 lwrCC:bc decNm:97 lwrCC:f decNm:4 ( , % lwrCC:eax , decNm:4 )",
						 
						 @"*0x01023eec",
						 @"* decNm:0 lwrCC:x decNm:01023 lwrCC:eec",
						 
						 @"*0xf4(%ebp)",
						 @"* decNm:0 lwrCC:xf decNm:4 ( % lwrCC:ebp )",
						 
						 @"*0xfffff4f4(%ebp)",
						 @"* decNm:0 lwrCC:xfffff decNm:4 lwrCC:f decNm:4 ( % lwrCC:ebp )",
						 
						 @"%al,0xffffff2b(%ebp)",
						 @"% lwrCC:al , decNm:0 lwrCC:xffffff decNm:2 lwrCC:b ( % lwrCC:ebp )",
						 
						 @"%cl,0xffff4085(%ecx)",
						 @"% lwrCC:cl , decNm:0 lwrCC:xffff decNm:4085 ( % lwrCC:ecx )",
						 
						 @"%dl,0x0000009a(%eax)",
						 @"% lwrCC:dl , decNm:0 lwrCC:x decNm:0000009 lwrCC:a ( % lwrCC:eax )",
						 
						 @"%eax,0x0000025c(%edx)",
						 @"% lwrCC:eax , decNm:0 lwrCC:x decNm:0000025 lwrCC:c ( % lwrCC:edx )",
						 
						 @"%edx,0xfffff630(%ebp)",
						 @"% lwrCC:edx , decNm:0 lwrCC:xfffff decNm:630 ( % lwrCC:ebp )",
						 
						 @"$0x09249249,0x0c(%ebp)",
						 @"$ decNm:0 lwrCC:x decNm:09249249 , decNm:0 lwrCC:x decNm:0 lwrCC:c ( % lwrCC:ebp )",
						 
						 @"$0x4e,%eax",
						 @"$ decNm:0 lwrCC:x decNm:4 lwrCC:e , % lwrCC:eax",
						 
						 @"$0xffffeca0,%esi",
						 @"$ decNm:0 lwrCC:xffffeca decNm:0 , % lwrCC:esi",
						 
						 @"$0xffffffff,0x00000244(%edx)",
						 @"$ decNm:0 lwrCC:xffffffff , decNm:0 lwrCC:x decNm:00000244 ( % lwrCC:edx )",
						 
						 @"0x000000bc(%edx)",
						 @"decNm:0 lwrCC:x decNm:000000 lwrCC:bc ( % lwrCC:edx )",
						 
						 @"0x00b97a3f(%ecx),%eax",
						 @"decNm:0 lwrCC:x decNm:00 lwrCC:b decNm:97 lwrCC:a decNm:3 lwrCC:f ( % lwrCC:ecx ) , % lwrCC:eax",
						 
						 @"0x00f35d04(%eax),%esi",
						 @"decNm:0 lwrCC:x decNm:00 lwrCC:f decNm:35 lwrCC:d decNm:04 ( % lwrCC:eax ) , % lwrCC:esi",
						 
						 @"0x0123e904,%eax",
						 @"decNm:0 lwrCC:x decNm:0123 lwrCC:e decNm:904 , % lwrCC:eax",
						 
						 @"0x012417ec",
						 @"decNm:0 lwrCC:x decNm:012417 lwrCC:ec",
						 
						 @"0x05(%ecx),%edx",
						 @"decNm:0 lwrCC:x decNm:05 ( % lwrCC:ecx ) , % lwrCC:edx",
						 
						 @"0x100b9a53a",
						 @"decNm:0 lwrCC:x decNm:100 lwrCC:b decNm:9 lwrCC:a decNm:53 lwrCC:a",
						 
						 @"0x30000002,%eax",
						 @"decNm:0 lwrCC:x decNm:30000002 , % lwrCC:eax",
						 
						 @"0x48(%esi)",
						 @"decNm:0 lwrCC:x decNm:48 ( % lwrCC:esi )",
						 
						 @"0x60(%edi),%xmm0",
						 @"decNm:0 lwrCC:x decNm:60 ( % lwrCC:edi ) , % lwrCC:xmm decNm:0",
						 
						 @"0x60(%edx),%edx",
						 @"decNm:0 lwrCC:x decNm:60 ( % lwrCC:edx ) , % lwrCC:edx",
						 
						 @"0xfe2ce6e0(%edi,%eax),%edi",
						 @"decNm:0 lwrCC:xfe decNm:2 lwrCC:ce decNm:6 lwrCC:e decNm:0 ( % lwrCC:edi , % lwrCC:eax ) , % lwrCC:edi",
						 
						 @"0xff,",
						 @"decNm:0 lwrCC:xff ,",
						 
						 @"0xff(%esi,%edi,8),%ecx",
						 @"decNm:0 lwrCC:xff ( % lwrCC:esi , % lwrCC:edi , decNm:8 ) , % lwrCC:ecx",
						 
						 @"0xff(%esi,%esi),%esi",
						 @"decNm:0 lwrCC:xff ( % lwrCC:esi , % lwrCC:esi ) , % lwrCC:esi",
						 
						 @"0xff(%esi),%edx",
						 @"decNm:0 lwrCC:xff ( % lwrCC:esi ) , % lwrCC:edx",
						 
						 @"0xffffff68(%ebp,%ecx,8),%xmm0",
						 @"decNm:0 lwrCC:xffffff decNm:68 ( % lwrCC:ebp , % lwrCC:ecx , decNm:8 ) , % lwrCC:xmm decNm:0",
						 
						 @"0xffffff7c(%ebp),%ax",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:c ( % lwrCC:ebp ) , % lwrCC:ax",
						 
						 @"0xffffff7f(%ebp)",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:f ( % lwrCC:ebp )",
						 
						 @"0xffffff7f(%ebp),%al",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:f ( % lwrCC:ebp ) , % lwrCC:al",
						 
						 @"0xffffff7f(%ebp),%eax",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:f ( % lwrCC:ebp ) , % lwrCC:eax",
						 
						 @"0xfffffff0(,%eax,8),%eax",
						 @"decNm:0 lwrCC:xfffffff decNm:0 ( , % lwrCC:eax , decNm:8 ) , % lwrCC:eax",
						 
						 @"0xffffff7c(%ebp,%ecx,4),%eax",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:c ( % lwrCC:ebp , % lwrCC:ecx , decNm:4 ) , % lwrCC:eax",
						 
						 @"0xffffff7c(%ebp,%eax,4)",
						 @"decNm:0 lwrCC:xffffff decNm:7 lwrCC:c ( % lwrCC:ebp , % lwrCC:eax , decNm:4 )",
						 
						 @"%eax,%es:(%eax)",
						 @"% lwrCC:eax , % lwrCC:es : ( % lwrCC:eax )",
						 
						 nil];
	return allTests;
}

- (void)testStringTokenise {
	
	NSArray *testArray = [TokenArrayTests testData];
	
	for( uint i=0; i<[testArray count]; i=i+2) {

		NSString *thisInputString = [testArray objectAtIndex:i];
		NSString *thisVerifyString = [testArray objectAtIndex:i+1];
		TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:thisInputString] autorelease];
		NSString *output = [tokensFromThisString outputString];
		if( [output isEqualToString:thisVerifyString]==NO ){
			
			STAssertTrue( [output length]==[thisVerifyString length], @"Fucked up lengths %i, %i %c %c", [output length], [thisVerifyString length], [output characterAtIndex:0], [thisVerifyString characterAtIndex:0] );
			STFail( @"%@   !=   %@", output, thisVerifyString );
		}
	}
}

- (void)testParseHexNumber {
	
	// 1 hex number
	TokenArray *tkns = [TokenArray tokensWithString:@"0xFF0A"];
	[tkns secondPass];
	
	STAssertTrue( tkns.count==1, @"doh %i", tkns.count );
	STAssertTrue( [tkns tokenAtIndex:0].type == hexNum, @"doh" );
	STAssertTrue( strcmp( [tkns tokenAtIndex:0].value, "FF0A" )==0, @"doh" );
	
	// multiple hex numbers
	TokenArray *tkns2 = [TokenArray tokensWithString:@",0xf,0x1a2a3a"];
	[tkns2 secondPass];

	STAssertTrue( tkns2.count==4, @"doh %i", tkns2.count );
	
	STAssertTrue( [tkns2 tokenAtIndex:0].type == comma, @"doh" );
	STAssertTrue( [tkns2 tokenAtIndex:1].type == hexNum, @"doh" );
	STAssertTrue( [tkns2 tokenAtIndex:2].type == comma, @"doh" );
	STAssertTrue( [tkns2 tokenAtIndex:3].type == hexNum, @"doh" );

	STAssertTrue( strcmp( [tkns2 tokenAtIndex:1].value, "f" )==0, @"doh" );
	STAssertTrue( strcmp( [tkns2 tokenAtIndex:3].value, "1a2a3a" )==0, @"doh" );
}

- (void)testParseRegisters {
	
	// 1 register
	TokenArray *tkns = [TokenArray tokensWithString:@"%eax"];
	[tkns secondPass];
	
	STAssertTrue( tkns.count==1, @"doh %i", tkns.count );
	STAssertTrue( [tkns tokenAtIndex:0].type == registerVal, @"doh" );
	STAssertTrue( strcmp( [tkns tokenAtIndex:0].value, "eax" )==0, @"doh" );
	
	// multiple registers
	TokenArray *tkns2 = [TokenArray tokensWithString:@"%eax,%eab"];
	[tkns2 secondPass];

	STAssertTrue( tkns2.count==3, @"doh %i", tkns2.count );

	STAssertTrue( [tkns2 tokenAtIndex:0].type == registerVal, @"doh" );
	STAssertTrue( strcmp( [tkns tokenAtIndex:0].value, "eax" )==0, @"doh" );
	
	STAssertTrue( [tkns2 tokenAtIndex:2].type == registerVal, @"doh" );
	STAssertTrue( strcmp( [tkns2 tokenAtIndex:2].value, "eab" )==0, @"doh" );
	
	TokenArray *tkns3 = [TokenArray tokensWithString:@"%xmm0"];
	[tkns3 secondPass];
	STAssertTrue( tkns3.count==1, @"doh %i", tkns3.count );
	STAssertTrue( [tkns3 tokenAtIndex:0].type == registerVal, @"doh" );
	STAssertTrue( strcmp( [tkns3 tokenAtIndex:0].value, "xmm0" )==0, @"doh" );
}

- (void)testSecondPass {
	
	NSArray *testArray = [TokenArrayTests testData];
	
	for( uint i=0; i<[testArray count]; i=i+2) {
		
		NSString *thisInputString = [testArray objectAtIndex:i];

		TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:thisInputString] autorelease];
		[tokensFromThisString secondPass];
		NSString *output = [tokensFromThisString outputString];
		
		NSLog( @"%@",output);
	}
}

- (void)testPattern {
	
	TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:@"0xffffff7c(%ebp,%eax,4)"] autorelease];
	[tokensFromThisString secondPass];
	
	NSString *pattern = [tokensFromThisString pattern];
	NSString *patternVerfiy = @"0xff ( %r , %r , 66 )";
	
	STAssertTrue( [pattern isEqualToString:patternVerfiy], @"%@", pattern );
}


@end
