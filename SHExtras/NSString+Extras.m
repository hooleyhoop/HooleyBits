//
//  NSString+Extras.m
//  BBExtras
//
//  Created by Jonathan del Strother on 06/03/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "NSString+Extras.h"


@implementation NSString(Extras)

-(NSColor*)colorFromHex
{
	const char	*hexString = [self UTF8String];
	if (*hexString=='#')
		hexString++;	//Skip the # if present
		
	int stringLength = strlen(hexString);
	if ((stringLength != 3)&&(stringLength != 6))
	{
		NSLog(@"%@ is not a valid hex string", self);
		return nil;
	}


	char* endPtr;
	int compositeColor = strtoul(hexString, &endPtr, 16);
	if (*endPtr != '\0')
	{
		NSLog(@"%@ is not a hex string", self);
		return nil;
	}

	int r,g,b;
	if (stringLength == 3)
	{
		b = compositeColor%16;
		b += b*16;
		compositeColor /= 16;

		g = compositeColor%16;
		g += g*16;
		compositeColor /= 16;
		
		r = compositeColor%16;
		r += r*16;
	}
	else if (stringLength == 6)
	{
		b = compositeColor%256;
		compositeColor /= 256;

		g = compositeColor%256;
		compositeColor /= 256;
		
		r = compositeColor%256;
	}

	return [NSColor colorWithCalibratedRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1.0];
}

@end
