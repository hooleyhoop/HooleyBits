//
//  Argument.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 14/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "Argument.h"
#import "BasicToken.h"

2010-06-15 13:20:06.055 SimpleFileParser[29037:a0f] ( %r , 66 )

/* All argument formats 
 
	%r						// register
	0xff					// ff
	$ 0xff					// immediate hex

 
	// displacement(base_register,index_register,scale)
	// Value is relative to segmant register, $ss when base register is  %ebp or %esp and %ds for all other base registers.
	0xff ( %r )				// memory location + ff
	( %r )					// memory location
	( %r , %r , 66 )		// indirect
	( %r , %r )				// indirect
	0xff ( %r , %r )		// indirect
	0xff ( %r , %r , 66 )	// indirect
	0xff ( , %r , 66 )		// indirect
	0xff ( , %r )			// indirect

	// Indirect with different segmanr register
	%r : ( %r )
	%r : 0xff ( %r )
 
	// A segment override can also be specified as an operator prefix:
	// es/movl (%eax),%edx

	// What the fuck? - Not at all clear what the asterisk does. It MUST be evaluated last
	// ie. 'value at' 0xff ( , %r , 66 )

	* 0xff ( , %r , 66 )
	* %r
	* 0xff
	* ( %r , %r , 66 )
	* 0xff ( %r , %r , 66 )
	* 0xff ( %r )
 
	// These seem wierd i need to check out - here! %xmm and 0 need to be appended
	// <r ( 66 )> - rgstr:st ( decNm:0 )   ---   fstp %st(0)
	// <( reg , 66 )> - ( rgstr:esp , decNm:8 )   ---    cmpl $0x61,(%esp,8)
 
	%r ( 66 )
	( %r , 66 )


 
*/

@implementation Argument

+ (id)emptyArgument {
	return [[[self alloc] init] autorelease];
}

- (id)init {
	self = [super init];
	_allTokens = [[NSMutableArray array] retain];
	return self;
}

- (void)dealloc {
	[_allTokens release];
	[super dealloc];
}

- (void)addToken:(BasicToken *)tok {
	[_allTokens addObject:tok];
}

- (NSString *)output {
	
	NSString *outputString = @"";
	
	for( BasicToken *each in _allTokens ){
		if([outputString length]==0)
			outputString = [each outputString];
		else
			outputString = [NSString stringWithFormat:@"%@ %@", outputString, [each outputString]];
	}
	return outputString;
}

- (NSString *)pattern {
	
	NSString *blergh = @"";
	for( BasicToken* each in _allTokens ) 
	{
		NSString *value = [each patternString];
		if([blergh length]==0)
			blergh = value;
		else
			blergh = [NSString stringWithFormat:@"%@ %@", blergh, value];
	}
	return blergh;
}

@end
