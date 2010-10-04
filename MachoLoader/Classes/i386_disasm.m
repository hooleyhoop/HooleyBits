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

#define MAX_MNEMONIC	11	/* Maximum number of chars per mnemonic, plus a byte for '\0' */
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

extern struct symbol;

enum argType {
	NULL_ARG,
	REGISTER_ARG,
	IMMEDIATE_ARG,
	INDIRECT_ARG,
	DISPLACEMENT_ARG
};

struct HooAbstractDataType {
	enum argType isah;
};

struct HooReg {
	enum argType		isah;
	char				name[MAX_MNEMONIC];
	char				prettyName[40];	
};

//struct BonkersHooReg {
//	enum argType		isah;
//	char				name1[MAX_MNEMONIC];
//	char				name2[MAX_MNEMONIC];
//	char				prettyName1[40];	
//	char				prettyName2[40];	
//};

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
	enum argType		isah;
	const struct HooReg	*segmentRegister;
	uint64				displacement;
	struct HooReg		*baseRegister;
	struct HooReg		*indexRegister;
	NSUInteger			scale;
};

#define NEW_INDIRECT( x,segReg,displace,baseReg,indexReg,scaleSize) x=calloc(1, sizeof(struct IndirectVal)); x->isah=INDIRECT_ARG; x->segmentRegister=segReg; x->displacement=displace; x->baseRegister=baseReg; x->indexRegister=indexReg; x->scale=scaleSize;

#define NEW_IMMEDIATE( immedStructPtr, immVal ) immedStructPtr = calloc(1, sizeof(struct ImediateValue)); immedStructPtr->isah=IMMEDIATE_ARG; immedStructPtr->value=immVal;

#define NEW_DISPLACEMENT( displaceStructPtr, intVal ) displaceStructPtr = calloc(1, sizeof(struct DisplacementValue)); displaceStructPtr->isah=DISPLACEMENT_ARG; displaceStructPtr->value=intVal;


/*
 * This is the structure that is used for storing all the op code information.
 */
struct instable {
	char name[MAX_MNEMONIC];
	const struct instable *indirect;
	unsigned adr_mode;
	int flags;
	const struct instable *arch64;
	char *printStr;
	
#define ISJUMP 1		// ie. does this change the execution flow
#define ISBRANCH 2		// ie. does this conditionally change the execution flow
#define ISCOMPARE 4
#define NOTUSED 8	
	// notused isCompare isBranch isJump
	// ie
	uint16 typeBitField;
};
#define	TERM	0	/* used to indicate that the 'indirect' field of the */
			/* 'instable' terminates - no pointer.	*/
#define	INVALID	{"",TERM,UNKNOWN,0}
/*
 * These are defined this way to make the initializations in the tables simpler
 * and more readable for differences between 32-bit and 64-bit architectures.
 */
#define	INVALID_32 "",TERM,UNKNOWN,0
static const struct instable op_invalid_64 = {"",TERM,/* UNKNOWN */0,0};
#define INVALID_64 (&op_invalid_64)

/* Flags */
#define HAS_SUFFIX			0x1	/* For instructions which may have a 'w', 'l', or 'q' suffix */
#define IS_POINTER_SIZED	0x2	/* For instructions which implicitly have operands which are sizeof(void *) */

