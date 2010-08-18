//
//  Segment.h
//  MachoLoader
//
//  Created by Steven Hooley on 16/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface Segment : NSObject {

	NSUInteger		_startAddr;
	NSUInteger		_length;
	NSString		*_name;
}

@property (readonly) NSString *name;

+ (id)name:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len;

- (id)initWithName:(NSString *)name start:(NSUInteger)memAddr length:(NSUInteger)len;

- (NSComparisonResult)compareStartAddress:(Segment *)seg;
- (NSComparisonResult)compareStartAddressToAddress:(NSUInteger)otherAddress;

- (NSUInteger)startAddress;
- (NSUInteger)lastAddress;

@end
