//
//  PhraseProabilityTests.m
//  TypeSetter
//
//  Created by Steven Hooley on 24/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <PhraseProbability/PhraseProbability.h>

@interface PhraseProabilityTests : SenTestCase {
	
}

@end


@implementation PhraseProabilityTests

- (void)testWords {
	// - (NSArray *)words

	PhraseAnalyser *pa3 = [PhraseAnalyser analyserWithString:@"  a big hairy.   \n Fox, oops.    "];
	STAssertTrue( [[[pa3 words] objectAtIndex:0] isEqualToString:@"a"], @"grrr %@", [[pa3 words] objectAtIndex:0] );
	STAssertTrue( [[[pa3 words] objectAtIndex:1] isEqualToString:@"big"], @"grrr %@", [[pa3 words] objectAtIndex:0] );
	STAssertTrue( [[[pa3 words] objectAtIndex:2] isEqualToString:@"hairy."], @"grrr %@", [[pa3 words] objectAtIndex:0] );
	STAssertTrue( [[[pa3 words] objectAtIndex:3] isEqualToString:@"Fox,"], @"grrr %@", [[pa3 words] objectAtIndex:0] );
	STAssertTrue( [[[pa3 words] objectAtIndex:4] isEqualToString:@"oops."], @"grrr %@", [[pa3 words] objectAtIndex:0] );
}


- (void)testWordCount {
	// - (NSUInteger)wordCount
	
	PhraseAnalyser *pa1 = [PhraseAnalyser analyserWithString:@"a big hairy fox"];
	STAssertTrue( [pa1 wordCount]==4, @"grrr %i", [pa1 wordCount] );

	PhraseAnalyser *pa2 = [PhraseAnalyser analyserWithString:@"a big hairy. fox"];
	STAssertTrue( [pa2 wordCount]==4, @"grrr %i", [pa2 wordCount] );
	
	PhraseAnalyser *pa3 = [PhraseAnalyser analyserWithString:@"  a big hairy.   \n Fox, oops.    "];
	STAssertTrue( [pa3 wordCount]==5, @"grrr %i", [pa3 wordCount] );
}

- (void)testPhraseCount {
	// - (NSUInteger)phraseCount
	
	NSString *srcString = @"a big hairy fox";
	PhraseAnalyser *pa = [PhraseAnalyser analyserWithString:srcString];
	NSUInteger count = [pa phraseCount];
	
	STAssertTrue( count==10, @"grrr %i", count );
}

- (void)testPhrases {
	
	// - (NSArray *)phrases
	
	PhraseAnalyser *pa3 = [PhraseAnalyser analyserWithString:@"  a big hairy.   \n Fox, oops.    "];
	NSArray *phrases = [pa3 phrases];
	
	STAssertTrue( [[phrases objectAtIndex:0] isEqualToString:@"a"], @"grrr %@", [phrases objectAtIndex:0] );
	STAssertTrue( [[phrases objectAtIndex:1] isEqualToString:@"a big"], @"grrr %@", [phrases objectAtIndex:1] );
	STAssertTrue( [[phrases objectAtIndex:2] isEqualToString:@"a big hairy."], @"grrr %@", [phrases objectAtIndex:2] );
	STAssertTrue( [[phrases objectAtIndex:3] isEqualToString:@"a big hairy. Fox,"], @"grrr %@", [phrases objectAtIndex:3] );
	STAssertTrue( [[phrases objectAtIndex:4] isEqualToString:@"a big hairy. Fox, oops."], @"grrr %@", [phrases objectAtIndex:4] );

	STAssertTrue( [[phrases objectAtIndex:5] isEqualToString:@"big"], @"grrr %@", [phrases objectAtIndex:5] );
	STAssertTrue( [[phrases objectAtIndex:6] isEqualToString:@"big hairy."], @"grrr %@", [phrases objectAtIndex:6] );
	STAssertTrue( [[phrases objectAtIndex:7] isEqualToString:@"big hairy. Fox,"], @"grrr %@", [phrases objectAtIndex:7] );
	STAssertTrue( [[phrases objectAtIndex:8] isEqualToString:@"big hairy. Fox, oops."], @"grrr %@", [phrases objectAtIndex:8] );
	
	STAssertTrue( [[phrases objectAtIndex:9] isEqualToString:@"hairy."], @"grrr %@", [phrases objectAtIndex:9] );
	STAssertTrue( [[phrases objectAtIndex:10] isEqualToString:@"hairy. Fox,"], @"grrr %@", [phrases objectAtIndex:10] );
	STAssertTrue( [[phrases objectAtIndex:11] isEqualToString:@"hairy. Fox, oops."], @"grrr %@", [phrases objectAtIndex:11] );
	
	STAssertTrue( [[phrases objectAtIndex:12] isEqualToString:@"Fox,"], @"grrr %@", [phrases objectAtIndex:12] );
	STAssertTrue( [[phrases objectAtIndex:13] isEqualToString:@"Fox, oops."], @"grrr %@", [phrases objectAtIndex:13] );

	STAssertTrue( [[phrases objectAtIndex:14] isEqualToString:@"oops."], @"grrr %@", [phrases objectAtIndex:14] );
}

- (void)testBreakIntoLines {
	// + (NSArray *)breakIntoLines:(NSString *)input
	
	PhraseAnalyser *pa3 = [PhraseAnalyser analyserWithString:@"the simple \n case"];
	NSArray *lines = [pa3 breakIntoLines];
	STAssertTrue([lines count]==2, @"ffu");
	
	STAssertTrue( [[lines objectAtIndex:0] isEqualToString:@"the simple"], @"grrr %@", [lines objectAtIndex:0] );
	STAssertTrue( [[lines objectAtIndex:1] isEqualToString:@"case"], @"grrr %@", [lines objectAtIndex:1] );

}
	
	
@end