void hooleyDebug() {
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
										  uint64 sect_addr,
										  NSUInteger *length,
										  uint64 *left,
										  const uint64 addr,
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
//);

//static void immediate(
//	const char **symadd,
//	const char **symsub,
//	uint64_t *value,
//	uint32_t value_size,
//	const char *sect,
//	uint32_t sect_addr,
//	uint32_t *length,
//	uint32_t *left,
//	const cpu_type_t cputype,
//	const uint32_t addr,
//	const struct relocation_info *sorted_relocs,
//	const uint32_t nsorted_relocs,
//	const struct nlist *symbols,
//	const struct nlist_64 *symbols64,
//	const NSUInteger nsymbols,
//	const char *strings,
//	const NSUInteger strings_size,
//	const struct symbol *sorted_symbols,
//	const NSUInteger nsorted_symbols,
//	const int verbose
//);
static void replacement_immediate(
					  const char **symadd,
					  const char **symsub,
					  uint64_t *value,
					  NSUInteger value_size,
					  const char *sect,
					  uint64 sect_addr,
					  NSUInteger *length,
					  uint64 *left,
					  const cpu_type_t cputype,
					  const uint64 addr,
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
    uint64_t sect_addr,
    NSUInteger *length,
    uint64 *left,
    const cpu_type_t cputype,
    const uint64_t addr,
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

//static void get_symbol(
//    const char **symadd,
//    const char **symsub,
//    uint64_t *offset,
//    const cpu_type_t cputype,
//    const uint32_t sect_offset,
//    const uint64_t value,
//    const struct relocation_info *relocs,
//    const uint32_t nrelocs,
//    const struct nlist *symbols,
//    const struct nlist_64 *symbols64,
//    const NSUInteger nsymbols,
//    const char *strings,
//    const NSUInteger strings_size,
//    const struct symbol *sorted_symbols,
//    const NSUInteger nsorted_symbols,
//    const int verbose);


//static void print_operand( const char *seg, const char *symadd, const char *symsub, uint64_t value, NSUInteger value_size, const char *result, const char *tail);
//static void replacementPrint_operand( char *outPutBuffer, struct HooReg *segReg, const char *symadd, const char *symsub, uint64_t value, NSUInteger value_size, const char *result, const char *tail);
static uint64_t get_value( const NSUInteger size, const char *sect, NSUInteger *length, uint64 *left);
static void modrm_byte( NSUInteger *mode, NSUInteger *reg, NSUInteger *r_m, unsigned char byte);

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

//#define IMMEDIATE(symadd, symsub, value, value_size) \
//immediate((symadd), (symsub), (value), (value_size), sect, sect_addr, \
//&length, &left, cputype, addr, sorted_relocs, \
//nsorted_relocs, symbols, symbols64, nsymbols, strings, \
//strings_size, sorted_symbols, nsorted_symbols, verbose)

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

/*
 * These are the instruction formats as they appear in the disassembly tables.
 * Here they are given numerical values for use in the actual disassembly of
 * an instruction.
 */
#define UNKNOWN	0
#define MRw	2
#define IMlw	3
#define IMw	4
#define IR	5
#define OA	6
#define AO	7
#define MS	8
#define SM	9
#define Mv	10
#define Mw	11
#define M	12
#define R	13
#define RA	14
#define SEG	15
#define MR	16
#define IA	17
#define MA	18
#define SD	19
#define AD	20
#define SA	21
#define D	22
#define INM	23
#define SO	24
#define BD	25
#define I	26
#define P	27
#define V	28
#define DSHIFT	29 /* for double shift that has an 8-bit immediate */
#define U	30
#define OVERRIDE 31
#define GO_ON	32
#define O	33	/* for call	*/
#define JTAB	34	/* jump table (not used at NeXT) */
#define IMUL	35	/* for 186 iimul instr  */
#define CBW 36 /* so that data16 can be evaluated for cbw and its variants */
#define MvI	37	/* for 186 logicals */
#define ENTER	38	/* for 186 enter instr  */
#define RMw	39	/* for 286 arpl instr */
#define Ib	40	/* for push immediate byte */
#define F	41	/* for 287 instructions */
#define FF	42	/* for 287 instructions */
#define DM	43	/* 16-bit data */
#define AM	44	/* 16-bit addr */
#define LSEG	45	/* for 3-bit seg reg encoding */
#define MIb	46	/* for 386 logicals */
#define SREG	47	/* for 386 special registers */
#define PREFIX	48	/* an instruction prefix like REP, LOCK */
#define INT3	49	/* The int 3 instruction, which has a fake operand */
#define DSHIFTcl 50	/* for double shift that implicitly uses %cl */
#define CWD	51	/* so that data16 can be evaluated for cwd and vars */
#define RET	52	/* single immediate 16-bit operand */
#define MOVZ	53	/* for movs and movz, with different size operands */
#define XINST	54	/* for cmpxchg and xadd */
#define BSWAP	55	/* for bswap */
#define Pi	56
#define Po	57
#define Vi	58
#define Vo	59
#define Mb	60
#define INMl	61
#define SSE2	62	/* SSE2 instruction with possible 3rd opcode byte */
#define SSE2i	63	/* SSE2 instruction with 8-bit immediate */
#define SSE2i1	64	/* SSE2 with one operand and 8-bit immediate */
#define SSE2tm	65	/* SSE2 with dest to memory */
#define SSE2tfm	66	/* SSE2 with dest to memory or memory to dest */
#define PFCH	67	/* prefetch instructions */
#define SFEN	68	/* sfence & clflush */
#define Mnol	69	/* no 'l' suffix, fildl, fistpl */
#define AMD3DNOW       70  /* 3DNow! instruction (SSE2 format with a suffix) */
#define PFCH3DNOW      71  /* 3DNow! prefetch instruction */
#define REX	72		/* 64-bit REX prefix */
#define IR64 73		/* IR with a 64-bit immediate if REX.W is set */
#define MNI 74		/* MNI instruction, differentiated by 2nd and 3rd opcode bytes */
#define MNIi 75		/* MNI instruction with 8-bit immediate, differentiated by 2nd and 3rd opcode bytes */
#define SSE4	76	/* SSE4 instruction with 3rd & 4th opcode bytes */
#define SSE4i	77	/* SSE4 instruction with 8-bit immediate */
#define SSE4itm	78	/* SSE4 with dest to memory and 8-bit immediate */
#define SSE4ifm	79	/* SSE4 with src from memory and 8-bit immediate */
#define SSE4MRw	80	/* SSE4.2 memory or register operand to register */
#define SSE4CRC	81	/* SSE4.2 crc memory or register operand to register */
#define SSE4CRCb	82	/* SSE4.2 crc byte memory or register operand to register */

/*
 * In 16-bit addressing mode:
 * Register operands may be indicated by a distinguished field.
 * An '8' bit register is selected if the 'w' bit is equal to 0,
 * and a '16' bit register is selected if the 'w' bit is equal to
 * 1 and also if there is no 'w' bit.
 */
//static const char * const REG16[8][2] = {
///* w bit		0		1		*/
///* reg bits */
///* 000	*/		{"%al",		"%ax"},
///* 001  */		{"%cl",		"%cx"},
///* 010  */		{"%dl",		"%dx"},
///* 011	*/		{"%bl",		"%bx"},
///* 100	*/		{"%ah",		"%sp"},
///* 101	*/		{"%ch",		"%bp"},
///* 110	*/		{"%dh",		"%si"},
///* 111	*/		{"%bh",		"%di"}
//};

/*
 * In 32-bit or 64-bit addressing mode:
 * Register operands may be indicated by a distinguished field.
 * An '8' bit register is selected if the 'w' bit is equal to 0,
 * and a '32' bit register is selected if the 'w' bit is equal to
 * 1 and also if there is no 'w' bit.
 */
//static const char * const REG32[16][3] = {
///* w bit		0				1			1 + REX.W	*/
///* reg bits */
///* 0000	*/		{"%al",			"%eax",			"%rax"},
///* 0001  */		{"%cl",			"%ecx",			"%rcx"},
///* 0010  */		{"%dl",			"%edx",			"%rdx"},
///* 0011	*/		{"%bl",			"%ebx",			"%rbx"},
///* 0100	*/		{"%ah",			"%esp",			"%rsp"},
///* 0101	*/		{"%ch",			"%ebp",			"%rbp"},
///* 0110	*/		{"%dh",			"%esi",			"%rsi"},
///* 0111	*/		{"%bh",			"%edi",			"%rdi"},
///* 1000	*/		{"%r8b",		"%r8d",			"%r8"},
///* 1001 */		{"%r9b",		"%r9d",			"%r9"},
///* 1010 */		{"%r10b",		"%r10d",		"%r10"},
///* 1011	*/		{"%r11b",		"%r11d",		"%r11"},
///* 1100	*/		{"%r12b",		"%r12d",		"%r12"},
///* 1101	*/		{"%r13b",		"%r13d",		"%r13"},
///* 1110	*/		{"%r14b",		"%r14d",		"%r14"},
///* 1111	*/		{"%r15b",		"%r15d",		"%r15"}
//};


static const struct HooReg acuml =						{REGISTER_ARG,"%al","%accumulator"};
static const struct HooReg acumx =						{REGISTER_ARG,"%ax","%accumulator"};
static const struct HooReg acumex =					{REGISTER_ARG,"%eax","%accumulator"};
static const struct HooReg dataReg =					{REGISTER_ARG,"%%dx","%data"};
static const struct HooReg countReg =					{REGISTER_ARG,"%cl","%count"};
static const struct HooReg source_indexReg =			{REGISTER_ARG,"%esi","%source_index"};
static const struct HooReg destination_indexReg =	{REGISTER_ARG,"%edi","%destination_index"};
static const struct HooReg base1 =						{REGISTER_ARG,"%bx","%base"};
static const struct HooReg sourceIndex1 =				{REGISTER_ARG,"%si","%source_index"};
static const struct HooReg code_seg_reg =				{REGISTER_ARG,"%cs","code_seg_reg"};
static const struct HooReg data_seg_reg =				{REGISTER_ARG,"%es","string_operation_dest_seg_reg"};
static const struct HooReg data_seg_reg2 =			{REGISTER_ARG,"%es","data_seg_reg"};
static const struct HooReg stack_seg_reg =			{REGISTER_ARG,"%ss","stack_seg_reg"};

static const struct HooReg REG16_Struct[8][2] = {
	{ {REGISTER_ARG,"%al","%accumulator"},
		{REGISTER_ARG,"%ax","%accumulator"} }, // al=low-byte, ah=high-byte, etc
	{ {REGISTER_ARG,"%cl","%count"},
		{REGISTER_ARG,"%cx","%count"} },
	{ {REGISTER_ARG,"%dl","%data"},
		{REGISTER_ARG,"%dx","%data"} },
	{ {REGISTER_ARG,"%bl","%base"},
		{REGISTER_ARG,"%bx","%base"} },
	{ {REGISTER_ARG,"%ah","%accumulator"},
		{REGISTER_ARG,"%sp","%stackPointer_top"} },
	{ {REGISTER_ARG,"%ch","%count"},
		{REGISTER_ARG,"%bp","%stackPointer_base"} },
	{ {REGISTER_ARG,"%dh","%data"},
		{REGISTER_ARG,"%si","%source_index"} },
	{ {REGISTER_ARG,"%bh","%base"},
		{REGISTER_ARG,"%di","%destination_index"} }
};

static const struct HooReg REG32_Struct[16][3] = {
	{ {REGISTER_ARG,"%al","%accumulator"},	{REGISTER_ARG,"%eax","%accumulator"},		{REGISTER_ARG,"%rax","%accumulator"} },
	{ {REGISTER_ARG,"%cl","%count"},		{REGISTER_ARG,"%ecx","%count"},			{REGISTER_ARG,"%rcx","%count"} },
	{ {REGISTER_ARG,"%dl","%data"},		{REGISTER_ARG,"%edx","%data"},				{REGISTER_ARG,"%rdx","%data"} },
	{ {REGISTER_ARG,"%bl","%base"},		{REGISTER_ARG,"%ebx","%base"},				{REGISTER_ARG,"%rbx","%base"} },
	{ {REGISTER_ARG,"%ah","%accumulator"},	{REGISTER_ARG,"%esp","%stackPointer_top"},	{REGISTER_ARG,"%rsp","%stackPointer_top"} },
	{ {REGISTER_ARG,"%ch","%count"},		{REGISTER_ARG,"%ebp","%stackPointer_base"},{REGISTER_ARG,"%rbp","%stackPointer_base"} },
	{ {REGISTER_ARG,"%dh","%data"},		{REGISTER_ARG,"%esi","%source_index"},		{REGISTER_ARG,"%rsi","%source_index"} },
	{ {REGISTER_ARG,"%bh","%base"},		{REGISTER_ARG,"%edi","%destination_index"},{REGISTER_ARG,"%rdi","%destination_index"} },
	{ {REGISTER_ARG,"%r8b","%reg8"},		{REGISTER_ARG,"%r8d","%reg8"},				{REGISTER_ARG,"%r8","%reg8"} },
	{ {REGISTER_ARG,"%r9b","%reg9"},		{REGISTER_ARG,"%r9d","%reg9"},				{REGISTER_ARG,"%r9","%reg9"} },
	{ {REGISTER_ARG,"%r10b","%reg10"},		{REGISTER_ARG,"%r10d","%reg10"},			{REGISTER_ARG,"%r10","%reg10"} },
	{ {REGISTER_ARG,"%r11b","%reg11"},		{REGISTER_ARG,"%r11d","%reg11"},			{REGISTER_ARG,"%r11","%reg11"} },
	{ {REGISTER_ARG,"%r12b","%reg12"},		{REGISTER_ARG,"%r12d","%reg12"},			{REGISTER_ARG,"%r12","%reg12"} },
	{ {REGISTER_ARG,"%r13b","%reg13"},		{REGISTER_ARG,"%r13d","%reg13"},			{REGISTER_ARG,"%r13","%reg13"} },
	{ {REGISTER_ARG,"%r14b","%reg14"},		{REGISTER_ARG,"%r14d","%reg14"},			{REGISTER_ARG,"%r14","%reg14"} },
	{ {REGISTER_ARG,"%r15b","%reg15"},		{REGISTER_ARG,"%r15d","%reg15"},			{REGISTER_ARG,"%r15","%reg15"} }
};



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

/*
 * When data16 has been specified, the following array specifies the registers
 * for the different addressing modes.  Indexed first by mode, then by register
 * number.
 */
static const char * const regname16[4][8] = {
/*reg  000        001        010        011        100    101   110     111 */
/*mod*/
/*00*/{"%bx,%si", "%bx,%di", "%bp,%si", "%bp,%di", "%si", "%di", "",    "%bx"},
/*01*/{"%bx,%si", "%bx,%di", "%bp,%si", "%bp,%di", "%si", "%di", "%bp", "%bx"},
/*10*/{"%bx,%si", "%bx,%di", "%bp,%si", "%bp,%di", "%si", "%di", "%bp", "%bx"},
/*11*/{"%ax",     "%cx",     "%dx",     "%bx",     "%sp", "%bp", "%si", "%di"}
};

// Return bonkers double reg
static const struct HooReg regname16_Struct[4][8][2] = {
	{
		{{REGISTER_ARG,"%bx","%base"},					{REGISTER_ARG,"%si","%source_index"}},
		{{REGISTER_ARG,"%bx","%base"},					{REGISTER_ARG,"%di","%destination_index"}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%si","%source_index"}}, 
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%di","%destination_index"}},
		{{REGISTER_ARG,"%si","%source_index"},		{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%di","%destination_index"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"",""},							{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bx","%base"},					{NULL_ARG,"",""}}	
	},
	{	{{REGISTER_ARG,"%bx,","%base,"},				{REGISTER_ARG,"%si"," %source_index"}},
		{{REGISTER_ARG,"%bx,","%base,"},				{REGISTER_ARG,"%di"," %destination_index"}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%si","%source_index"}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%di","%destination_index"}},
		{{REGISTER_ARG,"%si","%source_index"},		{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%di","%destination_index"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bx","%base"},					{NULL_ARG,"",""}}
	},
		{{{REGISTER_ARG,"%bx","%base"},				{REGISTER_ARG,"%si","%source_index"}},
		{{REGISTER_ARG,"%bx","%base"},					{REGISTER_ARG,"%di","%destination_index"}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%si","%source_index"}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{REGISTER_ARG,"%di","%destination_index"}},
		{{REGISTER_ARG,"%si","%source_index"},		{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%di","%destination_index"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bx","%base"},					{NULL_ARG,"",""}}
	},
	{	{{REGISTER_ARG,"%ax","%accumulator"},			{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%cx","%count"},				{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%dx","%data"},					{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bx","%base"},					{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%sp","%stackPointer_top"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%bp","%stackPointer_base"},	{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%si","%source_index"},		{NULL_ARG,"",""}},
		{{REGISTER_ARG,"%di","%destination_index"},	{NULL_ARG,"",""}}
	}
};
 
/*
 * When data16 has not been specified, fields, to determine the addressing mode,
 * and will also provide strings for printing.
 */
static const char * const regname32[4][8] = {
/*reg   000     001     010     011     100     101    110     111 */
/*mod*/
/*00 */{"%eax", "%ecx", "%edx", "%ebx", "%esp", "",     "%esi", "%edi"},
/*01 */{"%eax", "%ecx", "%edx", "%ebx", "%esp", "%ebp", "%esi", "%edi"},
/*10 */{"%eax", "%ecx", "%edx", "%ebx", "%esp", "%ebp", "%esi", "%edi"},
/*11 */{"%eax", "%ecx", "%edx", "%ebx", "%esp", "%ebp", "%esi", "%edi"}
};
static const struct HooReg regname32_Struct[4][8] = {
{ {REGISTER_ARG,"%eax","%accumulator"}, {REGISTER_ARG,"%ecx","%count"}, {REGISTER_ARG,"%edx","%data"}, {REGISTER_ARG,"%ebx","%base"}, {REGISTER_ARG,"%esp","%stackPointer_top"}, {REGISTER_ARG,"",""},						{REGISTER_ARG,"%esi","%source_index"}, {REGISTER_ARG,"%edi","%destination_index"}	},
{ {REGISTER_ARG,"%eax","%accumulator"}, {REGISTER_ARG,"%ecx","%count"}, {REGISTER_ARG,"%edx","%data"}, {REGISTER_ARG,"%ebx","%base"}, {REGISTER_ARG,"%esp","%stackPointer_top"}, {REGISTER_ARG,"%ebp","%stackPointer_base"},	{REGISTER_ARG,"%esi","%source_index"}, {REGISTER_ARG,"%edi","%destination_index"}	},
{ {REGISTER_ARG,"%eax","%accumulator"}, {REGISTER_ARG,"%ecx","%count"}, {REGISTER_ARG,"%edx","%data"}, {REGISTER_ARG,"%ebx","%base"}, {REGISTER_ARG,"%esp","%stackPointer_top"}, {REGISTER_ARG,"%ebp","%stackPointer_base"},	{REGISTER_ARG,"%esi","%source_index"}, {REGISTER_ARG,"%edi","%destination_index"}	},
{ {REGISTER_ARG,"%eax","%accumulator"}, {REGISTER_ARG,"%ecx","%count"}, {REGISTER_ARG,"%edx","%data"}, {REGISTER_ARG,"%ebx","%base"}, {REGISTER_ARG,"%esp","%stackPointer_top"}, {REGISTER_ARG,"%ebp","%stackPointer_base"},	{REGISTER_ARG,"%esi","%source_index"}, {REGISTER_ARG,"%edi","%destination_index"}	}
};

/*
 * When data16 has not been specified, fields, to determine the addressing mode,
 * and will also provide strings for printing.
 */
static const char * const regname64[4][16] = {
/*reg   0000    0001    0010    0011    0100    0101    0110    0111    1000    1001    1010    1011    1100    1101    1110    1111 */
/*mod*/
/*00 */{"%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi", "%r8",  "%r9",  "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"},
/*01 */{"%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi", "%r8",  "%r9",  "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"},
/*10 */{"%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi", "%r8",  "%r9",  "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"},
/*11 */{"%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi", "%r8",  "%r9",  "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"}
};
static const struct HooReg regname64_Struct[4][16] = {
{ {REGISTER_ARG,"%rax","%accumulator"}, {REGISTER_ARG,"%rcx","%count"}, {REGISTER_ARG,"%rdx","%data"}, {REGISTER_ARG,"%rbx","%base"}, {REGISTER_ARG,"%rsp","%stackPointer_top"}, {REGISTER_ARG,"%rbp","%stackPointer_base"}, {REGISTER_ARG,"%rsi","%source_index"}, {REGISTER_ARG,"%rdi","%destination_index"}, {REGISTER_ARG,"%r8","%reg8"},  {REGISTER_ARG,"%r9","%reg9"},  {REGISTER_ARG,"%r10","%reg10"}, {REGISTER_ARG,"%r11","%reg11"}, {REGISTER_ARG,"%r12","%reg12"}, {REGISTER_ARG,"%r13","%reg13"}, {REGISTER_ARG,"%r14","%reg14"}, {REGISTER_ARG,"%r15","%reg15"}	},
{ {REGISTER_ARG,"%rax","%accumulator"}, {REGISTER_ARG,"%rcx","%count"}, {REGISTER_ARG,"%rdx","%data"}, {REGISTER_ARG,"%rbx","%base"}, {REGISTER_ARG,"%rsp","%stackPointer_top"}, {REGISTER_ARG,"%rbp","%stackPointer_base"}, {REGISTER_ARG,"%rsi","%source_index"}, {REGISTER_ARG,"%rdi","%destination_index"}, {REGISTER_ARG,"%r8","%reg8"},  {REGISTER_ARG,"%r9","%reg9"},  {REGISTER_ARG,"%r10","%reg10"}, {REGISTER_ARG,"%r11","%reg11"}, {REGISTER_ARG,"%r12","%reg12"}, {REGISTER_ARG,"%r13","%reg13"}, {REGISTER_ARG,"%r14","%reg14"}, {REGISTER_ARG,"%r15","%reg15"}	},
{ {REGISTER_ARG,"%rax","%accumulator"}, {REGISTER_ARG,"%rcx","%count"}, {REGISTER_ARG,"%rdx","%data"}, {REGISTER_ARG,"%rbx","%base"}, {REGISTER_ARG,"%rsp","%stackPointer_top"}, {REGISTER_ARG,"%rbp","%stackPointer_base"}, {REGISTER_ARG,"%rsi","%source_index"}, {REGISTER_ARG,"%rdi","%destination_index"}, {REGISTER_ARG,"%r8","%reg8"},  {REGISTER_ARG,"%r9","%reg9"},  {REGISTER_ARG,"%r10","%reg10"}, {REGISTER_ARG,"%r11","%reg11"}, {REGISTER_ARG,"%r12","%reg12"}, {REGISTER_ARG,"%r13","%reg13"}, {REGISTER_ARG,"%r14","%reg14"}, {REGISTER_ARG,"%r15","%reg15"}	},
{ {REGISTER_ARG,"%rax","%accumulator"}, {REGISTER_ARG,"%rcx","%count"}, {REGISTER_ARG,"%rdx","%data"}, {REGISTER_ARG,"%rbx","%base"}, {REGISTER_ARG,"%rsp","%stackPointer_top"}, {REGISTER_ARG,"%rbp","%stackPointer_base"}, {REGISTER_ARG,"%rsi","%source_index"}, {REGISTER_ARG,"%rdi","%destination_index"}, {REGISTER_ARG,"%r8","%reg8"},  {REGISTER_ARG,"%r9","%reg9"},	{REGISTER_ARG,"%r10","%reg10"}, {REGISTER_ARG,"%r11","%reg11"}, {REGISTER_ARG,"%r12","%reg12"}, {REGISTER_ARG,"%r13","%reg13"}, {REGISTER_ARG,"%r14","%reg14"}, {REGISTER_ARG,"%r15","%reg15"}	}
};

/*
 * If r/m==100 then the following byte (the s-i-b byte) must be decoded
 */
static const int const scale_factor[4] = { 1, 2, 4, 8 };

static const char * const indexname[8] = {
    ",%eax",
    ",%ecx",
    ",%edx",
    ",%ebx",
    "",
    ",%ebp",
    ",%esi",
    ",%edi"
};

static const struct HooReg indexname_Struct[8] = {
    {REGISTER_ARG,"%eax","%accumulator"},
    {REGISTER_ARG,"%ecx","%count"},
    {REGISTER_ARG,"%edx","%data"},
    {REGISTER_ARG,"%ebx","%base"},
    {REGISTER_ARG,"",""},
    {REGISTER_ARG,"%ebp","%stackPointer_base"},
    {REGISTER_ARG,"%esi","%source_index"},
    {REGISTER_ARG,"%edi","%destination_index"}
};

static const struct HooReg indexname64_Struct[16] = {
	{REGISTER_ARG,"%rax","%accumulator"},
	{REGISTER_ARG,"%rcx","%count"},
	{REGISTER_ARG,"%rdx","%data"},
	{REGISTER_ARG,"%rbx","%base"},
	{REGISTER_ARG,"",""},
	{REGISTER_ARG,"%rbp","%stackPointer_base"},
	{REGISTER_ARG,"%rsi","%source_index"},
	{REGISTER_ARG,"%rdi","%destination_index"},
	{REGISTER_ARG,"%r8","%reg8"},
	{REGISTER_ARG,"%r9","%reg9"},
	{REGISTER_ARG,"%r10","%reg10"},
	{REGISTER_ARG,"%r11","%reg11"},
	{REGISTER_ARG,"%r12","%reg12"},
	{REGISTER_ARG,"%r13","%reg13"},
	{REGISTER_ARG,"%r14","%reg14"},
	{REGISTER_ARG,"%r15","%reg15"}
};

static const struct HooReg xmmReg_Struct[8] = {
	// can't think of any useful pretty strings
{REGISTER_ARG,"%xmm0","%xmm0"},
{REGISTER_ARG,"%xmm1","%xmm1"},
{REGISTER_ARG,"%xmm2","%xmm2"},
{REGISTER_ARG,"%xmm3","%xmm3"},
{REGISTER_ARG,"%xmm4","%xmm4"},
{REGISTER_ARG,"%xmm5","%xmm5"},
{REGISTER_ARG,"%xmm6","%xmm6"},
{REGISTER_ARG,"%xmm7","%xmm7"}
};

static const char * const indexname64[16] = {
    ",%rax",
    ",%rcx",
    ",%rdx",
    ",%rbx",
    "",
    ",%rbp",
    ",%rsi",
    ",%rdi",
	",%r8",
	",%r9",
	",%r10",
	",%r11",
	",%r12",
	",%r13",
	",%r14",
	",%r15"
};

/*
 * Segment registers are selected by a two or three bit field.
 */
static const struct HooReg SEGREG[8] = {
{REGISTER_ARG,"%es","string_operation_dest_seg_reg"},	// data segment register (string operation destination segment)
{REGISTER_ARG,"%cs","code_seg_reg"},					// code segment register
{REGISTER_ARG,"%ss","stack_seg_reg"},					// stack segment register
{REGISTER_ARG,"%ds","data_seg_reg"},					// data segment register
{REGISTER_ARG,"%fs","data_seg_reg"},					// data segment register
{REGISTER_ARG,"%gs","data_seg_reg"},					// data segment register
{REGISTER_ARG,"%?6","%??Reg"},							// 
{REGISTER_ARG,"%?7","%??Reg"},							// 
};

/*
 * Special Registers
 */
static const char * const DEBUGREG[] = {
	"%db0", "%db1", "%db2", "%db3", "%db4", "%db5", "%db6", "%db7",
	"%db8", "%db9", "%db10", "%db11", "%db12", "%db13", "%db14", "%db15"
};

static const char * const CONTROLREG[] = {
	"%cr0", "%cr1", "%cr2", "%cr3", "%cr4", "%cr5", "%cr6", "%cr7",
	"%cr8", "%cr9", "%cr10", "%cr11", "%cr12", "%cr13", "%cr14", "%cr15"
};

static const char * const TESTREG[8] = {
    "%tr0", "%tr1", "%tr2", "%tr3", "%tr4", "%tr5", "%tr6", "%tr7"
};

/*
 * Decode table for 0x0F00 opcodes
 */
static const struct instable op0F00[8] = {
	{"sldt",TERM,M,1},
	{"str",TERM,M,1},
	{"lldt",TERM,M,1},
	{"ltr",TERM,M,1},
	{"verr",TERM,M,1},
	{"verw",TERM,M,1},
	INVALID, INVALID,
};


/*
 * Decode table for 0x0F01 opcodes
 */
static const struct instable op0F01[8] = {
	{"sgdt",TERM,M,1},
	{"sidt",TERM,M,1},
	{"lgdt",TERM,M,1},
	{"lidt",TERM,M,1},
	{"smsw",TERM,M,1},
	INVALID,
	{"lmsw",TERM,M,1},
	{"invlpg",TERM,M,1},
};

/*
 * Decode table for 0x0F38 opcodes
 */
static const struct instable op0F38[256] = {
	{"pshufb",TERM,MNI,0},
	{"phaddw",TERM,MNI,0},
	{"phaddd",TERM,MNI,0},
	{"phaddsw",TERM,MNI,0},
	{"pmaddubsw",TERM,MNI,0},
	{"phsubw",TERM,MNI,0},
	{"phsubd",TERM,MNI,0},
	{"phsubsw",TERM,MNI,0},
	{"psignb",TERM,MNI,0},
	{"psignw",TERM,MNI,0},
	{"psignd",TERM,MNI,0},
	{"pmulhrsw",TERM,MNI,0},
	INVALID, INVALID, INVALID, INVALID,
	{"pblendvb",TERM,SSE4,0},
	INVALID, INVALID, INVALID,
	{"blendvps",TERM,SSE4,0},
	{"blendvpd",TERM,SSE4,0},
	INVALID,
	{"ptest",TERM,SSE4,0},
	INVALID, INVALID, INVALID, INVALID,
	{"pabsb",TERM,MNI,0},
	{"pabsw",TERM,MNI,0},
	{"pabsd",TERM,MNI,0},
	INVALID,
	{"pmovsxbw",TERM,SSE4,0},
	{"pmovsxbd",TERM,SSE4,0},
	{"pmovsxbq",TERM,SSE4,0},
	{"pmovsxwd",TERM,SSE4,0},
	{"pmovsxwq",TERM,SSE4,0},
	{"pmovsxdq",TERM,SSE4,0},
	INVALID, INVALID,
	{"pmuldq",TERM,SSE4,0},
	{"pcmpeqq",TERM,SSE4,0},
	{"movntdqa",TERM,SSE4,0},
	{"packusdw",TERM,SSE4,0},
	INVALID, INVALID, INVALID, INVALID,
	{"pmovzxbw",TERM,SSE4,0},
	{"pmovzxbd",TERM,SSE4,0},
	{"pmovzxbq",TERM,SSE4,0},
	{"pmovzxwd",TERM,SSE4,0},
	{"pmovzxwq",TERM,SSE4,0},
	{"pmovzxdq",TERM,SSE4,0},
	INVALID,
	{"pcmpgtq",TERM,SSE4,0},
	{"pminsb",TERM,SSE4,0},
	{"pminsd",TERM,SSE4,0},
	{"pminuw",TERM,SSE4,0},
	{"pminud",TERM,SSE4,0},
	{"pmaxsb",TERM,SSE4,0},
	{"pmaxsd",TERM,SSE4,0},
	{"pmaxuw",TERM,SSE4,0},
	{"pmaxud",TERM,SSE4,0},
	{"pmulld",TERM,SSE4,0},
	{"phminposuw",TERM,SSE4,0},
	INVALID, INVALID, INVALID, INVALID,	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"crc32b",TERM,SSE4CRCb,0},
	{"crc32",TERM,SSE4CRC,1},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
};

/*
 * Decode table for 0x0F3A opcodes
 */
static const struct instable op0F3A[112] = {
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"roundps",TERM,SSE4i,0},
	{"roundpd",TERM,SSE4i,0},
 	{"roundss",TERM,SSE4i,0},
	{"roundsd",TERM,SSE4i,0},
	{"blendps",TERM,SSE4i,0},
	{"blendpd",TERM,SSE4i,0},
 	{"pblendw",TERM,SSE4i,0},
	{"palignr",TERM,MNIi,0},
	INVALID, INVALID, INVALID, INVALID,
	{"pextrb",TERM,SSE4itm,0},
	{"pextrw",TERM,SSE4itm,0},
 	{"pextr",TERM,SSE4itm,0},
	{"extractps",TERM,SSE4itm,0},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"pinsrb",TERM,SSE4ifm,0},
	{"insertps",TERM,SSE4i,0},
 	{"pinsr",TERM,SSE4ifm,0},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"dpps",TERM,SSE4i,0},
	{"dppd",TERM,SSE4i,0},
	{"mpsadbw",TERM,SSE4i,0},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"pcmpestrm",TERM,SSE4i,0},
	{"pcmpestri",TERM,SSE4i,0},
 	{"pcmpistrm",TERM,SSE4i,0},
	{"pcmpistri",TERM,SSE4i,0},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
};

