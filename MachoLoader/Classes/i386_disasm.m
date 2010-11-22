/*
 * Copyright (c) 1999 Apple Computer, Inc. All rights reserved.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */
/*
 * This file contains the i386 disassembler routine used at NeXT Computer, Inc.
 * to match the the assembler used at NeXT.  It was addapted from a set of
 * source files with the following copyright which is retained below.
 */
/*
  Copyright 1988, 1989 by Intel Corporation, Santa Clara, California.

		All Rights Reserved

Permission to use, copy, modify, and distribute this software and
its documentation for any purpose and without fee is hereby
granted, provided that the above copyright notice appears in all
copies and that both the copyright notice and this permission notice
appear in supporting documentation, and that the name of Intel
not be used in advertising or publicity pertaining to distribution
of the software without specific, written prior permission.

INTEL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE
INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS,
IN NO EVENT SHALL INTEL BE LIABLE FOR ANY SPECIAL, INDIRECT, OR
CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN ACTION OF CONTRACT,
NEGLIGENCE, OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#import "ArgStack.h"
#import "Instructions.h"
#import "Registers.h"

#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <mach-o/reloc.h>
#import "MachoLoader.h"
#import "InstrArgStruct.h"
// #import "ExperimentalFrankenStructs.h"
#import "StringManipulation.h"

//#include "stuff/symbol.h"
//#include "stuff/bytesex.h"
//#include "otool.h"
//#include "ofile_print.h"
//#include "i386_disasm.h"
#import "DisassemblyChecker.h"

#import "i386_disasm.h"

#define MAX_RESULT	24	/* Maximum number of char in a register */
				/*  result expression "(%ebx,%ecx,8)" */

#define WBIT(x)	(x & 0x1)		/* to get w bit	*/
#define REGNO(x) (x & 0x7)		/* to get 3 bit register */
#define VBIT(x)	((x)>>1 & 0x1)		/* to get 'v' bit */
#define OPSIZE(data16,wbit,maybe64) ((wbit) ? ((data16) ? 2: ((maybe64) ? 8 : 4)) : 1 )
#define REX_W(x) (((x) & 0x8) == 0x8)	/* true if the REX.W bit is set --> 64-bit operand size */
#define REX_R(x) (((x) & 0x4) == 0x4)	/* true if the REX.R bit is set --> ModRM reg extension */
#define REX_X(x) (((x) & 0x2) == 0x2)	/* true if the REX.X bit is set --> SIB index extension */
#define REX_B(x) (((x) & 0x1) == 0x1)	/* true if the REX.B bit is set --> ModRM r/m, SIB base, or opcode reg extension */

#define REG_ONLY 3	/* mode indicates a single register with	*/
			/* no displacement is an operand		*/
#define BYTEOPERAND 0	/* value of the w-bit indicating a byte		*/
			/* operand (1-byte)				*/
#define LONGOPERAND 1	/* value of the w-bit indicating a long		*/
			/* operand (2-bytes or 4-bytes)			*/
#define EBP 5
#define ESP 4


struct ImediateValue {
	enum argType		isah;	
	uint64				value;
};

struct DisplacementValue {
	enum argType		isah;	
	uint64				value;
};

// always refers to a memory location
struct IndirectVal {
	enum argType			isah;
	const struct HooReg		*segmentRegister;
	uint64					displacement;
	const struct HooReg		*baseRegister;
	const struct HooReg		*indexRegister;
	NSUInteger				scale;
};

#define NEW_INDIRECT( x,segReg,displace,baseReg,indexReg,scaleSize) x=calloc(1, sizeof(struct IndirectVal)); x->isah=INDIRECT_ARG; x->segmentRegister=segReg; x->displacement=displace; x->baseRegister=baseReg; x->indexRegister=indexReg; x->scale=scaleSize;

#define NEW_IMMEDIATE( immedStructPtr, immVal ) immedStructPtr = calloc(1, sizeof(struct ImediateValue)); immedStructPtr->isah=IMMEDIATE_ARG; immedStructPtr->value=immVal;

#define NEW_DISPLACEMENT( displaceStructPtr, intVal ) displaceStructPtr = calloc(1, sizeof(struct DisplacementValue)); displaceStructPtr->isah=DISPLACEMENT_ARG; displaceStructPtr->value=intVal;


/* Flags */
#define HAS_SUFFIX			0x1	/* For instructions which may have a 'w', 'l', or 'q' suffix */
#define IS_POINTER_SIZED	0x2	/* For instructions which implicitly have operands which are sizeof(void *) */

void hooleyDebug( void ) {
	NSLog(@"woohoo");
}

static NSUInteger replacement_get_operand(
										  const char **symadd,
										  const char **symsub,
										  uint64 *value,
										  NSUInteger *value_size,
										  void *result,
										  const cpu_type_t cputype,
										  const NSUInteger mode,
										  const NSUInteger r_m,
										  const NSUInteger wbit,
										  const NSUInteger data16,
										  const NSUInteger addr16,
										  const NSUInteger sse2,
										  const NSUInteger mmx,
										  const unsigned int rex,
										  const char *sect,
										  char *sect_addr,
										  NSUInteger *length,
										  uint64 *left,
										  char *addr,
										  const struct relocation_info *sorted_relocs,
										  const NSUInteger nsorted_relocs,
										  const struct nlist *symbols,
										  const struct nlist_64 *symbols64,
										  const NSUInteger nsymbols,
										  const char *strings,
										  const NSUInteger strings_size,
										  const struct symbol *sorted_symbols,
										  const NSUInteger nsorted_symbols,
										  const NSUInteger verbose, 
										  struct HooReg *segReg );

static void replacement_immediate(
					  const char **symadd,
					  const char **symsub,
					  uint64_t *value,
					  NSUInteger value_size,
					  const char *sect,
					  const char *sect_addr,
					  NSUInteger *length,
					  uint64 *left,
					  const cpu_type_t cputype,
					  const char *addr,
					  const struct relocation_info *sorted_relocs,
					  const NSUInteger nsorted_relocs,
					  const struct nlist *symbols,
					  const struct nlist_64 *symbols64,
					  const NSUInteger nsymbols,
					  const char *strings,
					  const NSUInteger strings_size,
					  const struct symbol *sorted_symbols,
					  const NSUInteger nsorted_symbols,
					  const NSUInteger verbose
					  );


static void displacement(
    const char **symadd,
    const char **symsub,
    uint64 *value,
    const NSUInteger value_size,
    const char *sect,
    const char *sect_addr,
    NSUInteger *length,
    uint64 *left,
    const cpu_type_t cputype,
    const char *addr,
    const struct relocation_info *sorted_relocs,
    const NSUInteger nsorted_relocs,
    const struct nlist *symbols,
    const struct nlist_64 *symbols64,
    const NSUInteger nsymbols,
    const char *strings,
    const NSUInteger strings_size,
    const struct symbol *sorted_symbols,
    const NSUInteger nsorted_symbols,
    const NSUInteger verbose);


//static void print_operand( const char *seg, const char *symadd, const char *symsub, uint64_t value, NSUInteger value_size, const char *result, const char *tail);
//static void replacementPrint_operand( char *outPutBuffer, struct HooReg *segReg, const char *symadd, const char *symsub, uint64_t value, NSUInteger value_size, const char *result, const char *tail);
static uint64_t get_value( const NSUInteger size, const char *sect, NSUInteger *length, uint64 *left);
static void modrm_byte( uint32_t *mode, uint32_t *reg, uint32_t *r_m, unsigned char byte);

#define GET_BEST_REG_NAME( reg_name, reg_struct ) \
reg_name = (char *)reg_struct->prettyName;  \
if( !strcmp( reg_name, "unknown") ) \
reg_name = (char *)reg_struct->name; \

#define FILLARGS1(arg1) \
allArgs = calloc(1, sizeof(struct InstrArgStruct)); \
allArgs[0].numberOfArgs = 1; \
allArgs[0].value = (void *)arg1; \

#define FILLARGS2(arg1,arg2) \
allArgs = calloc(2, sizeof(struct InstrArgStruct)); \
allArgs[0].numberOfArgs = 2; \
allArgs[0].value = (void *)arg1; \
allArgs[1].value = (void *)arg2; \

#define FILLARGS3(arg1, arg2, arg3) \
allArgs = calloc(3, sizeof(struct InstrArgStruct)); \
allArgs[0].numberOfArgs = 3; \
allArgs[0].value = (void *)arg1; \
allArgs[1].value = (void *)arg2; \
allArgs[2].value = (void *)arg3; \

#define REPLACEMENT_GET_OPERAND(symadd, symsub, value, value_size, result) \
replacement_get_operand((symadd), (symsub), (value), (value_size), (result), \
cputype, mode, r_m, wbit, data16, addr16, sse2, mmx, rex, \
sect, sect_addr, &length, &left, addr, sorted_relocs, \
nsorted_relocs, symbols, symbols64, nsymbols, strings, \
strings_size, sorted_symbols, nsorted_symbols, verbose, segReg)

#define GET_OPERAND(symadd, symsub, value, value_size, result) \
get_operand((symadd), (symsub), (value), (value_size), (result), \
cputype, mode, r_m, wbit, data16, addr16, sse2, mmx, rex, \
sect, sect_addr, &length, &left, addr, sorted_relocs, \
nsorted_relocs, symbols, symbols64, nsymbols, strings, \
strings_size, sorted_symbols, nsorted_symbols, verbose)

#define DISPLACEMENT(symadd, symsub, value, value_size) \
	displacement((symadd), (symsub), (value), (value_size), sect, \
		     sect_addr, &length, &left, cputype, addr, sorted_relocs, \
		     nsorted_relocs, symbols, symbols64, nsymbols, strings, \
		     strings_size, sorted_symbols, nsorted_symbols, verbose)


#define REPLACEMENT_IMMEDIATE(symadd, symsub, value, value_size) \
replacement_immediate((symadd), (symsub), (value), (value_size), sect, sect_addr, \
&length, &left, cputype, addr, sorted_relocs, \
nsorted_relocs, symbols, symbols64, nsymbols, strings, \
strings_size, sorted_symbols, nsorted_symbols, verbose)



#define GET_SYMBOL(symadd, symsub, offset, sect_offset, value) \
	get_symbol((symadd), (symsub), (offset), cputype, (sect_offset), \
		   (value), sorted_relocs, nsorted_relocs, symbols, symbols64, \
		   nsymbols, strings, strings_size, sorted_symbols, \
		   nsorted_symbols, verbose)

#define GUESS_SYMBOL(value) \
	guess_symbol((value), sorted_symbols, nsorted_symbols, verbose)



#pragma mark -
#pragma mark Registers


hooReg_		*FloatingPointREG[9] = { &fp0_reg, &fp1_reg, &fp2_reg, &fp3_reg, &fp4_reg, &fp5_reg, &fp6_reg, &fp7_reg, &fp_reg };

hooReg_		*REG16_Struct[8][2] = {
	{ &acuml_reg,	&acumx_reg },			// al=low-byte, ah=high-byte, etc
	{ &count1_reg,	&count2_reg },
	{ &data2_reg,	&data1_reg },
	{ &base2_reg,	&base1_reg },
	{ &acum1_reg,	&spt1_reg },
	{ &count3_reg,	&spb1_reg },
	{ &data3_reg,	&sourceIndex2_reg },
	{ &base3_reg,	&destinationIndex2_reg }
};

hooReg_		*REG32_Struct[16][3] = {
	{ &acuml_reg,	&acumex_reg,			&acum2_reg },
	{ &count1_reg,	&count4_reg,			&count5_reg },
	{ &data2_reg,	&data4_reg,				&data5_reg },
	{ &base2_reg,	&base4_reg,				&base5_reg },
	{ &acum1_reg,	&spt2_reg,				&spt3_reg },
	{ &count3_reg,	&spb2_reg,				&spb3_reg },
	{ &data3_reg,	&sourceIndex1_reg,		&sourceIndex3_reg },
	{ &base3_reg,	&destinationIndex1_reg,	&destinationIndex3_reg },
	{ &r08_1_reg,	&r08_2_reg,				&r08_3_reg },
	{ &r09_1_reg,	&r09_2_reg,				&r09_3_reg },
	{ &r10_1_reg,	&r10_2_reg,				&r10_3_reg },
	{ &r11_1_reg,	&r11_2_reg,				&r11_3_reg },
	{ &r12_1_reg,	&r12_2_reg,				&r12_3_reg },
	{ &r13_1_reg,	&r13_2_reg,				&r13_3_reg },
	{ &r14_1_reg,	&r14_2_reg,				&r14_3_reg },
	{ &r15_1_reg,	&r15_2_reg,				&r15_3_reg }
};

// Return bonkers double reg
hooReg_		*regname16_Struct[4][8][2] = {
	{
		{ &base1_reg,				&sourceIndex2_reg},
		{ &base1_reg,				&destinationIndex2_reg},
		{ &spb1_reg,				&sourceIndex2_reg}, 
		{ &spb1_reg,				&destinationIndex2_reg},
		{ &sourceIndex2_reg,		&null_reg},
		{ &destinationIndex2_reg,	&null_reg},
		{ &empty_reg,				&null_reg},
		{ &base1_reg,				&null_reg}	
	},
	{	{ &base1_reg,				&sourceIndex2_reg },
		{ &base1_reg,				&destinationIndex2_reg },
		{ &spb1_reg,				&sourceIndex2_reg},
		{ &spb1_reg,				&destinationIndex2_reg},
		{ &sourceIndex2_reg,		&null_reg},
		{ &destinationIndex2_reg,	&null_reg},
		{ &spb1_reg,				&null_reg},
		{ &base1_reg,				&null_reg}
	},
	{	{ &base1_reg,				&sourceIndex2_reg},
		{ &base1_reg,				&destinationIndex2_reg},
		{ &spb1_reg,				&sourceIndex2_reg},
		{ &spb1_reg,				&destinationIndex2_reg},
		{ &sourceIndex2_reg,		&null_reg},
		{ &destinationIndex2_reg,	&null_reg},
		{ &spb1_reg,				&null_reg},
		{ &base1_reg,				&null_reg}
	},
	{	{ &acumx_reg,				&null_reg},
		{ &count2_reg,				&null_reg},
		{ &data1_reg,				&null_reg},
		{ &base1_reg,				&null_reg},
		{ &spt1_reg,				&null_reg},
		{ &spb1_reg,				&null_reg},
		{ &sourceIndex2_reg,		&null_reg},
		{ &destinationIndex2_reg,	&null_reg}
	}
};

hooReg_		*regname32_Struct[4][8] = {
	{ &acumex_reg, &count4_reg, &data4_reg, &base4_reg, &spt2_reg, &empty_reg, &sourceIndex1_reg, &destinationIndex1_reg	},
	{ &acumex_reg, &count4_reg, &data4_reg, &base4_reg, &spt2_reg, &spb2_reg, &sourceIndex1_reg, &destinationIndex1_reg	},
	{ &acumex_reg, &count4_reg, &data4_reg, &base4_reg, &spt2_reg, &spb2_reg, &sourceIndex1_reg, &destinationIndex1_reg	},
	{ &acumex_reg, &count4_reg, &data4_reg, &base4_reg, &spt2_reg, &spb2_reg, &sourceIndex1_reg, &destinationIndex1_reg	}
};

hooReg_		*regname64_Struct[4][16] = {
	{ &acum2_reg, &count5_reg, &data5_reg, &base5_reg, &spt3_reg, &spb3_reg, &sourceIndex3_reg, &destinationIndex3_reg, &r08_3_reg, &r09_3_reg, &r10_3_reg, &r11_3_reg, &r12_3_reg, &r13_3_reg, &r14_3_reg, &r15_3_reg	},
	{ &acum2_reg, &count5_reg, &data5_reg, &base5_reg, &spt3_reg, &spb3_reg, &sourceIndex3_reg, &destinationIndex3_reg, &r08_3_reg, &r09_3_reg, &r10_3_reg, &r11_3_reg, &r12_3_reg, &r13_3_reg, &r14_3_reg, &r15_3_reg	},
	{ &acum2_reg, &count5_reg, &data5_reg, &base5_reg, &spt3_reg, &spb3_reg, &sourceIndex3_reg, &destinationIndex3_reg, &r08_3_reg, &r09_3_reg, &r10_3_reg, &r11_3_reg, &r12_3_reg, &r13_3_reg, &r14_3_reg, &r15_3_reg	},
	{ &acum2_reg, &count5_reg, &data5_reg, &base5_reg, &spt3_reg, &spb3_reg, &sourceIndex3_reg, &destinationIndex3_reg, &r08_3_reg, &r09_3_reg, &r10_3_reg, &r11_3_reg, &r12_3_reg, &r13_3_reg, &r14_3_reg, &r15_3_reg	}
};

