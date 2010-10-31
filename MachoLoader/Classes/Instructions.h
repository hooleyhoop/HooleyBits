/*
 *  Instructions.h
 *  MachoLoader
 *
 *  Created by Steven Hooley on 14/10/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */


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


#define	TERM	0	/* used to indicate that the 'indirect' field of the */

#define MAX_MNEMONIC	11	/* Maximum number of chars per mnemonic, plus a byte for '\0' */

/*
 * This is the structure that is used for storing all the op code information.
 */
struct instable {
	const char name[MAX_MNEMONIC];
	const struct instable *indirect;
	const unsigned adr_mode;
	const int flags;
	const struct instable *arch64;
	const char *printStr;
	
#define ISJUMP 1		// ie. does this change the execution flow
#define ISBRANCH 2		// ie. does this conditionally change the execution flow
#define ISCOMPARE 4
#define NOTUSED 8	
	// notused isCompare isBranch isJump
	// ie
	uint16 typeBitField;
};

#define hooInstruction_ static const struct instable const

/* 'instable' terminates - no pointer.	*/
hooInstruction_		invalid_instr	= {"", TERM,0, 0, 0, "", 0};
hooInstruction_		op_invalid_64	= {"", TERM,/* UNKNOWN */0, 0, 0, "", 0};

#define	INVALID	(&invalid_instr)
#define INVALID_64 (&op_invalid_64)

/*
 * These are defined this way to make the initializations in the tables simpler
 * and more readable for differences between 32-bit and 64-bit architectures.
 */
#define	INVALID_32 "",TERM,UNKNOWN,0


// const char *varname;		-- values in varname are constant, ie varname[0] = 'a'; will warn
// char const *varname;		-- actual pointer "varname" is constant so varname = &somebuf; will warn
// here we use both

hooInstruction_		op_monitor	= {"monitor",TERM,GO_ON,0,0,"",0};
hooInstruction_		op_mwait	= {"mwait",TERM,GO_ON,0,0,"",0};

/* These opcode tables entries are only used for the 64-bit architecture */
hooInstruction_		op_swapgs	= {"swapgs",TERM,GO_ON,0,0,"",0};
hooInstruction_		op_syscall	= {"syscall",TERM,GO_ON,0,0,"",0};
hooInstruction_		op_sysret	= {"sysret",TERM,GO_ON,0,0,"",0};
hooInstruction_		opREX		= {"",TERM,REX,0,0,"",0};
hooInstruction_		op_movsl	= {"movsl",TERM,MOVZ,1,0,"",0};
hooInstruction_		op_cbtw		= {"cbtw",0,0,0,0,"%ax = %al",0};		// sign-extend byte in `%al' to word in `%ax'
hooInstruction_		op_cwtl		= {"cwtl",0,0,0,0,"%eax = %ax",0};		// sign-extend word in `%ax' to long in `%eax'
hooInstruction_		op_cwtd		= {"cwtd",0,0,0,0,"%dx:%ax = %ax",0};	// sign-extend word in `%ax' to long in `%dx:%ax'
hooInstruction_		op_cltd		= {"cltd",0,0,0,0,"%edx:%eax = %eax",0}; // sign-extend dword in `%eax' to quad in `%edx:%eax'


//a
//b
//c
//d
//e
//f
hooInstruction_		fstp1_instr		= { "fstp",		0,		0, 0, 0, "floatingPointStack.pop()",0};
//g
//h
//i
hooInstruction_		int3_instr		= { "int3",		0,		0, 0, 0, "--debug_breakpoint_interrupt()",0};
//j
//k
//l
hooInstruction_		lldt_instr		= { "lldt",		TERM,	M, 1,0,"",0};
hooInstruction_		ltr_instr		= { "ltr",		TERM,	M, 1,0,"",0};
//m
//n
//o
//p
//q
//r
//s
hooInstruction_		sldt_instr		= { "sldt",		TERM,	M, 1,0,"",0};
hooInstruction_		str_instr		= { "str",		TERM,	M, 1,0,"",0};
//t
//u
//v
hooInstruction_		verr_instr		= { "verr",		TERM,	M, 1,0,"",0};
hooInstruction_		verw_instr		= { "verw",		TERM,	M, 1,0,"",0};
//w
//x
//y
//z
hooInstruction_		sgdt_instr = {"sgdt",TERM,M,1,0,"",0};
hooInstruction_		sidt_instr = {"sidt",TERM,M,1,0,"",0};
hooInstruction_		lgdt_instr = {"lgdt",TERM,M,1,0,"",0};
hooInstruction_		lidt_instr = {"lidt",TERM,M,1,0,"",0};
hooInstruction_		smsw_instr = {"smsw",TERM,M,1,0,"",0};
hooInstruction_		lmsw_instr = {"lmsw",TERM,M,1,0,"",0};
hooInstruction_		invlpg_instr = {"invlpg",TERM,M,1,0,"",0};

// find \{"([a-z0-9]+)" replace \1_instr = {"\1"