static const struct instable op_monitor = {"monitor",TERM,GO_ON,0};
static const struct instable op_mwait   = {"mwait",TERM,GO_ON,0};

/* These opcode tables entries are only used for the 64-bit architecture */
static const struct instable op_swapgs = {"swapgs",TERM,GO_ON,0};
static const struct instable op_syscall = {"syscall",TERM,GO_ON,0};
static const struct instable op_sysret = {"sysret",TERM,GO_ON,0};
static const struct instable opREX = {"",TERM,REX,0};
static const struct instable op_movsl = {"movsl",TERM,MOVZ,1};

static const struct instable op_cbtw = {"cbtw",0,0,0,0,(char *)"%ax = %al"};		// sign-extend byte in `%al' to word in `%ax'
static const struct instable op_cwtl = {"cwtl",0,0,0,0,(char *)"%eax = %ax"};		// sign-extend word in `%ax' to long in `%eax'
static const struct instable op_cwtd = {"cwtd",0,0,0,0,(char *)"%dx:%ax = %ax"};	// sign-extend word in `%ax' to long in `%dx:%ax'
static const struct instable op_cltd = {"cltd",0,0,0,0,(char *)"%edx:%eax = %eax"}; // sign-extend dword in `%eax' to quad in `%edx:%eax'

/*
 * Decode table for 0x0F0F opcodes
 * Unlike the other decode tables, this one maps suffixes.
 */
