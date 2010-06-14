//
//  StringCounter.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StringCounter : NSObject {

	NSMutableDictionary *_allStrings;
}

- (void)add:(NSString *)val;
- (NSArray *)sortedCounts;
- (NSArray *)sortedStrings;

@end
