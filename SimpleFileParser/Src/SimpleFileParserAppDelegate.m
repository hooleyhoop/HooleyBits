//
//  SimpleFileParserAppDelegate.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SimpleFileParserAppDelegate.h"
#import "TokenArray.h"
#import "ArgumentScanner.h"
#import "StringCounter.h"

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
							 // aad,
//							  aam,
//							  addpd,
//							  cli,
//							  cmc,
//							  cmpsl,
//							  daa,
//							  enter,
//							  fadd,
//							  faddl,
//							  faddp,
//							  fadds,
//							  fchs,
//							  fcompl,
//							  fcoms,
//							  fdiv,
//							  fdivp,
//							  fdivr,
//							  fdivrp,
//							  fiaddl,
//							  fiadds,
//							  ficompl,
//							  ficomps,
//							  ficoms,
//							  filds,
//							  fld,
//							  fldt,
//							  fmul,
//							  fmulp,
//							  fstpt,
//							  fsub,
//							  fsubp,
//							  fsubr,
//							  fsubrl,
//							  fsubrp,
//							  fucomi,
//							  fucomip,
//							  inb,
//							  inl,
//							  int,
//							  into,
//							  iret,
//							  jno,
//							  lahf,
//							  lcall,
//							  les,
//							  ljmpl,
//							  "lock/addb",
//							  "lock/cmpxchgl",
//							  "lock/pushl",
//							  "lock/sbbl",
//							  "lock/xaddl",
//							  lodsb,
//							  lret,
//							  mov,
//							  movhpd,
//							  movsb,
//							  outb,
//							  punpckldq,
//							  pushw,
//							  rcrl,
//							  "repnz/addb",
//							  "repz/addl",
//							  "repz/orb",
//							  "repz/pushl",
//							  rorb,
//							  rorl,
//							  sahf,
//							  scasb,
//							  scasl,
//							  setp,
//							  shlb,
//							  shldl,
//							  stc,
//							  sti,
//							  stosb,
//							  stosl,
//							  "wait/addb",
//							  "wait/addl",
//							  "wait/sbbb",
//							  xlat							  
							  
@".byte",		@"",							  
@"aaa",		@"",	
@"aas",		@"",							  
@"adcb",		@"",							  
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
@"arpl",		@"",
							  
@"bound",		@"",							  
@"bswap",		@"",
							  
@"call",		@"stack.push(%eip), jump($1)",
@"calll",		@"stack.push(%eip), jump($1)",
@"cbtw",		@"convert byte to word",
							  
@"clc",		@"",							  
@"cld",			@"clean the address flag",
@"cltd",		@"",
							  
@"cmovael",		@"",
@"cmovaw",		@"",							  
@"cmoval",		@"",
@"cmovbel",		@"",
@"cmovbl",		@"",
@"cmovel",		@"if (el) move $1 to $2",
@"cmovew",		@"",
@"cmovgel",		@"",
@"cmovgl",		@"",
@"cmovlew",		@"",							  
@"cmovlel",		@"",
@"cmovll",		@"",
@"cmovnel",		@"",
@"cmovnew",		@"",
@"cmovnpl",		@"",							  
@"cmovnsl",		@"",
@"cmovsl",		@"",

@"cmpb",		@"compare byte",
@"cmpw",		@"compare word",
@"cmpl",		@"compare long",
@"cmpss",		@"compare float",
@"cmpsb",		@"",							  
@"cmpsd",		@"compare double",

@"cvtdq2pd",	@"",
@"cvtsd2ss",	@"",
@"cvtsi2sd",	@"",
@"cvtsi2ss",	@"",
@"cvtss2sd",	@"",
@"cvttpd2dq",	@"",
@"cvttsd2si",	@"",
@"cvttss2si",	@"",
@"cvttps2dq",	@"",
							  
@"cwtl",		@"convert word to long",

@"das",		@"",							  
@"decb",		@"decrement by 1",
@"decl",		@"decrement by 1",
@"decw",		@"decrement by 1",

@"divl",		@"unsigned divide",
@"divsd",		@"unsigned divide",
@"divss",		@"unsigned divide",

@"falc",		@"",							  
@"fcomp",		@"",							  
@"fildl",		@"",							  
@"fildq",		@"",
@"fistpq",		@"",							  
@"fld1",		@"load constant",
@"fldl",		@"load real",
@"flds",		@"load real",
@"fldz",		@"load constant",
@"fmuls",		@"",				
@"fmull",		@"",							  
@"fldcw",		@"",							  
@"fnstcw",		@"",							  
@"fstp",		@"store real",
@"fstpl",		@"",
@"fstps",		@"",
@"fsts",		@"",
@"fstl",		@"",							  
@"fxch",		@"",
							  