static const struct instable op0F0F[16][16] = {
{	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"pi2fw",TERM,AMD3DNOW,0},
	{"pi2fd",TERM,AMD3DNOW,0},
	INVALID, INVALID }, { INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"pf2iw",TERM,AMD3DNOW,0},
	{"pf2id",TERM,AMD3DNOW,0},
	INVALID, INVALID }, { INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"pfnacc",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pfpnacc",TERM,AMD3DNOW,0},
	INVALID }, {
	{"pfcmpge",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID, {
	"pfmin",TERM,AMD3DNOW,0},
	INVALID,
	{"pfrcp",TERM,AMD3DNOW,0},
	{"pfrsqrt",TERM,AMD3DNOW,0},
	INVALID, INVALID,
	{"pfsub",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pfadd",TERM,AMD3DNOW,0},
	INVALID },
	{{"pfcmpgt",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pfmax",TERM,AMD3DNOW,0},
	INVALID,
	{"pfrcpit1",TERM,AMD3DNOW,0},
	{"pfrsqit1",TERM,AMD3DNOW,0},
	INVALID, INVALID,
	{"pfsubr",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pfacc",TERM,AMD3DNOW,0},
	INVALID },
	{ {"pfcmpeq",TERM,AMD3DNOW,0},
	INVALID, INVALID,	INVALID,
	{"pfmul",TERM,AMD3DNOW,0},
	INVALID,
	{"pfrcpit2",TERM,AMD3DNOW,0},
	{"pmulhrw",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pswapd",TERM,AMD3DNOW,0},
	INVALID, INVALID, INVALID,
	{"pavgusb",TERM,AMD3DNOW,0} },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
	{ INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID },
};

/*
 * Decode table for 0x0FBA opcodes
 */
static const struct instable op0FBA[8] = {
	INVALID, INVALID, INVALID, INVALID,
	{"bt",TERM,MIb,1},
	{"bts",TERM,MIb,1},
	{"btr",TERM,MIb,1},
	{"btc",TERM,MIb,1},
};

/*
 * Decode table for 0x0FAE opcodes
 */
static const struct instable op0FAE[8] = {
	{"fxsave",TERM,M,1},
	{"fxrstor",TERM,M,1},
	{"ldmxcsr",TERM,M,1},
	{"stmxcsr",TERM,M,1},
	INVALID,
	{"lfence",TERM,GO_ON,0},
	{"mfence",TERM,GO_ON,0},
	{"clflush",TERM,SFEN,1},
};

/*
 * Decode table for 0x0F opcodes
 */
static const struct instable op0F[16][16] = {
{	{"",op0F00,TERM,0},
	{"",op0F01,TERM,0},
	{"lar",TERM,MR,0},
	{"lsl",TERM,MR,0},
	INVALID,
	{INVALID_32,&op_syscall},
	{"clts",TERM,GO_ON,0},
	{INVALID_32,&op_sysret},
	{"invd",TERM,GO_ON,0},
	{"wbinvd",TERM,GO_ON,0},
	INVALID,
	{"ud2",TERM,GO_ON,0},
	INVALID,
	{"prefetch",TERM,PFCH3DNOW,1},
	{"femms",TERM,GO_ON,0},
	{"",(const struct instable *)op0F0F,TERM,0} },
 {  {"mov",TERM,SSE2,0,0,							(char *)"@2 = @1"},
	{"mov",TERM,SSE2tm,0,0,							(char *)"@2 = @1"},
	{"mov",TERM,SSE2,0,0,							(char *)"@2 = @1"},
	{"movl",TERM,SSE2tm,0,0,						(char *)"@2 = @1"},
	{"unpckl",TERM,SSE2,0},
	{"unpckh",TERM,SSE2,0},
	{"mov",TERM,SSE2,0,0,							(char *)"@2 = @1"},
	{"movh",TERM,SSE2tm,0},
	{"prefetch",TERM,PFCH,1},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
	{"nop",TERM,M,1} },
{	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	INVALID,
	{"mov",TERM,SREG,0x03,0,						(char *)"@2 = @1"},
	INVALID,
	{"mova",TERM,SSE2,0},
	{"mova",TERM,SSE2tm,0},
	{"cvt",TERM,SSE2,0},
	{"movnt",TERM,SSE2tm,0},
	{"cvt",TERM,SSE2,0},
	{"cvt",TERM,SSE2,0} ,
	{"ucomi",TERM,SSE2,0},
	{"comi",TERM,SSE2,0} },
 {  {"wrmsr",TERM,GO_ON,0},
	{"rdtsc",TERM,GO_ON,0},
	{"rdmsr",TERM,GO_ON,0},
	{"rdpmc",TERM,GO_ON,0},
	{"sysenter",TERM,GO_ON,0},
	{"sysexit",TERM,GO_ON,0},
	INVALID, INVALID,
	{"",op0F38,TERM,0},
	INVALID,
	{"",op0F3A,TERM,0},
	INVALID, INVALID, INVALID, INVALID, INVALID },
	{{"cmovo",TERM,MRw,1},
	{"cmovno",TERM,MRw,1},
	{"cmovb",TERM,MRw,1},
	{"cmovae",TERM,MRw,1},
	{"cmove",TERM,MRw,1},
	{"cmovne",TERM,MRw,1},
	{"cmovbe",TERM,MRw,1},
	{"cmova",TERM,MRw,1},
	{"cmovs",TERM,MRw,1},
	{"cmovns",TERM,MRw,1},
	{"cmovp",TERM,MRw,1},
	{"cmovnp",TERM,MRw,1},
	{"cmovl",TERM,MRw,1},
	{"cmovge",TERM,MRw,1},
	{"cmovle",TERM,MRw,1},
	{"cmovg",TERM,MRw,1} },
	{{"movmsk",TERM,SSE2,0},
	{"sqrt",TERM,SSE2,0},
	{"rsqrt",TERM,SSE2,0},
	{"rcp",TERM,SSE2,0},
	{"and",TERM,SSE2,0,0,		(char *)"@2 = @2 & @1"},
	{"andn",TERM,SSE2,0},
	{"or",TERM,SSE2,0,0,		(char *)"@2 = @2 OR @1"},
	{"xor",TERM,SSE2,0,0,		(char *)"@2 = @2 XOR @1"},
	{"add",TERM,SSE2,0,0,		(char *)"@2 = @2 + @1"},
	{"mul",TERM,SSE2,0},
	{"cvt",TERM,SSE2,0},
	{"cvt",TERM,SSE2,0},
	{"sub",TERM,SSE2,0,0,		(char *)"@2 = @2 - @1"},
	{"min",TERM,SSE2,0},
	{"div",TERM,SSE2,0},
	{"max",TERM,SSE2,0} },
{
	{"punpcklbw",TERM,SSE2,0},
	{"punpcklwd",TERM,SSE2,0},
	{"punpckldq",TERM,SSE2,0},
	{"packsswb",TERM,SSE2,0},
	{"pcmpgtb",TERM,SSE2,0},
	{"pcmpgtw",TERM,SSE2,0},
	{"pcmpgtd",TERM,SSE2,0},
	{"packuswb",TERM,SSE2,0},
	{"punpckhbw",TERM,SSE2,0},
	{"punpckhwd",TERM,SSE2,0},
	{"punpckhdq",TERM,SSE2,0},
	{"packssdw",TERM,SSE2,0},
	{"punpckl",TERM,SSE2,0},
	{"punpckh",TERM,SSE2,0},
	{"movd",TERM,SSE2,0},
	{"mov",TERM,SSE2,0,0,				(char *)"@2 = @1"} },
{	{"pshu",TERM,SSE2i,0},
	{"ps",TERM,SSE2i1,0},
	{"ps",TERM,SSE2i1,0},
	{"ps",TERM,SSE2i1,0},
	{"pcmpeqb",TERM,SSE2,0},
	{"pcmpeqw",TERM,SSE2,0},
	{"pcmpeqd",TERM,SSE2,0},
	{"emms",TERM,GO_ON,0},
	{"vmread",TERM,RMw,0},
	{"vmwrite",TERM,MRw,0},
	INVALID, INVALID,
	{"haddp",TERM,SSE2,0},
	{"hsubp",TERM,SSE2,0},
	{"mov",TERM,SSE2tfm,0,0,			(char *)"@2 = @1"},
	{"mov",TERM,SSE2tm,0,0,				(char *)"@2 = @1"} },
{	{"jo",TERM,D,0x03},
	{"jno",TERM,D,0x03},
	{"jb",TERM,D,0x03},
	{"jae",TERM,D,0x03},
	{"je",TERM,D,0x03},
	{"jne",TERM,D,0x03},
	{"jbe",TERM,D,0x03},
	{"ja",TERM,D,0x03},
	{"js",TERM,D,0x03},
	{"jns",TERM,D,0x03},
	{"jp",TERM,D,0x03},
	{"jnp",TERM,D,0x03},
	{"jl",TERM,D,0x03},
	{"jge",TERM,D,0x03},
	{"jle",TERM,D,0x03},
	{"jg",TERM,D,0x03} },
 {  {"seto",TERM,Mb,0},
	{"setno",TERM,Mb,0},
	{"setb",TERM,Mb,0},
	{"setae",TERM,Mb,0},
	{"sete",TERM,Mb,0},
	{"setne",TERM,Mb,0},
	{"setbe",TERM,Mb,0},
	{"seta",TERM,Mb,0},
	{"sets",TERM,Mb,0},
	{"setns",TERM,Mb,0},
	{"setp",TERM,Mb,0},
	{"setnp",TERM,Mb,0},
	{"setl",TERM,Mb,0},
	{"setge",TERM,Mb,0},
	{"setle",TERM,Mb,0},
	{"setg",TERM,Mb,0} },
 {  
	{"_push",TERM,LSEG,0x03},
	{"pop",TERM,LSEG,0x03,0,	(char *)"stackPop( @1 )"},
	{"cpuid",TERM,GO_ON,0},
	{"bt",TERM,RMw,1},
	{"shld",TERM,DSHIFT,1},
	{"shld",TERM,DSHIFTcl,1},
	INVALID, INVALID,
	{"push",TERM,LSEG,0x03,0,	(char *)"stackPush( @1 )"},
	{"pop",TERM,LSEG,0x03,0,	(char *)"stackPop( @1 )"},
	{"rsm",TERM,GO_ON,0, INVALID_64},
	{"bts",TERM,RMw,1},
	{"shrd",TERM,DSHIFT,1},
	{"shrd",TERM,DSHIFTcl,1},
	{"",op0FAE,TERM,0},
	{"imul",TERM,MRw,1} },
 {  {"cmpxchgb",TERM,XINST,0},
	{"cmpxchg",TERM,XINST,1},
	{"lss",TERM,MR,0},
	{"btr",TERM,RMw,1},
	{"lfs",TERM,MR,0},
	{"lgs",TERM,MR,0},
	{"movzb",TERM,MOVZ,1,0,			(char *)"@2 = @1"},
	{"movzwl",TERM,MOVZ,0,0,		(char *)"@2 = @1"},
	{"popcnt",TERM,SSE4MRw,0},
	INVALID,
	{"",op0FBA,TERM,0},
	{"btc",TERM,RMw,1},
	{"bsf",TERM,MRw,1},
	{"bsr",TERM,MRw,1},
	{"movsb",TERM,MOVZ,1,0,			(char *)"@2 = @1"},
	{"movswl",TERM,MOVZ,0,0,		(char *)"@2 = @1"} },
{	{"xaddb",TERM,XINST,0},
	{"xadd",TERM,XINST,1},
	{"cmp",TERM,SSE2i,0,0,			(char *)"compare( @1, @2 )"},
	{"movnti",TERM,RMw,0},
	{"pinsrw",TERM,SSE2i,0},
	{"pextrw",TERM,SSE2i,0},
	{"shuf",TERM,SSE2i,0},
	{"cmpxchg8b",TERM,M,1},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0},
	{"bswap",TERM,BSWAP,0} },
 {  {"addsubp",TERM,SSE2,0},
	{"psrlw",TERM,SSE2,0},
	{"psrld",TERM,SSE2,0},
	{"psrlq",TERM,SSE2,0},
	{"paddq",TERM,SSE2,0},
	{"pmullw",TERM,SSE2,0},
	{"mov",TERM,SSE2tm,0,0,			(char *)"@2 = @1"},
	{"pmovmskb",TERM,SSE2,0},
	{"psubusb",TERM,SSE2,0},
	{"psubusw",TERM,SSE2,0},
	{"pminub",TERM,SSE2,0},
	{"pand",TERM,SSE2,0},
	{"paddusb",TERM,SSE2,0},
	{"paddusw",TERM,SSE2,0},
	{"pmaxub",TERM,SSE2,0},
	{"pandn",TERM,SSE2,0} },
{	{"pavgb",TERM,SSE2,0},
	{"psraw",TERM,SSE2,0},
	{"psrad",TERM,SSE2,0},
	{"pavgw",TERM,SSE2,0},
	{"pmulhuw",TERM,SSE2,0},
	{"pmulhw",TERM,SSE2,0},
	{"cvt",TERM,SSE2,0},
	{"movn",TERM,SSE2tm,0},
	{"psubsb",TERM,SSE2,0},
	{"psubsw",TERM,SSE2,0},
	{"pminsw",TERM,SSE2,0},
	{"por",TERM,SSE2,0},
	{"paddsb",TERM,SSE2,0},
	{"paddsw",TERM,SSE2,0},
	{"pmaxsw",TERM,SSE2,0},
	{"pxor",TERM,SSE2,0} },
{	{"lddqu",TERM,SSE2,0},
	{"psllw",TERM,SSE2,0},
	{"pslld",TERM,SSE2,0},
	{"psllq",TERM,SSE2,0},
	{"pmuludq",TERM,SSE2,0},
	{"pmaddwd",TERM,SSE2,0},
	{"psadbw",TERM,SSE2,0},
	{"maskmov",TERM,SSE2,0},
	{"psubb",TERM,SSE2,0},
	{"psubw",TERM,SSE2,0},
	{"psubd",TERM,SSE2,0},
	{"psubq",TERM,SSE2,0},
	{"paddb",TERM,SSE2,0},
	{"paddw",TERM,SSE2,0},
	{"paddd",TERM,SSE2,0},	INVALID },
};

/*
 * Decode table for 0x80 opcodes
 */
static const struct instable op80[8] = {
	{"addb",TERM,IMlw,0,0,			(char *)"@2 = @2 + @1"},
	{"orb",TERM,IMw,0,0,			(char *)"@2 = @2 OR @1"},
	{"adcb",TERM,IMlw,0},
	{"sbbb",TERM,IMlw,0},
	{"andb",TERM,IMw,0,0,			(char *)"@2 = @2 & @1"},
	{"subb",TERM,IMlw,0},
	{"xorb",TERM,IMw,0,0,			(char *)"@2 = @2 XOR @1"},
	{"cmpb",TERM,IMlw,0,0,			(char *)"compare( @1, @2 )"},
};

/*
 * Decode table for 0x81 opcodes.
 */
static const struct instable op81[8] = {
	{"add",TERM,IMlw,1,0,		(char *)"@2 = @2 + @1"},
	{"or",TERM,IMw,1,0,			(char *)"@2 = @2 OR @1"},
	{"adc",TERM,IMlw,1},
	{"sbb",TERM,IMlw,1},
	{"and",TERM,IMw,1,0,		(char *)"@2 = @2 & @1"},
	{"sub",TERM,IMlw,1,0,		(char *)"@2 = @2 - @1"},
	{"xor",TERM,IMw,1,0,		(char *)"@2 = @2 XOR @1"},
	{"cmp",TERM,IMlw,1,0,		(char *)"compare( @1, @2 )"},
};

/*
 * Decode table for 0x82 opcodes.
 */
static const struct instable op82[8] = {
	{"addb",TERM,IMlw,0,0,		(char *)"@2 = @2 + @1"},
	INVALID,
	{"adcb",TERM,IMlw,0},
	{"sbbb",TERM,IMlw,0},
	INVALID,
	{"subb",TERM,IMlw,0},
	INVALID,
	{"cmpb",TERM,IMlw,0},
};

/*
 * Decode table for 0x83 opcodes.
 */
static const struct instable op83[8] = {
	{"add",TERM,IMlw,1, 0,	(char *)"@2 = @2 + @1"},
	{"or",TERM,IMlw,1,0,	(char *)"@2 = @2 OR @1"},
	{"adc",TERM,IMlw,1},
	{"sbb",TERM,IMlw,1},
	{"and",TERM,IMlw,1,0,	(char *)"@2 = @2 & @1"},
	{"sub",TERM,IMlw,1,0,	(char *)"@2 = @2 - @1"},
	{"xor",TERM,IMlw,1,0,	(char *)"@2 = @2 XOR @1"},
	{"cmp",TERM,IMlw,1,0,	(char *)"compare( @1, @2 )"},
};

/*
 * Decode table for 0xC0 opcodes.
 */
static const struct instable opC0[8] = {
	{"rolb",TERM,MvI,0},
	{"rorb",TERM,MvI,0},
	{"rclb",TERM,MvI,0},
	{"rcrb",TERM,MvI,0},
	{"shlb",TERM,MvI,0},
	{"shrb",TERM,MvI,0},
	INVALID,
	{"sarb",TERM,MvI,0},
};

/*
 * Decode table for 0xD0 opcodes.
 */
static const struct instable opD0[8] = {
	{"rolb",TERM,Mv,0},
	{"rorb",TERM,Mv,0},
	{"rclb",TERM,Mv,0},
	{"rcrb",TERM,Mv,0},
	{"shlb",TERM,Mv,0},
	{"shrb",TERM,Mv,0},
	INVALID,
	{"sarb",TERM,Mv,0},
};

/*
 * Decode table for 0xC1 opcodes.
 * 186 instruction set
 */
static const struct instable opC1[8] = {
	{"rol",TERM,MvI,1},
	{"ror",TERM,MvI,1},
	{"rcl",TERM,MvI,1},
	{"rcr",TERM,MvI,1},
	{"shl",TERM,MvI,1},
	{"shr",TERM,MvI,1},
	INVALID,
	{"sar",TERM,MvI,1},
};

/*
 * Decode table for 0xD1 opcodes.
 */
static const struct instable opD1[8] = {
	{"rol",TERM,Mv,1},
	{"ror",TERM,Mv,1},
	{"rcl",TERM,Mv,1},
	{"rcr",TERM,Mv,1},
	{"shl",TERM,Mv,1},
	{"shr",TERM,Mv,1},
	INVALID,
	{"sar",TERM,Mv,1},
};

/*
 * Decode table for 0xD2 opcodes.
 */
static const struct instable opD2[8] = {
	{"rolb",TERM,Mv,0},
	{"rorb",TERM,Mv,0},
	{"rclb",TERM,Mv,0},
	{"rcrb",TERM,Mv,0},
	{"shlb",TERM,Mv,0},
	{"shrb",TERM,Mv,0},
	INVALID,
	{"sarb",TERM,Mv,0},
};

/*
 * Decode table for 0xD3 opcodes.
 */
static const struct instable opD3[8] = {
	{"rol",TERM,Mv,1},
	{"ror",TERM,Mv,1},
	{"rcl",TERM,Mv,1},
	{"rcr",TERM,Mv,1},
	{"shl",TERM,Mv,1},
	{"shr",TERM,Mv,1},
	INVALID,
	{"sar",TERM,Mv,1},
};

/*
 * Decode table for 0xF6 opcodes.
 */
static const struct instable opF6[8] = {
	{"testb",TERM,IMw,0,0,		(char *)"test( @1, @2 )"},
	INVALID,
	{"notb",TERM,Mw,0},
	{"negb",TERM,Mw,0},
	{"mulb",TERM,MA,0},
	{"imulb",TERM,MA,0},
	{"divb",TERM,MA,0},
	{"idivb",TERM,MA,0},
};

/*
 * Decode table for 0xF7 opcodes.
 */
static const struct instable opF7[8] = {
	{"test",TERM,IMw,1,0,		(char *)"test( @1, @2 )"},
	INVALID,
	{"not",TERM,Mw,1},
	{"neg",TERM,Mw,1},
	{"mul",TERM,MA,1},
	{"imul",TERM,MA,1},
	{"div",TERM,MA,1},
	{"idiv",TERM,MA,1},
};

/*
 * Decode table for 0xFE opcodes.
 */
static const struct instable opFE[8] = {
	{"incb",TERM,Mw,0},
	{"decb",TERM,Mw,0},
	INVALID, INVALID, INVALID, INVALID, INVALID, INVALID,
};

/*
 * Decode table for 0xFF opcodes.
 */
static const struct instable opFF[8] = {
	{"inc",TERM,Mw,1,0,		(char *)"@1 = @1 + 1"},
	{"dec",TERM,Mw,1,0,		(char *)"@1 = @1 - 1"},
	{"call",TERM,INM,1},
	{"lcall",TERM,INMl,1},
	{"jmp",TERM,INM,1},
	{"ljmp",TERM,INMl,1},
	{"push",TERM,M,0x030,0,	(char *)"stackPush( @1 )"},
	INVALID,
};

/* for 287 instructions, which are a mess to decode */
static const struct instable opFP1n2[8][8] = {
/* bit pattern:	1101 1xxx MODxx xR/M */
 {	{"fadds",TERM,M,0},
	{"fmuls",TERM,M,0},
	{"fcoms",TERM,M,0},
	{"fcomps",TERM,M,0},
	{"fsubs",TERM,M,0},
	{"fsubrs",TERM,M,0},
	{"fdivs",TERM,M,0},
	{"fdivrs",TERM,M,0} },
 {	{"flds",TERM,M,0},
	INVALID,
	{"fsts",TERM,M,0},
	{"fstps",TERM,M,0},
	{"fldenv",TERM,M,1},
	{"fldcw",TERM,M,1},
	{"fnstenv",TERM,M,1},
	{"fnstcw",TERM,M,1} },
 {	{"fiaddl",TERM,M,0},
	{"fimull",TERM,M,0},
	{"ficoml",TERM,M,0},
	{"ficompl",TERM,M,0},
	{"fisubl",TERM,M,0},
	{"fisubrl",TERM,M,0},
	{"fidivl",TERM,M,0},
	{"fidivrl",TERM,M,0} },
{	{"fildl",TERM,Mnol,0},
	{"fisttpl",TERM,M,0},
	{"fistl",TERM,M,0},
	{"fistpl",TERM,Mnol,0},
	INVALID,
	{"fldt",TERM,M,0},
	INVALID,
	{"fstpt",TERM,M,0} },
 {	{"faddl",TERM,M,0},
	{"fmull",TERM,M,0},
	{"fcoml",TERM,M,0},
	{"fcompl",TERM,M,0},
	{"fsubl",TERM,M,0},
	{"fsubrl",TERM,M,0},
	{"fdivl",TERM,M,0},
	{"fdivrl",TERM,M,0} },
 {	{"fldl",TERM,M,0},
	{"fisttpll",TERM,M,0},
	{"fstl",TERM,M,0},
	{"fstpl",TERM,M,0},
	{"frstor",TERM,M,1},
	INVALID,
	{"fnsave",TERM,M,1},
	{"fnstsw",TERM,M,1} },
 {	{"fiadds",TERM,M,0},
	{"fimuls",TERM,M,0},
	{"ficoms",TERM,M,0},
	{"ficomps",TERM,M,0},
	{"fisubs",TERM,M,0},
	{"fisubrs",TERM,M,0},
	{"fidivs",TERM,M,0},
	{"fidivrs",TERM,M,0} },
 {	{"filds",TERM,M,0},
	{"fisttps",TERM,M,0},
	{"fists",TERM,M,0},
	{"fistps",TERM,M,0},
	{"fbld",TERM,M,0},
	{"fildq",TERM,M,0},
	{"fbstp",TERM,M,0},
	{"fistpq",TERM,M,0} },
};

static const struct instable opFP3[8][8] = {
/* bit  pattern:	1101 1xxx 11xx xREG */
 {	{"fadd",TERM,FF,0},
	{"fmul",TERM,FF,0},
	{"fcom",TERM,F,0},
	{"fcomp",TERM,F,0},
	{"fsub",TERM,FF,0},
	{"fsubr",TERM,FF,0},
	{"fdiv",TERM,FF,0},
	{"fdivr",TERM,FF,0} },
 {	{"fld",TERM,F,0},
	{"fxch",TERM,F,0},
	{"fnop",TERM,GO_ON,0},
	{"fstp",TERM,F,0},
	INVALID, INVALID, INVALID, INVALID },
 {	{"fcmovb",TERM,FF,0},
	{"fcmove",TERM,FF,0},
	{"fcmovbe",TERM,FF,0},
	{"fcmovu",TERM,FF,0},
	INVALID,
	{"fucompp",TERM,GO_ON,0},
	INVALID, INVALID },
 {	{"fcmovnb",TERM,FF,0},
	{"fcmovne",TERM,FF,0},
	{"fcmovnbe",TERM,FF,0},
	{"fcmovnu",TERM,FF,0},
	INVALID,
	{"fucomi",TERM,FF,0},
	{"fcomi",TERM,FF,0},
	INVALID },
{	{"fadd",TERM,FF,0},
	{"fmul",TERM,FF,0},
	{"fcom",TERM,F,0},
	{"fcomp",TERM,F,0},
	{"fsub",TERM,FF,0},
	{"fsubr",TERM,FF,0},
	{"fdiv",TERM,FF,0},
	{"fdivr",TERM,FF,0} },
 {	{"ffree",TERM,F,0},
	{"fxch",TERM,F,0},
	{"fst",TERM,F,0},
	{"fstp",TERM,F,0},
	{"fucom",TERM,F,0},
	{"fucomp",TERM,F,0},
	INVALID, INVALID },
 {	{"faddp",TERM,FF,0},
	{"fmulp",TERM,FF,0},
	{"fcomp",TERM,F,0},
	{"fcompp",TERM,GO_ON,0},
	{"fsubp",TERM,FF,0},
	{"fsubrp",TERM,FF,0},
	{"fdivp",TERM,FF,0},
	{"fdivrp",TERM,FF,0} },
{	{"ffree",TERM,F,0},
	{"fxch",TERM,F,0},
	{"fstp",TERM,F,0},
	{"fstp",TERM,F,0},
	{"fnstsw",TERM,M,1},
	{"fucomip",TERM,FF,0},
	{"fcomip",TERM,FF,0},
	INVALID },
};

static const struct instable opFP4[4][8] = {
/* bit pattern:	1101 1001 111x xxxx */
 {	{"fchs",TERM,GO_ON,0},
	{"fabs",TERM,GO_ON,0},
	INVALID, INVALID,
	{"ftst",TERM,GO_ON,0},
	{"fxam",TERM,GO_ON,0},
	INVALID, INVALID },
 {	{"fld1",TERM,GO_ON,0},
	{"fldl2t",TERM,GO_ON,0},
	{"fldl2e",TERM,GO_ON,0},
	{"fldpi",TERM,GO_ON,0},
	{"fldlg2",TERM,GO_ON,0},
	{"fldln2",TERM,GO_ON,0},
	{"fldz",TERM,GO_ON,0},
	INVALID },
 {	{"f2xm1",TERM,GO_ON,0},
	{"fyl2x",TERM,GO_ON,0},
	{"fptan",TERM,GO_ON,0},
	{"fpatan",TERM,GO_ON,0},
	{"fxtract",TERM,GO_ON,0},
	{"fprem1",TERM,GO_ON,0},
	{"fdecstp",TERM,GO_ON,0},
	{"fincstp",TERM,GO_ON,0} },
{	{"fprem",TERM,GO_ON,0},
	{"fyl2xp1",TERM,GO_ON,0},
	{"fsqrt",TERM,GO_ON,0},
	{"fsincos",TERM,GO_ON,0},
	{"frndint",TERM,GO_ON,0},
	{"fscale",TERM,GO_ON,0},
	{"fsin",TERM,GO_ON,0},
	{"fcos",TERM,GO_ON,0} },
};

static const struct instable opFP5[8] = {
/* bit pattern:	1101 1011 1110 0xxx */
	INVALID, INVALID,
	{"fnclex",TERM,GO_ON,0},
	{"fninit",TERM,GO_ON,0},
	{"fsetpm",TERM,GO_ON,0},
	INVALID, INVALID, INVALID,
};

// static means only visible in this file

/*
 * Main decode table for the op codes.  The first two nibbles
 * will be used as an index into the table.  If there is a
 * a need to further decode an instruction, the array to be
 * referenced is indicated with the other two entries being
 * empty.
 */
static const struct instable distable[16][16] = {
{
	{"addb",TERM,RMw,0,0,				(char *)"@2 = @2 + @1"},
	{"add",TERM,RMw,1,0,				(char *)"@2 = @2 + @1"},
	{"addb",TERM,MRw,0,0,				(char *)"@2 = @2 + @1"},
	{"add",TERM,MRw,1,0,				(char *)"@2 = @2 + @1"},
	{"addb",TERM,IA,0,0,				(char *)"@2 = @2 + @1"},
	{"add",TERM,IA,1,0,					(char *)"@2 = @2 + @1"},
	{"push",TERM,SEG,0x03,INVALID_64,	(char *)"stackPush( @1 )"},
	{"pop",TERM,SEG,0x03,INVALID_64,	(char *)"stackPop( @1 )"},
	{"orb",TERM,RMw,0,0,				(char *)"@2 = @2 OR @1"},
	{"or",TERM,RMw,1,0,					(char *)"@2 = @2 OR @1"},
	{"orb",TERM,MRw,0,0,				(char *)"@2 = @2 OR @1"},
	{"or",TERM,MRw,1,0,					(char *)"@2 = @2 OR @1"},
	{"orb",TERM,IA,0,0,					(char *)"@2 = @2 OR @1"},
	{"or",TERM,IA,1,0,					(char *)"@2 = @2 OR @1"},
	{"push",TERM,SEG,0x03,INVALID_64,	(char *)"stackPush( @1 )"},
    {"",(const struct instable *)op0F,TERM,0}
},
{	{"adcb",TERM,RMw,0},
	{"adc",TERM,RMw,1},
	{"adcb",TERM,MRw,0},
	{"adc",TERM,MRw,1},
	{"adcb",TERM,IA,0},
	{"adc",TERM,IA,1},
	{"push",TERM,SEG,0x03,INVALID_64,	(char *)"stackPush( @1 )"},
	{"pop",TERM,SEG,0x03,INVALID_64,	(char *)"stackPop( @1 )"},
	{"sbbb",TERM,RMw,0},
	{"sbb",TERM,RMw,1},
	{"sbbb",TERM,MRw,0},
	{"sbb",TERM,MRw,1},
	{"sbbb",TERM,IA,0},
	{"sbb",TERM,IA,1},
	{"push",TERM,SEG,0x03,INVALID_64,	(char *)"stackPush( @1 )"},
	{"pop",TERM,SEG,0x03,INVALID_64,	(char *)"stackPop( @1 )"}
},
{	{"andb",TERM,RMw,0,0,				(char *)"@2 = @2 & @1"},
	{"and",TERM,RMw,1,0,				(char *)"@2 = @2 & @1"},
	{"andb",TERM,MRw,0,0,				(char *)"@2 = @2 & @1"},
	{"and",TERM,MRw,1,0,				(char *)"@2 = @2 & @1"},
	{"andb",TERM,IA,0,0,				(char *)"@2 = @2 & @1"},
	{"and",TERM,IA,1,0,					(char *)"@2 = @2 & @1"},
	{"%es:",TERM,OVERRIDE,0},
	{"daa",TERM,GO_ON,0,INVALID_64},
	{"subb",TERM,RMw,0},
	{"sub",TERM,RMw,1,0,				(char *)"@2 = @2 - @1"},
	{"subb",TERM,MRw,0},
	{"sub",TERM,MRw,1,0,				(char *)"@2 = @2 - @1"},
	{"subb",TERM,IA,0},
	{"sub",TERM,IA,1,0,					(char *)"@2 = @2 - @1"},
	{"%cs:",TERM,OVERRIDE,0},
	{"das",TERM,GO_ON,0,INVALID_64}
},
{	{"xorb",TERM,RMw,0,0,				(char *)"@2 = @2 XOR @1"},
	{"xor",TERM,RMw,1,0,				(char *)"@2 = @2 XOR @1"},
	{"xorb",TERM,MRw,0,0,				(char *)"@2 = @2 XOR @1"},
	{"xor",TERM,MRw,1,0,				(char *)"@2 = @2 XOR @1"},
	{"xorb",TERM,IA,0,0,				(char *)"@2 = @2 XOR @1"},
	{"xor",TERM,IA,1,0,					(char *)"@2 = @2 XOR @1"},
	{"%ss:",TERM,OVERRIDE,0},
	{"aaa",TERM,GO_ON,0,INVALID_64},
	{"cmpb",TERM,RMw,0},
	{"cmp",TERM,RMw,1,0,				(char *)"compare( @1, @2 )"},
	{"cmpb",TERM,MRw,0},
	{"cmp",TERM,MRw,1,0,				(char *)"compare( @1, @2 )"},
	{"cmpb",TERM,IA,0},
	{"cmp",TERM,IA,1,0,					(char *)"compare( @1, @2 )"},
	{"%ds:",TERM,OVERRIDE,0},
	{"aas",TERM,GO_ON,0,INVALID_64}
},
{	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"inc",TERM,R,1,&opREX,	(char *)"@1 = @1 + 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"},
	{"dec",TERM,R,1,&opREX,	(char *)"@1 = @1 - 1"}
},
{	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"push",TERM,R,0x03,0,	(char *)"stackPush( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"},
	{"pop",TERM,R,0x03,0,	(char *)"stackPop( @1 )"}
},
{	{"pusha",TERM,GO_ON,1,INVALID_64},
	{"popa",TERM,GO_ON,1,INVALID_64},
	{"bound",TERM,MR,1,INVALID_64},
	{"arpl",TERM,RMw,0,&op_movsl},
	{"%fs:",TERM,OVERRIDE,0},
	{"%gs:",TERM,OVERRIDE,0},
	{"data16",TERM,DM,0},
	{"addr16",TERM,AM,0},
	{"push",TERM,I,0x03,0,	(char *)"stackPush( @1 )"},
	{"imul",TERM,IMUL,1},
	{"push",TERM,Ib,0x03,0,	(char *)"stackPush( @1 )"},
	{"imul",TERM,IMUL,1},
	{"insb",TERM,GO_ON,0},
	{"ins",TERM,GO_ON,1},
	{"outsb",TERM,GO_ON,0},
	{"outs",TERM,GO_ON,1}
},
{	{"jo",TERM,BD,0},
	{"jno",TERM,BD,0},
	{"jb",TERM,BD,0},
	{"jae",TERM,BD,0},
	{"je",TERM,BD,0},
	{"jne",TERM,BD,0},
	{"jbe",TERM,BD,0},
	{"ja",TERM,BD,0},
	{"js",TERM,BD,0},
	{"jns",TERM,BD,0},
	{"jp",TERM,BD,0},
	{"jnp",TERM,BD,0},
	{"jl",TERM,BD,0},
	{"jge",TERM,BD,0},
	{"jle",TERM,BD,0},
	{"jg",TERM,BD,0}
},
{	{"",op80,TERM,0},
	{"",op81,TERM,0},
	{"",op82,TERM,0},
	{"",op83,TERM,0},
	{"testb",TERM,MRw,0,0,		(char *)"test( @1, @2 )"},
	{"test",TERM,MRw,1,0,		(char *)"test( @1, @2 )"},
	{"xchgb",TERM,MRw,0},
	{"xchg",TERM,MRw,1},
	{"movb",TERM,RMw,0,0,		(char *)"@2 = @1"},
	{"mov",TERM,RMw,1,0,		(char *)"@2 = @1" },
	{"movb",TERM,MRw,0,0,		(char *)"@2 = @1" },
	{"mov",TERM,MRw,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,SM,1,0,			(char *)"@2 = @1"},
	{"lea",TERM,MR,1,0,			(char *)"addr @2 = @1"},
	{"mov",TERM,MS,1,0,			(char *)"@2 = @1"},
	{"pop",TERM,M,0x03,0,		(char *)"stackPop( @1 )"}
},
{	{"nop",TERM,GO_ON,0},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"xchg",TERM,RA,1},
	{"",TERM,CBW,0},
	{"",TERM,CWD,0},
	{"lcall",TERM,SO,0},
	{"wait/",TERM,PREFIX,0},
	{"pushf",TERM,GO_ON,1},
	{"popf",TERM,GO_ON,1},
	{"sahf",TERM,GO_ON,0},
	{"lahf",TERM,GO_ON,0}
},
{	{"movb",TERM,OA,0,0,		(char *)"@2 = @1"},
	{"mov",TERM,OA,1,0,			(char *)"@2 = @1"},
	{"movb",TERM,AO,0,0,		(char *)"@2 = @1"},
	{"mov",TERM,AO,1,0,			(char *)"@2 = @1"},
	{"movsb",TERM,SD,0},
	{"movs",TERM,SD,1},
	{"cmpsb",TERM,SD,0},
	{"cmps",TERM,SD,1},
	{"testb",TERM,IA,0,0,		(char *)"test( @1, @2 )"},
	{"test",TERM,IA,1,0,		(char *)"test( @1, @2 )"},
	{"stosb",TERM,AD,0},
	{"stos",TERM,AD,1},
	{"lodsb",TERM,SA,0},
	{"lods",TERM,SA,1},
	{"scasb",TERM,AD,0},
	{"scas",TERM,AD,1}
},
{	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"movb",TERM,IR,0,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
	{"mov",TERM,IR64,1,0,		(char *)"@2 = @1"},
},
{	{"",opC0,TERM,0},
	{"",opC1,TERM,0},
	{"ret",TERM,RET,0},
	{"ret",TERM,GO_ON,0},
	{"les",TERM,MR,0,INVALID_64},
	{"lds",TERM,MR,0,INVALID_64},
	{"movb",TERM,IMw,0,0,		(char *)"@2 = @1"},
	{"mov",TERM,IMw,1,0,		(char *)"@2 = @1"},
	{"enter",TERM,ENTER,0},
	{"leave",TERM,GO_ON,0},
	{"lret",TERM,RET,0},
	{"lret",TERM,GO_ON,0},
	{"int",TERM,INT3,0},
	{"int",TERM,Ib,0},
	{"into",TERM,GO_ON,0,INVALID_64},
	{"iret",TERM,GO_ON,0}
},
{	{"",opD0,TERM,0},
	{"",opD1,TERM,0},
	{"",opD2,TERM,0},
	{"",opD3,TERM,0},
	{"aam",TERM,U,0,INVALID_64},
	{"aad",TERM,U,0,INVALID_64},
	{"falc",TERM,GO_ON,0},
	{"xlat",TERM,GO_ON,0},
/* 287 instructions.  Note that although the indirect field		*/
/* indicates opFP1n2 for further decoding, this is not necessarily	*/
/* the case since the opFP arrays are not partitioned according to key1	*/
/* and key2.  opFP1n2 is given only to indicate that we haven't		*/
/* finished decoding the instruction.					*/
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0},
	{"",(const struct instable *)opFP1n2,TERM,0}
},
{  {"loopnz",TERM,BD,0},
	{"loopz",TERM,BD,0},
	{"loop",TERM,BD,0},
	{"jcxz",TERM,BD,0},
	{"inb",TERM,Pi,0},
	{"in",TERM,Pi,1},
	{"outb",TERM,Po,0},
	{"out",TERM,Po,1},
	{"call",TERM,D,0x03},
	{"jmp",TERM,D,0x03},
	{"ljmp",TERM,SO,0},
	{"jmp",TERM,BD,0},
	{"inb",TERM,Vi,0},
	{"in",TERM,Vi,1},
	{"outb",TERM,Vo,0},
	{"out",TERM,Vo,1}
},
	{ {"lock/",TERM,PREFIX,0},
	INVALID,
	{"repnz/",TERM,PREFIX,0},
	{"repz/",TERM,PREFIX,0},
	{"hlt",TERM,GO_ON,0},
	{"cmc",TERM,GO_ON,0},
	{"",opF6,TERM,0},
	{"",opF7,TERM,0},
	{"clc",TERM,GO_ON,0},
	{"stc",TERM,GO_ON,0},
	{"cli",TERM,GO_ON,0},
	{"sti",TERM,GO_ON,0},
	{"cld",TERM,GO_ON,0},
	{"std",TERM,GO_ON,0},
	{"",opFE,TERM,0},
	{"",opFF,TERM,0} },
};

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
		return &code_seg_reg;
	} else if( !strcmp(segRegName, "%es:") ){
		return &data_seg_reg;
	} else if( !strcmp(segRegName, "%ss:") ){
		return &stack_seg_reg;
	} else if( !strcmp(segRegName, "%ds:") ){
		return &data_seg_reg2;
	} else if( !strcmp(segRegName, "%fs:") ){
		return &data_seg_reg2;
	} else if( !strcmp(segRegName, "%gs:") ){
		return &data_seg_reg2;
	}
	
	[NSException raise:@"Unknown segreg" format:@"Unknown segreg"];
	return NULL;
}

