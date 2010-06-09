//
//  SimpleFileParserAppDelegate.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SimpleFileParserAppDelegate.h"

@implementation SimpleFileParserAppDelegate

@synthesize window;

// registers
// %eip = next instruction address

// http://programminggroundup.blogspot.com/2007/01/appendix-b-common-x86-instructions.html
// http://siyobik.info/index.php?module=x86

+ (NSArray *)knownInstructions {
	
	static NSArray *knownInstructions;
	if(knownInstructions == nil)
		knownInstructions = [[NSArray arrayWithObjects: 
@"adcl",		@"$2 = $1 + $2",
@"addb",		@"$2 = $1 + $2",
@"addl",		@"$2 = $1 + $2",
@"addsd",		@"$2 = $1 + $2",
@"addss",		@"$2 = $1 + $2",
@"addw",		@"$2 = $1 + $2",

@"andb",		@"$2 = $1 & $2",
@"andl",		@"$2 = $1 & $2",
@"andnpd",		@"$2 = $1 & $2",
@"andnps",		@"$2 = $1 & $2",
@"andpd",		@"$2 = $1 & $2",
@"andps",		@"$2 = $1 & $2",
@"andw",		@"$2 = $1 & $2",

@"call",		@"stack.push(%eip), jump($1)",
@"calll",		@"stack.push(%eip), jump($1)",
@"cbtw",		@"convert byte to word",
@"cld",			@"clean the address flag",

@"cmovael",		@"",
@"cmoval",		@"",
@"cmovbel",		@"",
@"cmovbl",		@"",
@"cmovel",		@"if (el) move $1 to $2",
@"cmovgel",		@"",
@"cmovgl",		@"",
@"cmovlel",		@"",
@"cmovll",		@"",
@"cmovnel",		@"",
@"cmovnsl",		@"",
@"cmovsl",		@"",

@"cmpb",		@"compare byte",
@"cmpw",		@"compare word",
@"cmpl",		@"compare long",
@"cmpss",		@"compare float",
@"cmpsd",		@"compare double",

@"cvtdq2pd",	@"",
@"cvtsd2ss",	@"",
@"cvtsi2sd",	@"",
@"cvtsi2ss",	@"",
@"cvtss2sd",	@"",
@"cvttpd2dq",	@"",
@"cvttsd2si",	@"",
@"cvttss2si",	@"",

@"cwtl",		@"convert word to long",

@"decb",		@"decrement by 1",
@"decl",		@"decrement by 1",
@"decw",		@"decrement by 1",

@"divl",		@"unsigned divide",
@"divsd",		@"unsigned divide",
@"divss",		@"unsigned divide",

@"fld1",		@"load constant",
@"fldl",		@"load real",
@"flds",		@"load real",
@"fldz",		@"load constant",
@"fstp",		@"store real",
@"fstpl",		@"",
@"fstps",		@"",
@"fsts",		@"",
@"hlt",			@"halt",
@"idivl",		@"signed divide",
@"imull",		@"multiply",
@"incl",		@"",
@"incw",		@"",

@"jmp",			@"jump",
@"jmpl",		@"jump",
 
@"ja",			@"Jump if Condition is Met - short if above",
@"jal",			@"Jump if Condition is Met - short if above",
@"jae",			@"Jump if Condition is Met - short if above or equal",
@"jael",		@"Jump if Condition is Met - short if above or equal",
@"jb",			@"Jump if Condition is Met - short if below",
@"jbl",			@"Jump if Condition is Met - short if below",
@"jbe",			@"Jump if Condition is Met - short if below or equal",
@"jbel",		@"Jump if Condition is Met - short if below or equal",
@"je",			@"Jump if Condition is Met - short if equal",
@"jel",			@"Jump if Condition is Met - short if equal",
@"jg",			@"Jump if Condition is Met - short if greater",
@"jgl",			@"Jump if Condition is Met - short if greater",
@"jge",			@"Jump if Condition is Met - short if greater or equal",
@"jgel",		@"Jump if Condition is Met - short if greater or equal",
@"jl",			@"Jump if Condition is Met - short if less",
@"jll",			@"Jump if Condition is Met - ",
@"jle",			@"Jump if Condition is Met - short if less or equal",
@"jlel",		@"Jump if Condition is Met - short if less or equal",
@"jne",			@"Jump if Condition is Met - short if not equal",
@"jnel",		@"Jump if Condition is Met - ",
@"jns",			@"Jump if Condition is Met - short if not sign",
@"jnsl",		@"Jump if Condition is Met - ",
@"jp",			@"Jump if Condition is Met - short if parity",
@"jpl",			@"Jump if Condition is Met - ",
@"js",			@"Jump if Condition is Met - short if sign",
@"jsl",			@"Jump if Condition is Met - ",

@"leal",		@"Load Effective address",
@"leave",		@"",
@"lock/incl",	@"",
@"maxsd",		@"",
@"maxss",		@"",
@"minsd",		@"",
@"minss",		@"",

@"movapd",		@"move aligned packed double precision float",
@"movaps",		@"move aligned packed single precision float",

@"movb",		@"move byte (8)",
@"movw",		@"move word (16)",
@"movl",		@"move long (32)",
@"movd",		@"move double (64)",

@"movsd",		@"Move Scalar Double-Precision Floating-Point Value",
@"movss",		@"move scalar single precision float",
@"movsbl",		@"move byte to long (sign extension)",
@"movsbw",		@"move byte to word (sign extension)",
@"movswl",		@"move word to long (sign extension)",
@"movzbl",		@"move byte to long (zero other bytes)",
@"movzwl",		@"move word to long (zero other bytes)",

@"mull",		@"unsigned multiply",
@"mulss",		@"Multiply Scalar Single-Precision Floating-Point Values",
@"mulsd",		@"multiply double",

@"negl",		@"",
@"nop",			@"no op",
@"notl",		@"",
@"orb",			@"",
@"orl",			@"",
@"orpd",		@"",
@"orps",		@"",
@"orw",			@"",
@"popl",		@"",
@"psllq",		@"",
@"pushl",		@"push()",
@"pxor",		@"",
@"repz/cmpsb",	@"",
@"ret",			@"",
@"roll",		@"",
@"sarb",		@"",
@"sarl",		@"",
@"sarw",		@"",
@"sbbl",		@"",

@"seta",		@"",
@"setae",		@"",
@"setb",		@"",
@"setbe",		@"",
@"sete",		@"",
@"setg",		@"",
@"setge",		@"",
@"setl",		@"",
@"setle",		@"",
@"setne",		@"",
@"setnp",		@"",

@"shll",		@"",
@"shrb",		@"",
@"shrl",		@"",
@"shrw",		@"",
@"sqrtsd",		@"",

@"subb",		@"",
@"subl",		@"",
@"subpd",		@"",
@"subsd",		@"",
@"subss",		@"",
@"subw",		@"",
@"testb",		@"",
@"testl",		@"",
@"testw",		@"",
@"ucomisd",		@"",
@"ucomiss",		@"",
@"xorb",		@"",
@"xorl",		@"",
@"xorpd",		@"",
@"xorps",		@"",
@"xorw",		@"",
nil] retain];
	return knownInstructions;
}

