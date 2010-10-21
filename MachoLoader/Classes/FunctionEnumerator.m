//
//  FunctionEnumerator.m
//  MachoLoader
//
//  Created by Steven Hooley on 21/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "FunctionEnumerator.h"
#import "MachoLoader.h"

@implementation FunctionEnumerator

- (id)initWithAllFunctions:(struct hooleyAllFuctions *)arg {

	self = [super init];
	if(self){
		_allFuncs = arg;
	}
	return self;
}

- (NSUInteger)count {
	return _allFuncs->lastFunction->index + 1;
}

- (struct hooleyFuction *)firstFunction {

	_currentFunction = _allFuncs->firstFunction;
	return _currentFunction;
}

- (struct hooleyFuction *)nextFunction {
	
	_currentFunction = _currentFunction->next;
	return _currentFunction;
}


@end