static const struct HooReg *get_regStruct( NSUInteger reg, NSUInteger wbit, NSUInteger data16, NSUInteger rex ) {
	
	const struct HooReg *regStruct;
	if (rex != 0) {
		regStruct = &REG32_Struct[reg + (REX_R(rex) << 3)][wbit + REX_W(rex)];
	} else if (data16) {
		regStruct = &REG16_Struct[reg][wbit];
	} else {
		regStruct = &REG32_Struct[reg][wbit];
	}
	return regStruct;
}

/* yeah */
static const struct HooReg *get_r_m_regStruct( NSUInteger r_m, NSUInteger wbit, NSUInteger data16, NSUInteger rex ) {

	const struct HooReg *regStruct;
	if( rex!=0 ) {
		regStruct = &REG32_Struct[r_m + (REX_B(rex) << 3)][wbit + REX_W(rex)];
	} else if (data16) {
		regStruct = &REG16_Struct[r_m][wbit];
	} else {
		regStruct = &REG32_Struct[r_m][wbit];
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

void addLine( uint64_t memAddress, struct hooleyFuction **currentFuncPtr, const struct instable *dp, struct InstrArgStruct *args ) {
	
	struct hooleyFuction *currentFunc = *currentFuncPtr;

	struct hooleyCodeLine *newLine = calloc( 1, sizeof(struct hooleyCodeLine) );
	newLine->instr = dp;
	
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
	
	char lineToPrint[256];
	sprintf( lineToPrint, "%0x\t%s ", (uint)memAddress, dp->name);
	
	// lets just take a pepp at the arguments
	if (args) {

		for(NSUInteger i=0;i<args->numberOfArgs;i++){
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
					char *baseReg = indirectArg->baseRegister ? indirectArg->baseRegister->prettyName : "";
					char *indexReg = indirectArg->indexRegister ? indirectArg->indexRegister->prettyName : "_";
					sprintf( lineToPrint+strlen(lineToPrint), " %s:%qi(%s,%s,%qi)", segReg, (uint64)indirectArg->displacement, baseReg, indexReg, (uint64)indirectArg->scale );
					break;
				case DISPLACEMENT_ARG:
					displaceArg = (struct DisplacementValue *)abstractArgi;
					sprintf( lineToPrint+strlen(lineToPrint), " %0qx", displaceArg->value );
					break;
					
	//			case BONKERSREG_ARG:
	//				struct BonkersHooReg *imedArg = (struct BonkersHooReg *)argi;								
	//				NSLog(@"woohoo! found an INDIRECT_ARG. Wonder what it has inside?");							
	//				break;				
				default:
					NSLog(@"Unknown HooAbstractDataType");
					break;
			}
		}
	}
//	printf( "%s\n", lineToPrint );
}

struct instable *customInstruction( const char *instrName, const char *prettyStr ) {
	
	struct instable *customInstruction = calloc(1, sizeof(struct instable));
	strcpy( customInstruction->name, instrName );
	customInstruction->printStr = calloc(1,strlen(prettyStr)+1);
	strcpy( customInstruction->printStr, prettyStr );
	return customInstruction;
}

/*
  * i386_disassemble()
 */
NSUInteger i386_disassemble(
struct hooleyFuction **currentFuncPtr,
char *sect,
uint64 left,
uint64_t addr,
uint64_t sect_addr,
//enum byte_sex object_byte_sex,
struct relocation_info *sorted_relocs,
NSUInteger nsorted_relocs,
struct nlist *symbols,
struct nlist_64 *symbols64,
NSUInteger nsymbols,
struct symbol *sorted_symbols,
NSUInteger nsorted_symbols,
char *strings,
NSUInteger strings_size,
uint32_t *indirect_symbols,
NSUInteger nindirect_symbols,
cpu_type_t cputype,
struct load_command *load_commands,
NSUInteger ncmds,
NSUInteger sizeofcmds,
NSUInteger verbose,
NSUInteger iterationCounter						  
)
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
    NSUInteger opcode1=0, opcode2=0, opcode3=0, opcode4=0, opcode5=0, prefix_byte=0;
    const struct instable *dp=NULL, *prefix_dp=NULL;
    NSUInteger wbit=0, vbit=0;
    int got_modrm_byte=0;
    NSUInteger mode=0, reg=0, r_m=0;
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
	    byte = get_value(sizeof(char), sect, &length, &left);	// 0x14adc272, 0, 0xb9bb8b	=== //0xff 
	    opcode1 = byte >> 4 & 0xf;									//0xf
	    opcode2 = byte & 0xf;										//0xf

	    dp = &distable[opcode1][opcode2];
	    if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64 && dp->arch64 != NULL){
			dp = dp->arch64;
		}
	    if(dp->adr_mode == PREFIX){
			if(prefix_dp != NULL)
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
	if( dp->indirect == (const struct instable *)op0F)
	{
	    byte = get_value(sizeof(char), sect, &length, &left);
	    opcode4 = byte >> 4 & 0xf;
	    opcode5 = byte & 0xf;
	    dp = &op0F[opcode4][opcode5];
	    if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64 && dp->arch64 != NULL) {
			dp = dp->arch64;
		}
	    if(dp->indirect == op0F38 || dp->indirect == op0F3A)
		{
			hooleyDebug();

			/*
			* MNI instructions are SSE2ish instructions with an
			* extra byte.  Do the extra indirection here.
			*/
//NEVER			byte = get_value(sizeof(char), sect, &length, &left);
//NEVER			dp = &dp->indirect[byte];
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
			if(dp->indirect == (const struct instable *)op0F0F)
			{
				hooleyDebug();
	//NEVER		    data16 = FALSE;
	//NEVER		    mmx = TRUE;
	//NEVER		    if(got_modrm_byte == FALSE){
	//NEVER				hooleyDebug();
	//NEVER				got_modrm_byte = TRUE;
	//NEVER				byte = get_value(sizeof(char), sect, &length, &left);
	//NEVER				modrm_byte(&mode, &reg, &r_m, byte);
	//NEVER		    }
	//NEVER			GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
	//NEVER		    opcode_suffix = get_value(sizeof(char), sect, &length, &left);
	//NEVER		    dp = &op0F0F[opcode_suffix >> 4][opcode_suffix & 0x0F];

			} else if(dp->indirect == (const struct instable *)op0F01) {

				hooleyDebug();
	//NEVER		    if(got_modrm_byte == FALSE){
	//NEVER				hooleyDebug();
	//NEVER				got_modrm_byte = TRUE;
	//NEVER				byte = get_value(sizeof(char), sect, &length, &left);
	//NEVER				modrm_byte(&mode, &reg, &r_m, byte);
	//NEVER				opcode3 = reg;
	//NEVER		    }
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
					printf("%s", prefix_dp->name);
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
				printf("rep/");
			} else {
				// Repz = repeat while count is not equal
				// TODO: I really need to expand this shit
				printf("%s", prefix_dp->name);
			}
	    }
	}

	if(dp->indirect != TERM){

	    /*
	     * This must have been an opcode for which several instructions
	     * exist. The opcode3 field further decodes the instruction.
	     */
	    if(got_modrm_byte == FALSE){
			got_modrm_byte = TRUE;
			byte = get_value(sizeof(char), sect, &length, &left);
			modrm_byte(&mode, (NSUInteger *)&opcode3, &r_m, byte);
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
				hooleyDebug();
//NEVER				printf(".byte 0x%01x%01x, 0x%01x%01x 0x%02x #bad opcode\n", (unsigned int)opcode1, (unsigned int)opcode2, (unsigned int)opcode4, (unsigned int)opcode5, (unsigned int)byte);
				return(length);
			}
			/* instruction form 4 */
			else if(opcode2 == 0x9 && mode == 0x3 && opcode3 >= 4) {
				dp = &opFP4[opcode3-4][r_m];
			/* instruction form 3 */
			} else if(mode == 0x3) {
				dp = &opFP3[opcode2-8][opcode3];
			} else { /* instruction form 1 and 2 */
				dp = &opFP1n2[opcode2-8][opcode3];
			}
	    } else {
			dp = dp->indirect + opcode3;
		}
		/* now dp points the proper subdecode table entry */
	}

	if(dp->indirect != TERM){
	    printf(".byte 0x%02x #bad opcode\n", (unsigned int)byte);
		/* add a bad opcode line ?*/
	    return(length);
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
	if(dp->adr_mode != CBW && dp->adr_mode != CWD){

	    if((dp->flags & HAS_SUFFIX) != 0)
		{
			if(data16 == TRUE)
			{
				sprintf(mnemonic, "%sw", dp->name);
			} else {
				if(dp->adr_mode == Mnol || dp->adr_mode == INM)
				{
					sprintf(mnemonic, "%s", dp->name);
				} else if(REX_W(rex) != 0){
					sprintf(mnemonic, "%sq", dp->name);
				} else {
					sprintf(mnemonic, "%sl", dp->name);
				}
			}
	    } else {
			sprintf(mnemonic, "%s", dp->name);
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
	switch( dp -> adr_mode )
	{
		case BSWAP:
			reg_struct = get_regStruct((opcode5 & 0x7), 1, data16, rex);
			// eg bswap	%eax
			FILLARGS1( reg_struct );
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		case XINST:
			wbit = WBIT(opcode5);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			
			reg_struct = get_regStruct(reg, wbit, data16, rex);

			//Putback			printf("%s\t%s,", mnemonic, reg_name);
//Putback			print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			return(length);

		/* movsbl movsbw (0x0FBE) or movswl (0x0FBF) */
		/* movzbl movzbw (0x0FB6) or mobzwl (0x0FB7) */
		/* wbit lives in 2nd byte, note that operands are different sized */
		case MOVZ:
			/* Get second operand first so data16 can be destroyed */
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			reg_struct = get_regStruct(reg, LONGOPERAND, data16, rex);
			wbit = WBIT(opcode5);
			data16 = 1;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// eg movzbl	(%edx),%eax	
			FILLARGS2( abstractStrctPtr1, reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );		
			return(length);

		/* imul instruction, with either 8-bit or longer immediate */
		case IMUL:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);

			/* opcode 0x6B for byte, sign-extended displacement, 0x69 for word(s) */
			value0_size = OPSIZE(data16, opcode2==0x9, 0);
			REPLACEMENT_IMMEDIATE( &symadd0, &symsub0, &imm0, value0_size );
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// eg imull $0x44,%edx,%eax
			FILLARGS3( value0Immed, abstractStrctPtr1, reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs ); 
			return(length);

		/* memory or register operand to register, with 'w' bit	*/
		case MRw:
		case SSE4MRw:
			wbit = WBIT(opcode2);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// eg. movl 0x04(%ebp),%ebx
			FILLARGS2( abstractStrctPtr1,reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );		
			return(length);

		/* register to memory or register operand, with 'w' bit	*/
		/* arpl happens to fit here also because it is odd */
		case RMw:
			wbit = WBIT(opcode2);
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, &result0);
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			
			 // -- move register to oprand eg. movl	%esp,%ebp		movl %ebx,0x00(%esp)
			FILLARGS2( reg_struct, abstractStrctPtr1 );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* SSE2 instructions with further prefix decoding dest to memory or memory to dest depending on the opcode */
		case SSE2tfm:
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			struct ArgStack aStack;
			argStack_Init( &aStack );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x7e: /* movq & movd */
					if(prefix_byte == 0x66){
						/* movd from xmm to r/m32 */
						regNum = xmm_reg(reg, rex);
						reg_struct = &xmmReg_Struct[regNum];
						argStack_Push( &aStack, (int64_t)reg_struct );
						// printf("%sd\t%%xmm%u,", mnemonic, reg_struct);
						wbit = LONGOPERAND;
						abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
						argStack_Push( &aStack, (int64_t)abstractStrctPtr1 );

					} else if(prefix_byte == 0xf0){
						hooleyDebug();
//NEVER						/* movq from mm to mm/m64 */
//NEVER						printf("%sd\t%%mm%u,", mnemonic, reg);
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
//NEVER						wbit = LONGOPERAND;
//NEVER						GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
//NEVER						print_operand(seg, symadd1, symsub1, value1, value1_size, result1, "\n");
					}
			}
			
			if(aStack.size==2){
				FILLARGS2( aStack.data[0], aStack.data[1] );
			} else {
				[NSException raise:@"what?" format:@"what?"];
			}
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* SSE2 instructions with further prefix decoding dest to memory */
		case SSE2tm:
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			regNum = xmm_reg(reg, rex);
			reg_struct = &xmmReg_Struct[regNum]; //%xmm0
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
						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3) {
						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */ {
						printf("%sups\t", mnemonic);
					}
					break;

				case 0x13: /* movlpd & movlps */
				case 0x17: /* movhpd & movhps */
				case 0x29: /* movapd & movasd */
				case 0x2b: /* movntpd & movntsd */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						printf("%spd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
						printf("%sps\t", mnemonic);
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
						printf("%sdqa\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						hooleyDebug();
						printf("%sdqu\t", mnemonic);
					} else {
						hooleyDebug();
						sprintf(result0, "%%mm%lu", (unsigned long)reg);
						printf("%sq\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0xe7: /* movntdq & movntq */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%stdq\t", mnemonic);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sprintf(result0, "%%mm%u", reg);
//NEVER						printf("%stq\t", mnemonic);
//NEVER						mmx = TRUE;
//NEVER					}
//NEVER					break;
			}
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			
			// eg movsd	%xmm0,0x20(%edx,%ecx)
			FILLARGS2( reg_struct, abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* MNI instructions */
		case MNI:
			hooleyDebug();
//NEVER			data16 = FALSE;
//NEVER			if(got_modrm_byte == FALSE){
//NEVER				hooleyDebug();
//NEVER				got_modrm_byte = TRUE;
//NEVER				byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER			}
//NEVER			printf("%s\t", mnemonic);
//NEVER			GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER			print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER			printf("%s\n", result1);
//NEVER			return length;

		/* MNI instructions with 8-bit immediate */
		case MNIi:
			hooleyDebug();
//NEVER			data16 = FALSE;
//NEVER			if (got_modrm_byte == FALSE) {
//NEVER				hooleyDebug();
//NEVER				got_modrm_byte = TRUE;
//NEVER				byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER			}
//NEVER			GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER			byte = get_value(sizeof(char), sect, &length, &left);
//NEVER			printf("%s\t$0x%x,", mnemonic, byte);
//NEVER
//NEVER			print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER			printf("%s\n", result1);
//NEVER			return length;

		/* SSE2 instructions with further prefix decoding */
		case SSE2:
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			// eg // %xmm0
			regNum = xmm_reg(reg, rex);
			reg_struct = &xmmReg_Struct[regNum];
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
						printf("%spd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
						printf("%sps\t", mnemonic);
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
						hooleyDebug();
//NEVER						printf("%supd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						printf("%ssd\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						printf("%sss\t", mnemonic);
					} else /* no prefix_byte */{
						printf("%sups\t", mnemonic);
					}
					break;
				case 0x2a: /* cvtpi2pd, cvtsi2sd, cvtsi2ss & cvtpi2ps */
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						mmx = TRUE;
//NEVER						printf("%spi2pd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						wbit = LONGOPERAND;
						printf("%ssi2sd\t", mnemonic);
						// -- this is a suffix --
						
					} else if(prefix_byte == 0xf3){
						wbit = LONGOPERAND;
						printf("%ssi2ss\t", mnemonic);
					} else { /* no prefix_byte */
						hooleyDebug();
//NEVER						mmx = TRUE;
//NEVER						printf("%spi2ps\t", mnemonic);
					}
					break;
				case 0x2c: /* cvttpd2pi, cvttsd2si, cvttss2si & cvttps2pi */
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%stpd2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
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
						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%stps2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
					}
					break;

				case 0x2d: /* cvtpd2pi, cvtsd2si, cvtss2si & cvtps2pi */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%spd2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%ssd2si\t", mnemonic);
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER						strcpy(result1, reg_name);
//NEVER					} else if(prefix_byte == 0xf3){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%sss2si\t", mnemonic);
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER						strcpy(result1, reg_name);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%sps2pi\t", mnemonic);
//NEVER						sprintf(result1, "%%mm%u", reg);
//NEVER					}
//NEVER					break;
				case 0x2e: /* ucomisd & ucomiss */
				case 0x2f: /*  comisd &  comiss */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						printf("%ssd\t", mnemonic);
					} else /* no prefix_byte */{
						printf("%sss\t", mnemonic);
					}
					break;
				case 0xe0: /* pavgb */
				case 0xe3: /* pavgw */
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						sse2 = TRUE;
//Putback						printf("%s\t", mnemonic);
					} else { /* no prefix_byte */
						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
//NEVER						printf("%s\t", mnemonic);
//NEVER						mmx = TRUE;
					}
					break;
				case 0xe6: /* cvttpd2dq, cvtdq2pd & cvtpd2dq */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						printf("%stpd2dq\t", mnemonic);
					}
					if(prefix_byte == 0xf3){
						printf("%sdq2pd\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						hooleyDebug();
//NEVER						printf("%spd2dq\t", mnemonic);
					}
					break;
				case 0x5a: /* cvtpd2ps, cvtsd2ss, cvtss2sd & cvtps2pd */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						printf("%spd2ps\t", mnemonic);
					} else if(prefix_byte == 0xf2){
						printf("%ssd2ss\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						printf("%sss2sd\t", mnemonic);
					} else /* no prefix_byte */ {
						printf("%sps2pd\t", mnemonic);
					}
					break;
				case 0x5b: /* cvtdq2ps, cvttps2dq & cvtps2dq */
					sse2 = TRUE;
					if(prefix_byte == 0x66){
						hooleyDebug();
//NEVER						printf("%sps2dq\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						printf("%stps2dq\t", mnemonic);
					} else /* no prefix_byte */{
						hooleyDebug();
//NEVER						printf("%sdq2ps\t", mnemonic);
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
						printf("%s\t", mnemonic);
						sse2 = TRUE;
					} else { /* no prefix_byte */
						sprintf(result1, "%%mm%lu", (unsigned long)reg);
//Putback						printf("%s\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0x6c: /* punpcklqdq */
				case 0x6d: /* punpckhqdq */
					sse2 = TRUE;
					if(prefix_byte == 0x66) {
						printf("%sqdq\t", mnemonic);
					}
					break;
				case 0x6f: /* movdqa, movdqu & movq */
					if(prefix_byte == 0x66){
						sse2 = TRUE;
						printf("%sdqa\t", mnemonic);
					} else if(prefix_byte == 0xf3){
						sse2 = TRUE;
						printf("%sdqu\t", mnemonic);
					} else { /* no prefix_byte */
						sprintf(result1, "%%mm%lu", (unsigned long)reg);
						printf("%sq\t", mnemonic);
						mmx = TRUE;
					}
					break;
				case 0xd6: /* movdq2q & movq2dq */
					if(prefix_byte == 0xf2){
						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
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
						printf("%s\t", mnemonic);
						wbit = LONGOPERAND;
					} else { /* no prefix_byte */
						sprintf(result1, "%%mm%lu", (unsigned long)reg);
						printf("%s\t", mnemonic);
						wbit = LONGOPERAND;
					}
					break;
				case 0xd0: /* addsubpd */
				case 0x7c: /* haddp */
				case 0x7d: /* hsubp */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						printf("%sd\t", mnemonic);
//NEVER						sse2 = TRUE;
//NEVER					} else if(prefix_byte == 0xf2){
//NEVER						hooleyDebug();
//NEVER						printf("%ss\t", mnemonic);
//NEVER						sse2 = TRUE;
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
//NEVER						printf("%s\t", mnemonic);
//NEVER						mmx = TRUE;
//NEVER					}
//NEVER					break;
				case 0xd7: /* pmovmskb */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER						printf("%s\t%%xmm%u,%s\n", mnemonic, xmm_rm(r_m, rex), reg_name);
//NEVER						return(length);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER						printf("%s\t%%mm%u,%s\n", mnemonic, r_m, reg_name);
//NEVER						return(length);
//NEVER					}
//NEVER					break;
				case 0xda: /* pminub */
				case 0xde: /* pmaxub */
				case 0xe4: /* pmulhuw */
				case 0xea: /* pminsw */
				case 0xee: /* pmaxsw */
				case 0xf4: /* pmuludq */
				case 0xf6: /* psadbw */
					hooleyDebug();
//NEVER					if(prefix_byte == 0x66){
//NEVER						hooleyDebug();
//NEVER						sse2 = TRUE;
//NEVER						printf("%s\t", mnemonic);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						sprintf(result1, "%%mm%u", reg);
//NEVER						printf("%s\t", mnemonic);
//NEVER						mmx = TRUE;
//NEVER					}
//NEVER					break;
//NEVER				case 0xf0: /* lddqu */
//NEVER					hooleyDebug();
//NEVER					printf("%s\t", mnemonic);
//NEVER					sse2 = TRUE;
//NEVER					break;
//NEVER				case 0xf7: /* maskmovdqu & maskmovq */
//NEVER					hooleyDebug();
//NEVER					sse2 = TRUE;
//NEVER					if(prefix_byte == 0x66) {
//NEVER						hooleyDebug();
//NEVER						printf("%sdqu\t", mnemonic);
//NEVER					} else { /* no prefix_byte */
//NEVER						hooleyDebug();
//NEVER						printf("%sq\t%%mm%u,%%mm%u\n", mnemonic, r_m, reg);
//NEVER						return(length);
//NEVER					}
//NEVER					break;
			} // end switch

			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			
			// -- soo i dont have an operand and i dont have result1 register
			// i have missed the suffix off the operand. eg - i am printing cvttps2d %xmm0,%xmm0 as cvt  %xmm0 %xmm0 -- which doesn't tell you as 
			
			// eg movsd	(%eax),%xmm0
			FILLARGS2( abstractStrctPtr1, reg_struct );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );		
			return(length);

		/* SSE4 instructions */
		case SSE4:
				hooleyDebug();
