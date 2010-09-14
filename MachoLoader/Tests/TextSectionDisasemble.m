//
//  TextSectionDisasemble.m
//  MachoLoader
//
//  Created by Steven Hooley on 10/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

// Here is how i dumped the textSection
// NSData *dump = [NSData dataWithBytes:sect_pointer length:newSectSize];
// NSString *dumpString = [dump hexString];
// NSError *error;
// [dumpString writeToFile:@"/Applications/textSection.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];

#import "Hex.h"
#import "TextSectionDisasemble.h"

// This is just a small section of the complete dump
static const char *textSection = "6a0089e583e4f083ec108b5d04895c24008d4d08894c240483c301c1e30201cb895c2408e801000000f45589e557565383ec2c8b7d0c8b5d108b4508a30c30f200893d0830f200891d0430f2008b0f85c97507b900eeb900eb1989caeb0e3c2f740583c201eb0583c20189d10fb60284c075eb890d0030f20089d8eb0383c0048b1085d275f78d7004a100d023018b0085c07402ffd0a108d023018b0085c07402ffd0e87dee23018d45e089442404c7042404eeb900e85d000000ff55e08d45e489442404c7042434eeb900e8470000008b45e485c07408890424e862060000a104d02301c700000000008974240c895c2408897c24048b4508890424e888ce5f00890424e8e8ee230190906800100000ff25ec3e020190ff25f03e02015589e583ec088b4508c70001000000c9c35589e55383ec24e8000000005b8b45088945f48b45f48b50048b4508894424088b4508894424048d83e3ffffff890424ffd285c074098b45f4c700ffffffff83c4245bc9c35589e55383ec34e8000000005bc745f0000000008b45088945f48d45f0894424088d45f0894424048d83afffffff8904248b4508ffd085c07409c745e4ffffffffeb2a8d45f08904248b450cffd08b45f085c075128d45f08904248b450cffd0c745f0000000008b45f08945e48b45e483c4345bc9c35589e55383ec34e8000000005b8d45e889442404c704240e000000e83eed";

@interface TextSectionDisasembleTests : SenTestCase {
	
}



@end


@implementation TextSectionDisasembleTests

- (void)testData {
	
	NSString *textSectionStr = [NSString stringWithCString:textSection encoding:NSUTF8StringEncoding];
	NSData *textSec = [NSData dataWithHexSt;
	const void *bytes = [textSec bytes];

	TextSectionDisasemble *disasem = [[Tring:textSectionStr];
	NSUInteger length = [textSec length]extSectionDisasemble alloc] initWithData:bytes length:length];
	[disasem release];
}

@end



