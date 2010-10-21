//
//  DissasemblyProcessor.h
//  MachoLoader
//
//  Created by Steven Hooley on 21/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class FunctionEnumerator;

@interface DissasemblyProcessor : NSObject {

	FunctionEnumerator	*_functionEnumerator;
}

- (id)initWithFunctionEnumerator:(FunctionEnumerator *)f_enum;
- (void)processApp;

@end
