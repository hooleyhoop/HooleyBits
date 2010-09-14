//
//  TextSectionDisasemble.m
//  MachoLoader
//
//  Created by Steven Hooley on 10/09/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "TextSectionDisasemble.h"
#import "i386_disasm.h"

#pragma mark -
@interface TextSectionDisasemble ()

- (void)disasem:(const void *)bytes :(NSUInteger)length ;

@end

#pragma mark -
@implementation TextSectionDisasemble

- (id)initWithData:(const void *)bytes length:(NSUInteger)length {

	self = [super init];
	if(self){
		[self disasem:bytes :length];
	}
	return self;
}


- (void)dealloc {

	[super dealloc];
}

- (void)disasem:(const void *)bytes :(NSUInteger)length  {

	UInt8 *locPtr = (UInt8 *)bytes;
	NSUInteger left = length;
	NSUInteger j;
	for( NSUInteger i=0; i<length; ){

		j = i386_disassemble( (char *)locPtr, left, CPU_TYPE_I386 );
		locPtr = locPtr + j;
		NSLog(@"%i", j);
	}
}


@end
