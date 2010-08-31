//
//  AppDisassembly.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 04/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "AppDisassembly.h"
#import "OtoolDisassemblyParser.h"
#import "OutputFormatter.h"
#import "MachoLoader.h"
#import "CodeBlock.h"
#import "CodeLine.h"
#import "Argument.h"
#import "BasicToken.h"
#import "HexToken.h"
#import "HexLookup.h"

@implementation AppDisassembly

+ (id)createFromOtoolOutput:(NSString *)fileString {

	id processedFile = [[[self alloc] initWithOtoolOutput:fileString] autorelease];
	return processedFile;
}

- (id)initWithOtoolOutput:(NSString *)fileString {

	self = [super init];
	if(self){

		//putback -- this needs access to lookups
		_internalRepresentation = [[OtoolDisassemblyParser constructInternalRepresentation:fileString] retain];
	}
	return self;
}

- (void)dealloc {

	NSAssert( _of==nil, @"Are we still outputting?");

	[_internalRepresentation release];

	[super dealloc];
}

// http://www.scribd.com/doc/13353364/Primer-on-Reversing-Jail-Broken-iPhone-Native-ApplicationsbyShubNigurrath

// otx is open source? !
// http://otx.osxninja.com/builds/trunk/source/ObjcSwap.c

//nm can understand this shit!
//nm -m  /Users/shooley/Desktop/trashy/build/Debug/trashy.app/Contents/MacOS/trashy
//just try treating them as strings?

//	__TEXT __text
//	(null) (null)
//	• __IMPORT __jump_table
//	• __IMPORT __pointers
//	__DATA __data				// Initialized gloabl mutable variables, such as writable C strings and data arrays (for example int a = 1; or static int a = 1;)
//	__DATA __const				// Constant data needing relocation (for example, char * const p = "foo";)
//	• __TEXT __eh_frame
//	__TEXT (null)
//	__DATA __bss				// unitialised static variables: static int i;
//	__TEXT __StaticInit
//	__TEXT __const				// Initialised constant variables
//	•__TEXT __literal4			// single precision float constants
//	__DATA __common				// unitialised global variables: int i; (outside of functions)
//	__OBJC __message_refs
//	• __TEXT __literal8			// double precision float constants
//	• __TEXT __cstring			// constant c strings
//	__DATA __cfstring
//	__OBJC __cls_refs
//	__OBJC __class
//	__DATA __gcc_except_tab__DATA
//	__DATA __dyld				// Placeholder section used by the dynamic linker
//	__PAGEZERO (null)

// __DATA,__la_symbol_ptr		// Lazy symbol pointers, which are indirect references to functions imported from a different file.
// __DATA,__nl_symbol_ptr		// Non-lazy symbol pointers, which are indirect references to data items imported from a different file
// __DATA,__mod_init_func		// Module initialization functions. The C++ compiler places static constructors here
// __DATA,__mod_term_func		// Module termination functions.
- (void)gleanInfo:(MachoLoader *)lookup {
	
	for( CodeBlock *eachCodeBlock in _internalRepresentation )
	{
		for( CodeLine *eachCodeLine in eachCodeBlock)
		{
			NSArray *allArgs = eachCodeLine.arguments;
			
			if (allArgs && [allArgs count])
			{
				// one argument can contain more than one Hex number 0xff ( %r , %r , 66 )
				for( Argument *eachArg in allArgs )
				{
					NSMutableArray *allToks = [eachArg.allTokens copy];
					for( BasicToken *eachToken in allToks )
					{
						if( eachToken.type==hexNum )
						{
							// Hex tokens are cached - ie you should always get the same hex token back for the same hexString
							HexToken *aHexToken = [HexLookup tokenForHexString:eachToken.value];
							[eachArg replaceToken:eachToken with:aHexToken];
						}
					}
					[allToks release];
					allToks = nil;
				}
			}
		}	
	}
}

- (void)reformat {
	
	// replace register names with useful names
	
	// replace instruction names with useful names
	
	// improve instruction formatting - replace add reg1, reg2 with reg1 = reg1 + reg2
	
	// replace call Text text with unknown function call - need to work out arguments
	
	// replace any jmp Text text with label - create labels at jump points
}

- (void)outputToFile:(NSString *)fn {

	_of = [[OutputFormatter alloc] initWithCodeBlockStore:_internalRepresentation fileName:fn owner:self];
	[_of print];
}

- (void)_outputFormatterDidFinish {

	[_of release];
	_of = nil;
}

@end