hooReg_		*indexname_Struct[8]		= { &acumex_reg, &count4_reg, &data4_reg, &base4_reg, &empty_reg, &spb2_reg, &sourceIndex1_reg, &destinationIndex1_reg };
hooReg_		*indexname64_Struct[16]	= { &acum2_reg, &count5_reg, &data5_reg, &base5_reg, &empty_reg, &spb3_reg, &sourceIndex3_reg, &destinationIndex3_reg, &r08_3_reg, &r09_3_reg, &r10_3_reg, &r11_3_reg, &r12_3_reg, &r13_3_reg, &r14_3_reg, &r15_3_reg };
hooReg_		*xmmReg_Struct[8]			= { &xmm0_reg, &xmm1_reg, &xmm2_reg, &xmm3_reg, &xmm4_reg, &xmm5_reg, &xmm6_reg, &xmm7_reg };
hooReg_		*mmReg_Struct[8]			= { &mm0_reg, &mm1_reg, &mm2_reg, &mm3_reg, &mm4_reg, &mm5_reg, &mm6_reg, &mm7_reg };
hooReg_		*SEGREG[8]					= { &dataSeg1_reg, &codeSeg_reg, &stackSeg_reg, &dataSeg3_reg, &dataSeg4_reg, &dataSeg5_reg, &unknown1_reg, &unknown2_reg };


/*
 * If r/m==100 then the following byte (the s-i-b byte) must be decoded
 */
static const int const scale_factor[4] = { 1, 2, 4, 8 };

/*
 * In 16-bit mode:
 * This initialized array will be indexed by the 'r/m' and 'mod'
 * fields, to determine the size of the displacement in each mode.
 */
static const char dispsize16 [8][4] = {
	/* mod		00	01	10	11 */
	/* r/m */
	/* 000 */	{0,	1,	2,	0},
	/* 001 */	{0,	1,	2,	0},
	/* 010 */	{0,	1,	2,	0},
	/* 011 */	{0,	1,	2,	0},
	/* 100 */	{0,	1,	2,	0},
	/* 101 */	{0,	1,	2,	0},
	/* 110 */	{2,	1,	2,	0},
	/* 111 */	{0,	1,	2,	0}
};

/*
 * In 32-bit mode:
 * This initialized array will be indexed by the 'r/m' and 'mod'
 * fields, to determine the size of the displacement in this mode.
 */
static const char dispsize32 [8][4] = {
	/* mod		00	01	10	11 */
	/* r/m */
	/* 000 */	{0,	1,	4,	0},
	/* 001 */	{0,	1,	4,	0},
	/* 010 */	{0,	1,	4,	0},
	/* 011 */	{0,	1,	4,	0},
	/* 100 */	{0,	1,	4,	0},
	/* 101 */	{4,	1,	4,	0},
	/* 110 */	{0,	1,	4,	0},
	/* 111 */	{0,	1,	4,	0}
};



#pragma mark -
#pragma mark Instructions




//struct instable const *distableEntry( int opcode1, int opcode2 ) {
//
//	struct instable const *dp = &distable[opcode1][opcode2];
//
//	if(dp->adr_mode == PREFIX)
//	{
//	if(prefix_dp != NULL)
//	printf("%s", dp->name);
//	prefix_dp = dp;
//	prefix_byte = byte;
//	}
//	else if(dp->adr_mode == AM){
//	addr16 = !addr16;
//	prefix_byte = byte;
//	}
//	else if(dp->adr_mode == DM){
//	data16 = !data16;
//	prefix_byte = byte;
//	}
//	else if(dp->adr_mode == OVERRIDE){
//	seg = dp->name;
//	prefix_byte = byte;
//	}
//	else if(dp->adr_mode == REX){
//	rex = byte;
//	/*
//	* REX is a prefix, but we don't set prefix_byte here because
//	* we use that to detect things related to the other prefixes
//	* and we don't want the existence of those bytes to be hidden
//	* by the presence of a REX prefix.
//	*/
//	}
//	else
//	break;
//
//	return dp;
//}


//static const char *get_reg_name(int reg, int wbit, int data16, int rex) {
//	
//	const char *reg_name;
//
//	// A REX prefix takes precedent over a 66h prefix.
//	if (rex != 0) {
//		reg_name = REG32[reg + (REX_R(rex) << 3)][wbit + REX_W(rex)];
//	} else if (data16) {
//		reg_name = REG16[reg][wbit];
//	} else {
//		reg_name = REG32[reg][wbit];
//	}
//
//	return reg_name;
//}


static const struct HooReg *segRegPtrForName( char *segRegName ) {
	
	if( !strcmp(segRegName, "%cs:") ){
		return &codeSeg_reg;
	} else if( !strcmp(segRegName, "%es:") ){
		return &dataSeg1_reg;
	} else if( !strcmp(segRegName, "%ss:") ){
		return &stackSeg_reg;
	} else if( !strcmp(segRegName, "%ds:") ){
		return &dataSeg2_reg;
	} else if( !strcmp(segRegName, "%fs:") ){
		return &dataSeg2_reg;
	} else if( !strcmp(segRegName, "%gs:") ){
		return &dataSeg2_reg;
	}
	
	[NSException raise:@"Unknown segreg" format:@"Unknown segreg"];
	return NULL;
}

static const struct HooReg *get_regStruct( NSUInteger reg, NSUInteger wbit, NSUInteger data16, NSUInteger rex ) {
	
	const struct HooReg *regStruct;
	if (rex != 0) {
		regStruct = REG32_Struct[reg + (REX_R(rex) << 3)][wbit + REX_W(rex)];
	} else if (data16) {
		regStruct = REG16_Struct[reg][wbit];
	} else {
		regStruct = REG32_Struct[reg][wbit];
	}
	return regStruct;
}

/* yeah */
static const struct HooReg *get_r_m_regStruct( NSUInteger r_m, NSUInteger wbit, NSUInteger data16, NSUInteger rex ) {

	const struct HooReg *regStruct;
	if( rex!=0 ) {
		regStruct = REG32_Struct[r_m + (REX_B(rex) << 3)][wbit + REX_W(rex)];
	} else if (data16) {
		regStruct = REG16_Struct[r_m][wbit];
	} else {
		regStruct = REG32_Struct[r_m][wbit];
	}
	return regStruct;	
}

//static const char *get_r_m_name( int r_m, int wbit, int data16, int rex ) {
//
//	const char *reg_name;
//	// A REX prefix takes precedent over a 66h prefix.
//	if (rex != 0) {
//		reg_name = REG32[r_m + (REX_B(rex) << 3)][wbit + REX_W(rex)];
//	} else if (data16) {
//		reg_name = REG16[r_m][wbit];
//	} else {
//		reg_name = REG32[r_m][wbit];
//	}
//	return reg_name;
//}

// Returns the xmm register number referenced by reg and rex.
static NSUInteger xmm_reg(NSUInteger reg, NSUInteger rex) {
	return (reg + (REX_R(rex) << 3));
}

// Returns the xmm register number referenced by r_m and rex.
static NSUInteger xmm_rm(NSUInteger r_m, NSUInteger rex) {
	return (r_m + (REX_B(rex) << 3));
}

#define NOISY 1
#define NOISY2 1

void assertNumberOfArgs( const struct instable *dp, struct InstrArgStruct *args  ) {
	
	NSUInteger numberOfArgs = args!=NULL ? args->numberOfArgs : 0;
	NSUInteger expectedArgs = dp->class->numberOfArgs;
	if( numberOfArgs!=expectedArgs )
		// [NSException raise:@"Wrong Number of args" format:@"%i, expected %i for %s", numberOfArgs, expectedArgs, dp->name];
		NSLog(@"Wrong Number of args - really have %i, expected %i for %s", (int)numberOfArgs, (int)expectedArgs, dp->name);
}

//struct instable *customInstruction( const char *instrName, const char *prettyStr ) {
//	
//	struct instable *customInstruction = calloc(1, sizeof(struct instable));
//	strcpy( customInstruction->name, instrName );
//	customInstruction->printStr = calloc(1,strlen(prettyStr)+1);
//	strcpy( customInstruction->printStr, prettyStr );
//	return customInstruction;
//}

@implementation i386_disasm


- (id)initWithChecker:(DisassemblyChecker *)dc {
	
	self = [super init];
	if(self){
		_disChecker = [dc retain];
	}
	return self;
}

- (void)dealloc {
	[_disChecker release];
	[super dealloc];
}

- (void)addLine:(char *)memAddress
:(struct hooleyFuction **)currentFuncPtr
:(const struct instable *)dp
:(struct InstrArgStruct *)args
:(int)noisy {
	
	struct hooleyFuction *currentFunc = *currentFuncPtr;
	
	struct hooleyCodeLine *newLine = calloc( 1, sizeof(struct hooleyCodeLine) );
	newLine->address = memAddress;
	newLine->instr = dp;
	newLine->args = args;
	
	//	assertNumberOfArgs( dp, args );
	
	struct hooleyCodeLine *currentLine = currentFunc->lastLine;
	if(currentLine) {
		// append this new line
		newLine->prev = currentLine;
		currentLine->next = newLine;
	} else {
		// new line is the only line at the moment
		currentFunc->firstLine = newLine;
	}
	currentFunc->lastLine = newLine;
	
	//	verify address
	[_disChecker assertNextAdress:memAddress];
	
	// lets try to add Labels
	if( dp && (dp->typeBitField==ISBRANCH || dp->typeBitField==ISJUMP) ) {
		struct label *newLabel = calloc( 1, sizeof(struct label) );
		
		//TODO: replace the argument with the label
		
		if(currentFunc->labels){
			newLabel->prev = currentFunc->labels;
			currentFunc->labels->next = newLabel;
			currentFunc->labels = newLabel;
		} else {
			currentFunc->labels = newLabel;
		}
	}
	
	if(noisy)
	{
		char lineToPrint[256];
		sprintf( lineToPrint, "%p\t%s ", memAddress, (dp ? dp->name : "Null") );
		
		// lets just take a peep at the arguments
		if (args) {
			
			for( NSUInteger i=0; i<args->numberOfArgs; i++ ){
				struct InstrArgStruct argi = args[i];
				struct HooAbstractDataType *abstractArgi = argi.value;
				
				char *segReg;
				char *baseReg;
				char *indexReg;
				struct HooReg *regArg;
				struct ImediateValue *immedArg;
				struct IndirectVal *indirectArg;
				struct DisplacementValue *displaceArg;
				
				switch(abstractArgi->isah) {
					case REGISTER_ARG:
						regArg = (struct HooReg *)abstractArgi;
						sprintf( lineToPrint+strlen(lineToPrint), " %s", regArg->prettyName );
						break;
					case IMMEDIATE_ARG:
						immedArg = (struct ImediateValue *)abstractArgi;
						sprintf( lineToPrint+strlen(lineToPrint), " %0qx", immedArg->value );
						break;
					case INDIRECT_ARG:
						indirectArg = (struct IndirectVal *)abstractArgi;
						segReg = indirectArg->segmentRegister ? (char *)indirectArg->segmentRegister->prettyName : (char *)"_";
						char const *baseReg = indirectArg->baseRegister ? indirectArg->baseRegister->prettyName : "";
						char const *indexReg = indirectArg->indexRegister ? indirectArg->indexRegister->prettyName : "_";
						sprintf( lineToPrint+strlen(lineToPrint), " %s:%qi(%s,%s,%qi)", segReg, (uint64)indirectArg->displacement, baseReg, indexReg, (uint64)indirectArg->scale );
						break;
					case DISPLACEMENT_ARG:
						displaceArg = (struct DisplacementValue *)abstractArgi;
						sprintf( lineToPrint+strlen(lineToPrint), " %0qx", displaceArg->value );
						break;			
					default:
						NSLog(@"Unknown HooAbstractDataType");
						break;
				}
			}
		}
		printf( "%s\n", lineToPrint );
	}
}

/*
  * i386_disassemble()
 */
