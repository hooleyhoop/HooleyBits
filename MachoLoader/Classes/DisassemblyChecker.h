//
//  DisassemblyChecker.h
//  MachoLoader
//
//  Created by Steven Hooley on 01/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#define MAX_LINE_LENGTH             10000


@interface DisassemblyChecker : NSObject {

	NSString *_filePath;
	BOOL	_fat;
	FILE	*_otoolPipe;
}

- (id)initWithPath:(NSString *)aPath isFAT:(BOOL)fatFlag;

- (BOOL)openOTOOL;
- (BOOL)close;

- (void)assertNextAdress:(char *)memAddress;

- (char *)nextLine:(char *)theCLine;

@end
