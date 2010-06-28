//
//  Line.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface Line : NSObject {

	NSUInteger _address;
}

+ (id)lineWithAddress:(NSUInteger)addrr;
- (id)initWithAddress:(NSUInteger)addrr;

- (NSComparisonResult)compareAddress:(Line *)arg;

@end