- (NSUInteger)i386_disassemble
:(struct hooleyFuction **)currentFuncPtr
:(char *)sect
:(uint64)left
:(char *)addr
:(char *)sect_addr
//enum byte_sex object_byte_sex,
:(struct relocation_info *)sorted_relocs
:(NSUInteger)nsorted_relocs
:(struct nlist *)symbols
:(struct nlist_64 *)symbols64
:(NSUInteger)nsymbols
:(struct symbol *)sorted_symbols
:(NSUInteger)nsorted_symbols
:(char *)strings
:(NSUInteger)strings_size
:(uint32_t *)indirect_symbols
:(NSUInteger)nindirect_symbols
:(cpu_type_t)cputype
:(struct load_command *)load_commands
:(NSUInteger)ncmds
:(NSUInteger)sizeofcmds
:(NSUInteger)verbose
:(NSUInteger)iterationCounter
{
    char mnemonic[MAX_MNEMONIC+2]; /* one extra for suffix */
//    const char *seg = "";
	struct HooReg *segReg = NULL;

    const char *symbol0=NULL, *symbol1=NULL;
    const char *symadd0=NULL, *symsub0=NULL, *symadd1=NULL, *symsub1=NULL;
    uint64_t value0=0, value1=0;
    uint64_t imm0=0, imm1=0;
    NSUInteger value0_size=0, value1_size=0;
	
    char result0[MAX_RESULT], result1[MAX_RESULT];

	const char *indirect_symbol_name=NULL;

    NSUInteger i=0, length=0;
    unsigned char byte=0;
    unsigned char opcode_suffix=0;
    /* nibbles (4 bits) of the opcode */
    uint32_t opcode1=0, opcode2=0, opcode3=0, opcode4=0, opcode5=0, prefix_byte=0;
    const struct instable *dp=NULL, *prefix_dp=NULL;
    NSUInteger wbit=0, vbit=0;
    int got_modrm_byte=0;
    uint32_t mode=0, reg=0, r_m=0;
    const char *reg_name = NULL;
    NSUInteger data16=FALSE;		/* 16- or 32-bit data */
    NSUInteger addr16=FALSE;		/* 16- or 32-bit addressing */
    NSUInteger sse2=FALSE;		/* sse2 instruction using xmmreg's */
    NSUInteger mmx=FALSE;		/* mmx instruction using mmreg's */
    unsigned char rex=0, rex_save=0;/* x86-64 REX prefix */
	
	const struct HooReg *reg_struct=NULL;

	if(left == 0){
	   printf("(end of section)\n");
	   return(0);
	}

	memset(mnemonic, '\0', sizeof(mnemonic));
	memset(result0, '\0', sizeof(result0));
	memset(result1, '\0', sizeof(result1));
	
	/*
	 * As long as there is a prefix, the default segment register,
	 * addressing-mode, or data-mode in the instruction will be overridden.
	 * This may be more general than the chip actually is.
	 */
	prefix_dp = NULL;
	prefix_byte = 0;
	for(;;)
	{
	    byte = get_value( 1, sect, &length, &left);	// 0x14adc272, 0, 0xb9bb8b	=== //0xff 
	    opcode1 = byte >> 4 & 0xf;									//0xf
	    opcode2 = byte & 0xf;										//0xf

	    dp = distable[opcode1][opcode2];
	    if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64 && dp->arch64 != NULL){
			dp = dp->arch64;
		}
	    if(dp->adr_mode == PREFIX){
			if( prefix_dp!=NULL )
				printf("%s", dp->name);
			prefix_dp = dp;
			prefix_byte = byte;
	    } else if(dp->adr_mode == AM){
			addr16 = !addr16;
			prefix_byte = byte;
	    } else if(dp->adr_mode == DM){
			data16 = !data16;
			prefix_byte = byte;
	    } else if(dp->adr_mode == OVERRIDE){
			char *segRegName = (char *)dp->name;
			// seg = dp->name; // %cs
			segReg = (struct HooReg *)segRegPtrForName(segRegName);
			prefix_byte = byte;
	    } else if(dp->adr_mode == REX){
			rex = byte;
			/*
			 * REX is a prefix, but we don't set prefix_byte here because
			 * we use that to detect things related to the other prefixes
			 * and we don't want the existence of those bytes to be hidden
			 * by the presence of a REX prefix.
			 */
	    } else {
			break;
		}
	}

	got_modrm_byte = FALSE;

	/*
	 * Some 386 instructions have 2 bytes of opcode before the mod_r/m
	 * byte so we need to perform a table indirection.
	 */
	if( dp->indirect==(void *)op0F )
	{
	    byte = get_value( 1, sect, &length, &left);
	    opcode4 = byte >> 4 & 0xf;
	    opcode5 = byte & 0xf;
	    dp = op0F[opcode4][opcode5];
	    if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64 && dp->arch64 != NULL) {
			dp = dp->arch64;
		}
	    if( (char *)(dp->indirect)==(char *)op0F38 || (char *)(dp->indirect)==(char *)op0F3A )
		{
			/*
			* MNI instructions are SSE2ish instructions with an
			* extra byte.  Do the extra indirection here.
			*/
			byte = get_value( 1, sect, &length, &left);
			struct instable *(*instrTable) = (void *)dp->indirect;
			dp = instrTable[byte];
	    }
	    /*
	     * SSE and SSE2 instructions have 3 bytes of opcode and the
	     * "third opcode byte" is before the other two (where the prefix
	     * byte would be).  This is why the prefix byte is saved above and
	     * the printing of the last prefix is delayed.
	     */
	    if(dp->adr_mode == SSE2 ||
	       dp->adr_mode == SSE2i ||
	       dp->adr_mode == SSE2i1 ||
	       dp->adr_mode == SSE2tm ||
	       dp->adr_mode == SSE2tfm ||
	       dp->adr_mode == SSE4 ||
	       dp->adr_mode == SSE4i ||
	       dp->adr_mode == SSE4MRw ||
	       dp->adr_mode == SSE4CRC ||
	       dp->adr_mode == SSE4CRCb ||
	       (byte == 0xc7 && prefix_byte == 0xf3)){ /* for vmxon */
			prefix_dp = NULL;
	    } else {

			/*
			 * 3DNow! instructions have 2 bytes of opcode followed by their
			 * operands and then an instruction-specific suffix byte.
			 */
			if( dp->indirect==(void *)op0F0F )
			{
				data16 = FALSE;
				mmx = TRUE;
				if(got_modrm_byte == FALSE){
					got_modrm_byte = TRUE;
					byte = get_value( 1, sect, &length, &left);
					modrm_byte( &mode, &reg, &r_m, byte );
				}
				// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//HERE! what the fuck?				
				NSUInteger temp = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
				struct HooAbstractDataType * abstractStrctPtr1 = (struct HooAbstractDataType *)temp;
				opcode_suffix = get_value( 1, sect, &length, &left );
				int tag1 = opcode_suffix >> 4;
				int tag2 = opcode_suffix & 0x0F;
		//here		dp = &op0F0F[tag1][tag2];
				
				dp = (void *)op0F0F[tag1][tag2];
//here				printf("i did know what i was doing %s", test->name );

			} else if( dp->indirect==(void *)op0F01 ) {

			    if(got_modrm_byte == FALSE){
					got_modrm_byte = TRUE;
					byte = get_value( 1, sect, &length, &left);
					modrm_byte(&mode, &reg, &r_m, byte);
					opcode3 = reg;
			    }
				if(byte == 0xc8){
					hooleyDebug();
	//NEVER				data16 = FALSE;
	//NEVER				mmx = TRUE;
	//NEVER				dp = &op_monitor;
				} else if(byte == 0xc9){
					hooleyDebug();
	//NEVER				data16 = FALSE;
	//NEVER				mmx = TRUE;
	//NEVER				dp = &op_mwait;
				}
				if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
					hooleyDebug();
	//NEVER				if(opcode3 == 0x7 && got_modrm_byte && mode == REG_ONLY && r_m == 0) {
	//NEVER					hooleyDebug();
	//NEVER					dp = &op_swapgs;
	//NEVER				}
				}
			} else {

				/*
				 * Since the opcode is not an SSE or SSE2 instruction that
				 * uses the prefix byte as the "third opcode byte" print the
				 * delayed last prefix if any.
				 */
				if(prefix_dp != NULL) {
					// here! dont ignore this
					// printf("%s", prefix_dp->name);
				}
			}
		}
	} else {

	    /*
	     * The "pause" Spin Loop Hint instruction is a "repz" prefix
	     * followed by a nop (0x90).
	     */
	    if(prefix_dp != NULL && prefix_byte == 0xf3 && opcode1 == 0x9 && opcode2 == 0x0){
			hooleyDebug();
//NEVER			printf("pause\n");
//NEVER			return(length);
	    }
	    /*
	     * Since the opcode is not an SSE or SSE2 instruction print the
	     * delayed last prefix if any.
	     */
	    if(prefix_dp != NULL)
		{
			/*
			 * If the prefix is "repz" and the instruction is ins, outs,
			 * movs, lods, or stos then the name used is "rep".
			 */
			if(strcmp(prefix_dp->name, "repz/") == 0 &&
			   (byte == 0x6c || byte == 0x6d || /* ins */
				byte == 0x6e || byte == 0x6f || /* outs */
				byte == 0xa4 || byte == 0xa5 || /* movs */
				byte == 0xac || byte == 0xad || /* lods */
				byte == 0xaa || byte == 0xab))  /* stos */
			{
				// printf("rep/");
				NSLog(@"TODO: add rep/");
			} else {
				// Repz = repeat while count is not equal
				// TODO: I really need to expand this shit
				// printf("%s", prefix_dp->name);
			}
	    }
	}

	if( dp->indirect!=TERM ){

	    /*
	     * This must have been an opcode for which several instructions
	     * exist. The opcode3 field further decodes the instruction.
	     */
	    if(got_modrm_byte == FALSE){
			got_modrm_byte = TRUE;
			byte = get_value( 1, sect, &length, &left);
			modrm_byte( &mode, &opcode3, &r_m, byte );
	    }
	    /*
	     * decode 287 instructions (D8-DF) from opcodeN
	     */
	    if(opcode1 == 0xD && opcode2 >= 0x8)
		{
			/* instruction form 5 */
			if(opcode2 == 0xB && mode == 0x3 && opcode3 == 4) {
				hooleyDebug();
//NEVER				dp = &opFP5[r_m];
			} else if(opcode2 == 0xB && mode == 0x3 && opcode3 > 6){
				// printf(".byte 0x%01x%01x, 0x%01x%01x 0x%02x #bad opcode\n", (unsigned int)opcode1, (unsigned int)opcode2, (unsigned int)opcode4, (unsigned int)opcode5, (unsigned int)byte);
				return length;
			}
			/* instruction form 4 */
			else if(opcode2 == 0x9 && mode == 0x3 && opcode3 >= 4) {
				dp = opFP4[opcode3-4][r_m];
			/* instruction form 3 */
			} else if(mode == 0x3) {
				dp = opFP3[opcode2-8][opcode3];
			} else { /* instruction form 1 and 2 */
				dp = opFP1n2[opcode2-8][opcode3];
			}
	    } else {
			struct instable *(*instrTable) = (void *)dp->indirect;
			// dp = dp->indirect + opcode3;
			dp = instrTable[opcode3];
		}
		/* now dp points the proper subdecode table entry */
	}

	if( dp->indirect!=TERM ){
	    // printf(".byte 0x%02x #bad opcode\n", (unsigned int)byte);
		/* add a bad opcode line ?*/
	    return length ;
	}

	/*
	 * Some addressing modes are implicitly 64-bit.  Set REX.W for those
	 * so we don't have to change the logic for them later.
	 */
	if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
	    if((dp->flags & IS_POINTER_SIZED) != 0){
			rex |= 0x8;	/* Set REX.W if it isn't already set */
	    }
	}

	/* setup the mnemonic with a possible suffix */
	if( dp->adr_mode != CBW && dp->adr_mode != CWD ){

	    if( (dp->flags & HAS_SUFFIX) !=0 )
		{
			if(data16 == TRUE)
			{
				// sprintf(mnemonic, "%sw", dp->name);
			} else {
				if(dp->adr_mode == Mnol || dp->adr_mode == INM)
				{
					// sprintf(mnemonic, "%s", dp->name);
				} else if(REX_W(rex) != 0){
					// sprintf(mnemonic, "%sq", dp->name);
				} else {
					// sprintf(mnemonic, "%sl", dp->name);
				}
			}
	    } else {
			// sprintf(mnemonic, "%s", dp->name);
	    }
	    if(dp->adr_mode == BD)
		{
			// gohere
			if(segReg){
				if(strcmp(segReg->name, "%cs:") == 0){
					hooleyDebug();
	//NEVER				sprintf(mnemonic, "%s,pn", mnemonic);
	//NEVER				seg = "";
						
				} else if(strcmp(segReg->name, "%ds:") == 0){
					hooleyDebug();
	//NEVER				sprintf(mnemonic, "%s,pt", mnemonic);
	//NEVER				seg = "";
				}
			}
	    }
	}

	// Argument holders that i cant put in the switch
	char operandString1[256];
	char operandString2[256];
	struct HooAbstractDataType *abstractStrctPtr1;
	struct InstrArgStruct *allArgs;
	struct ImediateValue *value0Immed, *value1Immed;
	struct DisplacementValue *displaceStructPtr;
	NSUInteger regNum;
	
	/*
	 * Each instruction has a particular instruction syntax format
	 * stored in the disassembly tables.  The assignment of formats
	 * to instructions was made by the author.  Individual formats
	 * are explained as they are encountered in the following
	 * switch construct.
	 */
	switch( dp->adr_mode )
	{
		case BSWAP:
			reg_struct = get_regStruct((opcode5 & 0x7), 1, data16, rex);
			// eg bswap	%eax
			FILLARGS1( reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return length;

		case XINST:
			wbit = WBIT(opcode5);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			uint64 temp = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)temp;
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// printf("%s\t%s,", mnemonic, reg_name);
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			FILLARGS2( reg_struct, abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return length;

		/* movsbl movsbw (0x0FBE) or movswl (0x0FBF) */
		/* movzbl movzbw (0x0FB6) or mobzwl (0x0FB7) */
		/* wbit lives in 2nd byte, note that operands are different sized */
		case MOVZ:
		{
			/* Get second operand first so data16 can be destroyed */
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			reg_struct = get_regStruct(reg, LONGOPERAND, data16, rex);
			wbit = WBIT(opcode5);
			data16 = 1;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// eg movzbl	(%edx),%eax	
			FILLARGS2( abstractStrctPtr1, reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return length;
		}

		/* imul instruction, with either 8-bit or longer immediate */
		case IMUL:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;

			/* opcode 0x6B for byte, sign-extended displacement, 0x69 for word(s) */
			value0_size = OPSIZE(data16, opcode2==0x9, 0);
			REPLACEMENT_IMMEDIATE( &symadd0, &symsub0, &imm0, value0_size );			
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// eg imull $0x44,%edx,%eax
			FILLARGS3( value0Immed, abstractStrctPtr1, reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY2]; 
			return length;
		}

		/* memory or register operand to register, with 'w' bit	*/
		case MRw:
		case SSE4MRw:
		{
			wbit = WBIT(opcode2);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// eg. movl 0x04(%ebp),%ebx
			FILLARGS2( abstractStrctPtr1,reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return length;
		}

		/* register to memory or register operand, with 'w' bit	*/
		/* arpl happens to fit here also because it is odd */
		case RMw:
		{
			wbit = WBIT(opcode2);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, &result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			
			// TODO:
			// -- woah dude, woah. This returns (%rip) in result and 0x1848 in value0
			// -- and print_operand is supposed to put them together - i think i broke that.
			
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			
			 // -- move register to oprand eg. movl	%esp,%ebp		movl %ebx,0x00(%esp)
			FILLARGS2( reg_struct, abstractStrctPtr1 );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* SSE2 instructions with further prefix decoding dest to memory or memory to dest depending on the opcode */
		case SSE2tfm:
		{
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			struct ArgStack aStack;
			argStack_Init( &aStack );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x7e: /* movq & movd */
				{
					if(prefix_byte == 0x66){
						/* movd from xmm to r/m32 */
						regNum = xmm_reg(reg, rex);
						reg_struct = xmmReg_Struct[regNum];
						argStack_Push( &aStack, (int64_t)reg_struct );
						// printf("%sd\t%%xmm%u,", mnemonic, reg_struct);
						wbit = LONGOPERAND;
						NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
						abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
						argStack_Push( &aStack, (int64_t)abstractStrctPtr1 );

					} else if(prefix_byte == 0xf0){
						hooleyDebug();
//NEVER						/* movq from mm to mm/m64 */
//NEVER						printf("%sd\t%%mm%u,", mnemonic, reg);
						const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER						mmx = TRUE;
//NEVER						GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
//NEVER						print_operand(seg, symadd1, symsub1, value1, value1_size, result1, "\n");

					} else if(prefix_byte == 0xf3){
						hooleyDebug();
//NEVER						/* movq from xmm2/mem64 to xmm1 */
//NEVER						printf("%sq\t", mnemonic);
//NEVER						sse2 = TRUE;
//NEVER						GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER						print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER						printf("%%xmm%u\n", xmm_reg(reg, rex));

					} else { /* no prefix_byte */
						hooleyDebug();
//NEVER						/* movd from mm to r/m32 */
//NEVER						printf("%sd\t%%mm%u,", mnemonic, reg);
						const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER						wbit = LONGOPERAND;
//NEVER						GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
//NEVER						print_operand(seg, symadd1, symsub1, value1, value1_size, result1, "\n");
					}
				}
			}
			
			if(aStack.size==2){
				FILLARGS2( aStack.data[0], aStack.data[1] );
			} else {
				[NSException raise:@"what?" format:@"what?"];
			}
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return length;
		}

		/* SSE2 instructions with further prefix decoding dest to memory */
		case SSE2tm:
		{
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			regNum = xmm_reg(reg, rex);
			reg_struct = xmmReg_Struct[regNum]; //%xmm0
			// sprintf(result0, "%%xmm%u", );
			switch(opcode4 << 4 | opcode5)
			{
				case 0x11: /* movupd &  movups */
				   /*   movsd & movss */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						printf("%supd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
//						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3) {
//						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */ {
//						printf("%sups\t", mnemonic);
					}
					break;

				case 0x13: /* movlpd & movlps */
				case 0x17: /* movhpd & movhps */
				case 0x29: /* movapd & movasd */
				case 0x2b: /* movntpd & movntsd */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
//						printf("%spd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
//						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
//						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
//						printf("%sps\t", mnemonic);
					}
					break;
				case 0xd6: /* movq */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%sq\t", mnemonic);
//NEVER
//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						printf("%sdq2q\t", mnemonic);
//NEVER						mmx = TRUE;
//NEVER					}
//NEVER					break;

				case 0x7f: /* movdqa, movdqu, movq */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						// printf("%sdqa\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						hooleyDebug();
						// printf("%sdqu\t", mnemonic);
					} else {
						// sprintf(result0, "%%mm%lu", (unsigned long)reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%sq\t", mnemonic);
						mmx = TRUE;
					}
					break;
		
				case 0xe7: /* movntdq & movntq */
				{
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%stdq\t", mnemonic);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sprintf(result0, "%%mm%u", reg);
					const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER						printf("%stq\t", mnemonic);
//NEVER						mmx = TRUE;
//NEVER					}
//NEVER					break;
				}
			}
			// printf("%s,", result0);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// print_operand(seg, symadd1, symsub1, value1, value1_size, result1, "\n");

			// eg movsd	%xmm0,0x20(%edx,%ecx)
			FILLARGS2( reg_struct, abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* MNI instructions */
		case MNI:
		{
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			if(prefix_byte == 0x66){
				sse2 = TRUE;
				// sprintf(result1, "%%xmm%u", xmm_reg(reg, rex));
				regNum = xmm_reg(reg, rex);
				reg_struct = xmmReg_Struct[regNum];

			} else { /* no prefix byte */
				mmx = TRUE;
				// sprintf(result1, "%%mm%u", reg);
				reg_struct = mmReg_Struct[reg];

			}
			// printf("%s\t", mnemonic);
			// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// printf("%s\n", result1);
			FILLARGS2( abstractStrctPtr1, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];				
			return length;
		}
	
		/* MNI instructions with 8-bit immediate */
		case MNIi:
		{
			hooleyDebug();
//NEVER			data16 = FALSE;
//NEVER			if (got_modrm_byte == FALSE) {
//NEVER				hooleyDebug();
//NEVER				got_modrm_byte = TRUE;
//NEVER				byte = get_value( 1, sect, &length, &left);
//NEVER				modrm_byte(&mode, &reg, &r_m, byte);
//NEVER			}
//NEVER			if(prefix_byte == 0x66){
//NEVER				hooleyDebug();
//NEVER				sse2 = TRUE;
//NEVER				sprintf(result1, "%%xmm%u", xmm_reg(reg, rex));
//NEVER			} else { /* no prefix byte */
//NEVER				hooleyDebug();
//NEVER				mmx = TRUE;
//NEVER				sprintf(result1, "%%mm%u", reg);
			const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER			}
//NEVER			GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER			byte = get_value( 1, sect, &length, &left);
//NEVER			printf("%s\t$0x%x,", mnemonic, byte);
//NEVER
//NEVER			print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER			printf("%s\n", result1);
//NEVER			return length;
		}

		/* SSE2 instructions with further prefix decoding */
		case SSE2:
		{
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			// eg // %xmm0
			regNum = xmm_reg(reg, rex);
			reg_struct = xmmReg_Struct[regNum];
			// sprintf(result1, "%%xmm%u", regNum2 );
			
			switch(opcode4 << 4 | opcode5)
			{
				case 0x14: /* unpcklpd & unpcklps */
				case 0x15: /* unpckhpd & unpckhps */
				case 0x28: /* movapd & movasd */
				case 0x51: /* sqrtpd, sqrtsd, sqrtss &  sqrtps */
				case 0x52: /* rsqrtss & rsqrtps */
				case 0x53: /* rcpss & rcpps */
				case 0x54: /* andpd & andsd */
				case 0x55: /* andnpd & andnsd */
				case 0x56: /* orpd & orps */
				case 0x57: /* xorpd & xorps */
				case 0x58: /* addpd & addsd */
				case 0x59: /* mulpd, mulsd, mulss & mulps */
				case 0x5c: /* subpd, subsd, subss & subps */
				case 0x5d: /* minpd, minsd, minss & minps */
				case 0x5e: /* divpd, divsd, divss & divps */
				case 0x5f: /* maxpd, maxsd, maxss & maxps */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
//						printf("%spd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
//						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
//						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
//						printf("%sps\t", mnemonic);
					}
					break;
				case 0x12: /*   movlpd, movlps & movhlps */
					hooleyDebug();
//NEVER					sse2 = TRUE;
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%slpd\t", mnemonic);
//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						printf("movddup\t");
//NEVER					} else if(prefix_byte == 0xf3){
//NEVER						hooleyDebug();
//NEVER						printf("%movsldup\t");
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						if(mode == REG_ONLY){
//NEVER							hooleyDebug();
//NEVER							printf("%shlps\t", mnemonic);
//NEVER						} else {
//NEVER							hooleyDebug();
//NEVER							printf("%slps\t", mnemonic);
//NEVER						}
//NEVER					}
//NEVER					break;
				case 0x16: /* movhpd, movhps & movlhps */
					hooleyDebug();
//NEVER					sse2 = TRUE;
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%shpd\t", mnemonic);
//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						printf("%shsd\t", mnemonic);
//NEVER					} else if(prefix_byte == 0xf3){
//NEVER						hooleyDebug();
//NEVER						printf("movshdup\t");
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						if(mode == REG_ONLY){
//NEVER							hooleyDebug();
//NEVER							printf("%slhps\t", mnemonic);
//NEVER						} else {
//NEVER							hooleyDebug();
//NEVER							printf("%shps\t", mnemonic);
//NEVER						}
//NEVER					}
//NEVER					break;
				case 0x50: /* movmskpd &  movmskps */
					hooleyDebug();
//NEVER					sse2 = TRUE;
//NEVER					reg_name = get_reg_name(reg, 1, data16, rex);
					reg_struct = get_regStruct(reg, wbit, data16, rex);

//NEVER					strcpy(result1, reg_name);
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%spd\t", mnemonic);
//NEVER					} else /* no prefix_byte */{
//NEVER						hooleyDebug();
//NEVER						printf("%sps\t", mnemonic);
//NEVER					}
//NEVER					break;
				case 0x10: /*  movupd &   movups */
				   /*      movsd & movss */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						// printf("%supd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						// printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						// printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
						// printf("%sups\t", mnemonic);
					}
					break;
				case 0x2a: /* cvtpi2pd, cvtsi2sd, cvtsi2ss & cvtpi2ps */
					if(prefix_byte == 0x66){
						mmx = TRUE;
						// printf("%spi2pd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						wbit = LONGOPERAND;
						// printf("%ssi2sd\t", mnemonic);
						// -- this is a suffix --
						
					} else if(prefix_byte == 0xf3){
						wbit = LONGOPERAND;
						// printf("%ssi2ss\t", mnemonic);
					} else { /* no prefix_byte */
						mmx = TRUE;
						// printf("%spi2ps\t", mnemonic);
					}
					break;
				case 0x2c: /* cvttpd2pi, cvttsd2si, cvttss2si & cvttps2pi */
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%stpd2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
						const struct HooReg *mmReg = mmReg_Struct[reg];

					} else if(prefix_byte==0xf2){
						sse2 = TRUE;
						// printf("%stsd2si\t", mnemonic);
						// These appear to overwrite reg_strct - presume that that is correct						
						reg_struct = get_regStruct(reg, 1, data16, rex);
						// strcpy(result1, reg_name);
			
					} else if( prefix_byte==0xf3 ){
						sse2 = TRUE;
						// printf("%stss2si\t", mnemonic);
						// These appear to overwrite reg_strct - presume that that is correct
						reg_struct = get_regStruct(reg, 1, data16, rex);
						// strcpy(result1, reg_name);
						
					} else { /* no prefix_byte */
						sse2 = TRUE;
						// printf("%stps2pi\t", mnemonic);
						// sprintf(result1, "%%mm%u", reg);
						reg_struct = mmReg_Struct[reg];
					}
					break;

				case 0x2d: /* cvtpd2pi, cvtsd2si, cvtss2si & cvtps2pi */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%spd2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
					const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%ssd2si\t", mnemonic);
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
					reg_struct = get_regStruct(reg, wbit, data16, rex);

//NEVER						strcpy(result1, reg_name);
//NEVER					} else if(prefix_byte == 0xf3){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%sss2si\t", mnemonic);
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
					reg_struct = get_regStruct(reg, wbit, data16, rex);

//NEVER						strcpy(result1, reg_name);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%sps2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
					const struct HooReg *mmReg2 = mmReg_Struct[reg];

//NEVER					}
//NEVER					break;
				case 0x2e: /* ucomisd & ucomiss */
				case 0x2f: /*  comisd &  comiss */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
//						printf("%ssd\t", mnemonic);
					} else /* no prefix_byte */{
//						printf("%sss\t", mnemonic);
					}
					break;
				case 0xe0: /* pavgb */
				case 0xe3: /* pavgw */
					if(prefix_byte == 0x66){
						sse2 = TRUE;
						// printf("%s\t", mnemonic);
					} else { /* no prefix_byte */
						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
						const struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER						printf("%s\t", mnemonic);
//NEVER						mmx = TRUE;
					}
					break;
					
				case 0xe6: /* cvttpd2dq, cvtdq2pd & cvtpd2dq */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						// printf("%stpd2dq\t", mnemonic);
					}
					if(prefix_byte == 0xf3){
						// printf("%sdq2pd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						// printf("%spd2dq\t", mnemonic);
					}
					break;

				case 0x5a: /* cvtpd2ps, cvtsd2ss, cvtss2sd & cvtps2pd */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
//						printf("%spd2ps\t", mnemonic);
					} else if(prefix_byte == 0xf2){
//						printf("%ssd2ss\t", mnemonic);
					} else if(prefix_byte == 0xf3){
//						printf("%sss2sd\t", mnemonic);
					} else /* no prefix_byte */ {
//						printf("%sps2pd\t", mnemonic);
					}
					break;
					
				case 0x5b: /* cvtdq2ps, cvttps2dq & cvtps2dq */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						// printf("%sps2dq\t", mnemonic);
					} else if(prefix_byte == 0xf3){
//						printf("%stps2dq\t", mnemonic);
					} else /* no prefix_byte */{
						// printf("%sdq2ps\t", mnemonic);
					}
					break;
				case 0x60: /* punpcklbw */
				case 0x61: /* punpcklwd */
				case 0x62: /* punpckldq */
				case 0x63: /* packsswb */
				case 0x64: /* pcmpgtb */
				case 0x65: /* pcmpgtw */
				case 0x66: /* pcmpgtd */
				case 0x67: /* packuswb */
				case 0x68: /* punpckhbw */
				case 0x69: /* punpckhwd */
				case 0x6a: /* punpckhdq */
				case 0x6b: /* packssdw */
				case 0x74: /* pcmpeqb */
				case 0x75: /* pcmpeqw */
				case 0x76: /* pcmpeqd */
				case 0xd1: /* psrlw */
				case 0xd2: /* psrld */
				case 0xd3: /* psrlq */
				case 0xd4: /* paddq */
				case 0xd5: /* pmullw */
				case 0xd8: /* psubusb */
				case 0xd9: /* psubusw */
				case 0xdb: /* pand */
				case 0xdc: /* paddusb */
				case 0xdd: /* paddusw */
				case 0xdf: /* pandn */
				case 0xe1: /* psraw */
				case 0xe2: /* psrad */
				case 0xe5: /* pmulhw */
				case 0xe8: /* psubsb */
				case 0xe9: /* psubsw */
				case 0xeb: /* por */
				case 0xec: /* paddsb */
				case 0xed: /* paddsw */
				case 0xef: /* pxor */
				case 0xf1: /* psllw */
				case 0xf2: /* pslld */
				case 0xf3: /* psllq */
				case 0xf5: /* pmaddwd */
				case 0xf8: /* psubb */
				case 0xf9: /* psubw */
				case 0xfa: /* psubd */
				case 0xfb: /* psubq */
				case 0xfc: /* paddb */
				case 0xfd: /* paddw */
				case 0xfe: /* paddd */
					if(prefix_byte == 0x66){
						// printf("%s\t", mnemonic);
						sse2 = TRUE;
					} else { /* no prefix_byte */
						// sprintf(result1, "%%mm%lu", (unsigned long)reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%s\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0x6c: /* punpcklqdq */
				case 0x6d: /* punpckhqdq */
					sse2 = TRUE;
					if(prefix_byte == 0x66) {
//						printf("%sqdq\t", mnemonic);
					}
					break;
				case 0x6f: /* movdqa, movdqu & movq */
					if(prefix_byte == 0x66){
						sse2 = TRUE;
//						printf("%sdqa\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						sse2 = TRUE;
//						printf("%sdqu\t", mnemonic);
					} else { /* no prefix_byte */
						// sprintf(result1, "%%mm%lu", (unsigned long)reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%sq\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0xd6: /* movdq2q & movq2dq */
					if(prefix_byte == 0xf2){
						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
						reg_struct = mmReg_Struct[reg];

//NEVER						printf("%sdq2q\t", mnemonic);
//NEVER						sse2 = TRUE;
					} else if(prefix_byte == 0xf3){
						hooleyDebug();
//NEVER						printf("%sq2dq\t", mnemonic);
//NEVER						mmx = TRUE;
					}
					break;
				case 0x6e: /* movd */
					if(prefix_byte == 0x66){
//						printf("%s\t", mnemonic);
						wbit = LONGOPERAND;
					} else { /* no prefix_byte */
						// sprintf(result1, "%%mm%lu", (unsigned long)reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%s\t", mnemonic);
						wbit = LONGOPERAND;
					}
					break;
				case 0xd0: /* addsubpd */
				case 0x7c: /* haddp */
				case 0x7d: /* hsubp */
					if(prefix_byte == 0x66){
						// printf("%sd\t", mnemonic);
						sse2 = TRUE;
					} else if(prefix_byte == 0xf2){
						// printf("%ss\t", mnemonic);
						sse2 = TRUE;
					} else { /* no prefix_byte */
						// sprintf(result1, "%%mm%lu", reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%s\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0xd7: /* pmovmskb */
				{
					if(prefix_byte == 0x66){
						reg_struct = get_regStruct(reg, 1, data16, rex);
						NSUInteger regNum = xmm_rm(r_m, rex);
						const struct HooReg *reg_struct2 = xmmReg_Struct[regNum]; //%xmm0
						FILLARGS2( reg_struct2, reg_struct );
						[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
						// printf("%s\t%%xmm%u,%s\n", mnemonic, reg_struct2, reg_name);
						return length;
						
					} else { /* no prefix_byte */
						reg_struct = get_regStruct(reg, 1, data16, rex);
						const struct HooReg *mmReg = mmReg_Struct[r_m];
						FILLARGS2( mmReg, reg_struct );
						[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
						// printf("%s\t%%mm%u,%s\n", mnemonic, mmReg, reg_name);
						return length;
					}
					break;
				}
				case 0xda: /* pminub */
				case 0xde: /* pmaxub */
				case 0xe4: /* pmulhuw */
				case 0xea: /* pminsw */
				case 0xee: /* pmaxsw */
				case 0xf4: /* pmuludq */
				case 0xf6: /* psadbw */
				{
					if(prefix_byte == 0x66){
						sse2 = TRUE;
						// printf("%s\t", mnemonic);
					} else { /* no prefix_byte */
						// sprintf(result1, "%%mm%u", reg);
						reg_struct = mmReg_Struct[reg];
						// printf("%s\t", mnemonic);
						mmx = TRUE;
					}
					break;
				}
				case 0xf0: /* lddqu */
					hooleyDebug();
//NEVER					printf("%s\t", mnemonic);
//NEVER					sse2 = TRUE;
					break;
				case 0xf7: /* maskmovdqu & maskmovq */
				{
					hooleyDebug();
//NEVER					sse2 = TRUE;
//NEVER					if(prefix_byte == 0x66) {
//NEVER						hooleyDebug();
//NEVER						printf("%sdqu\t", mnemonic);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						printf("%sq\t%%mm%u,%%mm%u\n", mnemonic, r_m, reg);
					const struct HooReg *mmReg2 = mmReg_Struct[reg];

//NEVER						return(length);
//NEVER					}
					break;
				}
		
			} // end switch
			
			/* woah - so that was pretty complicated, huh? This needs some checking. Perhaps we would be better pushing the arguments onto our arg stack? */
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			
			// -- soo i dont have an operand and i dont have result1 register
			// i have missed the suffix off the operand. eg - i am printing cvttps2d %xmm0,%xmm0 as cvt  %xmm0 %xmm0 -- which doesn't tell you as 
			
			// eg movsd	(%eax),%xmm0
			FILLARGS2( abstractStrctPtr1, reg_struct );
			// printf("%s\n", result1);
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return length;
		}

		/* SSE4 instructions */
		case SSE4:
				hooleyDebug();
//NEVER				sse2 = TRUE;
//NEVER				data16 = FALSE;
//NEVER				wbit = LONGOPERAND;
//NEVER				if(got_modrm_byte == FALSE){
//NEVER					hooleyDebug();
//NEVER					got_modrm_byte = TRUE;
//NEVER					byte = get_value( 1, sect, &length, &left);
//NEVER					modrm_byte(&mode, &reg, &r_m, byte);
//NEVER				}
//NEVER				printf("%s\t", mnemonic);
//NEVER				sprintf(result1, "%%xmm%u", xmm_reg(reg, rex));
//NEVER				GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER				print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER				printf("%s\n", result1);
//NEVER				return(length);

		/* SSE4 instructions with 8 bit immediate */
		case SSE4i:
				hooleyDebug();
//NEVER				sse2 = TRUE;
//NEVER				data16 = FALSE;
//NEVER				wbit = LONGOPERAND;
//NEVER				if(got_modrm_byte == FALSE){
//NEVER					hooleyDebug();
//NEVER					got_modrm_byte = TRUE;
//NEVER					byte = get_value( 1, sect, &length, &left);
//NEVER					modrm_byte(&mode, &reg, &r_m, byte);
//NEVER				}
//NEVER				GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER				byte = get_value( 1, sect, &length, &left);
//NEVER				printf("%s\t$0x%x,", mnemonic, byte);
//NEVER				print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER				printf("%%xmm%u\n", xmm_reg(reg, rex));
//NEVER				return(length);

		/* SSE4 instructions with dest to memory and 8-bit immediate */
		case SSE4itm:
				hooleyDebug();
//NEVER					sse2 = FALSE;
//NEVER					data16 = FALSE;
//NEVER					wbit = LONGOPERAND;
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value( 1, sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					byte = get_value( 1, sect, &length, &left);
//NEVER					if(dp == &op0F3A[0x16])
//NEVER					{
//NEVER						hooleyDebug();
//NEVER						if(rex != 0)
//NEVER						{
//NEVER							hooleyDebug();
//NEVER							printf("%sq\t$0x%x,", mnemonic, byte);
//NEVER						} else {
//NEVER							hooleyDebug();
//NEVER							printf("%sd\t$0x%x,", mnemonic, byte);
//NEVER						}
//NEVER					} else {
//NEVER						hooleyDebug();
//NEVER						printf("%s\t$0x%x,", mnemonic, byte);
//NEVER					}
//NEVER					printf("%%xmm%u,", xmm_reg(reg, rex));
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
//NEVER					return(length);

		/* SSE4 instructions with src from memory and 8-bit immediate */
		case SSE4ifm:
				hooleyDebug();

//NEVER					sse2 = FALSE;
//NEVER					data16 = FALSE;
//NEVER					wbit = LONGOPERAND;
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value( 1, sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					byte = get_value( 1, sect, &length, &left);
//NEVER					if(dp == &op0F3A[0x22]){
//NEVER						hooleyDebug();
//NEVER						if(rex != 0) {
//NEVER							hooleyDebug();
//NEVER							printf("%sq\t$0x%x,", mnemonic, byte);
//NEVER						} else {
//NEVER							hooleyDebug();
//NEVER							printf("%sd\t$0x%x,", mnemonic, byte);
//NEVER						}
//NEVER					} else {
//NEVER						hooleyDebug();
//NEVER						printf("%s\t$0x%x,", mnemonic, byte);
//NEVER					}
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER					printf("%%xmm%u\n", xmm_reg(reg, rex));
//NEVER					return(length);

		/* SSE4.2 instructions memory or register operand to register */
		case SSE4CRCb:
				hooleyDebug();
//NEVER					wbit = 0;
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value( 1, sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					/*
//NEVER					* This hack is to get the byte register name for SSE4CRCb opcodes
//NEVER					* when get_operand() is called but not when reg_name() is called
//NEVER					* after that.
//NEVER					*/
//NEVER					rex_save = rex;
//NEVER					if(mode == 0x3){
//NEVER						hooleyDebug();
//NEVER						rex = 0;
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					rex = rex_save;
//NEVER					reg_name = get_reg_name(reg, 1 /* wbit */, 0 /* data16 */, rex);
			reg_struct = get_regStruct(reg, 1 /* wbit */, 0 /* data16 */, rex);

//NEVER					printf("%s\t", mnemonic);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER					printf("%s\n", reg_name);
//NEVER					return(length);

		case SSE4CRC:
				hooleyDebug();
//NEVER					wbit = 1;
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value( 1, sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					reg_name = get_reg_name(reg, 1 /* wbit */, 0 /* data16 */, rex);
			reg_struct = get_regStruct(reg, 1 /* wbit */, 0 /* data16 */, rex);

//NEVER					printf("%s\t", mnemonic);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER					printf("%s\n", reg_name);
//NEVER					return(length);

		/* SSE2 instructions with 8 bit immediate with further prefix decoding*/
		case SSE2i:
		{
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			/* pshufw */
			if((opcode4 << 4 | opcode5) == 0x70 && prefix_byte == 0) {
				mmx = TRUE;
			}
			/* pinsrw */
			else if((opcode4 << 4 | opcode5) == 0xc4) {
				wbit = LONGOPERAND;
			} else {
				sse2 = TRUE;
			}
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			byte = get_value( 1, sect, &length, &left);
			NEW_IMMEDIATE( value0Immed, byte );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x70: /* pshufd, pshuflw, pshufhw & pshufw */
					if(prefix_byte == 0x66) {
						// printf("%sfd\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf2) {
						// printf("%sflw\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf3) {
						// printf("%sfhw\t$0x%x,", mnemonic, byte);
					} else { /* no prefix_byte */
						// printf("%sfw\t$0x%x,", mnemonic, byte);
						// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
						// printf("%%mm%u\n", reg);
						FILLARGS3( value0Immed, abstractStrctPtr1, &mmReg_Struct[reg] );
						[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
						return length;
					}
					break;
	
				case 0xc4: /* pinsrw */
					if(prefix_byte == 0x66){
						// printf("%s\t$0x%x,", mnemonic, byte);
					} else { /* no prefix_byte */
						// printf("%s\t$0x%x,", mnemonic, byte);
						// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
						// printf("%%mm%u\n", reg);
						const struct HooReg *mmReg = mmReg_Struct[reg];
						FILLARGS3( value0Immed, abstractStrctPtr1, mmReg );
						[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
						return length;
					}
					break;
				case 0xc5: /* pextrw */
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66){
//NEVER								hooleyDebug();
//NEVER								reg_name = get_reg_name(reg, 1, data16, rex);
					reg_struct = get_regStruct(reg, 1, data16, rex);
					NSUInteger regNum = xmm_rm(r_m, rex);
					const struct HooReg *reg_struct2 = xmmReg_Struct[regNum]; //%xmm0
					
//NEVER								printf("%s\t$0x%x,%%xmm%u,%s\n", mnemonic, byte, reg_struct2, reg_struct);
//NEVER								return(length);
//NEVER							} else { /* no prefix_byte */
//NEVER								hooleyDebug();
//NEVER								reg_name = get_reg_name(reg, 1, data16, rex);
					reg_struct = get_regStruct(reg, 1, data16, rex);

//NEVER								printf("%s\t$0x%x,%%mm%u,%s\n", mnemonic, byte, r_m,reg_name);
				//	struct HooReg *mmReg = mmReg_Struct[reg];

//NEVER								return(length);
//NEVER							}
					break;
				default:
					if(prefix_byte == 0x66) {
						// printf("%spd\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf2) {
						// printf("%ssd\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf3) {
						// printf("%sss\t$0x%x,", mnemonic, byte);
					} else {/* no prefix_byte */
						// printf("%sps\t$0x%x,", mnemonic, byte);
					}
					break;
			}
			
			// TODO: looks like there is a possibility of reg_struct already used by this point 
			// TODO: -- and then here unpack the stack into the arglist?
			
			// eg cmpsd $0x2,%xmm0,%xmm2
			// printf("%%xmm%u\n", xmm_reg(reg, rex));
			
			regNum = xmm_reg(reg, rex);
			reg_struct = xmmReg_Struct[regNum]; //%xmm0
			FILLARGS3( value0Immed, abstractStrctPtr1, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* SSE2 instructions with 8 bit immediate and only 1 reg */
		case SSE2i1:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			byte = get_value( 1, sect, &length, &left);
			NEW_IMMEDIATE( value0Immed, byte );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x71: /* psrlw, psllw, psraw & psrld */
							if(prefix_byte == 0x66){
								if(reg == 0x2){
									// printf("%srlw\t$0x%x,", mnemonic, byte);
								} else if(reg == 0x4) {
									hooleyDebug();
									printf("%sraw\t$0x%x,", mnemonic, byte);
								} else if(reg == 0x6) {
									// printf("%sllw\t$0x%x,", mnemonic, byte);
								}
							} else { /* no prefix_byte */
								if(reg == 0x2) {
									hooleyDebug();
									printf("%srlw\t$0x%x,", mnemonic, byte);
								} else if(reg == 0x4) {
									hooleyDebug();
									printf("%sraw\t$0x%x,", mnemonic, byte);
								} else if(reg == 0x6) {
									hooleyDebug();
									printf("%sllw\t$0x%x,", mnemonic, byte);
								}
								printf("%%mm%u\n", r_m);
								const struct HooReg *mmReg = mmReg_Struct[r_m];
								
								return length;
							}
					break;
				case 0x72: /* psrld, pslld & psrad */
					if(prefix_byte == 0x66){
						if(reg == 0x2){
							hooleyDebug();
//NEVER									printf("%srld\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x4){
							hooleyDebug();
//NEVER									printf("%srad\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x6){
//Putback									printf("%slld\t$0x%x,", mnemonic, byte);
						}
					} else { /* no prefix_byte */
						if(reg == 0x2){
							hooleyDebug();
//NEVER									printf("%srld\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x4){
							hooleyDebug();
//NEVER									printf("%srad\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x6){
							hooleyDebug();
//NEVER									printf("%slld\t$0x%x,", mnemonic, byte);
						}
//Putback								printf("%%mm%u\n", r_m);
						const struct HooReg *reg_struct = mmReg_Struct[r_m];

						return length;
					}
					break;
				case 0x73: /* pslldq & psrldq, psrlq & psllq */
					if(prefix_byte == 0x66){
						if(reg == 0x7){
							// printf("%slldq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x3){
							// printf("%srldq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x2){
							// printf("%srlq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x6){
							// printf("%sllq\t$0x%x,", mnemonic, byte);
						}
					} else { /* no prefix_byte */
						hooleyDebug();
//NEVER								if(reg == 0x2){
//NEVER									hooleyDebug();
//NEVER									printf("%srlq\t$0x%x,", mnemonic, byte);
//NEVER								} else if(reg == 0x6){
//NEVER									hooleyDebug();
//NEVER									printf("%sllq\t$0x%x,", mnemonic, byte);
//NEVER								}
//NEVER								printf("%%mm%u\n", r_m);
						const struct HooReg *mmReg = mmReg_Struct[r_m];
//NEVER								return length;
					}
					break;
			}
			
			regNum = xmm_rm(r_m, rex);
			const struct HooReg *reg_struct = xmmReg_Struct[regNum]; //%xmm0
			// printf("%%xmm%u\n", reg_struct );
			// eg psllq $0x1f,%xmm2
			FILLARGS2( value0Immed, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return length;

		/* 3DNow instructions */
		case AMD3DNOW:
//Putback					printf("%s\t", mnemonic);
					sprintf(result1, "%%mm%lu", (unsigned long)reg);
//Putback			struct HooReg *mmReg = &mmReg_Struct[r_m];

//Putback					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//Putback					printf("%s\n", result1);
					return length;

		/* prefetch instructions */
		case PFCH:
					hooleyDebug();
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value( 1, sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					switch(reg)
//NEVER					{
//NEVER						case 0:
//NEVER							hooleyDebug();
//NEVER							printf("%snta", dp->name);
//NEVER							break;
//NEVER						case 1:
//NEVER							hooleyDebug();
//NEVER							printf("%st0", dp->name);
//NEVER							break;
//NEVER						case 2:
//NEVER							hooleyDebug();
//NEVER							printf("%st1", dp->name);
//NEVER							break;
//NEVER						case 3:
//NEVER							hooleyDebug();
//NEVER							printf("%st2", dp->name);
//NEVER							break;
//NEVER					}
//NEVER					if(data16 == TRUE){
//NEVER						hooleyDebug();
//NEVER						printf("w\t");
//NEVER					}else{
//NEVER						hooleyDebug();
//NEVER						printf("l\t");
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
//NEVER					return(length);

		/* 3DNow! prefetch instructions */
		case PFCH3DNOW:
		{
			if(got_modrm_byte == FALSE)
			{
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			switch(reg)
			{
				case 0:
					// printf("%s\t", dp->name);
					break;
				case 1:
					// printf("%sw\t", dp->name);
					break;
			}
			// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			FILLARGS1( abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return length;
		}

		/* sfence & clflush */
		case SFEN:
				hooleyDebug();
//NEVER					if(mode == REG_ONLY && r_m == 0){
//NEVER						hooleyDebug();
//NEVER						printf("sfence\n");
//NEVER						return(length);
//NEVER					}
//NEVER					printf("%s\t", mnemonic);
//NEVER					reg = opcode3;
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
//NEVER					return(length);

		/* Double shift. Has immediate operand specifying the shift. */
		case DSHIFT:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			value0_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			FILLARGS3( value0Immed, reg_struct, abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* Double shift. With no immediate operand, specifies using %cl. */
		case DSHIFTcl:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// cl is &count1_reg
			// eg shldl	%cl,%eax,%esi
			FILLARGS3( &count1_reg, reg_struct, abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* immediate to memory or register operand */
		case IMlw:
		{
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;

			/* A long immediate is expected for opcode 0x81, not 0x80 & 0x83 */
			value0_size = OPSIZE(data16, opcode2==1, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg. andl $0xf0,%esp    subl $0x10,%esp
			FILLARGS2( value0Immed, abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* immediate to memory or register operand with the 'w' bit present */
		case IMw:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			value0_size = OPSIZE(data16, wbit, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg movl	$0x00021730, 0x04(%edx)
			FILLARGS2( value0Immed, abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;
		}

		/* immediate to register with register in low 3 bits of op code */
		case IR:
			wbit = (opcode2 >> 3) & 0x1; /* w-bit here (with regs) is bit 3 */
			reg = REGNO(opcode2);
			value0_size = OPSIZE(data16, wbit, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_r_m_regStruct(reg, wbit, data16, rex);
			// eg movb	$0x00,%al
			FILLARGS2( value0Immed, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;

		/* immediate to register with register in low 3 bits of op code, possibly with a 64-bit immediate */
		case IR64:
			wbit = (opcode2 >> 3) & 0x1; /* w-bit here (with regs) is bit 3 */
			reg = REGNO(opcode2);
			value0_size = OPSIZE(data16, wbit, REX_W(rex));
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_r_m_regStruct(reg, wbit, data16, rex);		
			 // eg. movl	$0x00b9ee00,%ecx
			FILLARGS2( value0Immed, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;

		/* memory operand to accumulator */
		case OA:
			if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
				value0_size = OPSIZE(addr16, LONGOPERAND, 1);
				// strcpy(mnemonic, "movabsl");
			} else {
				value0_size = OPSIZE(addr16, LONGOPERAND, 0);
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);			
			NEW_IMMEDIATE( value0Immed, imm0 );
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			// eg movl	0x0123d000,%eax
			FILLARGS2( value0Immed, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return length;

		/* accumulator to memory operand */
		case AO:
			if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
				value0_size = OPSIZE(addr16, LONGOPERAND, 1);
				// strcpy(mnemonic, "movabsl");
			} else {
				value0_size = OPSIZE(addr16, LONGOPERAND, 0);
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			// eg movl	%eax,0x00f2300c
			FILLARGS2( reg_struct, value0Immed );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return length;

		/* memory or register operand to segment register */
		case MS:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			segReg = (struct HooReg *)SEGREG[reg];
			FILLARGS2( abstractStrctPtr1, segReg );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);
		}

		/* segment register to memory or register operand	*/
		case SM:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;		
			segReg = (struct HooReg *)SEGREG[reg];
			// printf("%s\t%s,", mnemonic, SEGREG[reg]);
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			FILLARGS2( segReg, abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);
		}

		/* rotate or shift instrutions, which may shift by 1 or */
		/* consult the cl register, depending on the 'v' bit	*/
		case Mv:
		{
			vbit = VBIT(opcode2);
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			/* When vbit is set, register is an operand, otherwise just $0x1 */
			if(vbit){
				// reg_name = vbit ? "%cl," : "" ;
				FILLARGS2( &count1_reg, abstractStrctPtr1 );
			} else {
				// reg_name = vbit ? "%cl," : "" ;
				FILLARGS1(abstractStrctPtr1);
			}
			// eg sarl	%eax
			// shll		%cl,%edx
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];	
			return(length);
		}

		/* immediate rotate or shift instrutions, which may or */
		/* may not consult the cl register, depending on the 'v' bit */
		case MvI:
		{
			vbit = VBIT(opcode2);
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			value1_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm0, value1_size);
			NEW_IMMEDIATE( value0Immed, imm0 );

			/* When vbit is set, register is an operand, otherwise just $0x1 */
			if(vbit) {
				// reg_name = vbit ? "%cl," : "" ;
				[NSException raise:@"what?" format:@"what?"];
				// FILLARGS3(value0Immed, count1_reg, value0);				
			} else {
				FILLARGS2(value0Immed, abstractStrctPtr1);
			}
			// eg shll	$0x02,%eb
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		case MIb:
		{
			wbit = LONGOPERAND;
			// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			value1_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm0, value1_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// printf("%s\t$", mnemonic);
			// print_operand("", symadd1, symsub1, imm0, value1_size, "", ",");
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			FILLARGS2( value0Immed, abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		/* single memory or register operand with 'w' bit present */
		case Mw:
		{
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			FILLARGS1( abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);
		}

		/* single memory or register operand but don't use 'l' suffix */
		case Mnol:
		/* single memory or register operand */
		case M:
		{
			switch(byte)
			{
				case 0xc1:
					hooleyDebug();
					printf("vmcall\n");
					return(length);
				case 0xc2:
					hooleyDebug();
					printf("vmlaunch\n");
					return(length);
				case 0xc3:
					hooleyDebug();
					printf("vmresume\n");
					return(length);
				case 0xc4:
					hooleyDebug();
	//NEVER							printf("vmxoff\n");
					return(length);
				case 0xc7:
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66){
//NEVER								hooleyDebug();
//NEVER								sprintf(mnemonic, "vmclear");
//NEVER							}else if(prefix_byte == 0xf3){
//NEVER								hooleyDebug();
//NEVER								sprintf(mnemonic, "vmxon");
//NEVER							} else {
//NEVER								hooleyDebug();
//NEVER								if(got_modrm_byte == FALSE){
//NEVER									hooleyDebug();
//NEVER									got_modrm_byte = TRUE;
//NEVER									byte = get_value(1, sect, &length, &left);
//NEVER									modrm_byte(&mode, &reg, &r_m, byte);
//NEVER								}
//NEVER								if(reg == 6){
//NEVER									hooleyDebug();
//NEVER									sprintf(mnemonic, "vmptrld");
//NEVER								}else if(reg == 7){
//NEVER									hooleyDebug();
//NEVER									sprintf(mnemonic, "vmptrst");
//NEVER								}
//NEVER							}
				break;
			}
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;

			// eg nopl	0x00(%eax,%eax)   fldl	0xe8(%ebp)
			FILLARGS1( abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}
	
		/* single memory or register operand */
		case Mb:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = BYTEOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// eg setbe	%al
			FILLARGS1( abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		case SREG: /* special register */
				hooleyDebug();
//NEVER					byte = get_value( 1, sect, &length, &left);
//NEVER					modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					vbit = 0;
//NEVER					switch(opcode5)
//NEVER					{
//NEVER						case 2:
//NEVER							hooleyDebug();
//NEVER							vbit = 1;
//NEVER							/* fall thru */
//NEVER						case 0:
//NEVER							hooleyDebug();
//NEVER							reg_name = CONTROLREG[reg + (REX_R(rex) << 3)];
//NEVER							break;
//NEVER						case 3:
//NEVER							hooleyDebug();
//NEVER							vbit = 1;
//NEVER							/* fall thru */
//NEVER						case 1:
//NEVER							hooleyDebug();
//NEVER							reg_name = DEBUGREG[reg + (REX_R(rex) << 3)];
//NEVER							break;
//NEVER						case 6:
//NEVER							hooleyDebug();
//NEVER							vbit = 1;
//NEVER							/* fall thru */
//NEVER						case 4:
//NEVER							hooleyDebug();
//NEVER							reg_name = TESTREG[reg];
//NEVER							break;
//NEVER					}
//NEVER					if(vbit){
//NEVER						hooleyDebug();
//NEVER						const char *reg_name2 =  get_r_m_name(r_m, 1, data16,rex);
//NEVER						printf("%s\t%s,%s\n", mnemonic, reg_name2, reg_name);
//NEVER					} else {
//NEVER						hooleyDebug();
//NEVER						const char *reg_name2 =  get_r_m_name(r_m, 1,data16, rex);
//NEVER						printf("%s\t%s,%s\n", mnemonic, reg_name, reg_name2);
//NEVER					}
					return(length);

		/* single register operand with register in the low 3 bits of op code */
		case R:
			reg = REGNO(opcode2);
			reg_struct = get_r_m_regStruct(reg, LONGOPERAND, data16, rex);

			BOOL isNewFunc = !strcmp(dp->name, "push") && !strcmp(reg_struct->name,"%ebp");
			if (isNewFunc) {
				/* NEW FUNCTION */
				// Not entirely sure this is a sufficient test (push instruction) for a new function
				struct hooleyFuction *currentFunc = *currentFuncPtr;
				struct hooleyFuction *newFunc = calloc( 1, sizeof(struct hooleyFuction) );
				newFunc->prev = currentFunc;
				newFunc->index = currentFunc->index+1;
				currentFunc->next = newFunc;
				currentFunc = newFunc;
				*currentFuncPtr = currentFunc;
			}
			// eg. pushl %ebp
			FILLARGS1(reg_struct);
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);

		/* register to accumulator with register in the low 3 */
		/* bits of op code, xchg instructions */
		case RA:
		{
			reg = REGNO(opcode2);
			reg_struct = get_regStruct(reg, LONGOPERAND, data16, rex);
			// printf("%s\t%s,%s\n", mnemonic, reg_name, (data16 ? "%ax" : "%eax"));
			const struct HooReg *secondReg = data16 ? &acumx_reg : &acumex_reg;
			FILLARGS2( reg_struct, secondReg );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);
		}
		/* single segment register operand, with reg in bits 3-4 of op code */
		case SEG:
			reg = byte >> 3 & 0x3; /* segment register */
			segReg = (struct HooReg *)SEGREG[reg];
			// printf("%s\t%s\n", mnemonic, segReg->name );
			// eg pushw	%es
			FILLARGS1( segReg );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);

		/* single segment register operand, with register in	*/
		/* bits 3-5 of op code					*/
		case LSEG:
			reg = byte >> 3 & 0x7; /* long seg reg from opcode */
			segReg = (struct HooReg *)SEGREG[reg];
			// printf("%s\t%s\n", mnemonic, segReg->name);
			FILLARGS1( segReg );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);

		/* memory or register operand to register */
		case MR:
		{
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value( 1, sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND; //1 clang gcc
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			//	eg. leal 0x08(%ebp),%ecx
			FILLARGS2(abstractStrctPtr1, reg_struct);
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		/* immediate operand to accumulator */
		case IA:
			value0_size = OPSIZE(data16, WBIT(opcode2), 0);
			switch(value0_size) {
				case 1:
					reg_struct = &acuml_reg;
				case 2:
					reg_struct = &acumx_reg;
				case 4:
					reg_struct = &acumex_reg;
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			//eg cmpb	$0x2f,%al
			FILLARGS2( value0Immed, reg_struct );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);

		/* memory or register operand to accumulator */
		case MA:
		{
			wbit = WBIT(opcode2);
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// eg mull	%ecx
			FILLARGS1( abstractStrctPtr1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		/* si register to di register */
		case SD:
			if(addr16 == TRUE) {
				struct IndirectVal *indirect1, *indirect2;
				NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)&sourceIndex2_reg, 0, scale_factor[0] );
				NEW_INDIRECT( indirect2, 0, 0, (struct HooReg *)&destinationIndex2_reg, 0, scale_factor[0] );
				FILLARGS2( indirect1, indirect2 );
				[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
				// printf("%s\t%s(%%si),(%%di)\n", mnemonic, seg);
			} else {
				//TODO: this is in the repz loop
				struct IndirectVal *indirect1, *indirect2;
				NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)&sourceIndex1_reg, 0, scale_factor[0] );
				NEW_INDIRECT( indirect2, 0, 0, (struct HooReg *)&destinationIndex1_reg, 0, scale_factor[0] );
				FILLARGS2( indirect1, indirect2 );
				// printf("%s\t%s(%%esi),(%%edi)\n", mnemonic, segReg->name);
				[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			}
			return(length);

		/* accumulator to di register */
		case AD:
		{
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			GET_BEST_REG_NAME( reg_name, reg_struct );
			struct HooReg *indexReg;		
			if(addr16 == TRUE) {
				// printf("%s\t%s,%s(%%di)\n", mnemonic, reg_name, seg);
				indexReg = (struct HooReg *)&destinationIndex2_reg;
			} else {
				// printf("%s\t%s,%s(%%edi)\n", mnemonic, reg_name, seg);
				indexReg = (struct HooReg *)&destinationIndex1_reg;
			}
			struct IndirectVal *indirect1;			
			NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)indexReg, 0, scale_factor[0] );
			
			FILLARGS2( reg_struct, indirect1 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		/* si register to accumulator */
		case SA:
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			if(addr16 == TRUE){
				hooleyDebug();
	//NEVER printf("%s\t%s(%%si),%s\n", mnemonic, seg, reg_name);
			}else{
				// printf("%s\t%s(%%esi),%s\n", mnemonic, seg, reg_name);
				struct IndirectVal *indirect1;
				// lodsl (%esi),%eax
				NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)&sourceIndex1_reg, 0, scale_factor[0] );
				FILLARGS2( indirect1, reg_struct );
				[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			}
			return(length);

		/* single operand, a 16/32 bit displacement */
		case D:
			value0_size = OPSIZE(data16, LONGOPERAND, 0);
			DISPLACEMENT(&symadd0, &symsub0, &value0, value0_size);			
			NEW_DISPLACEMENT( displaceStructPtr, value0 );
			// eg. calll 0x00002aea
			FILLARGS1(displaceStructPtr);			
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY2]; 
			return(length);

		/* indirect to memory or register operand */
		case INM:
		{
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			
			if((mode == 0 && (r_m == 5 || r_m == 4)) || mode == 1 || mode == 2 || mode == 3) {
				// TODO: How do we accomodate this little fella?
				// printf("%s\t*", mnemonic);
			}

			FILLARGS1( abstractStrctPtr1 );			
			// eg jmp	*%ecx, *0x00ac6798(,%eax,4)
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY]; 
			return(length);
		}

		/* indirect to memory or register operand (for lcall and ljmp) */
		case INMl:
		{
			wbit = LONGOPERAND;
			NSUInteger needThis = REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)needThis;
			// eg ljmpl *%ebx				// TODO: missing the asterisk?
			FILLARGS1( abstractStrctPtr1 );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}

		/*
		* For long jumps and long calls -- a new code segment
		* register and an offset in IP -- stored in object
		* code in reverse order
		*/
		case SO:
			value1_size = OPSIZE(data16, LONGOPERAND, 0);
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm1, value1_size);
			NEW_IMMEDIATE( value1Immed, imm1 );
			value0_size = sizeof(short);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			//		printf("%s\t$", mnemonic);
			//		print_operand("", symadd0, symsub0, imm0, value0_size, "", ",$");
			//		print_operand(seg, symadd1, symsub1, imm1, value1_size, "", "\n");
			FILLARGS2( value0Immed, value1Immed );						
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);

		/* jmp/call. single operand, 8 bit displacement */
		case BD:
			value0_size = 1;
			DISPLACEMENT( &symadd0, &symsub0, &value0, value0_size );
			NEW_DISPLACEMENT( displaceStructPtr, value0 );
			// eg jne	0x00002b1a
			FILLARGS1( displaceStructPtr );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY2];
			return(length);

		/* single 32/16 bit immediate operand */
		case I:
			value0_size = OPSIZE(data16, LONGOPERAND, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			FILLARGS1( value0Immed );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			// eg pushl  $0x00001000
			return(length);

		/* single 8 bit immediate operand */
		case Ib:
			value0_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );

			// eg. pushl $0x00 
			FILLARGS1( value0Immed );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);

		case ENTER:
			// wooo exotic!
			value0_size = sizeof(short);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			value1_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm1, value1_size);
			NEW_IMMEDIATE( value1Immed, imm1 );
			// printf("%s\t$", mnemonic);
			// print_operand("", symadd0, symsub0, imm0, value0_size, "", ",$");
			// print_operand("", symadd1, symsub1, imm1, value1_size, "", "\n");
			FILLARGS2( value0Immed, value1Immed );						
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);

		/* 16-bit immediate operand */
		case RET:
			value0_size = sizeof(short);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg ret	$0x0004	
			FILLARGS1( value0Immed );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY]; 		
			return(length);

		/* single 8 bit port operand */
		case P:
			value0_size = 1;
			REPLACEMENT_IMMEDIATE( &symadd0, &symsub0, &imm0, value0_size );
			NEW_IMMEDIATE( value0Immed, imm0 );
			// printf("%s\t$", mnemonic);
			// print_operand(seg, symadd0, symsub0, imm0, value0_size, "", "\n");
			FILLARGS1( value0Immed );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];				
			return(length);

		/* single 8 bit (input) port operand				*/
		case Pi:
			value0_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// printf("%s\t$", mnemonic);
			// print_operand(seg, symadd0, symsub0, imm0, value0_size, "", ",%eax\n");
			// eg inl $0x05,%eax
			FILLARGS2( value0Immed, &acumex_reg );			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];			
			return(length);

		/* single 8 bit (output) port operand				*/
		case Po:
		{
			value0_size = 1;
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg  outb %al,$0x00
			FILLARGS2( &acumex_reg, value0Immed );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return(length);
		}
		/* single operand, dx register (variable port instruction) */
		case V:
//Putback					printf("%s\t%s(%%dx)\n", mnemonic, seg);
					return(length);

		/* single operand, dx register (variable (input) port instruction) */
		case Vi:
		{
			// printf("%s\t%s%%dx,%%eax\n", mnemonic, seg);
			// eg inl %dx,%eax
			if(segReg) {
				FILLARGS3( segReg, &data1_reg, &acumex_reg );
			} else {
				FILLARGS2( &data1_reg, &acumex_reg );
			}
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return(length);
		}

		/* single operand, dx register (variable (output) port instruction)*/
		case Vo:
			// printf("%s\t%s%%eax,%%dx\n", mnemonic, segReg->name);
			// eg outb %al,%dx
			if(segReg) {
				FILLARGS3( segReg, &acumex_reg, &data1_reg );
			} else {
				FILLARGS2( &acumex_reg, &data1_reg );
			}			
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];		
			return(length);

		/* The int instruction, which has two forms: int 3 (breakpoint) or  */
		/* int n, where n is indicated in the subsequent byte (format Ib).  */
		/* The int 3 instruction (opcode 0xCC), where, although the 3 looks */
		/* like an operand, it is implied by the opcode. It must be converted */
		/* to the correct base and output. */
		case INT3:
			// printf("%s\t$0x3\n", mnemonic);
			[self addLine:addr :currentFuncPtr :&int3_instr :NULL :NOISY];
			return(length);

		/* just an opcode and an unused byte that must be discarded */
		case U:
			byte = get_value( 1, sect, &length, &left);
			// printf("%s\n", mnemonic);
			[self addLine:addr :currentFuncPtr :dp :NULL :NOISY];			
			return(length);

		case CBW:
			if(data16==TRUE){
				// printf("cbtw\n"); // -- sign-extend byte in `%al' to word in `%ax'
				[self addLine:addr :currentFuncPtr :&op_cbtw :NULL :NOISY];				
			}else{
				// printf("cwtl\n"); // -- sign-extend word in `%ax' to long in `%eax'
				[self addLine:addr :currentFuncPtr :&op_cwtl :NULL :NOISY];
			}
			return(length);

		case CWD:
			if(data16 == TRUE){
				// printf("cwtd\n");
				[self addLine:addr :currentFuncPtr :&op_cwtd :NULL :NOISY];
			}else{
				// printf("cltd\n");
				[self addLine:addr :currentFuncPtr :&op_cltd :NULL :NOISY];				
			}
			return(length);

		/* no disassembly, the mnemonic was all there was so go on */
		case GO_ON:
			 // eg. hlt, nop, etc.
			if( strcmp(dp->name, "nop" )) {
				[self addLine:addr :currentFuncPtr :dp :NULL :NOISY];
			}
			return(length);

		/* float reg */
		case F:
		{
			// printf("%s\t%%st(%1.1u)\n", mnemonic, r_m);
			[self addLine:addr :currentFuncPtr :&fstp1_instr :NULL :NOISY];
			return(length);
		}
		/* float reg to float reg, with ret bit present */
		case FF:
		{
			const struct HooReg *reg_struct2;
			/* return result bit for 287 instructions */
			if(((opcode2 >> 2) & 0x1) == 0x1 && opcode2 != 0xf) {
				// fsubrp	%st,%st(1)
				reg_struct = FloatingPointREG[0];
				reg_struct2 = FloatingPointREG[r_m];
				//printf("%s\t%%st,%%st(%1.1u)\n", mnemonic, r_m);
			} else {
				// fucomip	%st(1),%st
				reg_struct = FloatingPointREG[r_m];
				reg_struct2 = FloatingPointREG[0];
				// printf("%s\t%%st(%1.1u),%%st\n", mnemonic, r_m);
			}
			FILLARGS2( reg_struct, reg_struct2 );
			[self addLine:addr :currentFuncPtr :dp :allArgs :NOISY];
			return(length);
		}
		/* an invalid op code */
		case AM:
		case DM:
		case OVERRIDE:
		case PREFIX:
		case UNKNOWN:
			default:
				// printf(".byte 0x%02x", 0xff & sect[0]);
				// for(i = 1; i < length; i++) {
				//	printf(", 0x%02x", 0xff & sect[i]);
				// }
				// printf(" #bad opcode\n");
				[self addLine:addr :currentFuncPtr :NULL :NULL :NOISY];
				return(length);
	} /* end switch */
}

@end

static NSUInteger replacement_get_operand(
						const char **symadd,
						const char **symsub,
						uint64 *value,
						NSUInteger *value_size,
						void *result,
						const cpu_type_t cputype,
						const NSUInteger mode,
						const NSUInteger r_m,
						const NSUInteger wbit,
						const NSUInteger data16,
						const NSUInteger addr16,
						const NSUInteger sse2,
						const NSUInteger mmx,
						const unsigned int rex,
						const char *sect,
						char *sect_addr,
						NSUInteger *length,
						uint64 *left,
						char *addr,
						const struct relocation_info *sorted_relocs,
						const NSUInteger nsorted_relocs,
						const struct nlist *symbols,
						const struct nlist_64 *symbols64,
						const NSUInteger nsymbols,
						const char *strings,
						const NSUInteger strings_size,
						const struct symbol *sorted_symbols,
						const NSUInteger nsorted_symbols,
						const NSUInteger verbose,
						struct HooReg *segReg
						)
{
    int s_i_b;				/* flag presence of scale-index-byte */
    unsigned char byte;		/* the scale-index-byte */
    uint32_t ss;			/* scale-factor from scale-index-byte */
    uint32_t index; 		/* index register number from scale-index-byte*/
    uint32_t base;  		/* base register number from scale-index-byte */
	uint64_t sect_offset;
    uint64_t offset;
	
	*symadd = NULL;
	*symsub = NULL;
	*value = 0;
	//	*result = '\0';
	
	/* check for the presence of the s-i-b byte */
	if( r_m==ESP && mode!=REG_ONLY && (((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) || addr16 == FALSE)){
		//clang + GCC
	    s_i_b = TRUE;
	    byte = get_value( 1, sect, length, left); //0x10d61e99b, 0x7fff5fbfe0f8, 0x7fff5fbfdea8
	    modrm_byte( &ss, &index, &base, byte ); // 2, 2, 5, in clang this resets byte to 0
	} else {
	    s_i_b = FALSE;
	}
	if(addr16) {
	    *value_size = dispsize16[r_m][mode];
	}else{
		//gcc + clang
	    *value_size = dispsize32[r_m][mode];
	}
	if( s_i_b==TRUE && mode==0 && base==EBP ) //clang base==5
		//clang
	    *value_size = sizeof(int32_t);
	
	if(*value_size != 0){
		//clang
		sect_offset = addr + *length - sect_addr;
	    *value = get_value(*value_size, sect, length, left);
//putback		GET_SYMBOL(symadd, symsub, &offset, sect_offset, *value);
//putback		if(*symadd != NULL){
//putback			*value = offset;
//putback		} else {
//putback			*symadd = GUESS_SYMBOL(*value);
//putback			if(*symadd != NULL)
//putback				*value = 0;
//putback		}
	}
	
	if(s_i_b == TRUE){
	    if(((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) && !addr16){
			/* If the scale factor is 1, don't display it. */
			if(ss == 0){
				/*
				 * If mode is 0 and base is 5 (regardless of the rex bit)
				 * there is no base register, and if the index is
				 * also 4 then the operand is just a displacement.
				 */
				if(mode == 0 && base == 5 && index == 4){
					// result = "";
					return 0;
				} else {
					const struct HooReg *reg_struct = regname64_Struct[mode][base + (REX_B(rex) << 3)];					
					const struct HooReg *indexReg = indexname64_Struct[index + (REX_X(rex) << 3)];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[0] );
					return (NSUInteger)indirStrct;
//					sprintf(result, "(%s%s)", reg_struct, todo );
				}
			}
			else {
				/*
				 * If mode is 0 and base is 5 (regardless of the rex bit)
				 * there is no base register.
				 */
				if(mode == 0 && base == 5){
										
					// It is not clear if it was the reg or the index reg in the original source
					const struct HooReg *indexReg = indexname64_Struct[index + (REX_X(rex) << 3)];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT(  indirStrct, segReg, 0, 0, (struct HooReg *)indexReg, scale_factor[ss] );
					return (NSUInteger)indirStrct;
//					sprintf( result, "(%s,%s)", todo, scale_factor[ss] );
			
				} else {
					const struct HooReg *reg_struct = regname64_Struct[mode][base + (REX_B(rex) << 3)];
					const struct HooReg *indexReg = indexname64_Struct[index + (REX_X(rex) << 3)];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, segReg, 0,(struct HooReg *)reg_struct,(struct HooReg *)indexReg, scale_factor[ss]);
					return (NSUInteger)indirStrct;
					// sprintf(result, "(%s%s,%s)", reg_struct, todo, scale_factor[ss] );
				}
			}
	    } else {
			/* If the scale factor is 1, don't display it. */
			if(ss == 0){
				/*
				 * If mode is 0 and base is 5 it there is no base register,
				 * and if the index is also 4 then the operand is just a
				 * displacement.
				 */
				if(mode == 0 && base == 5 && index == 4){
					// result = "";
					return 0;
				} else {
					const struct HooReg *reg_struct = regname32_Struct[mode][base];
					const struct HooReg *indexReg = indexname_Struct[index];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[0] );
					return (NSUInteger)indirStrct;
				}
			} else {
				//clang
				const struct HooReg *reg_struct = regname32_Struct[mode][base];
				const struct HooReg *indexReg = indexname_Struct[index];				
				struct IndirectVal *indirStrct;
				NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[ss]);
				return (NSUInteger)indirStrct;
				// char *reg_name;
				// GET_BEST_REG_NAME( reg_name, reg_struct );
				// sprintf(result, "(%s%s,%s)", reg_name, indexname[index], scale_factor[ss]);
			}
	    }
	} else { /* no s-i-b */
	    if(mode == REG_ONLY){
			if(sse2 == TRUE) {
				NSUInteger regNum = xmm_rm(r_m, rex);
				const struct HooReg *reg_struct = xmmReg_Struct[regNum]; //%xmm0
				// sprintf(result, "%%xmm%u", );
				return (NSUInteger)reg_struct;

			} else if(mmx == TRUE) {
				// sprintf(result, "%%mm%ld", (unsigned long)r_m);
				const struct HooReg *mmReg = mmReg_Struct[r_m];
				return (NSUInteger)mmReg;

			} else if (data16 == FALSE || rex != 0) {
				/* The presence of a REX byte overrides 66h. */
				//const char *regname = REG32[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
				const struct HooReg *reg_struct = REG32_Struct[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];				
				return (NSUInteger)reg_struct;
	
			} else {
				const struct HooReg *reg_struct = REG16_Struct[r_m][wbit];
				return (NSUInteger)reg_struct;

				// const char *reg_name; // = REG16[r_m][wbit];
				// GET_BEST_REG_NAME( reg_name, reg_struct );
				// strcpy(result, reg_name);
			}
	    } else { /* Modes 00, 01, or 10 */
			if(r_m == EBP && mode == 0){ /* displacement only */
				if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
					/*
					 * In 64-bit mode, mod=00 and r/m=101 defines
					 * RIP-relative addressing with a 32-bit displacement.
					 * In 32-bit mode, it's just a 32-bit displacement. See
					 * section 2.2.1.6 ("RIP-Relative Addressing") of Volume
					 * 2A of the Intel IA-32 manual.
					 */
			
						
					// sprintf(result, "(%%rip)");
					const struct HooReg *reg_struct = &rip_reg;
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, 0, *value, (struct HooReg *)reg_struct, 0, scale_factor[0] ); // could use ss in here i think
					return (NSUInteger)indirStrct;
					
				} else {
					struct DisplacementValue *displaceStructPtr;
					NEW_DISPLACEMENT( displaceStructPtr, *value );
					return (NSUInteger)displaceStructPtr;
				}
			} else {
				/* Modes 00, 01, or 10, not displacement only, no s-i-b */
				if(addr16 == TRUE) {
					if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
						/*
						 *  In 64-bit mode, the address size prefix drops us
						 * down to 32-bit, not 16-bit.
						 */
						const struct HooReg *reg_struct = regname32_Struct[mode][r_m];
						char *reg_name;
						GET_BEST_REG_NAME( reg_name, reg_struct );
						sprintf(result, "(%s)", reg_name);
	
					} else {
						const struct HooReg *reg_struct1 = regname16_Struct[mode][r_m][0];
						const struct HooReg *reg_struct2 = regname16_Struct[mode][r_m][1];
						if (reg_struct2->isah==NULL_ARG) {
							reg_struct2 = 0;
						}						
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg, *value, reg_struct1, reg_struct2, scale_factor[0] );
						return (NSUInteger)indirStrct;
					}
				} else {
					if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
						const struct HooReg *reg_struct = regname64_Struct[mode][r_m + (REX_B(rex) << 3)];				
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, 0, scale_factor[0] );
						return (NSUInteger)indirStrct;
					
						// sprintf(result, "(%s)", 1 );
					} else {
						//gcc
						const struct HooReg *reg_struct = regname32_Struct[mode][r_m];					
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, 0, scale_factor[0] );
						return (NSUInteger)indirStrct;

						// char *reg_name;
						// GET_BEST_REG_NAME( reg_name, reg_struct );
						// sprintf(result, "(%s)", reg_name);
						
					}
				}
			}
	    }
	}
	[NSException raise:@"what the fuck" format:@"seriously"];
	return 0;
}