hooInstruction_ lock_prefix = {"lock/",TERM,PREFIX,0,0,"",0};
hooInstruction_ pfcmpeq_instr = {"pfcmpeq",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ _push_instr = {"_push",TERM,LSEG,0x03,0,"",0};

hooInstruction_ CBW_instr = {"",TERM,CBW,0,0,"",0};
hooInstruction_ CWD_instr = {"",TERM,CWD,0,0,"",0};
hooInstruction_ cs_instr = {"%cs:",TERM,OVERRIDE,0,0,"",0};
hooInstruction_ ds_instr = {"%ds:",TERM,OVERRIDE,0,0,"",0};
hooInstruction_ es_instr = {"%es:",TERM,OVERRIDE,0,0,"",0};
hooInstruction_ fs_instr = {"%fs:",TERM,OVERRIDE,0,0,"",0};
hooInstruction_ gs_instr = {"%gs:",TERM,OVERRIDE,0,0,"",0};
hooInstruction_ ss_instr = {"%ss:",TERM,OVERRIDE,0,0,"",0};

hooInstruction_ aaa_instr = {"aaa",TERM,GO_ON,0,INVALID_64,"",0};
hooInstruction_ aad_instr = {"aad",TERM,U,0,INVALID_64,"",0};
hooInstruction_ aam_instr = {"aam",TERM,U,0,INVALID_64,"",0};
hooInstruction_ aas_instr = {"aas",TERM,GO_ON,0,INVALID_64,"",0};

hooInstruction_ adc_instr1 = {"adc",TERM,IA,1,0,"",0};
hooInstruction_ adc_instr2 = {"adc",TERM,IMlw,1,0,"",0};
hooInstruction_ adc_instr3 = {"adc",TERM,MRw,1,0,"",0};
hooInstruction_ adc_instr4 = {"adc",TERM,RMw,1,0,"",0};

hooInstruction_ adcb_instr1 = {"adcb",TERM,IA,0,0,"",0};
hooInstruction_ adcb_instr2 = {"adcb",TERM,IMlw,0,0,"",0};
hooInstruction_ adcb_instr3 = {"adcb",TERM,MRw,0,0,"",0};
hooInstruction_ adcb_instr4 = {"adcb",TERM,RMw,0,0,"",0};

hooInstruction_ add_instr1 = {"add",TERM,IA,1,0,"@2 = @2 + @1",0};
hooInstruction_ add_instr2 = {"add",TERM,IMlw,1,0,"@2 = @2 + @1",0};
hooInstruction_ add_instr3 = {"add",TERM,MRw,1,0,"@2 = @2 + @1",0};
hooInstruction_ add_instr4 = {"add",TERM,RMw,1,0,"@2 = @2 + @1",0};
hooInstruction_ add_instr5 = {"add",TERM,SSE2,0,0,"@2 = @2 + @1",0};

hooInstruction_ addb_instr1 = {"addb",TERM,IA,0,0,"@2 = @2 + @1",0};
hooInstruction_ addb_instr2 = {"addb",TERM,IMlw,0,0,"@2 = @2 + @1",0};
hooInstruction_ addb_instr3 = {"addb",TERM,MRw,0,0,"@2 = @2 + @1",0};
hooInstruction_ addb_instr4 = {"addb",TERM,RMw,0,0,"@2 = @2 + @1",0};

hooInstruction_ addr16_instr = {"addr16",TERM,AM,0,0,"",0};
hooInstruction_ addsubp_instr = {"addsubp",TERM,SSE2,0,0,"",0};

hooInstruction_ and_instr1 = {"and",TERM,IA,1,0,"@2 = @2 & @1",0};
hooInstruction_ and_instr2 = {"and",TERM,IMlw,1,0,"@2 = @2 & @1",0};
hooInstruction_ and_instr3 = {"and",TERM,IMw,1,0,"@2 = @2 & @1",0};
hooInstruction_ and_instr4 = {"and",TERM,MRw,1,0,"@2 = @2 & @1",0};
hooInstruction_ and_instr5 = {"and",TERM,RMw,1,0,"@2 = @2 & @1",0};
hooInstruction_ and_instr6 = {"and",TERM,SSE2,0,0,"@2 = @2 & @1",0};

hooInstruction_ andb_instr1 = {"andb",TERM,IA,0,0,"@2 = @2 & @1",0};
hooInstruction_ andb_instr2 = {"andb",TERM,IMw,0,0,"@2 = @2 & @1",0};
hooInstruction_ andb_instr3 = {"andb",TERM,MRw,0,0,"@2 = @2 & @1",0};
hooInstruction_ andb_instr4 = {"andb",TERM,RMw,0,0,"@2 = @2 & @1",0};

hooInstruction_ andn_instr = {"andn",TERM,SSE2,0,0,"",0};
hooInstruction_ arpl_instr = {"arpl",TERM,RMw,0,&op_movsl,"",0};
hooInstruction_ blendpd_instr = {"blendpd",TERM,SSE4i,0,0,"",0};
hooInstruction_ blendps_instr = {"blendps",TERM,SSE4i,0,0,"",0};
hooInstruction_ bound_instr = {"bound",TERM,MR,1,INVALID_64,"",0};
hooInstruction_ bsf_instr = {"bsf",TERM,MRw,1,0,"",0};
hooInstruction_ bsr_instr = {"bsr",TERM,MRw,1,0,"",0};
hooInstruction_ bswap_instr = {"bswap",TERM,BSWAP,0,0,"",0};

hooInstruction_ bt_instr1 = {"bt",TERM,MIb,1,0,"",0};
hooInstruction_ bt_instr2 = {"bt",TERM,RMw,1,0,"",0};

hooInstruction_ btc_instr1 = {"btc",TERM,MIb,1,0,"",0};
hooInstruction_ btc_instr2 = {"btc",TERM,RMw,1,0,"",0};

hooInstruction_ btr_instr1 = {"btr",TERM,MIb,1,0,"",0};
hooInstruction_ btr_instr2 = {"btr",TERM,RMw,1,0,"",0};

hooInstruction_ bts_instr1 = {"bts",TERM,MIb,1,0,"",0};
hooInstruction_ bts_instr2 = {"bts",TERM,RMw,1,0,"",0};

hooInstruction_ call_instr1 = {"call",TERM,D,0x03,0,"",0};
hooInstruction_ call_instr2 = {"call",TERM,INM,1,0,"",0};

hooInstruction_ clc_instr = {"clc",TERM,GO_ON,0,0,"",0};
hooInstruction_ cld_instr = {"cld",TERM,GO_ON,0,0,"",0};
hooInstruction_ clflush_instr = {"clflush",TERM,SFEN,1,0,"",0};
hooInstruction_ cli_instr = {"cli",TERM,GO_ON,0,0,"",0};
hooInstruction_ clts_instr = {"clts",TERM,GO_ON,0,0,"",0};
hooInstruction_ cmc_instr = {"cmc",TERM,GO_ON,0,0,"",0};
hooInstruction_ cmova_instr = {"cmova",TERM,MRw,1,0,"",0};
hooInstruction_ cmovae_instr = {"cmovae",TERM,MRw,1,0,"",0};
hooInstruction_ cmovb_instr = {"cmovb",TERM,MRw,1,0,"",0};
hooInstruction_ cmovbe_instr = {"cmovbe",TERM,MRw,1,0,"",0};
hooInstruction_ cmove_instr = {"cmove",TERM,MRw,1,0,"",0};
hooInstruction_ cmovg_instr = {"cmovg",TERM,MRw,1,0,"",0};
hooInstruction_ cmovge_instr = {"cmovge",TERM,MRw,1,0,"",0};
hooInstruction_ cmovl_instr = {"cmovl",TERM,MRw,1,0,"",0};
hooInstruction_ cmovle_instr = {"cmovle",TERM,MRw,1,0,"",0};
hooInstruction_ cmovne_instr = {"cmovne",TERM,MRw,1,0,"",0};
hooInstruction_ cmovno_instr = {"cmovno",TERM,MRw,1,0,"",0};
hooInstruction_ cmovnp_instr = {"cmovnp",TERM,MRw,1,0,"",0};
hooInstruction_ cmovns_instr = {"cmovns",TERM,MRw,1,0,"",0};
hooInstruction_ cmovp_instr = {"cmovp",TERM,MRw,1,0,"",0};
hooInstruction_ cmovs_instr = {"cmovs",TERM,MRw,1,0,"",0};

hooInstruction_ cmp_instr1 = {"cmp",TERM,IA,1,0,"compare( @1, @2 )",0};
hooInstruction_ cmp_instr2 = {"cmp",TERM,IMlw,1,0,"compare( @1, @2 )",0};
hooInstruction_ cmp_instr3 = {"cmp",TERM,MRw,1,0,"compare( @1, @2 )",0};
hooInstruction_ cmp_instr4 = {"cmp",TERM,RMw,1,0,"compare( @1, @2 )",0};
hooInstruction_ cmp_instr5 = {"cmp",TERM,SSE2i,0,0,"compare( @1, @2 )",0};

hooInstruction_ cmpb_instr1 = {"cmpb",TERM,IA,0,0,"",0};
hooInstruction_ cmpb_instr2 = {"cmpb",TERM,IMlw,0,0,"compare( @1, @2 )",0};
hooInstruction_ cmpb_instr3 = {"cmpb",TERM,IMlw,0,0,"",0};
hooInstruction_ cmpb_instr4 = {"cmpb",TERM,MRw,0,0,"",0};
hooInstruction_ cmpb_instr5 = {"cmpb",TERM,RMw,0,0,"",0};

hooInstruction_ cmps_instr = {"cmps",TERM,SD,1,0,"",0};
hooInstruction_ cmpsb_instr = {"cmpsb",TERM,SD,0,0,"",0};
hooInstruction_ cmpxchg_instr = {"cmpxchg",TERM,XINST,1,0,"",0};
hooInstruction_ cmpxchg8b_instr = {"cmpxchg8b",TERM,M,1,0,"",0};
hooInstruction_ cmpxchgb_instr = {"cmpxchgb",TERM,XINST,0,0,"",0};
hooInstruction_ comi_instr = {"comi",TERM,SSE2,0,0,"",0};
hooInstruction_ cpuid_instr = {"cpuid",TERM,GO_ON,0,0,"",0};
hooInstruction_ cvt_instr = {"cvt",TERM,SSE2,0,0,"",0};

hooInstruction_ daa_instr = {"daa",TERM,GO_ON,0,INVALID_64,"",0};
hooInstruction_ das_instr = {"das",TERM,GO_ON,0,INVALID_64,"",0};
hooInstruction_ data16_instr = {"data16",TERM,DM,0,0,"",0};

hooInstruction_ dec_instr1 = {"dec",TERM,Mw,1,0,"@1 = @1 - 1",0};
hooInstruction_ dec_instr2 = {"dec",TERM,R,1, &opREX, "@1 = @1 - 1",0};

hooInstruction_ decb_instr = {"decb",TERM,Mw,0,0,"",0};

hooInstruction_ div_instr1 = {"div",TERM,MA,1,0,"",0};
hooInstruction_ div_instr2 = {"div",TERM,SSE2,0,0,"",0};

hooInstruction_ divb_instr = {"divb",TERM,MA,0,0,"",0};
hooInstruction_ dppd_instr = {"dppd",TERM,SSE4i,0,0,"",0};
hooInstruction_ dpps_instr = {"dpps",TERM,SSE4i,0,0,"",0};
hooInstruction_ emms_instr = {"emms",TERM,GO_ON,0,0,"",0};
hooInstruction_ enter_instr = {"enter",TERM,ENTER,0,0,"",0};
hooInstruction_ extractps_instr = {"extractps",TERM,SSE4itm,0,0,"",0};
hooInstruction_ f2xm1_instr = {"f2xm1",TERM,GO_ON,0,0,"",0};
hooInstruction_ fabs_instr = {"fabs",TERM,GO_ON,0,0,"",0};
hooInstruction_ fadd_instr = {"fadd",TERM,FF,0,0,"",0};

hooInstruction_ faddl_instr = {"faddl",TERM,M,0,0,"",0};
hooInstruction_ faddp_instr = {"faddp",TERM,FF,0,0,"",0};
hooInstruction_ fadds_instr = {"fadds",TERM,M,0,0,"",0};
hooInstruction_ falc_instr = {"falc",TERM,GO_ON,0,0,"",0};
hooInstruction_ fbld_instr = {"fbld",TERM,M,0,0,"",0};
hooInstruction_ fbstp_instr = {"fbstp",TERM,M,0,0,"",0};
hooInstruction_ fchs_instr = {"fchs",TERM,GO_ON,0,0,"",0};
hooInstruction_ fcmovb_instr = {"fcmovb",TERM,FF,0,0,"",0};
hooInstruction_ fcmovbe_instr = {"fcmovbe",TERM,FF,0,0,"",0};
hooInstruction_ fcmove_instr = {"fcmove",TERM,FF,0,0,"",0};
hooInstruction_ fcmovnb_instr = {"fcmovnb",TERM,FF,0,0,"",0};
hooInstruction_ fcmovnbe_instr = {"fcmovnbe",TERM,FF,0,0,"",0};
hooInstruction_ fcmovne_instr = {"fcmovne",TERM,FF,0,0,"",0};
hooInstruction_ fcmovnu_instr = {"fcmovnu",TERM,FF,0,0,"",0};
hooInstruction_ fcmovu_instr = {"fcmovu",TERM,FF,0,0,"",0};
hooInstruction_ fcom_instr = {"fcom",TERM,F,0,0,"",0};

hooInstruction_ fcomi_instr = {"fcomi",TERM,FF,0,0,"",0};
hooInstruction_ fcomip_instr = {"fcomip",TERM,FF,0,0,"",0};
hooInstruction_ fcoml_instr = {"fcoml",TERM,M,0,0,"",0};
hooInstruction_ fcomp_instr = {"fcomp",TERM,F,0,0,"",0};

hooInstruction_ fcompl_instr = {"fcompl",TERM,M,0,0,"",0};
hooInstruction_ fcompp_instr = {"fcompp",TERM,GO_ON,0,0,"",0};
hooInstruction_ fcomps_instr = {"fcomps",TERM,M,0,0,"",0};
hooInstruction_ fcoms_instr = {"fcoms",TERM,M,0,0,"",0};
hooInstruction_ fcos_instr = {"fcos",TERM,GO_ON,0,0,"",0};
hooInstruction_ fdecstp_instr = {"fdecstp",TERM,GO_ON,0,0,"",0};
hooInstruction_ fdiv_instr = {"fdiv",TERM,FF,0,0,"",0};

hooInstruction_ fdivl_instr = {"fdivl",TERM,M,0,0,"",0};
hooInstruction_ fdivp_instr = {"fdivp",TERM,FF,0,0,"",0};
hooInstruction_ fdivr_instr = {"fdivr",TERM,FF,0,0,"",0};

hooInstruction_ fdivrl_instr = {"fdivrl",TERM,M,0,0,"",0};
hooInstruction_ fdivrp_instr = {"fdivrp",TERM,FF,0,0,"",0};
hooInstruction_ fdivrs_instr = {"fdivrs",TERM,M,0,0,"",0};
hooInstruction_ fdivs_instr = {"fdivs",TERM,M,0,0,"",0};
hooInstruction_ femms_instr = {"femms",TERM,GO_ON,0,0,"",0};
hooInstruction_ ffree_instr = {"ffree",TERM,F,0,0,"",0};

hooInstruction_ fiaddl_instr = {"fiaddl",TERM,M,0,0,"",0};
hooInstruction_ fiadds_instr = {"fiadds",TERM,M,0,0,"",0};
hooInstruction_ ficoml_instr = {"ficoml",TERM,M,0,0,"",0};
hooInstruction_ ficompl_instr = {"ficompl",TERM,M,0,0,"",0};
hooInstruction_ ficomps_instr = {"ficomps",TERM,M,0,0,"",0};
hooInstruction_ ficoms_instr = {"ficoms",TERM,M,0,0,"",0};
hooInstruction_ fidivl_instr = {"fidivl",TERM,M,0,0,"",0};
hooInstruction_ fidivrl_instr = {"fidivrl",TERM,M,0,0,"",0};
hooInstruction_ fidivrs_instr = {"fidivrs",TERM,M,0,0,"",0};
hooInstruction_ fidivs_instr = {"fidivs",TERM,M,0,0,"",0};
hooInstruction_ fildl_instr = {"fildl",TERM,Mnol,0,0,"",0};
hooInstruction_ fildq_instr = {"fildq",TERM,M,0,0,"",0};
hooInstruction_ filds_instr = {"filds",TERM,M,0,0,"",0};
hooInstruction_ fimull_instr = {"fimull",TERM,M,0,0,"",0};
hooInstruction_ fimuls_instr = {"fimuls",TERM,M,0,0,"",0};
hooInstruction_ fincstp_instr = {"fincstp",TERM,GO_ON,0,0,"",0};
hooInstruction_ fistl_instr = {"fistl",TERM,M,0,0,"",0};
hooInstruction_ fistpl_instr = {"fistpl",TERM,Mnol,0,0,"",0};
hooInstruction_ fistpq_instr = {"fistpq",TERM,M,0,0,"",0};
hooInstruction_ fistps_instr = {"fistps",TERM,M,0,0,"",0};
hooInstruction_ fists_instr = {"fists",TERM,M,0,0,"",0};
hooInstruction_ fisttpl_instr = {"fisttpl",TERM,M,0,0,"",0};
hooInstruction_ fisttpll_instr = {"fisttpll",TERM,M,0,0,"",0};
hooInstruction_ fisttps_instr = {"fisttps",TERM,M,0,0,"",0};
hooInstruction_ fisubl_instr = {"fisubl",TERM,M,0,0,"",0};
hooInstruction_ fisubrl_instr = {"fisubrl",TERM,M,0,0,"",0};
hooInstruction_ fisubrs_instr = {"fisubrs",TERM,M,0,0,"",0};
hooInstruction_ fisubs_instr = {"fisubs",TERM,M,0,0,"",0};
hooInstruction_ fld_instr = {"fld",TERM,F,0,0,"",0};
hooInstruction_ fld1_instr = {"fld1",TERM,GO_ON,0,0,"",0};
hooInstruction_ fldcw_instr = {"fldcw",TERM,M,1,0,"",0};
hooInstruction_ fldenv_instr = {"fldenv",TERM,M,1,0,"",0};
hooInstruction_ fldl_instr = {"fldl",TERM,M,0,0,"",0};
hooInstruction_ fldl2e_instr = {"fldl2e",TERM,GO_ON,0,0,"",0};
hooInstruction_ fldl2t_instr = {"fldl2t",TERM,GO_ON,0,0,"",0};
hooInstruction_ fldlg2_instr = {"fldlg2",TERM,GO_ON,0,0,"",0};
hooInstruction_ fldln2_instr = {"fldln2",TERM,GO_ON,0,0,"",0};
hooInstruction_ fldpi_instr = {"fldpi",TERM,GO_ON,0,0,"",0};
hooInstruction_ flds_instr = {"flds",TERM,M,0,0,"",0};
hooInstruction_ fldt_instr = {"fldt",TERM,M,0,0,"",0};
hooInstruction_ fldz_instr = {"fldz",TERM,GO_ON,0,0,"",0};
hooInstruction_ fmul_instr = {"fmul",TERM,FF,0,0,"",0};

hooInstruction_ fmull_instr = {"fmull",TERM,M,0,0,"",0};
hooInstruction_ fmulp_instr = {"fmulp",TERM,FF,0,0,"",0};
hooInstruction_ fmuls_instr = {"fmuls",TERM,M,0,0,"",0};
hooInstruction_ fnclex_instr = {"fnclex",TERM,GO_ON,0,0,"",0};
hooInstruction_ fninit_instr = {"fninit",TERM,GO_ON,0,0,"",0};
hooInstruction_ fnop_instr = {"fnop",TERM,GO_ON,0,0,"",0};
hooInstruction_ fnsave_instr = {"fnsave",TERM,M,1,0,"",0};
hooInstruction_ fnstcw_instr = {"fnstcw",TERM,M,1,0,"",0};
hooInstruction_ fnstenv_instr = {"fnstenv",TERM,M,1,0,"",0};

hooInstruction_ fnstsw_instr = {"fnstsw",TERM,M,1,0,"",0};
hooInstruction_ fpatan_instr = {"fpatan",TERM,GO_ON,0,0,"",0};
hooInstruction_ fprem_instr = {"fprem",TERM,GO_ON,0,0,"",0};
hooInstruction_ fprem1_instr = {"fprem1",TERM,GO_ON,0,0,"",0};
hooInstruction_ fptan_instr = {"fptan",TERM,GO_ON,0,0,"",0};
hooInstruction_ frndint_instr = {"frndint",TERM,GO_ON,0,0,"",0};
hooInstruction_ frstor_instr = {"frstor",TERM,M,1,0,"",0};
hooInstruction_ fscale_instr = {"fscale",TERM,GO_ON,0,0,"",0};
hooInstruction_ fsetpm_instr = {"fsetpm",TERM,GO_ON,0,0,"",0};
hooInstruction_ fsin_instr = {"fsin",TERM,GO_ON,0,0,"",0};
hooInstruction_ fsincos_instr = {"fsincos",TERM,GO_ON,0,0,"",0};
hooInstruction_ fsqrt_instr = {"fsqrt",TERM,GO_ON,0,0,"",0};
hooInstruction_ fst_instr = {"fst",TERM,F,0,0,"",0};
hooInstruction_ fstl_instr = {"fstl",TERM,M,0,0,"",0};
hooInstruction_ fstp_instr = {"fstp",TERM,F,0,0,"",0};

hooInstruction_ fstpl_instr = {"fstpl",TERM,M,0,0,"",0};
hooInstruction_ fstps_instr = {"fstps",TERM,M,0,0,"",0};
hooInstruction_ fstpt_instr = {"fstpt",TERM,M,0,0,"",0};
hooInstruction_ fsts_instr = {"fsts",TERM,M,0,0,"",0};
hooInstruction_ fsub_instr = {"fsub",TERM,FF,0,0,"",0};

hooInstruction_ fsubl_instr = {"fsubl",TERM,M,0,0,"",0};
hooInstruction_ fsubp_instr = {"fsubp",TERM,FF,0,0,"",0};
hooInstruction_ fsubr_instr = {"fsubr",TERM,FF,0,0,"",0};

hooInstruction_ fsubrl_instr = {"fsubrl",TERM,M,0,0,"",0};
hooInstruction_ fsubrp_instr = {"fsubrp",TERM,FF,0,0,"",0};
hooInstruction_ fsubrs_instr = {"fsubrs",TERM,M,0,0,"",0};
hooInstruction_ fsubs_instr = {"fsubs",TERM,M,0,0,"",0};
hooInstruction_ ftst_instr = {"ftst",TERM,GO_ON,0,0,"",0};
hooInstruction_ fucom_instr = {"fucom",TERM,F,0,0,"",0};
hooInstruction_ fucomi_instr = {"fucomi",TERM,FF,0,0,"",0};
hooInstruction_ fucomip_instr = {"fucomip",TERM,FF,0,0,"",0};
hooInstruction_ fucomp_instr = {"fucomp",TERM,F,0,0,"",0};
hooInstruction_ fucompp_instr = {"fucompp",TERM,GO_ON,0,0,"",0};
hooInstruction_ fxam_instr = {"fxam",TERM,GO_ON,0,0,"",0};
hooInstruction_ fxch_instr = {"fxch",TERM,F,0,0,"",0};

hooInstruction_ fxrstor_instr = {"fxrstor",TERM,M,1,0,"",0};
hooInstruction_ fxsave_instr = {"fxsave",TERM,M,1,0,"",0};
hooInstruction_ fxtract_instr = {"fxtract",TERM,GO_ON,0,0,"",0};
hooInstruction_ fyl2x_instr = {"fyl2x",TERM,GO_ON,0,0,"",0};
hooInstruction_ fyl2xp1_instr = {"fyl2xp1",TERM,GO_ON,0,0,"",0};
hooInstruction_ haddp_instr = {"haddp",TERM,SSE2,0,0,"",0};
hooInstruction_ hlt_instr = {"hlt",TERM,GO_ON,0,0,"",0};
hooInstruction_ hsubp_instr = {"hsubp",TERM,SSE2,0,0,"",0};
hooInstruction_ idiv_instr = {"idiv",TERM,MA,1,0,"",0};
hooInstruction_ idivb_instr = {"idivb",TERM,MA,0,0,"",0};
hooInstruction_ imul_instr = {"imul",TERM,IMUL,1,0,"",0};

hooInstruction_ imul_instr1 = {"imul",TERM,MA,1,0,"",0};
hooInstruction_ imul_instr2 = {"imul",TERM,MRw,1,0,"",0};

hooInstruction_ imulb_instr = {"imulb",TERM,MA,0,0,"",0};

hooInstruction_ in_instr1 = {"in",TERM,Pi,1,0,"",0};
hooInstruction_ in_instr2 = {"in",TERM,Vi,1,0,"",0};

hooInstruction_ inb_instr1 = {"inb",TERM,Pi,0,0,"",0};
hooInstruction_ inb_instr2 = {"inb",TERM,Vi,0,0,"",0};

hooInstruction_ inc_instr1 = {"inc",TERM,Mw,1,0,"@1 = @1 + 1",0};
hooInstruction_ inc_instr2 = {"inc",TERM,R,1,&opREX,"@1 = @1 + 1",0};

hooInstruction_ incb_instr = {"incb",TERM,Mw,0,0,"",0};
hooInstruction_ ins_instr = {"ins",TERM,GO_ON,1,0,"",0};
hooInstruction_ insb_instr = {"insb",TERM,GO_ON,0,0,"",0};
hooInstruction_ insertps_instr = {"insertps",TERM,SSE4i,0,0,"",0};

hooInstruction_ int_instr1 = {"int",TERM,Ib,0,0,"",0};
hooInstruction_ int_instr2 = {"int",TERM,INT3,0,0,"",0};

hooInstruction_ into_instr = {"into",TERM,GO_ON,0,INVALID_64,"",0};
hooInstruction_ invd_instr = {"invd",TERM,GO_ON,0,0,"",0};
hooInstruction_ iret_instr = {"iret",TERM,GO_ON,0,0,"",0};

hooInstruction_ ja_instr1 = {"ja",TERM,BD,0,0,"jump short if above",ISBRANCH};
hooInstruction_ ja_instr2 = {"ja",TERM,D,0x03,0,"jump short if above",ISBRANCH};

hooInstruction_ jae_instr1 = {"jae",TERM,BD,0,0,"jump short if above or equal",ISBRANCH};
hooInstruction_ jae_instr2 = {"jae",TERM,D,0x03,0,"jump short if above or equal",ISBRANCH};

hooInstruction_ jb_instr1 = {"jb",TERM,BD,0,0,"jump short if below",ISBRANCH};
hooInstruction_ jb_instr2 = {"jb",TERM,D,0x03,0,"jump short if below",ISBRANCH};

hooInstruction_ jbe_instr1 = {"jbe",TERM,BD,0,0,"jump short if below or equal",ISBRANCH};
hooInstruction_ jbe_instr2 = {"jbe",TERM,D,0x03,0,"jump short if below or equal",ISBRANCH};

hooInstruction_ jcxz_instr = {"jcxz",TERM,BD,0,0,"jump short if CX register is 0",ISBRANCH};

hooInstruction_ je_instr1 = {"je",TERM,BD,0,0,"jump short if equal",ISBRANCH};
hooInstruction_ je_instr2 = {"je",TERM,D,0x03,0,"jump short if equal",ISBRANCH};

hooInstruction_ jg_instr1 = {"jg",TERM,BD,0,0,"jump short if greater",ISBRANCH};
hooInstruction_ jg_instr2 = {"jg",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jge_instr1 = {"jge",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jge_instr2 = {"jge",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jl_instr1 = {"jl",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jl_instr2 = {"jl",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jle_instr1 = {"jle",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jle_instr2 = {"jle",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jmp_instr1 = {"jmp",TERM,BD,0,0,"goto @1",ISJUMP};
hooInstruction_ jmp_instr2 = {"jmp",TERM,D,0x03,0,"goto @1",ISJUMP};
hooInstruction_ jmp_instr3 = {"jmp",TERM,INM,1,0,"goto @1",ISJUMP};

hooInstruction_ jne_instr1 = {"jne",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jne_instr2 = {"jne",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jno_instr1 = {"jno",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jno_instr2 = {"jno",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jnp_instr1 = {"jnp",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jnp_instr2 = {"jnp",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jns_instr1 = {"jns",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jns_instr2 = {"jns",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jo_instr1 = {"jo",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jo_instr2 = {"jo",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ jp_instr1 = {"jp",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ jp_instr2 = {"jp",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ js_instr1 = {"js",TERM,BD,0,0,"",ISBRANCH};
hooInstruction_ js_instr2 = {"js",TERM,D,0x03,0,"",ISBRANCH};

hooInstruction_ lahf_instr = {"lahf",TERM,GO_ON,0,0,"",0};
hooInstruction_ lar_instr = {"lar",TERM,MR,0,0,"",0};

hooInstruction_ lcall_instr1 = {"lcall",TERM,INMl,1,0,"",0};
hooInstruction_ lcall_instr2 = {"lcall",TERM,SO,0,0,"",0};

hooInstruction_ lddqu_instr = {"lddqu",TERM,SSE2,0,0,"",0};
hooInstruction_ ldmxcsr_instr = {"ldmxcsr",TERM,M,1,0,"",0};
hooInstruction_ lds_instr = {"lds",TERM,MR,0,INVALID_64,"",0};
hooInstruction_ lea_instr = {"lea",TERM,MR,1,0,"addr @2 = @1",0};
hooInstruction_ leave_instr = {"leave",TERM,GO_ON,0,0,"",0};
hooInstruction_ les_instr = {"les",TERM,MR,0,INVALID_64,"",0};
hooInstruction_ lfence_instr = {"lfence",TERM,GO_ON,0,0,"",0};
hooInstruction_ lfs_instr = {"lfs",TERM,MR,0,0,"",0};
hooInstruction_ lgs_instr = {"lgs",TERM,MR,0,0,"",0};

hooInstruction_ ljmp_instr1 = {"ljmp",TERM,INMl,1,0,"",ISJUMP};
hooInstruction_ ljmp_instr2 = {"ljmp",TERM,SO,0,0,"",ISJUMP};

hooInstruction_ lods_instr = {"lods",TERM,SA,1,0,"",0};
hooInstruction_ lodsb_instr = {"lodsb",TERM,SA,0,0,"",0};
hooInstruction_ loop_instr = {"loop",TERM,BD,0,0,"",0};
hooInstruction_ loopnz_instr = {"loopnz",TERM,BD,0,0,"",0};
hooInstruction_ loopz_instr = {"loopz",TERM,BD,0,0,"",0};

hooInstruction_ lret_instr1 = {"lret",TERM,GO_ON,0,0,"",0};
hooInstruction_ lret_instr2 = {"lret",TERM,RET,0,0,"",0};

hooInstruction_ lsl_instr = {"lsl",TERM,MR,0,0,"",0};
hooInstruction_ lss_instr = {"lss",TERM,MR,0,0,"",0};
hooInstruction_ maskmov_instr = {"maskmov",TERM,SSE2,0,0,"",0};
hooInstruction_ max_instr = {"max",TERM,SSE2,0,0,"",0};
hooInstruction_ mfence_instr = {"mfence",TERM,GO_ON,0,0,"",0};
hooInstruction_ min_instr = {"min",TERM,SSE2,0,0,"",0};

hooInstruction_ mov_instr1 = {"mov",TERM,AO,1,0,"@2 = @1",0};
hooInstruction_ mov_instr2 = {"mov",TERM,IMw,1,0,"@2 = @1",0};
hooInstruction_ mov_instr3 = {"mov",TERM,IR64,1,0,"@2 = @1",0};
hooInstruction_ mov_instr4 = {"mov",TERM,MRw,1,0,"@2 = @1",0};
hooInstruction_ mov_instr5 = {"mov",TERM,MS,1,0,"@2 = @1",0};
hooInstruction_ mov_instr6 = {"mov",TERM,OA,1,0,"@2 = @1",0};
hooInstruction_ mov_instr7 = {"mov",TERM,RMw,1,0,"@2 = @1",0};
hooInstruction_ mov_instr8 = {"mov",TERM,SM,1,0,"@2 = @1",0};
hooInstruction_ mov_instr9 = {"mov",TERM,SREG,0x03,0,"@2 = @1",0};
hooInstruction_ mov_instr10 = {"mov",TERM,SSE2,0,0,"@2 = @1",0};
hooInstruction_ mov_instr11 = {"mov",TERM,SSE2tfm,0,0,"@2 = @1",0};
hooInstruction_ mov_instr12 = {"mov",TERM,SSE2tm,0,0,"@2 = @1",0};

hooInstruction_ mova_instr1 = {"mova",TERM,SSE2,0,0,"",0};
hooInstruction_ mova_instr2 = {"mova",TERM,SSE2tm,0,0,"",0};

hooInstruction_ movb_instr1 = {"movb",TERM,AO,0,0,"@2 = @1",0};
hooInstruction_ movb_instr2 = {"movb",TERM,IMw,0,0,"@2 = @1",0};
hooInstruction_ movb_instr3 = {"movb",TERM,IR,0,0,"@2 = @1",0};
hooInstruction_ movb_instr4 = {"movb",TERM,MRw,0,0,"@2 = @1",0};
hooInstruction_ movb_instr5 = {"movb",TERM,OA,0,0,"@2 = @1",0};
hooInstruction_ movb_instr6 = {"movb",TERM,RMw,0,0,"@2 = @1",0};

hooInstruction_ movd_instr = {"movd",TERM,SSE2,0,0,"",0};
hooInstruction_ movh_instr = {"movh",TERM,SSE2tm,0,0,"",0};
hooInstruction_ movl_instr = {"movl",TERM,SSE2tm,0,0,"@2 = @1",0};
hooInstruction_ movn_instr = {"movn",TERM,SSE2tm,0,0,"",0};
hooInstruction_ movnt_instr = {"movnt",TERM,SSE2tm,0,0,"",0};
hooInstruction_ movnti_instr = {"movnti",TERM,RMw,0,0,"",0};
hooInstruction_ movs_instr = {"movs",TERM,SD,1,0,"",0};

hooInstruction_ movsb_instr1 = {"movsb",TERM,MOVZ,1,0,"@2 = @1",0};
hooInstruction_ movsb_instr2 = {"movsb",TERM,SD,0,0,"",0};

hooInstruction_ movswl_instr = {"movswl",TERM,MOVZ,0,0,"@2 = @1",0};
hooInstruction_ movzb_instr = {"movzb",TERM,MOVZ,1,0,"@2 = @1",0};
hooInstruction_ movzwl_instr = {"movzwl",TERM,MOVZ,0,0,"@2 = @1",0};
hooInstruction_ mpsadbw_instr = {"mpsadbw",TERM,SSE4i,0,0,"",0};

hooInstruction_ mul_instr1 = {"mul",TERM,MA,1,0,"",0};
hooInstruction_ mul_instr2 = {"mul",TERM,SSE2,0,0,"",0};

hooInstruction_ mulb_instr = {"mulb",TERM,MA,0,0,"",0};
hooInstruction_ neg_instr = {"neg",TERM,Mw,1,0,"",0};
hooInstruction_ negb_instr = {"negb",TERM,Mw,0,0,"",0};

hooInstruction_ nop_instr1 = {"nop",TERM,GO_ON,0,0,"",0};
hooInstruction_ nop_instr2 = {"nop",TERM,M,1,0,"",0};

hooInstruction_ not_instr = {"not",TERM,Mw,1,0,"",0};
hooInstruction_ notb_instr = {"notb",TERM,Mw,0,0,"",0};

hooInstruction_ or_instr1 = {"or",TERM,IA,1,0,"@2 = @2 OR @1",0};
hooInstruction_ or_instr2 = {"or",TERM,IMlw,1,0,"@2 = @2 OR @1",0};
hooInstruction_ or_instr3 = {"or",TERM,IMw,1,0,"@2 = @2 OR @1",0};
hooInstruction_ or_instr4 = {"or",TERM,MRw,1,0,"@2 = @2 OR @1",0};
hooInstruction_ or_instr5 = {"or",TERM,RMw,1,0,"@2 = @2 OR @1",0};
hooInstruction_ or_instr6 = {"or",TERM,SSE2,0,0,"@2 = @2 OR @1",0};

hooInstruction_ orb_instr1 = {"orb",TERM,IA,0,0,"@2 = @2 OR @1",0};
hooInstruction_ orb_instr2 = {"orb",TERM,IMw,0,0,"@2 = @2 OR @1",0};
hooInstruction_ orb_instr3 = {"orb",TERM,MRw,0,0,"@2 = @2 OR @1",0};
hooInstruction_ orb_instr4 = {"orb",TERM,RMw,0,0,"@2 = @2 OR @1",0};

hooInstruction_ out_instr1 = {"out",TERM,Po,1,0,"",0};
hooInstruction_ out_instr2 = {"out",TERM,Vo,1,0,"",0};

hooInstruction_ outb_instr1 = {"outb",TERM,Po,0,0,"",0};
hooInstruction_ outb_instr2 = {"outb",TERM,Vo,0,0,"",0};

hooInstruction_ outs_instr = {"outs",TERM,GO_ON,1,0,"",0};
hooInstruction_ outsb_instr = {"outsb",TERM,GO_ON,0,0,"",0};
hooInstruction_ packssdw_instr = {"packssdw",TERM,SSE2,0,0,"",0};
hooInstruction_ packsswb_instr = {"packsswb",TERM,SSE2,0,0,"",0};
hooInstruction_ packuswb_instr = {"packuswb",TERM,SSE2,0,0,"",0};
hooInstruction_ paddb_instr = {"paddb",TERM,SSE2,0,0,"",0};
hooInstruction_ paddd_instr = {"paddd",TERM,SSE2,0,0,"",0};
hooInstruction_ paddq_instr = {"paddq",TERM,SSE2,0,0,"",0};
hooInstruction_ paddsb_instr = {"paddsb",TERM,SSE2,0,0,"",0};
hooInstruction_ paddsw_instr = {"paddsw",TERM,SSE2,0,0,"",0};
hooInstruction_ paddusb_instr = {"paddusb",TERM,SSE2,0,0,"",0};
hooInstruction_ paddusw_instr = {"paddusw",TERM,SSE2,0,0,"",0};
hooInstruction_ paddw_instr = {"paddw",TERM,SSE2,0,0,"",0};
hooInstruction_ palignr_instr = {"palignr",TERM,MNIi,0,0,"",0};
hooInstruction_ pand_instr = {"pand",TERM,SSE2,0,0,"",0};
hooInstruction_ pandn_instr = {"pandn",TERM,SSE2,0,0,"",0};
hooInstruction_ pavgb_instr = {"pavgb",TERM,SSE2,0,0,"",0};
hooInstruction_ pavgusb_instr = {"pavgusb",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pavgw_instr = {"pavgw",TERM,SSE2,0,0,"",0};
hooInstruction_ pblendw_instr = {"pblendw",TERM,SSE4i,0,0,"",0};
hooInstruction_ pcmpeqb_instr = {"pcmpeqb",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpeqd_instr = {"pcmpeqd",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpeqw_instr = {"pcmpeqw",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpestri_instr = {"pcmpestri",TERM,SSE4i,0,0,"",0};
hooInstruction_ pcmpestrm_instr = {"pcmpestrm",TERM,SSE4i,0,0,"",0};
hooInstruction_ pcmpgtb_instr = {"pcmpgtb",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpgtd_instr = {"pcmpgtd",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpgtw_instr = {"pcmpgtw",TERM,SSE2,0,0,"",0};
hooInstruction_ pcmpistri_instr = {"pcmpistri",TERM,SSE4i,0,0,"",0};
hooInstruction_ pcmpistrm_instr = {"pcmpistrm",TERM,SSE4i,0,0,"",0};
hooInstruction_ pextr_instr = {"pextr",TERM,SSE4itm,0,0,"",0};
hooInstruction_ pextrb_instr = {"pextrb",TERM,SSE4itm,0,0,"",0};

hooInstruction_ pextrw_instr1 = {"pextrw",TERM,SSE2i,0,0,"",0};
hooInstruction_ pextrw_instr2 = {"pextrw",TERM,SSE4itm,0,0,"",0};

hooInstruction_ pf2id_instr = {"pf2id",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pf2iw_instr = {"pf2iw",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfacc_instr = {"pfacc",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfadd_instr = {"pfadd",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfcmpge_instr = {"pfcmpge",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfmax_instr = {"pfmax",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfmin_instr = {"pfmin",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfmul_instr = {"pfmul",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfnacc_instr = {"pfnacc",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfpnacc_instr = {"pfpnacc",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfrcp_instr = {"pfrcp",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfrcpit1_instr = {"pfrcpit1",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfrcpit2_instr = {"pfrcpit2",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfrsqit1_instr = {"pfrsqit1",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfrsqrt_instr = {"pfrsqrt",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfsub_instr = {"pfsub",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pfsubr_instr = {"pfsubr",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pi2fd_instr = {"pi2fd",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pi2fw_instr = {"pi2fw",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pinsr_instr = {"pinsr",TERM,SSE4ifm,0,0,"",0};
hooInstruction_ pinsrb_instr = {"pinsrb",TERM,SSE4ifm,0,0,"",0};
hooInstruction_ pinsrw_instr = {"pinsrw",TERM,SSE2i,0,0,"",0};
hooInstruction_ pmaddwd_instr = {"pmaddwd",TERM,SSE2,0,0,"",0};
hooInstruction_ pmaxsw_instr = {"pmaxsw",TERM,SSE2,0,0,"",0};
hooInstruction_ pmaxub_instr = {"pmaxub",TERM,SSE2,0,0,"",0};
hooInstruction_ pminsw_instr = {"pminsw",TERM,SSE2,0,0,"",0};
hooInstruction_ pminub_instr = {"pminub",TERM,SSE2,0,0,"",0};
hooInstruction_ pmovmskb_instr = {"pmovmskb",TERM,SSE2,0,0,"",0};
hooInstruction_ pmulhrw_instr = {"pmulhrw",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ pmulhuw_instr = {"pmulhuw",TERM,SSE2,0,0,"",0};
hooInstruction_ pmulhw_instr = {"pmulhw",TERM,SSE2,0,0,"",0};
hooInstruction_ pmullw_instr = {"pmullw",TERM,SSE2,0,0,"",0};
hooInstruction_ pmuludq_instr = {"pmuludq",TERM,SSE2,0,0,"",0};
hooInstruction_ pop_instr = {"pop",TERM,LSEG,0x03,0,"stackPop( @1 )",0};

hooInstruction_ pop_instr1 = {"pop",TERM,M,0x03,0,"stackPop( @1 )",0};
hooInstruction_ pop_instr2 = {"pop",TERM,R,0x03,0,"stackPop( @1 )",0};
hooInstruction_ pop_instr3 = {"pop",TERM,SEG,0x03,INVALID_64,"stackPop( @1 )",0};

hooInstruction_ popa_instr = {"popa",TERM,GO_ON,1,INVALID_64,"",0};
hooInstruction_ popcnt_instr = {"popcnt",TERM,SSE4MRw,0,0,"",0};
hooInstruction_ popf_instr = {"popf",TERM,GO_ON,1,0,"",0};
hooInstruction_ por_instr = {"por",TERM,SSE2,0,0,"",0};

hooInstruction_ prefetch_instr1 = {"prefetch",TERM,PFCH,1,0,"",0};
hooInstruction_ prefetch_instr2 = {"prefetch",TERM,PFCH3DNOW,1,0,"",0};

hooInstruction_ ps_instr = {"ps",TERM,SSE2i1,0,0,"",0};
hooInstruction_ psadbw_instr = {"psadbw",TERM,SSE2,0,0,"",0};
hooInstruction_ pshu_instr = {"pshu",TERM,SSE2i,0,0,"",0};
hooInstruction_ pslld_instr = {"pslld",TERM,SSE2,0,0,"",0};
hooInstruction_ psllq_instr = {"psllq",TERM,SSE2,0,0,"",0};
hooInstruction_ psllw_instr = {"psllw",TERM,SSE2,0,0,"",0};
hooInstruction_ psrad_instr = {"psrad",TERM,SSE2,0,0,"",0};
hooInstruction_ psraw_instr = {"psraw",TERM,SSE2,0,0,"",0};
hooInstruction_ psrld_instr = {"psrld",TERM,SSE2,0,0,"",0};
hooInstruction_ psrlq_instr = {"psrlq",TERM,SSE2,0,0,"",0};
hooInstruction_ psrlw_instr = {"psrlw",TERM,SSE2,0,0,"",0};
hooInstruction_ psubb_instr = {"psubb",TERM,SSE2,0,0,"",0};
hooInstruction_ psubd_instr = {"psubd",TERM,SSE2,0,0,"",0};
hooInstruction_ psubq_instr = {"psubq",TERM,SSE2,0,0,"",0};
hooInstruction_ psubsb_instr = {"psubsb",TERM,SSE2,0,0,"",0};
hooInstruction_ psubsw_instr = {"psubsw",TERM,SSE2,0,0,"",0};
hooInstruction_ psubusb_instr = {"psubusb",TERM,SSE2,0,0,"",0};
hooInstruction_ psubusw_instr = {"psubusw",TERM,SSE2,0,0,"",0};
hooInstruction_ psubw_instr = {"psubw",TERM,SSE2,0,0,"",0};
hooInstruction_ pswapd_instr = {"pswapd",TERM,AMD3DNOW,0,0,"",0};
hooInstruction_ punpckh_instr = {"punpckh",TERM,SSE2,0,0,"",0};
hooInstruction_ punpckhbw_instr = {"punpckhbw",TERM,SSE2,0,0,"",0};
hooInstruction_ punpckhdq_instr = {"punpckhdq",TERM,SSE2,0,0,"",0};
hooInstruction_ punpckhwd_instr = {"punpckhwd",TERM,SSE2,0,0,"",0};
hooInstruction_ punpckl_instr = {"punpckl",TERM,SSE2,0,0,"",0};
hooInstruction_ punpcklbw_instr = {"punpcklbw",TERM,SSE2,0,0,"",0};
hooInstruction_ punpckldq_instr = {"punpckldq",TERM,SSE2,0,0,"",0};
hooInstruction_ punpcklwd_instr = {"punpcklwd",TERM,SSE2,0,0,"",0};

hooInstruction_ push_instr1 = {"push",TERM,I,0x03,0,"stackPush( @1 )",0};
hooInstruction_ push_instr2 = {"push",TERM,Ib,0x03,0,"stackPush( @1 )",0};
hooInstruction_ push_instr3 = {"push",TERM,LSEG,0x03,0,"stackPush( @1 )",0};
hooInstruction_ push_instr4 = {"push",TERM,M,0x030,0,"stackPush( @1 )",0};
hooInstruction_ push_instr5 = {"push",TERM,R,0x03,0,"stackPush( @1 )",0};
hooInstruction_ push_instr6 = {"push",TERM,SEG,0x03,INVALID_64,"stackPush( @1 )",0};

hooInstruction_ pusha_instr = {"pusha",TERM,GO_ON,1,INVALID_64,"",0};
hooInstruction_ pushf_instr = {"pushf",TERM,GO_ON,1,0,"",0};
hooInstruction_ pxor_instr = {"pxor",TERM,SSE2,0,0,"",0};

hooInstruction_ rcl_instr1 = {"rcl",TERM,Mv,1,0,"",0};
hooInstruction_ rcl_instr2 = {"rcl",TERM,MvI,1,0,"",0};

hooInstruction_ rclb_instr1 = {"rclb",TERM,Mv,0,0,"",0};
hooInstruction_ rclb_instr2 = {"rclb",TERM,MvI,0,0,"",0};

hooInstruction_ rcp_instr = {"rcp",TERM,SSE2,0,0,"",0};

hooInstruction_ rcr_instr1 = {"rcr",TERM,Mv,1,0,"",0};
hooInstruction_ rcr_instr2 = {"rcr",TERM,MvI,1,0,"",0};

hooInstruction_ rcrb_instr1 = {"rcrb",TERM,Mv,0,0,"",0};
hooInstruction_ rcrb_instr2 = {"rcrb",TERM,MvI,0,0,"",0};

hooInstruction_ rdmsr_instr = {"rdmsr",TERM,GO_ON,0,0,"",0};
hooInstruction_ rdpmc_instr = {"rdpmc",TERM,GO_ON,0,0,"",0};
hooInstruction_ rdtsc_instr = {"rdtsc",TERM,GO_ON,0,0,"",0};
hooInstruction_ repnz_prefix = {"repnz/",TERM,PREFIX,0,0,"",0};
hooInstruction_ repz_prefix = {"repz/",TERM,PREFIX,0,0,"",0};

hooInstruction_ ret_instr1 = {"ret",TERM,GO_ON,0,0,"",0};
hooInstruction_ ret_instr2 = {"ret",TERM,RET,0,0,"",0};

hooInstruction_ rol_instr1 = {"rol",TERM,Mv,1,0,"",0};
hooInstruction_ rol_instr2 = {"rol",TERM,MvI,1,0,"",0};

hooInstruction_ rolb_instr1 = {"rolb",TERM,Mv,0,0,"",0};
hooInstruction_ rolb_instr2 = {"rolb",TERM,MvI,0,0,"",0};

hooInstruction_ ror_instr1 = {"ror",TERM,Mv,1,0,"",0};
hooInstruction_ ror_instr2 = {"ror",TERM,MvI,1,0,"",0};

hooInstruction_ rorb_instr1 = {"rorb",TERM,Mv,0,0,"",0};
hooInstruction_ rorb_instr2 = {"rorb",TERM,MvI,0,0,"",0};

hooInstruction_ roundpd_instr = {"roundpd",TERM,SSE4i,0,0,"",0};
hooInstruction_ roundps_instr = {"roundps",TERM,SSE4i,0,0,"",0};
hooInstruction_ roundsd_instr = {"roundsd",TERM,SSE4i,0,0,"",0};
hooInstruction_ roundss_instr = {"roundss",TERM,SSE4i,0,0,"",0};
hooInstruction_ rsm_instr = {"rsm",TERM,GO_ON,0,INVALID_64,"",0};
hooInstruction_ rsqrt_instr = {"rsqrt",TERM,SSE2,0,0,"",0};
hooInstruction_ sahf_instr = {"sahf",TERM,GO_ON,0,0,"",0};

hooInstruction_ sar_instr1 = {"sar",TERM,Mv,1,0,"",0};
hooInstruction_ sar_instr2 = {"sar",TERM,MvI,1,0,"",0};

hooInstruction_ sarb_instr1 = {"sarb",TERM,Mv,0,0,"",0};
hooInstruction_ sarb_instr2 = {"sarb",TERM,MvI,0,0,"",0};

hooInstruction_ sbb_instr1 = {"sbb",TERM,IA,1,0,"",0};
hooInstruction_ sbb_instr2 = {"sbb",TERM,IMlw,1,0,"",0};
hooInstruction_ sbb_instr3 = {"sbb",TERM,MRw,1,0,"",0};
hooInstruction_ sbb_instr4 = {"sbb",TERM,RMw,1,0,"",0};

hooInstruction_ sbbb_instr1 = {"sbbb",TERM,IA,0,0,"",0};
hooInstruction_ sbbb_instr2 = {"sbbb",TERM,IMlw,0,0,"",0};
hooInstruction_ sbbb_instr3 = {"sbbb",TERM,MRw,0,0,"",0};
hooInstruction_ sbbb_instr4 = {"sbbb",TERM,RMw,0,0,"",0};

hooInstruction_ scas_instr = {"scas",TERM,AD,1,0,"",0};
hooInstruction_ scasb_instr = {"scasb",TERM,AD,0,0,"",0};
hooInstruction_ seta_instr = {"seta",TERM,Mb,0,0,"",0};
hooInstruction_ setae_instr = {"setae",TERM,Mb,0,0,"",0};
hooInstruction_ setb_instr = {"setb",TERM,Mb,0,0,"",0};
hooInstruction_ setbe_instr = {"setbe",TERM,Mb,0,0,"",0};
hooInstruction_ sete_instr = {"sete",TERM,Mb,0,0,"",0};
hooInstruction_ setg_instr = {"setg",TERM,Mb,0,0,"",0};
hooInstruction_ setge_instr = {"setge",TERM,Mb,0,0,"",0};
hooInstruction_ setl_instr = {"setl",TERM,Mb,0,0,"",0};
hooInstruction_ setle_instr = {"setle",TERM,Mb,0,0,"",0};
hooInstruction_ setne_instr = {"setne",TERM,Mb,0,0,"",0};
hooInstruction_ setno_instr = {"setno",TERM,Mb,0,0,"",0};
hooInstruction_ setnp_instr = {"setnp",TERM,Mb,0,0,"",0};
hooInstruction_ setns_instr = {"setns",TERM,Mb,0,0,"",0};
hooInstruction_ seto_instr = {"seto",TERM,Mb,0,0,"",0};
hooInstruction_ setp_instr = {"setp",TERM,Mb,0,0,"",0};
hooInstruction_ sets_instr = {"sets",TERM,Mb,0,0,"",0};

hooInstruction_ shl_instr1 = {"shl",TERM,Mv,1,0,"",0};
hooInstruction_ shl_instr2 = {"shl",TERM,MvI,1,0,"",0};

hooInstruction_ shlb_instr1 = {"shlb",TERM,Mv,0,0,"",0};
hooInstruction_ shlb_instr2 = {"shlb",TERM,MvI,0,0,"",0};
hooInstruction_ shld_instr3 = {"shld",TERM,DSHIFT,1,0,"",0};
hooInstruction_ shld_instr4 = {"shld",TERM,DSHIFTcl,1,0,"",0};

hooInstruction_ shr_instr1 = {"shr",TERM,Mv,1,0,"",0};
hooInstruction_ shr_instr2 = {"shr",TERM,MvI,1,0,"",0};

hooInstruction_ shrb_instr1 = {"shrb",TERM,Mv,0,0,"",0};
hooInstruction_ shrb_instr2 = {"shrb",TERM,MvI,0,0,"",0};

hooInstruction_ shrd_instr1 = {"shrd",TERM,DSHIFT,1,0,"",0};
hooInstruction_ shrd_instr2 = {"shrd",TERM,DSHIFTcl,1,0,"",0};

hooInstruction_ shuf_instr = {"shuf",TERM,SSE2i,0,0,"",0};
hooInstruction_ sqrt_instr = {"sqrt",TERM,SSE2,0,0,"",0};
hooInstruction_ stc_instr = {"stc",TERM,GO_ON,0,0,"",0};
hooInstruction_ std_instr = {"std",TERM,GO_ON,0,0,"",0};
hooInstruction_ sti_instr = {"sti",TERM,GO_ON,0,0,"",0};
hooInstruction_ stmxcsr_instr = {"stmxcsr",TERM,M,1,0,"",0};
hooInstruction_ stos_instr = {"stos",TERM,AD,1,0,"",0};
hooInstruction_ stosb_instr = {"stosb",TERM,AD,0,0,"",0};

hooInstruction_ sub_instr1 = {"sub",TERM,IA,1,0,"@2 = @2 - @1",0};
hooInstruction_ sub_instr2 = {"sub",TERM,IMlw,1,0,"@2 = @2 - @1",0};
hooInstruction_ sub_instr3 = {"sub",TERM,MRw,1,0,"@2 = @2 - @1",0};
hooInstruction_ sub_instr4 = {"sub",TERM,RMw,1,0,"@2 = @2 - @1",0};
hooInstruction_ sub_instr5 = {"sub",TERM,SSE2,0,0,"@2 = @2 - @1",0};

hooInstruction_ subb_instr1 = {"subb",TERM,IA,0,0,"",0};
hooInstruction_ subb_instr2 = {"subb",TERM,IMlw,0,0,"",0};
hooInstruction_ subb_instr3 = {"subb",TERM,MRw,0,0,"",0};
hooInstruction_ subb_instr4 = {"subb",TERM,RMw,0,0,"",0};

hooInstruction_ sysenter_instr = {"sysenter",TERM,GO_ON,0,0,"",0};
hooInstruction_ sysexit_instr = {"sysexit",TERM,GO_ON,0,0,"",0};

hooInstruction_ test_instr1 = {"test",TERM,IA,1,0,"test( @1, @2 )",0};
hooInstruction_ test_instr2 = {"test",TERM,IMw,1,0,"test( @1, @2 )",0};
hooInstruction_ test_instr3 = {"test",TERM,MRw,1,0,"test( @1, @2 )",0};

hooInstruction_ testb_instr1 = {"testb",TERM,IA,0,0,"test( @1, @2 )",0};
hooInstruction_ testb_instr2 = {"testb",TERM,IMw,0,0,"test( @1, @2 )",0};
hooInstruction_ testb_instr3 = {"testb",TERM,MRw,0,0,"test( @1, @2 )",0};

hooInstruction_ ucomi_instr = {"ucomi",TERM,SSE2,0,0,"",0};
hooInstruction_ ud2_instr = {"ud2",TERM,GO_ON,0,0,"",0};
hooInstruction_ unpckh_instr = {"unpckh",TERM,SSE2,0,0,"",0};
hooInstruction_ unpckl_instr = {"unpckl",TERM,SSE2,0,0,"",0};
hooInstruction_ vmread_instr = {"vmread",TERM,RMw,0,0,"",0};
hooInstruction_ vmwrite_instr = {"vmwrite",TERM,MRw,0,0,"",0};
hooInstruction_ wait_prefix = {"wait/",TERM,PREFIX,0,0,"",0};
hooInstruction_ wbinvd_instr = {"wbinvd",TERM,GO_ON,0,0,"",0};
hooInstruction_ wrmsr_instr = {"wrmsr",TERM,GO_ON,0,0,"",0};
hooInstruction_ xadd_instr = {"xadd",TERM,XINST,1,0,"",0};
hooInstruction_ xaddb_instr = {"xaddb",TERM,XINST,0,0,"",0};

hooInstruction_ xchg_instr1 = {"xchg",TERM,MRw,1,0,"",0};
hooInstruction_ xchg_instr2 = {"xchg",TERM,RA,1,0,"",0};

hooInstruction_ xchgb_instr = {"xchgb",TERM,MRw,0,0,"",0};
hooInstruction_ xlat_instr = {"xlat",TERM,GO_ON,0,0,"",0};

hooInstruction_ xor_instr1 = {"xor",TERM,IA,1,0,"@2 = @2 XOR @1",0};
hooInstruction_ xor_instr2 = {"xor",TERM,IMlw,1,0,"@2 = @2 XOR @1",0};
hooInstruction_ xor_instr3 = {"xor",TERM,IMw,1,0,"@2 = @2 XOR @1",0};
hooInstruction_ xor_instr4 = {"xor",TERM,MRw,1,0,"@2 = @2 XOR @1",0};
hooInstruction_ xor_instr5 = {"xor",TERM,RMw,1,0,"@2 = @2 XOR @1",0};
hooInstruction_ xor_instr6 = {"xor",TERM,SSE2,0,0,"@2 = @2 XOR @1",0};

hooInstruction_ xorb_instr1 = {"xorb",TERM,IA,0,0,"@2 = @2 XOR @1",0};
hooInstruction_ xorb_instr2 = {"xorb",TERM,IMw,0,0,"@2 = @2 XOR @1",0};
hooInstruction_ xorb_instr3 = {"xorb",TERM,MRw,0,0,"@2 = @2 XOR @1",0};
hooInstruction_ xorb_instr4 = {"xorb",TERM,RMw,0,0,"@2 = @2 XOR @1",0};

hooInstruction_ cmovo_instr = {"cmovo",TERM,MRw,1,0,"",0};
hooInstruction_ movmsk_instr = {"movmsk",TERM,SSE2,0,0,"",0};
hooInstruction_ pfcmpgt_instr = {"pfcmpgt",TERM,AMD3DNOW,0,0,"",0};

hooInstruction_ pshufb_instr = {"pshufb",TERM,MNI,0,0,"",0};
hooInstruction_ phaddw_instr = {"phaddw",TERM,MNI,0,0,"",0};
hooInstruction_ phaddd_instr = {"phaddd",TERM,MNI,0,0,"",0};
hooInstruction_ phaddsw_instr = {"phaddsw",TERM,MNI,0,0,"",0};
hooInstruction_ pmaddubsw_instr = {"pmaddubsw",TERM,MNI,0,0,"",0};
hooInstruction_ phsubw_instr = {"phsubw",TERM,MNI,0,0,"",0};
hooInstruction_ phsubd_instr = {"phsubd",TERM,MNI,0,0,"",0};
hooInstruction_ phsubsw_instr = {"phsubsw",TERM,MNI,0,0,"",0};
hooInstruction_ psignb_instr = {"psignb",TERM,MNI,0,0,"",0};
hooInstruction_ psignw_instr = {"psignw",TERM,MNI,0,0,"",0};
hooInstruction_ psignd_instr = {"psignd",TERM,MNI,0,0,"",0};
hooInstruction_ pmulhrsw_instr = {"pmulhrsw",TERM,MNI,0,0,"",0};
hooInstruction_ pblendvb_instr = {"pblendvb",TERM,SSE4,0,0,"",0};
hooInstruction_ blendvps_instr = {"blendvps",TERM,SSE4,0,0,"",0};
hooInstruction_ blendvpd_instr = {"blendvpd",TERM,SSE4,0,0,"",0};
hooInstruction_ ptest_instr = {"ptest",TERM,SSE4,0,0,"",0};
hooInstruction_ pabsb_instr = {"pabsb",TERM,MNI,0,0,"",0};
hooInstruction_ pabsw_instr = {"pabsw",TERM,MNI,0,0,"",0};
hooInstruction_ pabsd_instr = {"pabsd",TERM,MNI,0,0,"",0};

hooInstruction_ pmovsxbw_instr = {"pmovsxbw",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovsxbd_instr = {"pmovsxbd",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovsxbq_instr = {"pmovsxbq",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovsxwd_instr = {"pmovsxwd",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovsxwq_instr = {"pmovsxwq",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovsxdq_instr = {"pmovsxdq",TERM,SSE4,0,0,"",0};
hooInstruction_ pmuldq_instr = {"pmuldq",TERM,SSE4,0,0,"",0};
hooInstruction_ pcmpeqq_instr = {"pcmpeqq",TERM,SSE4,0,0,"",0};
hooInstruction_ movntdqa_instr = {"movntdqa",TERM,SSE4,0,0,"",0};
hooInstruction_ packusdw_instr = {"packusdw",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxbw_instr = {"pmovzxbw",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxbd_instr = {"pmovzxbd",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxbq_instr = {"pmovzxbq",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxwd_instr = {"pmovzxwd",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxwq_instr = {"pmovzxwq",TERM,SSE4,0,0,"",0};
hooInstruction_ pmovzxdq_instr = {"pmovzxdq",TERM,SSE4,0,0,"",0};
hooInstruction_ pcmpgtq_instr = {"pcmpgtq",TERM,SSE4,0,0,"",0};
hooInstruction_ pminsb_instr = {"pminsb",TERM,SSE4,0,0,"",0};
hooInstruction_ pminsd_instr = {"pminsd",TERM,SSE4,0,0,"",0};
hooInstruction_ pminuw_instr = {"pminuw",TERM,SSE4,0,0,"",0};
hooInstruction_ pminud_instr = {"pminud",TERM,SSE4,0,0,"",0};
hooInstruction_ pmaxsb_instr = {"pmaxsb",TERM,SSE4,0,0,"",0};
hooInstruction_ pmaxsd_instr = {"pmaxsd",TERM,SSE4,0,0,"",0};
hooInstruction_ pmaxuw_instr = {"pmaxuw",TERM,SSE4,0,0,"",0};
hooInstruction_ pmaxud_instr = {"pmaxud",TERM,SSE4,0,0,"",0};
hooInstruction_ pmulld_instr = {"pmulld",TERM,SSE4,0,0,"",0};
hooInstruction_ phminposuw_instr = {"phminposuw",TERM,SSE4,0,0,"",0};
hooInstruction_ crc32b_instr = {"crc32b",TERM,SSE4CRCb,0,0,"",0};
hooInstruction_ crc32_instr = {"crc32",TERM,SSE4CRC,1,0,"",0};


/* Decode table for 0x0F00 opcodes */
hooInstruction_		*op0F00[8] = { &sldt_instr, &str_instr, &lldt_instr, &ltr_instr, &verr_instr, &verw_instr, &invalid_instr, &invalid_instr };

/* Decode table for 0x0F01 opcodes */
hooInstruction_		*op0F01[8] = { &sgdt_instr, &sidt_instr, &lgdt_instr, &lidt_instr, &smsw_instr, &invalid_instr, &lmsw_instr, &invlpg_instr };

/*
 * Decode table for 0x0F3A opcodes
 */
hooInstruction_ *op0F3A[112] = {
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&roundps_instr,
&roundpd_instr,
&roundss_instr,
&roundsd_instr,
&blendps_instr,
&blendpd_instr,
&pblendw_instr,
&palignr_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&pextrb_instr,
&pextrw_instr2,
&pextr_instr,
&extractps_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&pinsrb_instr, &insertps_instr, &pinsr_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&dpps_instr, &dppd_instr, &mpsadbw_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&pcmpestrm_instr, &pcmpestri_instr, &pcmpistrm_instr, &pcmpistri_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
};


/*
 * Decode table for 0x0FAE opcodes
 */
hooInstruction_ *op0FAE[8] = { &fxsave_instr, &fxrstor_instr, &ldmxcsr_instr, &stmxcsr_instr, &invalid_instr, &lfence_instr, &mfence_instr, &clflush_instr };

/*
 * Decode table for 0x0FBA opcodes
 */
hooInstruction_ *op0FBA[8] = { &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &bt_instr1, &bts_instr1, &btr_instr1, &btc_instr1 };

/*
 * Decode table for 0x80 opcodes
 */
hooInstruction_ *op80[8] = { &addb_instr2, &orb_instr2, &adcb_instr2, &sbbb_instr2, &andb_instr2, &subb_instr2, &xorb_instr2, &cmpb_instr2 };

/*
 * Decode table for 0x81 opcodes.
 */
hooInstruction_ *op81[8] = { &add_instr2, &or_instr3, &adc_instr2, &sbb_instr2, &and_instr3, &sub_instr2, &xor_instr3, &cmp_instr2 };

/*
 * Decode table for 0x82 opcodes.
 */
hooInstruction_ *op82[8] = { &addb_instr2, &invalid_instr, &adcb_instr2, &sbbb_instr2, &invalid_instr, &subb_instr2, &invalid_instr, &cmpb_instr3 };

/*
 * Decode table for 0x83 opcodes.
 */
hooInstruction_ *op83[8] = { &add_instr2, &or_instr2, &adc_instr2, &sbb_instr2, &and_instr2, &sub_instr2, &xor_instr2, &cmp_instr2 };

/*
 * Decode table for 0xC0 opcodes.
 */
hooInstruction_ *opC0[8] = { &rolb_instr2, &rorb_instr2, &rclb_instr2, &rcrb_instr2, &shlb_instr2, &shrb_instr2, &invalid_instr, &sarb_instr2 };

/*
 * Decode table for 0xD0 opcodes.
 */
hooInstruction_ *opD0[8] = { &rolb_instr1, &rorb_instr1, &rclb_instr1, &rcrb_instr1, &shlb_instr1, &shrb_instr1, &invalid_instr, &sarb_instr1 };

/*
 * Decode table for 0xC1 opcodes.
 * 186 instruction set
 */
hooInstruction_ *opC1[8] = { &rol_instr2, &ror_instr2, &rcl_instr2, &rcr_instr2, &shl_instr2, &shr_instr2, &invalid_instr, &sar_instr2 };

/*
 * Decode table for 0xD1 opcodes.
 */
hooInstruction_ *opD1[8] = { &rol_instr1, &ror_instr1, &rcl_instr1, &rcr_instr1, &shl_instr1, &shr_instr1, &invalid_instr, &sar_instr1 };

/*
 * Decode table for 0xD2 opcodes.
 */
hooInstruction_ *opD2[8] = { &rolb_instr1, &rorb_instr1, &rclb_instr1, &rcrb_instr1, &shlb_instr1, &shrb_instr1, &invalid_instr, &sarb_instr1 };

/*
 * Decode table for 0xD3 opcodes.
 */
hooInstruction_ *opD3[8] = { &rol_instr1, &ror_instr1, &rcl_instr1, &rcr_instr1, &shl_instr1, &shr_instr1, &invalid_instr, &sar_instr1 };

/*
 * Decode table for 0xF6 opcodes.
 */
hooInstruction_ *opF6[8] = { &testb_instr2, &invalid_instr, &notb_instr, &negb_instr, &mulb_instr, &imulb_instr, &divb_instr, &idivb_instr };

/*
 * Decode table for 0xF7 opcodes.
 */
hooInstruction_ *opF7[8] = { &test_instr2, &invalid_instr, &not_instr, &neg_instr, &mul_instr1, &imul_instr1, &div_instr1, &idiv_instr };

/*
 * Decode table for 0xFE opcodes.
 */
hooInstruction_ *opFE[8] = { &incb_instr, &decb_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr };

/*
 * Decode table for 0xFF opcodes.
 */
hooInstruction_ *opFF[8] = { &inc_instr1, &dec_instr1, &call_instr2, &lcall_instr1, &jmp_instr3, &ljmp_instr1, &push_instr4, &invalid_instr };


hooInstruction_ op80_instr = {"",(void *)op80,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op81_instr = {"",(void *)op81,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op82_instr = {"",(void *)op82,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op83_instr = {"",(void *)op83,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opC0_instr = {"",(void *)opC0,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opC1_instr = {"",(void *)opC1,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opD0_instr = {"",(void *)opD0,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opD1_instr = {"",(void *)opD1,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opD2_instr = {"",(void *)opD2,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opD3_instr = {"",(void *)opD3,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opF6_instr = {"",(void *)opF6,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opF7_instr = {"",(void *)opF7,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opFE_instr = {"",(void *)opFE,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ opFF_instr = {"",(void *)opFF,TERM,0,0,"crazy indirect shit",0};

/*
 * Decode table for 0x0F0F opcodes
 * Unlike the other decode tables, this one maps suffixes.
 */
hooInstruction_ *op0F0F[16][16] = {
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pi2fw_instr, &pi2fd_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pf2iw_instr, &pf2id_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfnacc_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfpnacc_instr, &invalid_instr },
{ &pfcmpge_instr, &invalid_instr, &invalid_instr, &invalid_instr,  &pfmin_instr, &invalid_instr, &pfrcp_instr, &pfrsqrt_instr, &invalid_instr, &invalid_instr, &pfsub_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfadd_instr, &invalid_instr },
{ &pfcmpgt_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfmax_instr, &invalid_instr, &pfrcpit1_instr, &pfrsqit1_instr, &invalid_instr, &invalid_instr, &pfsubr_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfacc_instr, &invalid_instr },
{ &pfcmpeq_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pfmul_instr, &invalid_instr, &pfrcpit2_instr, &pmulhrw_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pswapd_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pavgusb_instr  },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, INVALID, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, INVALID, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
};

/*
 * Decode table for 0x0F38 opcodes
 */
hooInstruction_		*op0F38[256] = {
&pshufb_instr, &phaddw_instr, &phaddd_instr, &phaddsw_instr, &pmaddubsw_instr, &phsubw_instr, &phsubd_instr,
&phsubsw_instr, &psignb_instr, &psignw_instr, &psignd_instr, &pmulhrsw_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&pblendvb_instr, &invalid_instr, &invalid_instr, &invalid_instr, &blendvps_instr, &blendvpd_instr, &invalid_instr, &ptest_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &pabsb_instr, &pabsw_instr, &pabsd_instr,
&invalid_instr, &pmovsxbw_instr, &pmovsxbd_instr, &pmovsxbq_instr, &pmovsxwd_instr, &pmovsxwq_instr, &pmovsxdq_instr, &invalid_instr, &invalid_instr, &pmuldq_instr, &pcmpeqq_instr,
&movntdqa_instr, &packusdw_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&pmovzxbw_instr, &pmovzxbd_instr, &pmovzxbq_instr, &pmovzxwd_instr, &pmovzxwq_instr, &pmovzxdq_instr, &invalid_instr,
&pcmpgtq_instr, &pminsb_instr, &pminsd_instr, &pminuw_instr, &pminud_instr, &pmaxsb_instr, &pmaxsd_instr, &pmaxuw_instr, &pmaxud_instr, &pmulld_instr, &phminposuw_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
&crc32b_instr, &crc32_instr,
&invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr,
};

hooInstruction_ op0F00_instr = {"",(void *)op0F00,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op0F01_instr = {"",(void *)op0F01,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op0F3A_instr = {"",(void *)op0F3A,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op0F38_instr = {"",(void *)op0F38,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op0FAE_instr = {"",(void *)op0FAE,TERM,0,0,"crazy indirect shit",0};
hooInstruction_ op0FBA_instr = {"",(void *)op0FBA,TERM,0,0,"crazy indirect shit",0};

hooInstruction_ whatKindOfVoodooIsThis1_instr = {INVALID_32, &op_syscall,0,0};
hooInstruction_ whatKindOfVoodooIsThis2_instr = {INVALID_32, &op_sysret,0,0};

hooInstruction_ op0F0F_instr = {"",(void *)op0F0F,TERM,0,0,"crazy indirect shit",0};


/*
 * Decode table for 0x0F opcodes
 */
hooInstruction_ *op0F[16][16] = {
{ &op0F00_instr, &op0F01_instr, &lar_instr, &lsl_instr, &invalid_instr, &whatKindOfVoodooIsThis1_instr, &clts_instr, &whatKindOfVoodooIsThis2_instr, &invd_instr, &wbinvd_instr, &invalid_instr, &ud2_instr, &invalid_instr, &prefetch_instr2, &femms_instr,
&op0F0F_instr },
{ &mov_instr10, &mov_instr12, &mov_instr10, &movl_instr, &unpckl_instr, &unpckh_instr, &mov_instr10, &movh_instr, &prefetch_instr1, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &nop_instr2 },
{ &mov_instr9, &mov_instr9, &mov_instr9, &mov_instr9, &mov_instr9, &invalid_instr, &mov_instr9, &invalid_instr, &mova_instr1, &mova_instr2, &cvt_instr, &movnt_instr, &cvt_instr, &cvt_instr, &ucomi_instr, &comi_instr },
{ &wrmsr_instr, &rdtsc_instr, &rdmsr_instr, &rdpmc_instr, &sysenter_instr, &sysexit_instr, &invalid_instr, &invalid_instr, &op0F38_instr, &invalid_instr, &op0F3A_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &cmovo_instr, &cmovno_instr, &cmovb_instr, &cmovae_instr, &cmove_instr, &cmovne_instr, &cmovbe_instr, &cmova_instr, &cmovs_instr, &cmovns_instr, &cmovp_instr, &cmovnp_instr, &cmovl_instr, &cmovge_instr, &cmovle_instr, &cmovg_instr },
{ &movmsk_instr, &sqrt_instr, &rsqrt_instr, &rcp_instr, &and_instr6, &andn_instr, &or_instr6, &xor_instr6, &add_instr5, &mul_instr2, &cvt_instr, &cvt_instr, &sub_instr5, &min_instr, &div_instr2, &max_instr },
{ &punpcklbw_instr, &punpcklwd_instr, &punpckldq_instr, &packsswb_instr, &pcmpgtb_instr, &pcmpgtw_instr, &pcmpgtd_instr, &packuswb_instr, &punpckhbw_instr, &punpckhwd_instr, &punpckhdq_instr, &packssdw_instr, &punpckl_instr, &punpckh_instr, &movd_instr, &mov_instr10 },
{ &pshu_instr, &ps_instr, &ps_instr, &ps_instr, &pcmpeqb_instr, &pcmpeqw_instr, &pcmpeqd_instr, &emms_instr, &vmread_instr, &vmwrite_instr, &invalid_instr, &invalid_instr, &haddp_instr, &hsubp_instr, &mov_instr11, &mov_instr12 },
{ &jo_instr2, &jno_instr2, &jb_instr2, &jae_instr2, &jae_instr2, &jne_instr2, &jbe_instr1, &ja_instr2, &js_instr2, &jns_instr2, &jp_instr2, &jnp_instr2, &jl_instr2, &jge_instr2, &jle_instr2, &jg_instr2 },
{ &seto_instr, &setno_instr, &setb_instr, &setae_instr, &sete_instr, &setne_instr, &setbe_instr, &seta_instr, &sets_instr, &setns_instr, &setp_instr, &setnp_instr, &setl_instr, &setge_instr, &setle_instr, &setg_instr },
{ &_push_instr, &pop_instr, &cpuid_instr, &bt_instr2, &shld_instr3, &shld_instr4, &invalid_instr, &invalid_instr, &push_instr3, &pop_instr, &rsm_instr, &bts_instr2, &shrd_instr1, &shrd_instr2, &op0FAE_instr, &imul_instr2 },
{ &cmpxchgb_instr, &cmpxchg_instr, &lss_instr, &btr_instr2, &lfs_instr, &lgs_instr, &movzb_instr, &movzwl_instr, &popcnt_instr, &invalid_instr, &op0FBA_instr, &btc_instr2, &bsf_instr, &bsr_instr, &movsb_instr1, &movswl_instr },
{ &xaddb_instr, &xadd_instr, &cmp_instr5, &movnti_instr, &pinsrw_instr, &pextrw_instr1, &shuf_instr, &cmpxchg8b_instr, &bswap_instr, &bswap_instr, &bswap_instr, &bswap_instr, &bswap_instr, &bswap_instr, &bswap_instr, &bswap_instr },
{ &addsubp_instr, &psrlw_instr, &psrld_instr, &psrlq_instr, &paddq_instr, &pmullw_instr, &mov_instr12, &pmovmskb_instr, &psubusb_instr, &psubusw_instr, &pminub_instr, &pand_instr, &paddusb_instr, &paddusw_instr, &pmaxub_instr, &pandn_instr },
{ &pavgb_instr, &psraw_instr, &psrad_instr, &pavgw_instr, &pmulhuw_instr, &pmulhw_instr, &cvt_instr, &movn_instr, &psubsb_instr, &psubsw_instr, &pminsw_instr, &por_instr, &paddsb_instr, &paddsw_instr, &pmaxsw_instr, &pxor_instr },
{ &lddqu_instr, &psllw_instr, &pslld_instr, &psllq_instr, &pmuludq_instr, &pmaddwd_instr, &psadbw_instr, &maskmov_instr, &psubb_instr, &psubw_instr, &psubd_instr, &psubq_instr, &paddb_instr, &paddw_instr, &paddd_instr,	&invalid_instr },
};

/* These reference the table above so have to go here */
hooInstruction_ op0F_instr = {"",(void *)op0F,TERM,0,0,"crazy indirect shit",0};

/* for 287 instructions, which are a mess to decode */
hooInstruction_ *opFP1n2[8][8] = {
	/* bit pattern:	1101 1xxx MODxx xR/M */
{ &fadds_instr, &fmuls_instr, &fcoms_instr, &fcomps_instr, &fsubs_instr, &fsubrs_instr, &fdivs_instr, &fdivrs_instr },
{ &flds_instr, &invalid_instr, &fsts_instr, &fstps_instr, &fldenv_instr, &fldcw_instr, &fnstenv_instr, &fnstcw_instr },
{ &fiaddl_instr, &fimull_instr, &ficoml_instr, &ficompl_instr, &fisubl_instr, &fisubrl_instr, &fidivl_instr, &fidivrl_instr }, { &fildl_instr, &fisttpl_instr, &fistl_instr, &fistpl_instr, &invalid_instr, &fldt_instr, &invalid_instr, &fstpt_instr },
{ &faddl_instr, &fmull_instr, &fcoml_instr, &fcompl_instr, &fsubl_instr, &fsubrl_instr, &fdivl_instr, &fdivrl_instr },
{ &fldl_instr, &fisttpll_instr, &fstl_instr, &fstpl_instr, &frstor_instr, &invalid_instr, &fnsave_instr, &fnstsw_instr },
{ &fiadds_instr, &fimuls_instr, &ficoms_instr, &ficomps_instr, &fisubs_instr, &fisubrs_instr, &fidivs_instr, &fidivrs_instr },
{ &filds_instr, &fisttps_instr, &fists_instr, &fistps_instr, &fbld_instr, &fildq_instr, &fbstp_instr, &fistpq_instr } };

hooInstruction_ opFP1n2_instr = {"",(void *)opFP1n2,TERM,0,0,"crazy indirect shit",0};

/* Hopefully without dependencies */

hooInstruction_ *opFP3[8][8] = {
/* bit  pattern:	1101 1xxx 11xx xREG */
{ &fadd_instr, &fmul_instr, &fcom_instr, &fcomp_instr, &fsub_instr, &fsubr_instr, &fdiv_instr, &fdivr_instr },
{ &fld_instr, &fxch_instr, &fnop_instr, &fstp_instr, &invalid_instr, &invalid_instr, &invalid_instr, &invalid_instr },
{ &fcmovb_instr, &fcmove_instr, &fcmovbe_instr, &fcmovu_instr, &invalid_instr, &fucompp_instr, &invalid_instr, &invalid_instr },
{ &fcmovnb_instr, &fcmovne_instr, &fcmovnbe_instr, &fcmovnu_instr, &invalid_instr, &fucomi_instr, &decb_instr, &invalid_instr },
{ &fadd_instr, &fmul_instr, &fcom_instr, &fcomp_instr, &fsub_instr, &fsubr_instr, &fdiv_instr, &fdivr_instr },
{ &ffree_instr, &fxch_instr, &fst_instr, &fstp_instr, &fucom_instr, &fucomp_instr, &invalid_instr, &invalid_instr },
{ &faddp_instr, &fmulp_instr, &fcomp_instr, &fcompp_instr, &fsubp_instr, &fsubrp_instr, &fdivp_instr, &fdivrp_instr },
{ &ffree_instr, &fxch_instr, &fstp_instr, &fstp_instr, &fnstsw_instr, &fucomip_instr, &fcomip_instr, &invalid_instr }
};

hooInstruction_ *opFP4[4][8] = {
/* bit pattern:	1101 1001 111x xxxx */
{ &fchs_instr, &fabs_instr, &invalid_instr, &invalid_instr, &ftst_instr, &fxam_instr, &invalid_instr, &invalid_instr },
{ &fld1_instr, &fldl2t_instr, &fldl2e_instr, &fldpi_instr, &fldlg2_instr, &fldln2_instr, &fldz_instr, &invalid_instr },
{ &f2xm1_instr, &fyl2x_instr, &fptan_instr, &fpatan_instr, &fxtract_instr, &fprem1_instr, &fdecstp_instr, &fincstp_instr },
{ &fprem_instr, &fyl2xp1_instr, &fsqrt_instr, &fsincos_instr, &frndint_instr, &fscale_instr, &fsin_instr, &fcos_instr },
};

hooInstruction_ *opFP5[8] = {
/* bit pattern:	1101 1011 1110 0xxx */
&invalid_instr, &invalid_instr, &fnclex_instr, &fninit_instr, &fsetpm_instr, &invalid_instr, &invalid_instr, &invalid_instr };

// static means only visible in this file

/*
 * Main decode table for the op codes.  The first two nibbles
 * will be used as an index into the table.  If there is a
 * a need to further decode an instruction, the array to be
 * referenced is indicated with the other two entries being
 * empty.
 */
hooInstruction_ *distable[16][16] = {
{ &addb_instr4, &add_instr4, &addb_instr3,&add_instr3, &addb_instr1, &add_instr1, &push_instr6, &pop_instr3, &orb_instr4, &or_instr5, &orb_instr3, &or_instr4, &orb_instr1, &or_instr1, &push_instr6, &op0F_instr },
{ &adcb_instr4, &adc_instr4, &adcb_instr3, &adc_instr3, &adcb_instr1, &adc_instr1, &push_instr6, &pop_instr3, &sbbb_instr4, &sbb_instr4, &sbbb_instr3, &sbb_instr3, &sbbb_instr1, &sbb_instr1, &push_instr6, &pop_instr3 },
{ &andb_instr4, &and_instr5, &andb_instr3, &and_instr4, &andb_instr1, &and_instr1, &es_instr, &daa_instr, &subb_instr4, &sub_instr4, &subb_instr3, &sub_instr3, &subb_instr1, &sub_instr1, &cs_instr, &das_instr },
{ &xorb_instr4, &xor_instr5, &xorb_instr3, &xor_instr4, &xorb_instr1, &xor_instr1, &ss_instr, &aaa_instr, &cmpb_instr5, &cmp_instr4, &cmpb_instr4, &cmp_instr3, &cmpb_instr1, &cmp_instr1, &ds_instr, &aas_instr },
{ &inc_instr2, &inc_instr2, &inc_instr2, &inc_instr2, &inc_instr2, &inc_instr2, &inc_instr2, &inc_instr2, &dec_instr2, &dec_instr2, &dec_instr2, &dec_instr2, &dec_instr2, &dec_instr2, &dec_instr2, &dec_instr2 },
{ &push_instr5, &push_instr5, &push_instr5, &push_instr5, &push_instr5, &push_instr5, &push_instr5, &push_instr5, &pop_instr2, &pop_instr2, &pop_instr2, &pop_instr2, &pop_instr2, &pop_instr2, &pop_instr2, &pop_instr2 },
{ &pusha_instr, &popa_instr, &bound_instr, &arpl_instr, &fs_instr, &gs_instr, &data16_instr, &addr16_instr, &push_instr1, &imul_instr, &push_instr2, &imul_instr, &insb_instr, &ins_instr, &outsb_instr, &outs_instr },
{ &jo_instr1, &jno_instr1, &jb_instr1, &jae_instr1, &je_instr1, &jne_instr1, &jbe_instr1, &ja_instr1, &js_instr1, &jns_instr1, &jp_instr1, &jnp_instr1, &jl_instr1, &jge_instr1, &jle_instr1, &jg_instr1 },
{ &op80_instr, &op81_instr, &op82_instr, &op83_instr, &testb_instr3, &test_instr3, &xchgb_instr, &xchg_instr1, &movb_instr6, &mov_instr7, &movb_instr4, &mov_instr4, &mov_instr8, &lea_instr, &mov_instr5, &pop_instr1 },
{ &nop_instr1, &xchg_instr2, &xchg_instr2, &xchg_instr2, &xchg_instr2, &xchg_instr2, &xchg_instr2, &xchg_instr2, &CBW_instr, &CWD_instr, &lcall_instr2, &wait_prefix, &pushf_instr, &popf_instr, &sahf_instr, &lahf_instr },
{ &movb_instr5, &mov_instr6, &movb_instr1, &mov_instr1, &movsb_instr2, &movs_instr, &cmpsb_instr, &cmps_instr, &testb_instr1, &test_instr1, &stosb_instr, &stos_instr, &lodsb_instr, &lods_instr, &scasb_instr, &scas_instr },
{ &movb_instr3, &movb_instr3, &movb_instr3, &movb_instr3, &movb_instr3, &movb_instr3, &movb_instr3, &movb_instr3, &mov_instr3, &mov_instr3, &mov_instr3, &mov_instr3, &mov_instr3, &mov_instr3, &mov_instr3, &mov_instr3 },
{ &opC0_instr, &opC1_instr, &ret_instr2, &ret_instr1, &les_instr, &lds_instr, &movb_instr2, &mov_instr2, &enter_instr, &leave_instr, &lret_instr2, &lret_instr1, &int_instr2, &int_instr1, &into_instr, &iret_instr },
{ &opD0_instr, &opD1_instr, &opD2_instr, &opD3_instr, &aam_instr, &aad_instr, &falc_instr, &xlat_instr,
/* 287 instructions.  Note that although the indirect field		*/
/* indicates opFP1n2 for further decoding, this is not necessarily	*/
/* the case since the opFP arrays are not partitioned according to key1	*/
/* and key2.  opFP1n2 is given only to indicate that we haven't		*/
/* finished decoding the instruction.					*/
&opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr, &opFP1n2_instr},
{ &loopnz_instr, &loopz_instr, &loop_instr, &jcxz_instr, &inb_instr1, &in_instr1, &outb_instr1, &out_instr1, &call_instr1, &jmp_instr2, &ljmp_instr2, &jmp_instr1, &inb_instr2, &in_instr2, &outb_instr2, &out_instr2 },
{ &lock_prefix, &invalid_instr, &repnz_prefix, &repz_prefix, &hlt_instr, &cmc_instr, &opF6_instr, &opF7_instr, &clc_instr, &stc_instr, &cli_instr, &sti_instr, &cld_instr, &std_instr, &opFE_instr, &opFF_instr }
};