//NEVER				sse2 = TRUE;
//NEVER				data16 = FALSE;
//NEVER				wbit = LONGOPERAND;
//NEVER				if(got_modrm_byte == FALSE){
//NEVER					hooleyDebug();
//NEVER					got_modrm_byte = TRUE;
//NEVER					byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER					byte = get_value(sizeof(char), sect, &length, &left);
//NEVER					modrm_byte(&mode, &reg, &r_m, byte);
//NEVER				}
//NEVER				GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER				byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
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
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					reg_name = get_reg_name(reg, 1 /* wbit */, 0 /* data16 */, rex);
//NEVER					printf("%s\t", mnemonic);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER					printf("%s\n", reg_name);
//NEVER					return(length);

		/* SSE2 instructions with 8 bit immediate with further prefix decoding*/
		case SSE2i:
			data16 = FALSE;
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			/* pshufw */
			if((opcode4 << 4 | opcode5) == 0x70 && prefix_byte == 0) {
				hooleyDebug();
//NEVER						mmx = TRUE;
			}
			/* pinsrw */
			else if((opcode4 << 4 | opcode5) == 0xc4) {
				hooleyDebug();
//NEVER						wbit = LONGOPERAND;
			} else {
				sse2 = TRUE;
			}
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			byte = get_value(sizeof(char), sect, &length, &left);
			NEW_IMMEDIATE( value0Immed, byte );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x70: /* pshufd, pshuflw, pshufhw & pshufw */
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66) {
//NEVER								hooleyDebug();
//NEVER								printf("%sfd\t$0x%x,", mnemonic, byte);
//NEVER							} else if(prefix_byte == 0xf2) {
//NEVER								hooleyDebug();
//NEVER								printf("%sflw\t$0x%x,", mnemonic, byte);
//NEVER							} else if(prefix_byte == 0xf3) {
//NEVER								hooleyDebug();
//NEVER								printf("%sfhw\t$0x%x,", mnemonic, byte);
//NEVER							} else { /* no prefix_byte */
//NEVER								hooleyDebug();
//NEVER								printf("%sfw\t$0x%x,", mnemonic, byte);
//NEVER								print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER								printf("%%mm%u\n", reg);
//NEVER								return(length);
//NEVER							}
					break;
				case 0xc4: /* pinsrw */
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66){
//NEVER								hooleyDebug();
//NEVER								printf("%s\t$0x%x,", mnemonic, byte);
//NEVER							} else { /* no prefix_byte */
//NEVER								hooleyDebug();
//NEVER								printf("%s\t$0x%x,", mnemonic, byte);
//NEVER								print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//NEVER								printf("%%mm%u\n", reg);
//NEVER								return(length);
//NEVER							}
					break;
				case 0xc5: /* pextrw */
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66){
//NEVER								hooleyDebug();
//NEVER								reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER								printf("%s\t$0x%x,%%xmm%u,%s\n", mnemonic, byte,
//NEVER								   xmm_rm(r_m, rex), reg_name);
//NEVER								return(length);
//NEVER							} else { /* no prefix_byte */
//NEVER								hooleyDebug();
//NEVER								reg_name = get_reg_name(reg, 1, data16, rex);
//NEVER								printf("%s\t$0x%x,%%mm%u,%s\n", mnemonic, byte, r_m,reg_name);
//NEVER								return(length);
//NEVER							}
					break;
				default:
					if(prefix_byte == 0x66) {
						hooleyDebug();
//NEVER								printf("%spd\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf2) {
						//TODO:-- maybe need to push these onto a stack?
						printf("%ssd\t$0x%x,", mnemonic, byte);
					} else if(prefix_byte == 0xf3) {
						printf("%sss\t$0x%x,", mnemonic, byte);
					} else {/* no prefix_byte */
						hooleyDebug();
//NEVER								printf("%sps\t$0x%x,", mnemonic, byte);
					}
					break;
			}
			
			// TODO: looks like there is a possibility of reg_struct already used by this point 
			//TODO: -- and then here unpack the stack into the arglist?
			
			// eg cmpsd $0x2,%xmm0,%xmm2
			// printf("%%xmm%u\n", xmm_reg(reg, rex));
			
			regNum = xmm_reg(reg, rex);
			reg_struct = &xmmReg_Struct[regNum]; //%xmm0
			FILLARGS3( value0Immed, abstractStrctPtr1, reg_struct );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* SSE2 instructions with 8 bit immediate and only 1 reg */
		case SSE2i1:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			byte = get_value(sizeof(char), sect, &length, &left);
			NEW_IMMEDIATE( value0Immed, byte );

			switch(opcode4 << 4 | opcode5)
			{
				case 0x71: /* psrlw, psllw, psraw & psrld */
					hooleyDebug();
//NEVER							if(prefix_byte == 0x66){
//NEVER								hooleyDebug();
//NEVER								if(reg == 0x2){
//NEVER									hooleyDebug();
//NEVER									printf("%srlw\t$0x%x,", mnemonic, byte);
//NEVER								} else if(reg == 0x4) {
//NEVER									hooleyDebug();
//NEVER									printf("%sraw\t$0x%x,", mnemonic, byte);
//NEVER								} else if(reg == 0x6) {
//NEVER									hooleyDebug();
//NEVER									printf("%sllw\t$0x%x,", mnemonic, byte);
//NEVER								}
//NEVER							} else { /* no prefix_byte */
//NEVER								if(reg == 0x2) {
//NEVER									hooleyDebug();
//NEVER									printf("%srlw\t$0x%x,", mnemonic, byte);
//NEVER								} else if(reg == 0x4) {
//NEVER									hooleyDebug();
//NEVER									printf("%sraw\t$0x%x,", mnemonic, byte);
//NEVER								} else if(reg == 0x6) {
//NEVER									hooleyDebug();
//NEVER									printf("%sllw\t$0x%x,", mnemonic, byte);
//NEVER								}
//NEVER								printf("%%mm%u\n", r_m);
//NEVER								return(length);
//NEVER							}
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
						return(length);
					}
					break;
				case 0x73: /* pslldq & psrldq, psrlq & psllq */
					if(prefix_byte == 0x66){
						if(reg == 0x7){
							printf("%slldq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x3){
							hooleyDebug();
//NEVER									printf("%srldq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x2){
							hooleyDebug();
//NEVER									printf("%srlq\t$0x%x,", mnemonic, byte);
						}else if(reg == 0x6){
							printf("%sllq\t$0x%x,", mnemonic, byte);
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
//NEVER								return(length);
					}
					break;
			}
			
			regNum = xmm_rm(r_m, rex);
			const struct HooReg *reg_struct = &xmmReg_Struct[regNum]; //%xmm0
			// printf("%%xmm%u\n", reg_struct );
			// eg psllq $0x1f,%xmm2
			FILLARGS2( value0Immed, reg_struct );
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* 3DNow instructions */
		case AMD3DNOW:
//Putback					printf("%s\t", mnemonic);
					sprintf(result1, "%%mm%lu", (unsigned long)reg);
//Putback					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, ",");
//Putback					printf("%s\n", result1);
					return(length);

		/* prefetch instructions */
		case PFCH:
					hooleyDebug();
//NEVER					if(got_modrm_byte == FALSE){
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
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
				hooleyDebug();
//NEVER					if(got_modrm_byte == FALSE)
//NEVER					{
//NEVER						hooleyDebug();
//NEVER						got_modrm_byte = TRUE;
//NEVER						byte = get_value(sizeof(char), sect, &length, &left);
//NEVER						modrm_byte(&mode, &reg, &r_m, byte);
//NEVER					}
//NEVER					switch(reg)
//NEVER					{
//NEVER						case 0:
//NEVER							hooleyDebug();
//NEVER							printf("%s\t", dp->name);
//NEVER							break;
//NEVER						case 1:
//NEVER							hooleyDebug();
//NEVER							printf("%sw\t", dp->name);
//NEVER							break;
//NEVER					}
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
//NEVER					return(length);

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
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			value0_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			FILLARGS3( value0Immed, reg_struct, abstractStrctPtr1 );			
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* Double shift. With no immediate operand, specifies using %cl. */
		case DSHIFTcl:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			// cl is &countReg
			// eg shldl	%cl,%eax,%esi
			FILLARGS3( &countReg, reg_struct, abstractStrctPtr1 );			
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* immediate to memory or register operand */
		case IMlw:
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);

			/* A long immediate is expected for opcode 0x81, not 0x80 & 0x83 */
			value0_size = OPSIZE(data16, opcode2==1, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg. andl $0xf0,%esp    subl $0x10,%esp
			FILLARGS2( value0Immed, abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* immediate to memory or register operand with the 'w' bit present */
		case IMw:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd1, &symsub1, &value1, &value1_size, result1);
			value0_size = OPSIZE(data16, wbit, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg movl	$0x00021730, 0x04(%edx)
			FILLARGS2( value0Immed, abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

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
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

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
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* memory operand to accumulator */
		case OA:
			if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
				hooleyDebug();
//NEVER						value0_size = OPSIZE(addr16, LONGOPERAND, 1);
//NEVER						strcpy(mnemonic, "movabsl");
			} else {
				value0_size = OPSIZE(addr16, LONGOPERAND, 0);
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);			
			NEW_IMMEDIATE( value0Immed, imm0 );
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			// eg movl	0x0123d000,%eax
			FILLARGS2( value0Immed, reg_struct );
			addLine( addr, currentFuncPtr, dp, allArgs );		
			return(length);

		/* accumulator to memory operand */
		case AO:
			if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64){
				hooleyDebug();
//NEVER						value0_size = OPSIZE(addr16, LONGOPERAND, 1);
//NEVER						strcpy(mnemonic, "movabsl");
			} else {
				value0_size = OPSIZE(addr16, LONGOPERAND, 0);
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			wbit = WBIT(opcode2);
			reg_struct = get_regStruct(0, wbit, data16, rex);
			// eg movl	%eax,0x00f2300c
			FILLARGS2( reg_struct, value0Immed );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* memory or register operand to segment register */
		case MS:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			segReg = (struct HooReg *)&SEGREG[reg];
			FILLARGS2( abstractStrctPtr1, segReg );			
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* segment register to memory or register operand	*/
		case SM:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			// GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);			
			segReg = (struct HooReg *)&SEGREG[reg];
			// printf("%s\t%s,", mnemonic, SEGREG[reg]);
			// print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			FILLARGS2( segReg, abstractStrctPtr1 );			
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* rotate or shift instrutions, which may shift by 1 or */
		/* consult the cl register, depending on the 'v' bit	*/
		case Mv:
			vbit = VBIT(opcode2);
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			/* When vbit is set, register is an operand, otherwise just $0x1 */
			if(vbit){
				// reg_name = vbit ? "%cl," : "" ;
				FILLARGS2( &countReg, abstractStrctPtr1 );
			} else {
				// reg_name = vbit ? "%cl," : "" ;
				FILLARGS1(abstractStrctPtr1);
			}
			// eg sarl	%eax
			// shll		%cl,%edx
			addLine( addr, currentFuncPtr, dp, allArgs );	
			return(length);

		/* immediate rotate or shift instrutions, which may or */
		/* may not consult the cl register, depending on the 'v' bit */
		case MvI:
			vbit = VBIT(opcode2);
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			value1_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm0, value1_size);
			NEW_IMMEDIATE( value0Immed, imm0 );

			/* When vbit is set, register is an operand, otherwise just $0x1 */
			if(vbit) {
				// reg_name = vbit ? "%cl," : "" ;
				[NSException raise:@"what?" format:@"what?"];
				// FILLARGS3(value0Immed, countReg, value0);				
			} else {
				FILLARGS2(value0Immed, abstractStrctPtr1);
			}
			// eg shll	$0x02,%eb
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		case MIb:
				hooleyDebug();
//NEVER					wbit = LONGOPERAND;
//NEVER					GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
//NEVER					value1_size = sizeof(char);
//NEVER					REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm0, value1_size);
	//NEVER			NEW_IMMEDIATE( value0Immed, imm0 );
//NEVER					printf("%s\t$", mnemonic);
//NEVER					print_operand("", symadd1, symsub1, imm0, value1_size, "", ",");
//NEVER					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
					return(length);

		/* single memory or register operand with 'w' bit present */
		case Mw:
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			FILLARGS1( abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* single memory or register operand but don't use 'l' suffix */
		case Mnol:
		/* single memory or register operand */
		case M:
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
//NEVER									byte = get_value(sizeof(char), sect, &length, &left);
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
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);

			// eg nopl	0x00(%eax,%eax)   fldl	0xe8(%ebp)
			FILLARGS1( abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* single memory or register operand */
		case Mb:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = BYTEOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// eg setbe	%al
			FILLARGS1( abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		case SREG: /* special register */
				hooleyDebug();
//NEVER					byte = get_value(sizeof(char), sect, &length, &left);
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
				// Not entirely sure this is a sufficient test for a new function
				struct hooleyFuction *currentFunc = *currentFuncPtr;
				struct hooleyFuction *newFunc = calloc( 1, sizeof(struct hooleyFuction) );
				newFunc->prev = currentFunc;
				currentFunc->next = newFunc;
				currentFunc = newFunc;
				*currentFuncPtr = currentFunc;
			}
			// eg. pushl %ebp
			FILLARGS1(reg_struct);
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* register to accumulator with register in the low 3 */
		/* bits of op code, xchg instructions */
		case RA:
		{
			reg = REGNO(opcode2);
			reg_struct = get_regStruct(reg, LONGOPERAND, data16, rex);
			// printf("%s\t%s,%s\n", mnemonic, reg_name, (data16 ? "%ax" : "%eax"));
			const struct HooReg *secondReg = data16 ? &acumx : &acumex;
			FILLARGS2( reg_struct, secondReg );
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);
		}
		/* single segment register operand, with reg in bits 3-4 of op code */
		case SEG:
			reg = byte >> 3 & 0x3; /* segment register */
			segReg = (struct HooReg *)&SEGREG[reg];
			printf("%s\t%s\n", mnemonic, segReg->name );
			// eg pushw	%es
			FILLARGS1( segReg );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* single segment register operand, with register in	*/
		/* bits 3-5 of op code					*/
		case LSEG:
			reg = byte >> 3 & 0x7; /* long seg reg from opcode */
			segReg = (struct HooReg *)&SEGREG[reg];
			printf("%s\t%s\n", mnemonic, segReg->name);
			FILLARGS1( segReg );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* memory or register operand to register */
		case MR:
			if(got_modrm_byte == FALSE){
				got_modrm_byte = TRUE;
				byte = get_value(sizeof(char), sect, &length, &left);
				modrm_byte(&mode, &reg, &r_m, byte);
			}
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			reg_struct = get_regStruct(reg, wbit, data16, rex);
			//	eg. leal 0x08(%ebp),%ecx
			FILLARGS2(abstractStrctPtr1, reg_struct);
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* immediate operand to accumulator */
		case IA:
			value0_size = OPSIZE(data16, WBIT(opcode2), 0);
			switch(value0_size) {
				case 1:
					reg_struct = &acuml;
				case 2:
					reg_struct = &acumx;
				case 4:
					reg_struct = &acumex;
			}
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			//eg cmpb	$0x2f,%al
			FILLARGS2( value0Immed, reg_struct );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* memory or register operand to accumulator */
		case MA:
			wbit = WBIT(opcode2);
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// eg mull	%ecx
			FILLARGS1( abstractStrctPtr1 );
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* si register to di register */
		case SD:
			if(addr16 == TRUE) {
				hooleyDebug();
//NEVER						printf("%s\t%s(%%si),(%%di)\n", mnemonic, seg);
			} else {
				//TODO: this is in the repz loop
				struct IndirectVal *indirect1, *indirect2;
				NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)&source_indexReg, 0, scale_factor[0] );
				NEW_INDIRECT( indirect2, segReg, 0, (struct HooReg *)&destination_indexReg, 0, scale_factor[0] );
				FILLARGS2( indirect1, indirect2 );
				// printf("%s\t%s(%%esi),(%%edi)\n", mnemonic, segReg->name);