@"hlt",		@"halt",
@"idivl",		@"signed divide",
@"imulb",		@"",							  
@"imulw",		@"",
@"imull",		@"multiply",
@"incb",		@"",
@"incl",		@"",
@"incw",		@"",
@"insb",		@"",
@"insl",		@"",
@"invd",		@"",
							  
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
@"jcxz",		@"",							  
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
@"jnp",		@"",					
@"jo",		@"",							  
@"jns",			@"Jump if Condition is Met - short if not sign",
@"jnsl",		@"Jump if Condition is Met - ",
@"jp",			@"Jump if Condition is Met - short if parity",
@"jpl",			@"Jump if Condition is Met - ",
@"js",			@"Jump if Condition is Met - short if sign",
@"jsl",			@"Jump if Condition is Met - ",

@"lds",		@"",							  
@"leal",		@"Load Effective address",
@"leave",		@"",
@"ljmp",		@"",							  
@"lock/incl",	@"",
@"lock/sbbb",		@"",							  
@"lodsl",		@"",
@"loop",		@"",							  
@"loopz",		@"",							  
@"loopnz",		@"",
							  
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
@"movsl",		@"",							  
@"movsbl",		@"move byte to long (sign extension)",
@"movsbw",		@"move byte to word (sign extension)",
@"movswl",		@"move word to long (sign extension)",
@"movzbl",		@"move byte to long (zero other bytes)",
@"movzwl",		@"move word to long (zero other bytes)",
@"movups",		@"",
							  
@"mull",		@"unsigned multiply",
@"mulb",		@"",
@"mulss",		@"Multiply Scalar Single-Precision Floating-Point Values",
@"mulsd",		@"multiply double",

@"negb",		@"",							  
@"negw",		@"",							  
@"negl",		@"",
@"nop",			@"no op",
@"nopl",		@"",							  
@"notl",		@"",
							  
@"orb",			@"",
@"orl",			@"",
@"orpd",		@"",
@"orps",		@"",
@"orw",			@"",
@"outsb",		@"",
@"outsl",		@"",
@"outl",		@"",
							  
@"paddd",			@"",
@"popl",		@"",
@"popf",		@"",							  
@"popal",		@"",							  
@"por",		@"",
@"psllq",		@"",
@"pslld",		@"",
@"pushal",		@"",
@"push",		@"",						  
@"pushl",		@"stack.push()",
@"pushf",		@"",							  
@"pxor",		@"",
							  
@"rclb",		@"",							  
@"repz/addb",		@"",							  
@"repz/cmpsb",	@"",
@"rep/stosl",	@"",
@"ret",			@"",
@"retl",			@"",
@"rolb",		@"",				
@"rolw",		@"",							  
@"roll",		@"",
							  
@"sarb",		@"",
@"sarl",		@"",
@"sarw",		@"",
@"sbbb",		@"",							  
@"sbbw",		@"",
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
@"shrdl",		@"",
@"shrl",		@"",
@"shrw",		@"",
@"sldt",		@"",							  
@"sqrtss",		@"",							  
@"sqrtsd",		@"",
@"std",		@"",
@"subb",		@"",
@"subl",		@"",
@"subpd",		@"",
@"subsd",		@"",
@"subss",		@"",
@"subw",		@"",
@"subps",		@"",
							  
@"testb",		@"",
@"testl",		@"",
@"testw",		@"",
@"ucomisd",		@"",
@"ucomiss",		@"",
						
@"xchg",		@"",							  
@"xchgb",		@"",							  
@"xchgl",		@"",							  
@"xorb",		@"",
@"xorl",		@"",
@"xorpd",		@"",
@"xorps",		@"",
@"xorw",		@"",
							
nil] retain];
	return knownInstructions;
}

- (BOOL)isKnownInstruction:(NSString *)instruction {

	NSArray *knownInstructions = [SimpleFileParserAppDelegate knownInstructions];
	BOOL isFound = [knownInstructions containsObject:instruction];
//	if(!isFound){
//		NSLog(@"oopps %i", [knownInstructions indexOfObjectIdenticalTo:instruction]);
//	}
	return isFound;
}