//static void get_operand(
//const char **symadd,
//const char **symsub,
//uint64 *value,
//NSUInteger *value_size,
//void *result,
//const cpu_type_t cputype,
//const uint32_t mode,
//const uint32_t r_m,
//const uint32_t wbit,
//const int data16,
//const int addr16,
//const int sse2,
//const int mmx,
//const unsigned int rex,
//const char *sect,
//uint32_t sect_addr,
//uint32_t *length,
//uint64 *left,
//const uint32_t addr,
//const struct relocation_info *sorted_relocs,
//const uint32_t nsorted_relocs,
//const struct nlist *symbols,
//const struct nlist_64 *symbols64,
//const NSUInteger nsymbols,
//const char *strings,
//const NSUInteger strings_size,
//const struct symbol *sorted_symbols,
//const NSUInteger nsorted_symbols,
//const int verbose
//)
//{
//    int s_i_b;		/* flag presence of scale-index-byte */
//    unsigned char byte;		/* the scale-index-byte */
//    uint32_t ss;		/* scale-factor from scale-index-byte */
//    uint32_t index; 		/* index register number from scale-index-byte*/
//    uint32_t base;  		/* base register number from scale-index-byte */
//	uint32_t sect_offset;
//    uint64_t offset;
//
//	*symadd = NULL;
//	*symsub = NULL;
//	*value = 0;
////	*result = '\0';
//
//	/* check for the presence of the s-i-b byte */
//	if(r_m == ESP && mode != REG_ONLY && (((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) || addr16 == FALSE)){
//	    s_i_b = TRUE;
//	    byte = get_value( 1, sect, length, left);
//	    modrm_byte(&ss, &index, &base, byte);
//	} else {
//	    s_i_b = FALSE;
//	}
//	if(addr16) {
//	    *value_size = dispsize16[r_m][mode];
//	}else{
//	    *value_size = dispsize32[r_m][mode];
//	}
//	if(s_i_b == TRUE && mode == 0 && base == EBP)
//	    *value_size = sizeof(int32_t);
//
//	if(*value_size != 0){
//		sect_offset = addr + *length - sect_addr;
//	    *value = get_value(*value_size, sect, length, left);
//		GET_SYMBOL(symadd, symsub, &offset, sect_offset, *value);
//		if(*symadd != NULL){
//			*value = offset;
//		} else {
//			*symadd = GUESS_SYMBOL(*value);
//			if(*symadd != NULL)
//				*value = 0;
//			}
//	}
//
//	if(s_i_b == TRUE){
//	    if(((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) && !addr16){
//		/* If the scale factor is 1, don't display it. */
//		if(ss == 0){
//		    /*
//		     * If mode is 0 and base is 5 (regardless of the rex bit)
//		     * there is no base register, and if the index is
//		     * also 4 then the operand is just a displacement.
//		     */
//		    if(mode == 0 && base == 5 && index == 4){
//				result = (char *)"";
//		    } else {
//				const char *reg_name = regname64[mode][base + (REX_B(rex) << 3)];
//				const char *todo = indexname64[index + (REX_X(rex) << 3)];
//				sprintf(result, "(%s%s)", reg_name, todo );
//		    }
//		} else {
//		    /*
//		     * If mode is 0 and base is 5 (regardless of the rex bit)
//		     * there is no base register.
//		     */
//		    if(mode == 0 && base == 5){
//				const char *todo = indexname64[index + (REX_X(rex) << 3)];
//				sprintf(result, "(%s,%s)", todo, scale_factor[ss]);
//		    } else {
//				const char *reg_name = regname64[mode][base + (REX_B(rex) << 3)];
//				const char *todo = indexname64[index + (REX_X(rex) << 3)];
//				sprintf(result, "(%s%s,%s)", reg_name, todo, scale_factor[ss] );
//		    }
//		}
//	    } else {
//			/* If the scale factor is 1, don't display it. */
//			if(ss == 0){
//				/*
//				 * If mode is 0 and base is 5 it there is no base register,
//				 * and if the index is also 4 then the operand is just a
//				 * displacement.
//				 */
//				if(mode == 0 && base == 5 && index == 4){
//					result = (char *)"";
//				} else {
//					const char *regname = regname32[mode][base];
//					sprintf(result, "(%s%s)", regname, indexname[index]);
//				}
//			} else {
//				const char *regname = regname32[mode][base];				
//				sprintf(result, "(%s%s,%s)", regname, indexname[index], scale_factor[ss]);
//			}
//	    }
//	} else { /* no s-i-b */
//	    if(mode == REG_ONLY){
//			if(sse2 == TRUE) {
//				NSUInteger regNum = xmm_rm(r_m, rex);
//				const struct HooReg *reg_struct = xmmReg_Struct[regNum]; //%xmm0
//				sprintf(result, "%%xmm%u", xmm_rm(r_m, rex));
//			} else if(mmx == TRUE) {
//				sprintf(result, "%%mm%u", r_m);
				// struct HooReg *mmReg = &mmReg_Struct[r_m];

