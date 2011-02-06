//
//  GetOutTheFunkTests.m
//  InnerRender
//
//  Created by Steven Hooley on 04/02/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#pragma mark -
// So what does this get us over a CGRect?
@interface HooClosedPolygonEntity : NSObject {
}
@end

@implementation HooClosedPolygonEntity

+ (id)rectWithRect:(CGRect)dims {
	
	id ob = [[[self alloc] init] autorelease];
	[ob addRectPts: dims];
	return ob;
}

- (void)addRectPts: {
	
}
@end


#pragma mark -
@interface HooImgEntity : NSObject {
}
@end

@implementation HooImgEntity

+ (id)emptyImgWithSize:(CGSize)size {
	return [[[self alloc] init] autorelease];
}

@end

#pragma mark -
@interface PoorlyThoughtoutRenderer : NSObject {
}
@end

@implementation PoorlyThoughtoutRenderer

- (void)render:()vec1 into:()img {
	
	-- here, what the?
	
	////// woah! temp - test each damn pixel
	// see which are inside
	// _ _ _ _ _ _ 100.5, 100.5
	// |         |
	// |         |
	// ----------- 10.5, 10.5
	
	-- assume cords can be flipped easily, dont fret it
	-- iterate every pixel? or just within bounds of rect
	-- origin is in bottom left
	
	for( NSInteger y=0; y<height; y++ )
	{
		for( NSInteger x=0; x<width; x=x++ )
		{
			double pt[2] = {x,y};			
			int result = pointinpoly( pt, allPts );
			if(result){
				// Set the least significant bit to indicate it is inside
				pixelBuffer[y/20][x/20] |= mask_table[ 0 ];
			}
		}
	}	
}

@end


#pragma mark -
@interface SimpleImgWindow : NSObject {
}
@end

@implementation SimpleImgWindow

+ (id)windowWithImage:img {
	return [[[self alloc] init] autorelease];
}

- (void)show {
	
}

@end


#pragma mark -
#pragma mark Tests
@interface GetOutTheFunkTests : SenTestCase {
}
@end

// 1) given a path that fits into a large image, render into a large image

@implementation GetOutTheFunkTests

- (void)testSomething {
	
	/* Not really a test, huh? */
	id vec1 = [HooClosedPolygonEntity rectWithRect:CGRectMake(10, 10, 80, 80)];
	id img = [HooImgEntity emptyImgWithSize:CGSizeMake(100, 100)];

	id rendererThing = [[[PoorlyThoughtoutRenderer alloc] init] autorelease];
	[rendererThing render:vec1 into:img];
		
	id win = [SimpleImgWindow windowWithImage:img];
	[win show];
}


// How is this informed by tdd?
// or OO?
// Didnt i learn something once?
// Classes should be specialized. Few Dependencies
// objects shouldnt ask for objects it doesnt care about in order to get object it cares about
// #warning - No getters on Domain Objects!
// Entities track identity. It could be via an account number or a unique combination of name and address. Make it just do that and move everything else out.
// apply: exposes less state than an iterator
// Yes, a file name is something that can be represented as a string. But it IS not a string. It IS a named entity used by the operating system to locate a data file on some secondary store.
// So the phrase of the month is Semantic Invariants: What is the meaning behind those immutable properties that define a class?
// The gist of his argument is based on an analysis of the “semantic invariants” of the two proposed classes. For a given String class, you as programmer make certain assumptions about its behavior. You assume that if you concatenated two strings together, that the result would be a string equal to sum of the lengths of both the original strings:
// This is not true for filenames
// Dont make an application. Design a domain specific “language” that can be used to talk about applications in this domain. 

@end
