//
//  TimeSignature.m
//  Music Editor
//
//  Created by Konstantine Prevas on 6/24/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import "TimeSignature.h"
//#import "CompoundTimeSig.h"
//#import "TimeSignatureDraw.h"
//#import "TimeSignatureController.h"

@implementation TimeSignature

+ (id)timeSignatureWithTop:(int)top bottom:(int)bottom {
    
	static NSMutableDictionary *cachedSigs;
	if(cachedSigs == nil){
		cachedSigs = [[NSMutableDictionary dictionary] retain];
	}
	NSString *key = [NSString stringWithFormat:@"%d/%d", top, bottom];
	id sig = [cachedSigs objectForKey:key];
	if(sig == nil){
		sig = [[TimeSignature alloc] initWithTop:top bottom:bottom];
		[cachedSigs setObject:sig forKey:key];
	}
	return sig;
}

//+(id)fromNSNumberArray:(NSArray *)array{
//	if([array isEqual:[NSNull null]]) return [NSNull null];
//	if([array count] > 2) return [CompoundTimeSig fromNSNumberArray:(NSArray *)array];
//	return [self timeSignatureWithTop:[[array objectAtIndex:0] intValue] bottom:[[array objectAtIndex:1] intValue]];
//}

- (id)initWithTop:(int)_top bottom:(int)_bottom {
    
	if(self = [super init]){
		top = _top;
		bottom = _bottom;
	}
	return self;
}

- (TimeSignature *)getTimeSignatureAfterMeasures:(int)numMeasures {
	return self;
}

//-(int)getTop{
//	return top;
//}
//
//-(int)getBottom{
//	return bottom;
//}
//
//-(int)getSecondTop{
//	return top;
//}
//-(int)getSecondBottom{
//	return bottom;
//}

- (float)getMeasureDuration {
	return (float)(top * 3)/(float)bottom;
}

//// this is a class method instead of an instance method so that we can handle NSNulls
//+(NSArray *)asNSNumberArray:(id)sig{
//	if([sig isEqual:[NSNull null]]){
//		return nil;
//	}
//	if([sig isKindOfClass:[CompoundTimeSig class]]){
//		return [CompoundTimeSig asNSNumberArray:sig];
//	}
//	return [NSArray arrayWithObjects:[NSNumber numberWithInt:[sig getTop]], [NSNumber numberWithInt:[sig getBottom]], nil];
//}
//
//-(void)addToLilypondString:(NSMutableString *)string{
//	[string appendFormat:@"\\time %d/%d ", [self getTop], [self getBottom]];
//}
//
//-(void)addToMusicXMLString:(NSMutableString *)string{
//	[string appendFormat:@"<time>\n<beats>%d</beats>\n<beat-type>%d</beat-type>\n</time>\n", [self getTop], [self getBottom]];
//}
//
//-(Class)getViewClass{
//	return [TimeSignatureDraw class];
//}
//
//-(Class)getControllerClass{
//	return [TimeSignatureController class];
//}

@end