//			} else if (data16 == FALSE || rex != 0) {
//				/* The presence of a REX byte overrides 66h. */
//				//const char *regname = REG32[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
//				const struct HooReg *reg_struct = REG32_Struct[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
//				// *(struct HooReg *)result = *reg_struct;
//				char *reg_name;
//				GET_BEST_REG_NAME( reg_name, reg_struct );
//				strcpy(result, reg_name);
//			} else {
//				const struct HooReg *reg_struct = &REG16_Struct[r_m][wbit];
//				const char *reg_name; // = REG16[r_m][wbit];
//				GET_BEST_REG_NAME( reg_name, reg_struct );
//				strcpy(result, reg_name);
//			}
//	    } else { /* Modes 00, 01, or 10 */
//		if(r_m == EBP && mode == 0){ /* displacement only */
//		    if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
//			/*
//			 * In 64-bit mode, mod=00 and r/m=101 defines
//			 * RIP-relative addressing with a 32-bit displacement.
//			 * In 32-bit mode, it's just a 32-bit displacement. See
//			 * section 2.2.1.6 ("RIP-Relative Addressing") of Volume
//			 * 2A of the Intel IA-32 manual.
//			 */
//				sprintf(result, "(%%rip)");
//		    } else {
////eh?				*result = '\0';
//			}
//		} else {
//		    /* Modes 00, 01, or 10, not displacement only, no s-i-b */
//		    if(addr16 == TRUE) {
//				if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
//			    /*
//			     *  In 64-bit mode, the address size prefix drops us
//			     * down to 32-bit, not 16-bit.
//			     */
//					const char *reg_name = regname32[mode][r_m];					
//					sprintf(result, "(%s)", reg_name);
//				} else {
//					/* Woahh.. This is Fun */
//					//const struct HooReg *reg_struct = regname16_Struct[mode][r_m];
//					// BONKERS ARG ALERT!
//					// const char *reg_name; // = regname16[mode][r_m];
//					// GET_BEST_REG_NAME( reg_name, reg_struct );
//					// TODO: This returns 2 registers, like this… (reg1,reg2)
//					sprintf(result, "(%s)", "%bp,%si" );
//				}
//		    } else {
//				if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
//					const char *reg_name = regname64[mode][r_m + (REX_B(rex) << 3)];
//					sprintf(result, "(%s)", reg_name );
//				} else {
//					const char *regname = regname32[mode][r_m];					
//					sprintf(result, "(%s)", regname);
//				}
//		    }
//		}
//	    }
//	}
//}


