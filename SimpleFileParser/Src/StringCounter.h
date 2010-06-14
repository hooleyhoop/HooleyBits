//
//  StringCounter.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StringCounter : NSObject {

	NSMutableDictionary	*_allStrings;
	NSMutableArray		*_sortedCounts, *_sortedStrings;
	BOOL					_isSorted;
}

NSInteger alphabeticSort(id string1, id string2, void *reverse);
NSArray *worderize( NSString *aLine );

- (void)add:(NSString *)val;
- (void)sort;
- (NSArray *)sortedCounts;
- (NSArray *)sortedStrings;

@end
