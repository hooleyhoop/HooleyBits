//
//  AppDisassembly.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface AppDisassembly : NSObject {

	id _internalRepresentation;
}

+ (id)createFromOtoolOutput:(NSString *)fileString;

- (id)initWithOtoolOutput:(NSString *)fileString;

@end
