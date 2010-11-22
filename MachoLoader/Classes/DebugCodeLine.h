//
//  DebugCodeLine.h
//  MachoLoader
//
//  Created by Steven Hooley on 21/11/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DebugCodeLine : NSObject {
@public;
	NSUInteger	_address;
	NSUInteger _numberOfArgs;
}

+ (id)lineWithAddress:(NSUInteger)addressInt instruction:(id)inst args:(id)arg;

- (id)initWithAddress:(NSUInteger)addressInt;

@end