NSInteger alphabeticSort(id string1, id string2, void *reverse)
{
    if ((NSInteger *)reverse == NO) {
        return [string2 localizedCaseInsensitiveCompare:string1];
    }
    return [string1 localizedCaseInsensitiveCompare:string2];
}

- (BOOL)isKnownInstruction:(NSString *)instruction {

	NSArray *knownInstructions = [SimpleFileParserAppDelegate knownInstructions];
	BOOL isFound = [knownInstructions containsObject:instruction];
	if(!isFound){
		NSLog(@"oopps %i", [knownInstructions indexOfObjectIdenticalTo:instruction]);
	}
	return isFound;
}

// -- i need to parse the form of the instruction, mv has many
- (void)processInstruction:(NSString *)instruction argument:(NSString *)arguments {
	
	-- calculate the format
	-----------------------
	opcode, argument-format, arguments
	
	
	NSMutableSet *allThisInstruction = [_allInstructions objectForKey:instruction];
	if(allThisInstruction==nil){
		allThisInstruction = [NSMutableSet setWithCapacity:100];
		[_allInstructions setObject:allThisInstruction forKey:instruction];
	}
	[allThisInstruction addObject:[NSString stringWithFormat:@"%@ %@", instruction, arguments]];
}

- (void)processLine:(NSString *)woohoo {

	NSArray *components = [woohoo componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *betterComponents = [NSMutableArray array];
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if([obj isEqualToString:@""])
			return;
		[betterComponents addObject:obj];
    }];
	
	NSString *instruction=nil, *arguments=nil;
	
	if([betterComponents count]>=4)
		instruction = [betterComponents objectAtIndex:3];
	if([betterComponents count]>=5)
		arguments = [betterComponents objectAtIndex:4];

	if(instruction){
		NSAssert([self isKnownInstruction:instruction], @"i do not know instruction %@", instruction );

		[self processInstruction:instruction argument:arguments];
	}
	// NSLog(@"%@", betterComponents);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	_allInstructions = [[NSMutableDictionary alloc] initWithCapacity:100];
	
	// strip the app to desired architectire
	// ditto --rsrc --arch i386 /Applications/Foo.app /Application/Foo-i386.app
	
	// otool
	// otool -t /Applications/Foo.app/Contents/MacOS/Foo >> data.txt			-- just data
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled with symbols
	
	NSError *outError;
	NSString *pathToInputFile = @"/Applications/Sibelius 6-386.app/Contents/MacOS/testData.txt";
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	// NSStringEncoding *enc = nil;
   // NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL usedEncoding:enc error:&outError];	
    NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:NSMacOSRomanStringEncoding error:&outError];	
	NSCharacterSet *wsp = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	void (^enumerateBlock)(NSString *, BOOL *) = ^(NSString *line, BOOL *stop) {
		NSString *strippedline = [line stringByTrimmingCharactersInSet:wsp];
		if ([strippedline length]) {	
			if ([strippedline characterAtIndex:0]=='+') {
				[self processLine:strippedline];
			}
		}
	};
	[fileString enumerateLinesUsingBlock:enumerateBlock];

	// -- read it a line at a time. -- try niave aproach
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
	
	// sort using a selector
	NSArray *allInstructSets = [_allInstructions allValues];
	for( NSSet *eachSet in allInstructSets){
		NSArray *allInstruct = [eachSet allObjects];
		int reverseSort = NO;
		allInstruct = [allInstruct sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
		NSLog(@"woo %@", allInstruct );

	}
	

	
	
	// -- sort by operator
	
	// -- output
}

@end
