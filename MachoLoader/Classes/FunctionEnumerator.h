//
//  FunctionEnumerator.h
//  MachoLoader
//
//  Created by Steven Hooley on 21/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//



@interface FunctionEnumerator : NSObject {

	struct hooleyAllFuctions	*_allFuncs;
	struct hooleyFuction		*_currentFunction;
}

- (id)initWithAllFunctions:(struct hooleyAllFuctions *)arg;
- (struct hooleyFuction *)firstFunction;
- (struct hooleyFuction *)nextFunction;
- (NSUInteger)count;

@end
