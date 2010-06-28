//
//  LineStore.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 28/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class Line;

@interface LineStore : NSObject {

	NSMutableArray *_lineStore;
}

- (NSUInteger)insertionIndexFor:(Line *)arg;

- (void)pushLine:(Line *)arg;
- (void)insertLine:(Line *)arg;


@end
