//
//  SimpleFileParserAppDelegate.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 09/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SimpleFileParserAppDelegate.h"
#import "AppDisassembly.h"

@implementation SimpleFileParserAppDelegate

@synthesize window = _window;

// registers
// %eip = next instruction address

// http://programminggroundup.blogspot.com/2007/01/appendix-b-common-x86-instructions.html
// http://siyobik.info/index.php?module=x86

+ (NSArray *)_disabled_knownInstructions {
	
	static NSArray *knownInstructions;
	if(knownInstructions == nil)
		knownInstructions = [[NSArray arrayWithObjects:

@".byte",		@"",	
							  
@"aaa",			@"ASCII Adjust After Addition",			// al = ASCII Adjust After Addition(al)
@"aad",			@"ASCII Adjust AX Before Division",		
@"aam",			@"",
@"aas",			@"ASCII Adjust AL After Subtraction",							  
@"adcb",		@"Add with Carry",							  
@"adcl",		@"Add with Carry",
@"addb",		@"Add",
@"addw",		@"Add",							
@"addl",		@"Add",
@"addpd",		@"Add Packed Double-Precision Floating-Point Values",
@"addsd",		@"Add Scalar Double-Precision Floating-Point Values",
@"addss",		@"Add Scalar Single-Precision Floating-Point Values",

@"andb",		@"Logical AND",
@"andw",		@"Logical AND",							  
@"andl",		@"Logical AND",
@"andnpd",		@"Bitwise Logical AND NOT of Packed Double-Precision Floating-Point Values",
@"andnps",		@"Bitwise Logical AND NOT of Packed Single-Precision Floating-Point Values",
@"andpd",		@"Bitwise Logical AND of Packed Double-Precision Floating-Point Values",
@"andps",		@"Bitwise Logical AND of Packed Single-Precision Floating-Point Values",
					
@"arpl",		@"Adjust RPL Field of Segment Selector",
							  
@"bound",		@"Check Array Index Against Bounds",
@"boundl",		@"Check Array Index Against Bounds",
@"bswap",		@"Byte Swap",
							  
@"call",		@"stack.push(%eip), jump($1)",
@"calll",		@"stack.push(%eip), jump($1)",
@"cbtw",		@"convert byte to word",
							  
@"clc",			@"Clear Carry Flag",							  
@"cld",			@"Clear Direction Flag",
@"cli",			@"Clear Interrupt Flag",
@"cltd",		@"",
@"cmc",			@"Complement Carry Flag",
							  
@"cmovaw",		@"Move if above (CF=0 and ZF=0)",								
@"cmoval",		@"Move if above (CF=0 and ZF=0)",
@"cmovael",		@"Move if above or equal (CF=0)",
@"cmovbl",		@"Move if below (CF=1)",
@"cmovbel",		@"Move if below or equal (CF=1 or ZF=1)",
@"cmovew",		@"move if equal (ZF=1)",
@"cmovel",		@"move if equal (ZF=1)",							
@"cmovgel",		@"Move if greater or equal (SF=OF)",
@"cmovgl",		@"Move if greater (ZF=0 and SF=OF)",
@"cmovlew",		@"Move if less or equal (ZF=1 or SF<>OF)",							  
@"cmovlel",		@"Move if less or equal (ZF=1 or SF<>OF)",
@"cmovll",		@"Move if less (SF<>OF)",
@"cmovnel",		@"Move if not equal (ZF=0)",
@"cmovnew",		@"Move if not equal (ZF=0)",
@"cmovnpl",		@"Move if not parity (PF=0)",							  
@"cmovnsl",		@"Move if not sign (SF=0)",
@"cmovsl",		@"Move if sign (SF=1)",

@"cmpb",		@"Compare Two Operands",
@"cmpw",		@"Compare Two Operands",
@"cmpl",		@"Compare Two Operands",
@"cmpss",		@"compare float",
@"cmpsd",		@"compare double",						
@"cmpsl",		@"Compare String",
@"cmpsb",		@"Compare String",							  

// The CMP instruction is typically used in conjunction with a conditional jump (Jcc), condition move (CMOVcc), or SETcc instruction. The condition codes used by the Jcc, CMOVcc, and SETcc instructions are based on the results of a CMP instruction. 

@"cvtdq2pd",	@"Convert Packed Doubleword Integers to Packed Double-Precision Floating-Point Values",
@"cvtsd2ss",	@"Convert Scalar Double-Precision Floating-Point Value to Scalar Single-Precision Floating-Point Value",
@"cvtsi2sd",	@"Convert Doubleword Integer to Scalar Double- Precision Floating-Point Value",
@"cvtsi2ss",	@"Convert Doubleword Integer to Scalar Single- Precision Floating-Point Value",
@"cvtss2sd",	@"Convert Scalar Single-Precision Floating-Point Value to Scalar Double-Precision Floating-Point Value",
@"cvttpd2dq",	@"Convert with Truncation Packed Double-Precision Floating-Point Values to Packed Doubleword Integers",
@"cvttsd2si",	@"Convert with Truncation Scalar Double-Precision Floating-Point Value to Signed Doubleword Integer",
@"cvttss2si",	@"Convert with Truncation Scalar Single-Precision Floating-Point Value to Doubleword Integer",
@"cvttps2dq",	@"Convert with Truncation Packed Single-Precision Floating-Point Values to Packed Doubleword Integers",
							  
@"cwtl",		@"convert word to long",

@"daa",			@"Decimal Adjust AL after Addition",
@"das",			@"Decimal Adjust AL after Subtraction",							  
@"decb",		@"decrement by 1",
@"decw",		@"decrement by 1",							  
@"decl",		@"decrement by 1",

@"divl",		@"unsigned divide",
@"divsd",		@"unsigned divide",
@"divss",		@"unsigned divide",

@"enter",		@"Make Stack Frame for Procedure Parameters",
							  
@"fadd",		@"Add",
@"faddl",		@"Add",
@"faddp",		@"Add",
@"fadds",		@"",
@"fiaddl",		@"Add",
@"fiadds",		@"Add",							  
@"falc",		@"",				
@"fchs",		@"Change Sign",
@"fcomp",		@"Compare Floating Point Values",
@"fcompl",		@"Compare Floating Point Values",
@"fcoms",		@"Compare Floating Point Values",
@"fdiv",		@"Divide",
@"fdivp",		@"Divide",
@"fdivr",		@"Reverse Divide",
@"fdivrp",		@"Reverse Divide",
@"ficompl",		@"Compare Integer",
@"ficomps",		@"Compare Integer",
@"ficoms",		@"Compare Integer",
@"fildl",		@"Load Integer",			
@"filds",		@"Load Integer",
@"fildq",		@"Load Integer",
@"fistpq",		@"Store Integer",							  
@"fld1",		@"load constant",
@"fldl",		@"load real",
@"fld",			@"Load Floating Point Value",
@"fldcwl",		@"Load x87 FPU Control Word",
@"fldt",		@"",
@"flds",		@"load real",
@"fldz",		@"load constant",
@"fmuls",		@"Multiply",
@"fmul",		@"Multiply",
@"fmulp",		@"Multiply",
@"fmull",		@"",
@"fnstcwl",		@"Store x87 FPU Control Word",
@"fldcw",		@"Load x87 FPU Control Word",							  
@"fnstcw",		@"Store x87 FPU Control Word",							  
@"fstp",		@"Store Floating Point Value",
@"fstpt",		@"",
@"fsub",		@"Subtract",
@"fsubp",		@"Subtract",
@"fsubr",		@"Reverse Subtract",
@"fsubrl",		@"",
@"fsubrp",		@"Reverse Subtract",
@"fstpl",		@"",
@"fstps",		@"",
@"fsts",		@"Store x87 FPU Status Word",
@"fstl",		@"",		
@"fucomi",		@"Compare Floating Point Values and Set EFLAGS",
@"fucomip",		@"Compare Floating Point Values and Set EFLAGS",
@"fxch",		@"Exchange Register Contents",

							  
@"hlt",			@"halt",
							  
@"idivl",		@"signed divide",
@"imulb",		@"",							  
@"imulw",		@"",
@"imull",		@"multiply",
@"inb",			@"",
@"inl",			@"",
@"int",			@"",
@"into",		@"Call to Interrupt Procedure",
@"iret",		@"Interrupt Return",
@"incb",		@"",
@"incl",		@"",
@"incw",		@"",
@"insb",		@"Input from Port to String",
@"insl",		@"",
@"invd",		@"Invalidate Internal Caches",
							  
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
@"jno",			@"",
@"jnp",			@"",				
@"jnpl",		@"",
@"jo",			@"",							  
@"jns",			@"Jump if Condition is Met - short if not sign",
@"jnsl",		@"Jump if Condition is Met - ",
@"jp",			@"Jump if Condition is Met - short if parity",
@"jpl",			@"Jump if Condition is Met - ",
@"js",			@"Jump if Condition is Met - short if sign",
@"jsl",			@"Jump if Condition is Met - ",

@"lahf",		@"Load Status Flags into AH Register",
@"lcall",		@"",
@"lds",			@"Load Far Pointer",							  
@"leal",		@"Load Effective address",
@"leave",		@"High Level Procedure Exit",
@"les",			@"Load Far Pointer",
@"ljmp",		@"",
@"ljmpl",		@"",
@"lock/incl",	@"",
@"lock/sbbb",		@"",
@"lock/addb",		@"",
@"lock/cmpxchgl",		@"",
@"lock/pushl",		@"",
@"lock/sbbl",		@"",
@"lock/xaddl",		@"",
							  
@"lodsb",		@"Load String",  
@"lodsl",		@"",
@"loop",		@"Loop According to ECX Counter",							  
@"loopz",		@"",							  
@"loopnz",		@"",
@"lret",		@"",
							  
@"maxsd",		@"Return Maximum Scalar Double-Precision Floating-Point Value",
@"maxss",		@"Return Maximum Scalar Single-Precision Floating-Point Value",
@"minsd",		@"Return Minimum Scalar Double-Precision Floating-Point Value",
@"minss",		@"Return Minimum Scalar Single-Precision Floating-Point Value",

@"movapd",		@"move aligned packed double precision float",
@"movaps",		@"move aligned packed single precision float",

@"movb",		@"move byte (8)",
@"movw",		@"move word (16)",
@"movl",		@"move long (32)",
@"movd",		@"move double (64)",
							  
@"movhpd",		@"Move High Packed Double-Precision Floating-Point Value",
							  
@"movsb",		@"Move Data from String to String",
@"movsw",		@"Move Data from String to String",
@"movsl",		@"",							  
@"movsd",		@"Move Data from String to String",
							  
@"movss",		@"move scalar single precision float",
@"movsbl",		@"move byte to long (sign extension)",
@"movsbw",		@"move byte to word (sign extension)",
@"movswl",		@"move word to long (sign extension)",
							  
@"movzbl",		@"move byte to long (zero other bytes)",
@"movzwl",		@"move word to long (zero other bytes)",

@"movups",		@"Move Unaligned Packed Single-Precision Floating- Point Values",
					
@"mulb",		@"",
@"mulw",		@"",							  
@"mull",		@"unsigned multiply",
@"muld",		@"unsigned multiply",
							  
@"mulss",		@"Multiply Scalar Single-Precision Floating-Point Values",
@"mulsd",		@"Multiply Scalar Double-Precision Floating-Point Values",

@"negb",		@"",							  
@"negw",		@"",							  
@"negl",		@"",
@"nop",			@"no op",
@"nopl",		@"",							  
@"notl",		@"",
							  
@"orb",			@"",
@"orl",			@"",
@"orpd",		@"Bitwise Logical OR of Double-Precision Floating-Point Values",
@"orps",		@"Bitwise Logical OR of Single-Precision Floating-Point Values",
@"orw",			@"",
@"outb",		@"",
@"outsb",		@"Output String to Port",
@"outsl",		@"",
@"outl",		@"",
							  
@"paddd",		@"Add Packed Integers",
@"popl",		@"",
@"popfl",		@"",
@"popf",		@"Pop Stack into EFLAGS Register",							  
@"popal",		@"",							  
@"por",			@"",
@"psllq",		@"Shift Packed Data Left Logical",
@"pslld",		@"Shift Packed Data Left Logical",
@"punpckldq",	@"Unpack Low Data",
@"pushal",		@"",
@"push",		@"Push Word or Doubleword Onto the Stack",						  
@"pushl",		@"stack.push()",
@"pushfl",			@"",
@"pushw",			@"",
@"pushf",		@"Push EFLAGS Register onto the Stack",							  
@"pxor",		@"Logical Exclusive OR",
							  
@"rclb",		@"",		
@"rcrl",		@"",

@"rep/stosl",		@"Repeat while( ECX(--)>0 ) stosl",

@"repz/addb",		@"Repeat while( ECX(--)>0 && ZF!=0 ) addb",							  
@"repz/cmpsb",		@"Repeat while( ECX(--)>0 && ZF!=0 ) cmpsb",
@"repz/addl",		@"Repeat while( ECX(--)>0 && ZF!=0 ) addl",
@"repz/orb",		@"Repeat while( ECX(--)>0 && ZF!=0 ) orb",
@"repz/pushl",		@"Repeat while( ECX(--)>0 && ZF!=0 ) pushl",	
							  
@"repnz/addb",		@"Repeat while( ECX(--)>0 && ZF!=1 ) addb",


							  
@"ret",			@"Return from Procedure",
@"retl",		@"",
@"rolb",		@"",				
@"rolw",		@"",							  
@"roll",		@"",
@"rorb",		@"",
@"rorl",		@"",	  
						
@"sahf",		@"Store AH into Flags",
@"sarb",		@"",
@"sarl",		@"",
@"sarw",		@"",
@"sbbb",		@"",							  
@"sbbw",		@"",
@"sbbl",		@"",
@"scasb",		@"Scan String",
@"scasl",		@"",
							  
//	flags
//	CF = carryFlag
//	PF = parityFlag
//	AF = adjustFlag
//	ZF = zeroFlag
//	SF = signFlag
//	TF = trapFlag
//	IF = interruptEnableFlag
//	DF = directionFlag
//	OF = overflowFlag
							  
							  
@"seta",		@"Set byte if above (CF=0 and ZF=0)",				// (CF==0 && ZF==0) ? $1=1 : $1=0
@"setae",		@"Set byte if above or equal (CF=0)",				// (CF==0) ? $1=1 : $1=0
@"setb",		@"Set byte if below (CF=1)",						// (CF==1) ? $1=1 : $1=0
@"setbe",		@"Set byte if below or equal (CF=1 or ZF=1)",		// (CF==1 || ZF==1) ? $1=1 : $1=0
@"sete",		@"Set byte if equal (ZF=1)",
@"setg",		@"Set byte if greater (ZF=0 and SF=OF)",
@"setge",		@"Set byte if greater or equal (SF=OF)",
@"setl",		@"Set byte if less (SF<>OF)",
@"setle",		@"Set byte if less or equal (ZF=1 or SF<>OF)",
@"setne",		@"Set byte if not equal (ZF=0)",
@"setnp",		@"Set byte if not parity (PF=0)",
@"setp",		@"Set byte if parity (PF=1)",
							  
@"shll",		@"",
@"shlb",		@"", 
@"shldl",		@"",
@"shrb",		@"",
@"shrdl",		@"",
@"shrl",		@"",
@"shrw",		@"",
@"sldt",		@"Store Local Descriptor Table Register",					
@"sldtl",		@"",
@"sqrtss",		@"Compute Square Root of Scalar Single-Precision Floating-Point Value",							  
@"sqrtsd",		@"Compute Square Root of Scalar Double-Precision Floating-Point Value",
							  
@"std",			@"Set Direction Flag",
@"stc",			@"Set Carry Flag",
@"sti",			@"Set Interrupt Flag",
							  
@"stos",		@"Store String",							  
@"stosb",		@"Store String",
@"stosw",		@"Store String",
@"stosl",		@"Store String",
@"stosd",		@"Store String",
							  
@"subb",		@"Subtract",
@"subw",		@"Subtract",
@"subl",		@"Subtract",
@"subss",		@"Subtract Scalar Single-Precision Floating-Point Values",
@"subsd",		@"Subtract Scalar Double-Precision Floating-Point Values",
@"subps",		@"Subtract Packed Single-Precision Floating-Point Values",
@"subpd",		@"Subtract Packed Double-Precision Floating-Point Values",

@"testb",		@"Logical Compare",
@"testw",		@"Logical Compare",
@"testl",		@"Logical Compare",
							  
@"ucomisd",		@"Unordered Compare Scalar Double-Precision Floating- Point Values and Set EFLAGS",
@"ucomiss",		@"Unordered Compare Scalar Single-Precision Floating- Point Values and Set EFLAGS",
						
@"wait/addb",		@"",
@"wait/addl",		@"",
@"wait/sbbb",		@"",
							  
@"xchg",		@"Exchange Register/Memory with Register",							  
@"xchgb",		@"Exchange Register/Memory with Register",							  
@"xchgl",		@"Exchange Register/Memory with Register",
							  
@"xlat",		@"Table Look-up Translation",
							  
@"xorb",		@"Logical Exclusive OR",
@"xorw",		@"Logical Exclusive OR",
@"xorl",		@"Logical Exclusive OR",
@"xord",		@"Logical Exclusive OR",
							  
@"xorps",		@"Bitwise Logical XOR for Single-Precision Floating-Point Values",
@"xorpd",		@"Bitwise Logical XOR for Double-Precision Floating-Point Values",
							
nil] retain];
	return knownInstructions;
}