//				printf("line>%lu\t\t", (unsigned long)iterationCounter);			
				addLine( addr, currentFuncPtr, dp, allArgs );
			}
			return(length);

		/* accumulator to di register */
		case AD:
					wbit = WBIT(opcode2);
					// reg_name = get_reg_name(0, wbit, data16, rex);
					reg_struct = get_regStruct(0, wbit, data16, rex);
					GET_BEST_REG_NAME( reg_name, reg_struct );
					
					if(addr16 == TRUE) {
//NEVER						hooleyDebug();
//NEVER						printf("%s\t%s,%s(%%di)\n", mnemonic, reg_name, seg);
					} else {
//Putback						printf("%s\t%s,%s(%%edi)\n", mnemonic, reg_name, seg);
					}
					return(length);

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
				NEW_INDIRECT( indirect1, segReg, 0, (struct HooReg *)&source_indexReg, 0, scale_factor[0] );
				FILLARGS2( indirect1, reg_struct );
				addLine( addr, currentFuncPtr, dp, allArgs );
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
			addLine( addr, currentFuncPtr, dp, allArgs ); 
			return(length);

		/* indirect to memory or register operand */
		case INM:
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			
			if((mode == 0 && (r_m == 5 || r_m == 4)) || mode == 1 || mode == 2 || mode == 3) {
//Putback						printf("%s\t*", mnemonic);
			} else {
//Putback						printf("%s\t", mnemonic);
			}