//static void immediate(
//					  const char **symadd,
//					  const char **symsub,
//					  uint64_t *value,
//					  uint32_t value_size,
//					  const char *sect,
//					  uint32_t sect_addr,
//					  uint32_t *length,
//					  uint32_t *left,
//					  cpu_type_t cputype,
//					  const uint32_t addr,
//					  const struct relocation_info *sorted_relocs,
//					  const uint32_t nsorted_relocs,
//					  const struct nlist *symbols,
//					  const struct nlist_64 *symbols64,
//					  const uint32_t nsymbols,
//					  const char *strings,
//					  const uint32_t strings_size,
//					  const struct symbol *sorted_symbols,
//					  const NSUInteger nsorted_symbols,
//					  const int verbose
//					  ) {
//	
//	uint64_t offset;
//	uint32_t sect_offset = addr + *length - sect_addr;
//	*value = get_value(value_size, sect, length, left);
//	GET_SYMBOL(symadd, symsub, &offset, sect_offset, *value);
//	if(*symadd==NULL){
//		*symadd = GUESS_SYMBOL(*value);
//		if(*symadd != NULL)
//			*value = 0; //TODO: stop zeroing out this!
//	} else if(*symsub != NULL){
//		*value = offset;
//	}
//}

/*
 * immediate() is used to return the symbolic operand for an immediate operand.
 */
