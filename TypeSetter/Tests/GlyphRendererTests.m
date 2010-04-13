//
//  GlyphRendererTests.m
//  TypeSetter
//
//  Created by steve hooley on 09/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>


@interface GlyphRendererTests : SenTestCase {
	
}

@end


@implementation GlyphRendererTests

//SEE http://www.mulle-kybernetik.com/artikel/Optimization/opti-5.html
// to write your own alloc

// niave implementation
+ alloc
{
	NSObject   *p;
	
	p = (NSObject *) malloc( sizeof( NSCalendarDate));
	memset( p, 0, sizeof( *p));
	p->isa = self;
	return( p);
}

+ (id)allocWithZone:(NSZone *)zone {

	NSZone *zone1 = NSCreateZone( 0x1000, 0x1000, YES);

	return( NSAllocateObject( self, 0, zone)); //  mallocs and sets isa
}

- (void)setUp {
	NSLog(@"oh yeah");
}
- (void)tearDown {
	NSLog(@"oh yeah");
}
- (void)testSomeShit {
	
}

@end