//Putback					print_operand(seg, symadd0, symsub0, value0, value0_size, result0, "\n");
			// eg jmp	*%ecx
			addLine( addr, currentFuncPtr, dp, NULL ); 
			return(length);

		/* indirect to memory or register operand (for lcall and ljmp) */
		case INMl:
			wbit = LONGOPERAND;
			abstractStrctPtr1 = (struct HooAbstractDataType *)REPLACEMENT_GET_OPERAND(&symadd0, &symsub0, &value0, &value0_size, result0);
			// eg ljmpl *%ebx				// TODO: missing the asterisk?
			FILLARGS1( abstractStrctPtr1 );			
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

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
//Putback					printf("%s\t$", mnemonic);
//Putback					print_operand("", symadd0, symsub0, imm0, value0_size, "", ",$");
//Putback					print_operand(seg, symadd1, symsub1, imm1, value1_size, "", "\n");
					return(length);

		/* jmp/call. single operand, 8 bit displacement */
		case BD:
			// gohere			
			value0_size = sizeof(char);
			DISPLACEMENT(&symadd0, &symsub0, &value0, value0_size);
			NEW_DISPLACEMENT( displaceStructPtr, value0 );
			// eg jne	0x00002b1a
			FILLARGS1( displaceStructPtr );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		/* single 32/16 bit immediate operand */
		case I:
			value0_size = OPSIZE(data16, LONGOPERAND, 0);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			FILLARGS1( value0Immed );
//			printf("line>%lu\t\t", (unsigned long)iterationCounter);			
			addLine( addr, currentFuncPtr, dp, allArgs );
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
			addLine( addr, currentFuncPtr, dp, allArgs );
			return(length);

		case ENTER:
			// wooo exotic!
			value0_size = sizeof(short);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			value1_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd1, &symsub1, &imm1, value1_size);
			NEW_IMMEDIATE( value1Immed, imm1 );
			// printf("%s\t$", mnemonic);
			// print_operand("", symadd0, symsub0, imm0, value0_size, "", ",$");
			// print_operand("", symadd1, symsub1, imm1, value1_size, "", "\n");
			FILLARGS2( value0Immed, value1Immed );						
			addLine( addr, currentFuncPtr, dp, allArgs );			
			return(length);

		/* 16-bit immediate operand */
		case RET:
			value0_size = sizeof(short);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg ret	$0x0004	
			FILLARGS1( value0Immed );			
			addLine( addr, currentFuncPtr, dp, allArgs ); 		
			return(length);

		/* single 8 bit port operand */
		case P:
			value0_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// printf("%s\t$", mnemonic);
			// print_operand(seg, symadd0, symsub0, imm0, value0_size, "", "\n");
			FILLARGS1( value0Immed );			
			addLine( addr, currentFuncPtr, dp, allArgs  );				
			return(length);

		/* single 8 bit (input) port operand				*/
		case Pi:
			value0_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// printf("%s\t$", mnemonic);
			// print_operand(seg, symadd0, symsub0, imm0, value0_size, "", ",%eax\n");
			// eg inl $0x05,%eax
			FILLARGS2( value0Immed, &acumex );			
			addLine( addr, currentFuncPtr, dp, allArgs  );			
			return(length);

		/* single 8 bit (output) port operand				*/
		case Po:
		{
			value0_size = sizeof(char);
			REPLACEMENT_IMMEDIATE(&symadd0, &symsub0, &imm0, value0_size);
			NEW_IMMEDIATE( value0Immed, imm0 );
			// eg  outb %al,$0x00
			FILLARGS2( &acumex, value0Immed );
			addLine( addr, currentFuncPtr, dp, allArgs  );		
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
				FILLARGS3( segReg, &dataReg, &acumex );
			} else {
				FILLARGS2( &dataReg, &acumex );
			}
			addLine( addr, currentFuncPtr, dp, allArgs  );		
			return(length);
		}

		/* single operand, dx register (variable (output) port instruction)*/
		case Vo:
			// printf("%s\t%s%%eax,%%dx\n", mnemonic, segReg->name);
			// eg outb %al,%dx
			if(segReg) {
				FILLARGS3( segReg, &acumex, &dataReg );
			} else {
				FILLARGS2( &acumex, &dataReg );
			}			
			addLine( addr, currentFuncPtr, dp, allArgs  );		
			return(length);

		/* The int instruction, which has two forms: int 3 (breakpoint) or  */
		/* int n, where n is indicated in the subsequent byte (format Ib).  */
		/* The int 3 instruction (opcode 0xCC), where, although the 3 looks */
		/* like an operand, it is implied by the opcode. It must be converted */
		/* to the correct base and output. */
		case INT3:
			// printf("%s\t$0x3\n", mnemonic);
			addLine( addr, currentFuncPtr, customInstruction( "int3", "--debug_breakpoint_interrupt()" ), NULL );
			return(length);

		/* just an opcode and an unused byte that must be discarded */
		case U:
			byte = get_value(sizeof(char), sect, &length, &left);
			// printf("%s\n", mnemonic);
			addLine( addr, currentFuncPtr, dp, NULL );			
			return(length);

		case CBW:
			if(data16==TRUE){
				// printf("cbtw\n"); // -- sign-extend byte in `%al' to word in `%ax'
				addLine( addr, currentFuncPtr, &op_cbtw, NULL );				
			}else{
				// printf("cwtl\n"); // -- sign-extend word in `%ax' to long in `%eax'
				addLine( addr, currentFuncPtr, &op_cwtl, NULL );
			}
			return(length);

		case CWD:
			if(data16 == TRUE){
				// printf("cwtd\n");
				addLine( addr, currentFuncPtr, &op_cwtd, NULL );
			}else{
				// printf("cltd\n");
				addLine( addr, currentFuncPtr, &op_cltd, NULL );				
			}
			return(length);

		/* no disassembly, the mnemonic was all there was so go on */
		case GO_ON:
			 // eg. hlt, nop, etc.
			if( strcmp(dp->name, "nop" )) {
				addLine( addr, currentFuncPtr, dp, NULL );
			}
			return(length);

		/* float reg */
		case F:
		{
			// printf("%s\t%%st(%1.1u)\n", mnemonic, r_m);
			addLine( addr, currentFuncPtr, customInstruction( "fstp", "floatingPointStack.pop()" ), NULL );
			return(length);
		}
		/* float reg to float reg, with ret bit present */
		case FF:
					/* return result bit for 287 instructions */
					if(((opcode2 >> 2) & 0x1) == 0x1 && opcode2 != 0xf) {
						printf("%s\t%%st,%%st(%1.1u)\n", mnemonic, r_m);
					} else {
						printf("%s\t%%st(%1.1u),%%st\n", mnemonic, r_m);
					}
					return(length);

		/* an invalid op code */
		case AM:
		case DM:
		case OVERRIDE:
		case PREFIX:
		case UNKNOWN:
			default:
				printf(".byte 0x%02x", 0xff & sect[0]);
				for(i = 1; i < length; i++) {
					printf(", 0x%02x", 0xff & sect[i]);
				}
				printf(" #bad opcode\n");
				return(length);
	} /* end switch */
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
						uint64 sect_addr,
						NSUInteger *length,
						uint64 *left,
						const uint64 addr,
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
	if(r_m == ESP && mode != REG_ONLY && (((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) || addr16 == FALSE)){
	    s_i_b = TRUE;
	    byte = get_value(sizeof(char), sect, length, left);
	    modrm_byte((NSUInteger *)&ss, (NSUInteger *)&index, (NSUInteger *)&base, byte);
	} else {
	    s_i_b = FALSE;
	}
	if(addr16) {
	    *value_size = dispsize16[r_m][mode];
	}else{
	    *value_size = dispsize32[r_m][mode];
	}
	if(s_i_b == TRUE && mode == 0 && base == EBP)
	    *value_size = sizeof(int32_t);
	
	if(*value_size != 0){
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
					const struct HooReg *reg_struct = &regname64_Struct[mode][base + (REX_B(rex) << 3)];					
					const struct HooReg *indexReg = &indexname64_Struct[index + (REX_X(rex) << 3)];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, segReg, 0, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[0] );
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
					// TODO: these have the comma in the args
					const struct HooReg *indexReg = &indexname64_Struct[index + (REX_X(rex) << 3)];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( 
								 indirStrct, segReg, 0, 0, 
								 (struct HooReg *)indexReg, 
								 scale_factor[ss] );
					
					return (NSUInteger)indirStrct;
//					sprintf( result, "(%s,%s)", todo, scale_factor[ss] );
				} else {
					const struct HooReg *reg_struct = &regname64_Struct[mode][base + (REX_B(rex) << 3)];
					const struct HooReg *indexReg = &indexname64_Struct[index + (REX_X(rex) << 3)];
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
					const struct HooReg *reg_struct = &regname32_Struct[mode][base];
					const struct HooReg *indexReg = &indexname_Struct[index];
					struct IndirectVal *indirStrct;
					NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[0] );
					return (NSUInteger)indirStrct;
				}
			} else {
				const struct HooReg *reg_struct = &regname32_Struct[mode][base];
				const struct HooReg *indexReg = &indexname_Struct[index];				
				struct IndirectVal *indirStrct;
				NEW_INDIRECT( indirStrct, segReg, 0, (struct HooReg *)reg_struct, (struct HooReg *)indexReg, scale_factor[ss]);
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
				const struct HooReg *reg_struct = &xmmReg_Struct[regNum]; //%xmm0
				// sprintf(result, "%%xmm%u", );
				return (NSUInteger)reg_struct;

			} else if(mmx == TRUE) {
				sprintf(result, "%%mm%ld", (unsigned long)r_m);
				
			} else if (data16 == FALSE || rex != 0) {
				/* The presence of a REX byte overrides 66h. */
				//const char *regname = REG32[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
				const struct HooReg *reg_struct = &REG32_Struct[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];				
				return (NSUInteger)reg_struct;
	
			} else {
				const struct HooReg *reg_struct = &REG16_Struct[r_m][wbit];
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
//TODO: here in 64bit mode					-- here
					sprintf(result, "(%%rip)");
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
						const struct HooReg *reg_struct = &regname32_Struct[mode][r_m];
						char *reg_name;
						GET_BEST_REG_NAME( reg_name, reg_struct );
						sprintf(result, "(%s)", reg_name);
					} else {
						struct HooReg *reg_structPair = regname16_Struct[mode][r_m];
						struct HooReg *reg_struct = &(reg_structPair[0]);
						struct HooReg *reg_struct2 = &(reg_structPair[1]);
						if (reg_struct2->isah==NULL_ARG) {
							reg_struct2 = 0;
						}						
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg,0, (struct HooReg *)reg_struct, reg_struct2, scale_factor[0] );
						return (NSUInteger)indirStrct;
					}
				} else {
					if((cputype & CPU_ARCH_ABI64) == CPU_ARCH_ABI64) {
						const struct HooReg *reg_struct = &regname64_Struct[mode][r_m + (REX_B(rex) << 3)];				
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg,0,(struct HooReg *)reg_struct,0, scale_factor[0] );
						return (NSUInteger)indirStrct;
					
						// sprintf(result, "(%s)", 1 );
					} else {
						
						const struct HooReg *reg_struct = &regname32_Struct[mode][r_m];					
						struct IndirectVal *indirStrct;
						NEW_INDIRECT( indirStrct, segReg, *value, (struct HooReg *)reg_struct,0, scale_factor[0] );
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
//	    byte = get_value(sizeof(char), sect, length, left);
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
//				sprintf(result, "%%xmm%u", xmm_rm(r_m, rex));
//			} else if(mmx == TRUE) {
//				sprintf(result, "%%mm%u", r_m);
//			} else if (data16 == FALSE || rex != 0) {
//				/* The presence of a REX byte overrides 66h. */
//				//const char *regname = REG32[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
//				const struct HooReg *reg_struct = &REG32_Struct[r_m + (REX_B(rex) << 3)][wbit +  REX_W(rex)];
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
//					//const struct HooReg *reg_struct = &regname16_Struct[mode][r_m];
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
	uint64 sect_addr,
	NSUInteger *length,
	uint64 *left,
	cpu_type_t cputype,
	const uint64 addr,
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
uint64_t sect_addr,
NSUInteger *length,
uint64 *left,

const cpu_type_t cputype,
const uint64_t addr,
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

	sect_offset = addr + *length - sect_addr;
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
	    *value += addr + *length;

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
				*value += addr + *length;
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
NSUInteger *mode,
NSUInteger *reg,
NSUInteger *r_m,
unsigned char byte)
{
	*r_m = byte & 0x7; /* r/m field from the byte */
	*reg = byte >> 3 & 0x7; /* register field from the byte */
	*mode = byte >> 6 & 0x3; /* mode field from the byte */
}
