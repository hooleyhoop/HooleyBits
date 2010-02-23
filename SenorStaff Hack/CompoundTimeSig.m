//
//  CompoundTimeSig.m
//  Señor Staff
//
//  Created by Konstantine Prevas on 1/8/07.
//  Copyright 2007 Konstantine Prevas. All rights reserved.
//

#import "CompoundTimeSig.h"
#import "CompoundTimeSigDraw.h"
#import "CompoundTimeSigController.h"

@implementation CompoundTimeSig

-(id)initWithFirstSig:(TimeSignature *)_firstSig secondSig:(TimeSignature *)_secondSig{
	if(self = [super init]){
		firstSig = [_firstSig retain];
		secondSig = [_secondSig retain];
	}
	return self;
}

-(TimeSignature *)getTimeSignatureAfterMeasures:(int)numMeasures{
	if(numMeasures % 2 == 0){
		return firstSig;
	}
	return secondSig;
}

-(TimeSignature *)firstSig{
	return firstSig;
}

-(TimeSignature *)secondSig{
	return secondSig;
}

-(int)getTop{
	return [firstSig getTop];
}
-(int)getBottom{
	return [firstSig getBottom];
}
-(int)getSecondTop{
	return [secondSig getTop];
}
-(int)getSecondBottom{
	return [secondSig getBottom];
}

+(id)fromNSNumberArray:(NSArray *)array{
	NSArray *firstArray = [array subarrayWithRange:NSMakeRange(0, 2)],
		*secondArray = [array subarrayWithRange:NSMakeRange(2, 2)];
	return [[[self alloc] initWithFirstSig:[TimeSignature fromNSNumberArray:firstArray]
								 secondSig:[TimeSignature fromNSNumberArray:secondArray]] autorelease];
}

+(NSArray *)asNSNumberArray:(id)sig{
	return [[TimeSignature asNSNumberArray:[sig firstSig]] arrayByAddingObjectsFromArray:[TimeSignature asNSNumberArray:[sig secondSig]]];
}

-(void)dealloc{
	[firstSig release];
	[secondSig release];
	firstSig = nil;
	secondSig = nil;
	[super dealloc];
}

-(Class)getViewClass{
	return [CompoundTimeSigDraw class];
}

-(Class)getControllerClass{
	return [CompoundTimeSigController class];
}

@end