static void replacement_immediate(
	const char **symadd,
	const char **symsub,
	uint64_t *value,
	NSUInteger value_size,
	const char *sect,
	const char *sect_addr,
	NSUInteger *length,
	uint64 *left,
	cpu_type_t cputype,
	const char *addr,
	const struct relocation_info *sorted_relocs,
	const NSUInteger nsorted_relocs,
	const struct nlist *symbols,
	const struct nlist_64 *symbols64,
	const NSUInteger nsymbols,
	const char *strings,
	const NSUInteger strings_size,
	const struct symbol *sorted_symbols,
	const NSUInteger nsorted_symbols,
	const NSUInteger verbose
) {

	uint64_t offset;

//putback	uint32_t sect_offset = addr + *length - sect_addr;
	*value = get_value(value_size, sect, length, left);
//putback	GET_SYMBOL(symadd, symsub, &offset, sect_offset, *value);
//putback	if(*symadd == NULL){
//putback		*symadd = GUESS_SYMBOL(*value);
//putback		if(*symadd != NULL)
//putback			*value = 0;
//putback	} else if(*symsub != NULL){
//putback		*value = offset;
//putback	}
}

/*
 * displacement() is used to return the symbolic operand for an operand that is
 * encoded as a displacement from the program counter.
 */
static void displacement(
const char **symadd,
const char **symsub,
uint64 *value,
const NSUInteger value_size,

const char *sect,
const char *sect_addr,
NSUInteger *length,
uint64 *left,

const cpu_type_t cputype,
const char *addr,
const struct relocation_info *sorted_relocs,
const NSUInteger nsorted_relocs,
const struct nlist *symbols,
const struct nlist_64 *symbols64,
const NSUInteger nsymbols,
const char *strings,
const NSUInteger strings_size,

const struct symbol *sorted_symbols,
const NSUInteger nsorted_symbols,
const NSUInteger verbose)
{
	uint64 sect_offset;
	uint64_t offset;
	uint64_t guess_addr;

	sect_offset = (uint64)addr + *length - (uint64)sect_addr;
	*value = get_value(value_size, sect, length, left);
	switch(value_size){
		case 1:
			if((*value) & 0x80)
				*value = *value | 0xffffff00;
			break;
		case 2:
			if((*value) & 0x8000)
				*value = *value | 0xffff0000;
			break;
	}
	if((cputype & CPU_ARCH_ABI64) != CPU_ARCH_ABI64)
	    *value = *value + (uint64)addr + *length;

//	GET_SYMBOL(symadd, symsub, &offset, sect_offset, *value);
//	if(*symadd == NULL){
	    if((cputype & CPU_ARCH_ABI64) != CPU_ARCH_ABI64)
		{
//			*symadd = GUESS_SYMBOL(*value);
//			if(*symadd != NULL)
//				*value = 0;
	    } else {
//			guess_addr = *value;
//			if((*value) & 0x80000000)
//				guess_addr |= 0xffffffff00000000ULL;
//			guess_addr += addr + *length;
//			*symadd = GUESS_SYMBOL(guess_addr);
//			if(*symadd != NULL)
//				*value = 0;
//			else
				*value += (uint64)addr + *length;
	    }
//	} else if(*symsub != NULL){
//	    *value = offset;
//	}
}