/* Useful Dyld enviro variables */
// DYLD_PRINT_BINDINGS 
// DYLD_NO_PIE
// DYLD_PRINT_SEGMENTS
// DYLD_PRINT_LIBRARIES

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	// strip the app to desired architectire
	// ditto --rsrc --arch i386 /Applications/Foo.app /Application/Foo-i386.app

	NSError *outError;
	NSString *pathToInputFile = [@"~/Desktop/testData_huge.txt" stringByExpandingTildeInPath];
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:NSMacOSRomanStringEncoding error:&outError];
	
	_dissasembled =  [[AppDisassembly alloc] initWithOtoolOutput:fileString];
	
	// This is asyncronous. Need to rethink some stuff
	[_dissasembled outputToFile:[@"~/Desktop/undisassembled.txt" stringByExpandingTildeInPath]];


//err! where has it gone?	_unknownArguments = [[NSMutableSet setWithCapacity:100] retain];
	
//err! where has it gone?	_allInstructions = [[[StringCounter alloc] init] autorelease];
//err! where has it gone?	_allOpCodeFormats = [[[StringCounter alloc] init] autorelease];
//err! where has it gone?	_allArgumentFormats = [[[StringCounter alloc] init] autorelease];
	

	
	// otool
	// otool -t /Applications/Foo.app/Contents/MacOS/Foo >> data.txt			-- just data
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled
	// otool -t -v -V /Applications/Foo.app/Contents/MacOS/Foo >> data.txt		-- decompiled with symbols
	

	

	 


	// -- read it a line at a time. -- try niave aproach
