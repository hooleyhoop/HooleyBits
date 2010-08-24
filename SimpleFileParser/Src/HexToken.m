//
//  HexToken.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 24/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "HexToken.h"


@implementation HexToken

+ (HexToken *)hexTokenWithCString:(const char *)hexStr {
	return [[[self alloc] initWithCString:hexStr] autorelease];
}

- (id)initWithCString:(const char *)hexStr {

	self = [super init];
	if(self){
		
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

@end
