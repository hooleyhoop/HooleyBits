//
//  YAMLParserTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 29/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "YAMLParser.h"

@interface YAMLParserTests : SenTestCase {
	
}

@end

@implementation YAMLParserTests

- (void)testParseRegisterYAML {
	
	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test2" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	YAMLParser *ayp = [[YAMLParser alloc] initWithFilePath:filePath];
	NSDictionary *rootDict = (NSDictionary *)ayp.rootDictionary;
	
	STAssertTrue([rootDict count]==3, @"%i", [rootDict count]);

	NSDictionary *reg1 = [rootDict objectForKey:@"reg1"];
	NSDictionary *reg2 = [rootDict objectForKey:@"reg2"];
	NSDictionary *reg3 = [rootDict objectForKey:@"reg3"];

	STAssertNotNil(reg1, nil);
	STAssertNotNil(reg2, nil);
	STAssertNotNil(reg3, nil);
	
	NSString *val1 = [reg1 objectForKey:@"key1"];
	NSString *val2 = [reg1 objectForKey:@"key2"];
	STAssertTrue([val1 isEqualToString:@"value1"], @"no");
	STAssertTrue([val2 isEqualToString:@"value2"], val2);
	
	NSString *val3 = [reg2 objectForKey:@"key1"];
	NSString *val4 = [reg2 objectForKey:@"key2"];
	STAssertTrue([val3 isEqualToString:@"value1"], @"no");
	STAssertTrue([val4 isEqualToString:@"value2"], val4);
	
	NSString *val5 = [reg3 objectForKey:@"key1"];
	NSString *val6 = [reg3 objectForKey:@"key2"];
	STAssertTrue([val5 isEqualToString:@"value1"], @"no");
	STAssertTrue([val6 isEqualToString:@"value2"], val6);
	
	[ayp release];
}

- (void)testParseOpcodeYAML {
	
	NSString *filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"test1" ofType:@"yaml"];
	NSAssert( filePath, @"Error loading opcode file" );
	
	YAMLParser *ayp = [[YAMLParser alloc] initWithFilePath:filePath];
	NSDictionary *rootDict = (NSDictionary *)ayp.rootDictionary;
	
	STAssertTrue([rootDict count]==3, @"%i", [rootDict count]);
	
	NSDictionary *category1 = [rootDict objectForKey:@"category1"];
	NSDictionary *category2 = [rootDict objectForKey:@"category2"];
	NSDictionary *category3 = [rootDict objectForKey:@"category3"];

	STAssertNotNil(category1, nil);
	STAssertNotNil(category2, nil);
	STAssertNotNil(category3, nil);

	NSDictionary *dict1_1 = [category1 objectForKey:@"dict1"];
	NSDictionary *dict2_1 = [category1 objectForKey:@"dict2"];
	STAssertNotNil(dict1_1, nil);
	STAssertNotNil(dict2_1, nil);

	NSDictionary *dict1_2 = [category2 objectForKey:@"dict1"];
	NSDictionary *dict2_2 = [category2 objectForKey:@"dict2"];
	STAssertNotNil(dict1_2, nil);
	STAssertNotNil(dict2_2, nil);

	NSDictionary *dict1_3 = [category3 objectForKey:@"dict1"];
	NSDictionary *dict2_3 = [category3 objectForKey:@"dict2"];
	STAssertNotNil(dict1_3, nil);
	STAssertNotNil(dict2_3, nil);
	
	NSString *val1 = [dict1_1 objectForKey:@"key1"];
	NSString *val2 = [dict1_1 objectForKey:@"key2"];
	STAssertTrue([val1 isEqualToString:@"value1"], @"no");
	STAssertTrue([val2 isEqualToString:@"value2"], val2);

	NSString *val3 = [dict2_2 objectForKey:@"key1"];
	NSString *val4 = [dict2_2 objectForKey:@"key2"];
	STAssertTrue([val3 isEqualToString:@"value1"], val3);
	STAssertTrue([val4 isEqualToString:@"value2"], val4);
	
	NSString *val5 = [dict1_3 objectForKey:@"key1"];
	NSString *val6 = [dict1_3 objectForKey:@"key2"];
	STAssertTrue([val5 isEqualToString:@"value1"], val5);
	STAssertTrue([val6 isEqualToString:@"value2"], val6);

	[ayp release];
}




@end
//
//
//2010-08-29 20:51:31.824 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.826 SimpleFileParser[1539:4507] Scalar: conditionals 0
//2010-08-29 20:51:31.827 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.828 SimpleFileParser[1539:4507] Scalar: monkey1 0
//2010-08-29 20:51:31.829 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.830 SimpleFileParser[1539:4507] Scalar: steve1 0
//2010-08-29 20:51:31.831 SimpleFileParser[1539:4507] Scalar: hya 1
//2010-08-29 20:51:31.831 SimpleFileParser[1539:4507] Scalar: steve2 0
//2010-08-29 20:51:31.832 SimpleFileParser[1539:4507] Scalar: trap 1
//2010-08-29 20:51:31.833 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.833 SimpleFileParser[1539:4507] Scalar: monkey2 0
//2010-08-29 20:51:31.834 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.835 SimpleFileParser[1539:4507] Scalar: steve1 0
//2010-08-29 20:51:31.836 SimpleFileParser[1539:4507] Scalar: sililoquay 1
//2010-08-29 20:51:31.837 SimpleFileParser[1539:4507] Scalar: steve2 0
//2010-08-29 20:51:31.837 SimpleFileParser[1539:4507] Scalar: gerbil 1
//2010-08-29 20:51:31.838 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.838 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.839 SimpleFileParser[1539:4507] Scalar: branch_instructions 0
//2010-08-29 20:51:31.840 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.840 SimpleFileParser[1539:4507] Scalar: monkey1 0
//2010-08-29 20:51:31.841 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.841 SimpleFileParser[1539:4507] Scalar: steve1 0
//2010-08-29 20:51:31.842 SimpleFileParser[1539:4507] Scalar: ccc 1
//2010-08-29 20:51:31.843 SimpleFileParser[1539:4507] Scalar: steve2 0
//2010-08-29 20:51:31.843 SimpleFileParser[1539:4507] Scalar: ddd 1
//2010-08-29 20:51:31.844 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.845 SimpleFileParser[1539:4507] Scalar: monkey2 0
//2010-08-29 20:51:31.846 SimpleFileParser[1539:4507] New Map
//2010-08-29 20:51:31.847 SimpleFileParser[1539:4507] Scalar: steve1 0
//2010-08-29 20:51:31.847 SimpleFileParser[1539:4507] Scalar: eee 1
//2010-08-29 20:51:31.848 SimpleFileParser[1539:4507] Scalar: steve2 0
//2010-08-29 20:51:31.848 SimpleFileParser[1539:4507] Scalar: fff 1
//2010-08-29 20:51:31.849 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.850 SimpleFileParser[1539:4507] End Map
//2010-08-29 20:51:31.851 SimpleFileParser[1539:4507] Scalar: normal_instructions 0
//2010-08-29 20:51:31.852 SimpleFileParser[1539:4507] Scalar: .byte name 1
//2010-08-29 20:51:31.854 SimpleFileParser[1539:a0f] donw