//	int reverseSort = NO;
	
//	NSArray *allUnknownArguments = [_unknownArguments allObjects];
//	allUnknownArguments = [allUnknownArguments sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
//	NSLog(@"%@", allUnknownArguments);
	
//err! where has it gone?	NSArray *allUnknownInstructions = [_unknownInstructions allObjects];
//err! where has it gone?	allUnknownInstructions = [allUnknownInstructions sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
//err! where has it gone?	if([allUnknownInstructions count])
//err! where has it gone?		NSLog(@"WARNING! UNKNOWN %@", allUnknownInstructions);

	
	// sort using a selector
//	NSArray *allInstructSets = [_allInstructions allValues];
//	for( NSSet *eachSet in allInstructSets ){
//		NSArray *allInstruct = [eachSet allObjects];
//		allInstruct = [allInstruct sortedArrayUsingFunction:alphabeticSort context:&reverseSort];
	//	NSLog(@"woo %@", allInstruct );
//	}
	
//err! where has it gone?	[_allArgumentFormats sort];
//err! where has it gone?	NSArray *allPatternCounts = [_allArgumentFormats sortedCounts];
//err! where has it gone?	NSArray *allPatternStrings = [_allArgumentFormats sortedStrings];

//	NSAssert([allPatternCounts count]==[allPatternStrings count], @"nah %i, %i", [allPatternCounts count],[allPatternStrings count] );
	
//err! where has it gone?	for( NSUInteger i=0; i<[allPatternStrings count]; i++ ) {
//err! where has it gone?		NSLog(@"%@", [allPatternStrings objectAtIndex:i] );
//err! where has it gone?	}
	
//	NSString *mostFrequentFormat;
//	uint occurance=0, maxOccurance = 0;

//	NSArray *allKeys = [_allArgumentFormats allKeys];
//	for( NSString *each in allKeys ){
//		occurance = [[_allArgumentFormats objectForKey:each] intValue];
//		if(occurance>maxOccurance){
//			maxOccurance = occurance;
//			mostFrequentFormat = each;
//		}
//	}
	
	// Best explanation of Registers http://www.delorie.com/djgpp/doc/ug/asm/about-386.html

//	NSLog(@"Most frequent format is %@ - %i", mostFrequentFormat, maxOccurance );


		
	
//	Most frequent format is: movl 0xff ( %r ) , %r - 67263   -----  movl 0x10(%ebp),%ebx -- ebx = *(ebp+0x10) --    base = *(StackFrame_BasePointer+0x10)

	// -- sort by operator
	
	// -- output
}


// read the arguments
// substitute movl for op2 = op1
// process the arguments into the instruction string




@end