//static void get_symbol(
//const char **symadd,
//const char **symsub,
//uint64_t *offset,
//const cpu_type_t cputype,
//const uint32_t sect_offset,
//const uint64_t value,
//const struct relocation_info *relocs,
//const uint32_t nrelocs,
//const struct nlist *symbols,
//const struct nlist_64 *symbols64,
//const NSUInteger nsymbols,
//const char *strings,
//const NSUInteger strings_size,
//const struct symbol *sorted_symbols,
//const NSUInteger nsorted_symbols,
//const int verbose)
//{
//    uint32_t i;
//    unsigned int r_symbolnum;
//    uint32_t n_strx;
//    struct scattered_relocation_info *sreloc, *pair;
//    const char *name, *add, *sub;
//
//    static char add_buffer[11]; /* max is "0x1234678\0" */
//    static char sub_buffer[11];
//
//	*symadd = NULL;
//	*symsub = NULL;
//	*offset = value;
//
////if(verbose == FALSE)
////    return;
//
//for(i = 0; i < nrelocs; i++){
//    if((cputype & CPU_ARCH_ABI64) != CPU_ARCH_ABI64 &&
//       ((relocs[i].r_address) & R_SCATTERED) != 0){
//	sreloc = (struct scattered_relocation_info *)(relocs + i);
//	if(sreloc->r_type == GENERIC_RELOC_PAIR){
//	    fprintf(stderr, "Stray GENERIC_RELOC_PAIR relocation entry "
//		    "%u\n", i);
//	    continue;
//	}
//	if(sreloc->r_type == GENERIC_RELOC_VANILLA){
//	    if(sreloc->r_address == sect_offset){
//		name = guess_symbol(sreloc->r_value, sorted_symbols, nsorted_symbols, verbose);
//		if(name != NULL){
//		    *symadd = name;
//		    *offset = value - sreloc->r_value;
//		    return;
//		}
//	    }
//	    continue;
//	}
//	if(sreloc->r_type != GENERIC_RELOC_SECTDIFF &&
//	   sreloc->r_type != GENERIC_RELOC_LOCAL_SECTDIFF){
//	    fprintf(stderr, "Unknown relocation r_type for entry %u\n", i);
//	    continue;
//	}
//	if(i + 1 < nrelocs){
//	    pair = (struct scattered_relocation_info *)(relocs + i + 1);
//	    if(pair->r_scattered == 0 ||
//	       pair->r_type != GENERIC_RELOC_PAIR){
//		fprintf(stderr, "No GENERIC_RELOC_PAIR relocation entry after entry %u\n", i);
//		continue;
//	    }
//	}
//	else {
//	    fprintf(stderr, "No GENERIC_RELOC_PAIR relocation entry after entry %u\n", i);
//	    continue;
//	}
//	i++; /* skip the pair reloc */
//
//	if(sreloc->r_address == sect_offset){
//	    add = guess_symbol(sreloc->r_value, sorted_symbols, nsorted_symbols, verbose);
//		sub = guess_symbol(pair->r_value, sorted_symbols, nsorted_symbols, verbose);
//		    if(add == NULL){
//			sprintf(add_buffer, "0x%x", (unsigned int)sreloc->r_value);
//			add = add_buffer;
//		    }
//		    if(sub == NULL){
//			sprintf(sub_buffer, "0x%x", (unsigned int)pair->r_value);
//			sub = sub_buffer;
//		    }
//		    *symadd = add;
//		    *symsub = sub;
//		    *offset = value - (sreloc->r_value - pair->r_value);
//		    return;
//		}
//	    }
//	    else {
//		if((uint32_t)relocs[i].r_address == sect_offset){
//		    r_symbolnum = relocs[i].r_symbolnum;
//		    if(relocs[i].r_extern){
//		        if(r_symbolnum >= nsymbols)
//			    return;
//			if(symbols != NULL)
//			    n_strx = symbols[r_symbolnum].n_un.n_strx;
//			else
//			    n_strx = symbols64[r_symbolnum].n_un.n_strx;
//			if(n_strx <= 0 || n_strx >= strings_size)
//			    return;
//			*symadd = strings + n_strx;
//			return;
//		    }
//		    break;
//		}
//	    }
//	}
//}

/*
 * print_operand() prints an operand from it's broken out symbolic
 * representation.
 */


//static void replacementPrint_operand( char *outPutBuffer, struct HooReg *segReg, const char *symadd, const char *symsub, uint64_t value, NSUInteger value_size, const char *result, const char *tail) {
//
//	if(symadd != NULL){
//	    if(symsub != NULL){
//			if(value_size != 0){
//				if(value != 0)
//					sprintf( outPutBuffer, "%s%s-%s+0x%0*llx%s%s", segReg->name, symadd, symsub, (int)value_size * 2, value, result, tail);
//				else
//					sprintf( outPutBuffer, "%s%s-%s%s%s", segReg->name, symadd, symsub, result, tail);
//				
//			} else {
//				sprintf( outPutBuffer, "%s%s%s%s", segReg->name, symadd, result, tail);
//			}
//	    } else {
//			if(value_size != 0){
//				if(value != 0)
//					sprintf( outPutBuffer, "%s%s+0x%0*llx%s%s", segReg->name, symadd, (int)value_size * 2, value, result, tail);
//				else
//					sprintf( outPutBuffer, "%s%s%s%s", segReg->name, symadd, result, tail);
//			} else {
//				sprintf( outPutBuffer, "%s%s%s%s", segReg->name, symadd, result, tail);
//			}
//	    }
//	} else {
//	    if(value_size != 0){
//			sprintf( outPutBuffer, "%s0x%0*llx%s%s", segReg->name, (int)value_size *2, value, result, tail);
//	    } else {
//			sprintf( outPutBuffer, "%s%s%s", segReg?segReg->name:"", result, tail);
//	    }
//	}
//}

//static void print_operand( const char *seg, const char *symadd, const char *symsub, uint64_t value, unsigned int value_size, const char *result, const char *tail) {
//	
//	if(symadd != NULL){
//	    if(symsub != NULL){
//			if(value_size != 0){
//				if(value != 0)
//					printf("%s%s-%s+0x%0*llx%s%s", seg, symadd, symsub, (int)value_size * 2, value, result, tail);
//				else
//					printf("%s%s-%s%s%s", seg, symadd, symsub, result, tail);
//
//			} else {
//				printf("%s%s%s%s", seg, symadd, result, tail);
//			}
//	    }
//	    else {
//		if(value_size != 0){
//		    if(value != 0)
//				printf("%s%s+0x%0*llx%s%s", seg, symadd, (int)value_size * 2, value, result, tail);
//		    else
//				printf("%s%s%s%s", seg, symadd, result, tail);
//		} else {
//		    printf("%s%s%s%s", seg, symadd, result, tail);
//		}
//	    }
//	} else {
//	    if(value_size != 0){
//			printf("%s0x%0*llx%s%s", seg, (int)value_size *2, value, result, tail);
//	    } else {
//			printf("%s%s%s", seg, result, tail);
//	    }
//	}
//}

/*
 * get_value() gets a value of size from sect + length and decrease left by the
 * size and increase length by size.  The size of the value can be 1, 2, 4, or 8
 * bytes and the value is in little endian byte order.  The value is always
 * returned as a uint64_t and is not sign extended.
 */
static uint64_t get_value(
const NSUInteger size,	/* size of the value to get as a number of bytes (in)*/
const char *sect,		/* pointer to the raw data of the section (in) */
NSUInteger *length,		/* number of bytes taken from the sect (in/out) */
uint64 *left)			/* number of bytes left in sect after length (in/out) */
{
    unsigned char byte;

	if(left==0)
	    return(0);

	uint64_t value = 0;
	for( NSUInteger i=0; i<size; i++) {
	    byte = 0;
	    if(*left > 0){
			byte = sect[*length];
			(*length)++;
			(*left)--;
	    }
	    value |= (uint64_t)byte << (8*i);
	}
	return(value);
}

/*
 * modrm_byte() breaks a byte out into its mode, reg and r/m bits.
 */
static void modrm_byte(
uint32_t *mode,
uint32_t *reg,
uint32_t *r_m,
unsigned char byte)
{
	uint32_t rmTemp = byte & 0x7; /* r/m field from the byte */
	uint32_t regTemp = byte >> 3 & 0x7; /* register field from the byte */
	uint32_t modeTemp = byte >> 6 & 0x3; /* mode field from the byte */
	*r_m = rmTemp;
	*reg = regTemp;
	*mode = modeTemp;
}
