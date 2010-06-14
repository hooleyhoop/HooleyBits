//
//  StringCounter.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "StringCounter.h"


@implementation StringCounter

#pragma mark Utilities
NSInteger alphabeticSort(id string1, id string2, void *reverse)
{
    if ((NSInteger *)reverse == NO) {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];
}

NSArray *worderize( NSString *aLine ) {

	NSArray *components = [aLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *betterComponents = [NSMutableArray array];
	[components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		if([obj isEqualToString:@""])
			return;
		[betterComponents addObject:obj];
	}];
	return betterComponents;
}

#pragma mark -
- (id)init {
	_allStrings = [[NSMutableDictionary alloc] init];
	return self;
}

- (void)dealloc {
	[_allStrings release];
	[_sortedCounts release];
	[super dealloc];
}

- (void)add:(NSString *)val {
	
	NSNumber *occuranceCount = [_allStrings objectForKey:val];
	NSNumber *newCount = nil;
	if(!occuranceCount)
		newCount = [NSNumber numberWithInt:1];
	else {
		newCount = [NSNumber numberWithInt:[occuranceCount intValue]+1];
	}
	[_allStrings setObject:newCount forKey:val];
}

- (void)sort {
	
	// Sort the numbers
	NSArray *allCounts = [_allStrings allValues];
	id sortedArray = [allCounts sortedArrayUsingComparator: ^(id ob1, id ob2) { 		
		if( [ob1 intValue] > [ob2 intValue] ) 
			return (NSComparisonResult)NSOrderedAscending;
		else if( [ob1 intValue] < [ob2 intValue] ) 
			return (NSComparisonResult)NSOrderedDescending;
		return (NSComparisonResult)NSOrderedSame; }
					  ];	
	NSMutableArray *withoutDuplicates = [NSMutableArray array];
    [sortedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if([withoutDuplicates indexOfObject:obj]==NSNotFound)
			[withoutDuplicates addObject:obj];
    }];
	
	_sortedCounts = [withoutDuplicates retain];

	// make an ordered array of the strings
	NSMutableArray *sortedStrings = [NSMutableArray array];
	[_sortedCounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		NSArray *allKeysForThis = [_allStrings allKeysForObject:obj];
		if( [allKeysForThis count]==1 )
			[sortedStrings addObject:[allKeysForThis objectAtIndex:0]];
		else {
			for( NSString *each in allKeysForThis )
				[sortedStrings addObject:each];
		}
    }];
	_sortedStrings = [sortedStrings retain];
	
	_isSorted = YES;
}

- (NSArray *)sortedCounts {
	
	NSAssert( _isSorted, @"sort first!");
	return _sortedCounts;
}

- (NSArray *)sortedStrings {

	NSAssert( _isSorted, @"sort first!");
	return _sortedStrings;
}
@end
