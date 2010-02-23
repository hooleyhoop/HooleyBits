//
//  MachoLoader.h
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MachoLoader : NSObject {

	NSMutableArray *_loadCommands;
	const void *codeAddr;
	size_t codeSize;
	
	NSMutableDictionary *addresses_;    // Addresses and symbols (STRONG)
	
	struct nlist *symtable_ptr;
	char *strtable;
}

- (id)initWithPath:(NSString *)aPath;

@end
