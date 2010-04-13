//
//  FlagsTests.m
//  AudioFFTRender
//
//  Created by Steven Hooley on 12/04/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AE_Effect.h"

@interface FlagsTests : SenTestCase {
	
}

@end

@implementation FlagsTests

- (void)testSomeFlagValues {

	NSUInteger testValue1 = PF_OutFlag_PIX_INDEPENDENT | PF_OutFlag_DEEP_COLOR_AWARE | PF_OutFlag_AUDIO_EFFECT_TOO;
	STAssertTrue( testValue1==0x42000400, @"%i", testValue1 );
	
	NSUInteger testValue2 = PF_OutFlag2_SUPPORTS_QUERY_DYNAMIC_FLAGS | PF_OutFlag2_SUPPORTS_SMART_RENDER | PF_OutFlag2_FLOAT_COLOR_AWARE | PF_OutFlag2_REVEALS_ZERO_ALPHA;	// See the test to determine if you need this 
	STAssertTrue( testValue2==0x1481, @"%i", testValue2 );

}


@end