// -- i need to parse the form of the instruction, mv has many
- (void)processInstruction:(NSString *)instruction argument:(NSString *)arguments {
	
	// -- calculate the format
	// -----------------------
	// opcode, argument-format, arguments
	if([arguments length])
		[_unknownArguments addObject:arguments];
	
	-- eh?
		[_allInstructions add:instruction];
	-- eh?
	
	NSMutableSet *allThisInstruction = [_allInstructions objectForKey:instruction];
	if(allThisInstruction==nil){
		allThisInstruction = [NSMutableSet setWithCapacity:100];
		[_allInstructions setObject:allThisInstruction forKey:instruction];
	}
	[allThisInstruction addObject:[NSString stringWithFormat:@"%@ %@", instruction, arguments]];
	
	// Parse argument string
	if(arguments){
		TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:arguments] autorelease];
		[tokensFromThisString secondPass];
		
		NSString *opcodeFormat = [NSString stringWithFormat:@"%@ %@", instruction, [tokensFromThisString pattern]];
		
		// collect opcode format data
		[_allOpCodeFormats add:opcodeFormat];
		
		// Collect argument formats
		ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tokensFromThisString];
		uint argumentCount = [scanner count];
		for( uint i=0; i<argumentCount; i++ )
		{
			NSNumber *newArgCount = nil;
			NSString *argumentPattern = [[scanner argumentAtIndex:i] pattern];
			
			// Collct argument-format data
			[_allArgumentFormats add:argumentPattern];
		}
		
	}
}

- (void)processLine:(NSString *)aLine {

	NSArray *components = worderize( aLine );
	
	NSString *instruction=nil, *arguments=nil;
	
	if([betterComponents count]>=4)
		instruction = [betterComponents objectAtIndex:3];
	if([betterComponents count]>=5)
		arguments = [betterComponents objectAtIndex:4];
	
	-- get the function call hint as well
	
	if(instruction){
		BOOL isKnown = [self isKnownInstruction:instruction];
		if(!isKnown){
			[_unknownInstructions addObject:instruction];
			return;
		}
		[self processInstruction:instruction argument:arguments];
	}
	if(arguments){
		TokenArray *tokensFromThisString  = [[[TokenArray alloc] initWithString:arguments] autorelease];
	}
	// NSLog(@"%@", betterComponents);
}

// DYLD_PRINT_BINDINGS DYLD_NO_PIE DYLD_PRINT_SEGMENTS DYLD_PRINT_LIBRARIES
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	_unknownInstructions = [[NSMutableSet setWithCapacity:100] retain];
	_unknownArguments = [[NSMutableSet setWithCapacity:100] retain];
	
	_allInstructions = [[[StringCounter alloc] init] autorelease];
	_allOpCodeFormats = [[[StringCounter alloc] init] autorelease];
	_allArgumentFormats = [[[StringCounter alloc] init] autorelease];
	
	// strip the app to desired architectire
	// ditto --rsrc --arch i386 /Applications/Foo.app /Application/Foo-i386.app
	
	// otool
	// otool -t /Applications/Foo.app/Contents/MacOS/Foo >> data.txt			-- just data
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled with symbols
	
	NSError *outError;
	NSString *pathToInputFile = [@"~/Desktop/testData.txt" stringByExpandingTildeInPath];
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
	int reverseSort = NO;
	
	NSArray *allUnknownArguments = [_unknownArguments allObjects];
	allUnknownArguments = [allUnknownArguments sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	// NSLog(@"%@", allUnknownArguments);
	
	NSArray *allUnknownInstructions = [_unknownInstructions allObjects];
	allUnknownInstructions = [allUnknownInstructions sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
//	NSLog(@"%@", allUnknownInstructions);

	
	// sort using a selector
	NSArray *allInstructSets = [_allInstructions allValues];
	for( NSSet *eachSet in allInstructSets ){
		NSArray *allInstruct = [eachSet allObjects];
		allInstruct = [allInstruct sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	//	NSLog(@"woo %@", allInstruct );
	}
	
	NSString *mostFrequentFormat;
	uint occurance=0, maxOccurance = 0;

	NSArray *allKeys = [_allOpCodeFormats allKeys];
	for( NSString *each in allKeys ){
		occurance = [[_allOpCodeFormats objectForKey:each] intValue];
		if(occurance>maxOccurance){
			maxOccurance = occurance;
			mostFrequentFormat = each;
		}
	}
	
	// Best explanation of Registers http://www.delorie.com/djgpp/doc/ug/asm/about-386.html

	NSLog(@"Most frequent format is %@ - %i", mostFrequentFormat, maxOccurance );

	NSArray *allPatternCounts = [_allOpCodeFormats sortedCounts];
	NSArray *allPatternStrings = [_allOpCodeFormats sortedStrings];
	

	
COUNT
	
VERIFY
	

	
	
//	Most frequent format is: movl 0xff ( %r ) , %r - 67263   -----  movl 0x10(%ebp),%ebx -- ebx = *(ebp+0x10) --    base = *(StackFrame_BasePointer+0x10)

	// -- sort by operator
	
	// -- output
}


// read the arguments
// substitute movl for op2 = op1
// process the arguments into the instruction string




@end
