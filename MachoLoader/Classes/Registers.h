/*
 *  Registers.h
 *  MachoLoader
 *
 *  Created by Steven Hooley on 14/10/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

enum argType {
	NULL_ARG,
	REGISTER_ARG,
	IMMEDIATE_ARG,
	INDIRECT_ARG,
	DISPLACEMENT_ARG,
	INDEXEDREGISTER_ARG
};

struct HooAbstractDataType {
	enum argType isah;
};

struct HooReg {
	enum argType		isah;
	char				name[MAX_MNEMONIC];
	char				prettyName[40];	
};

#define hooReg_ static const struct HooReg const

hooReg_		acuml_reg =					{REGISTER_ARG, "%al",		"%accumulator" };
hooReg_		acumx_reg =					{REGISTER_ARG, "%ax",		"%accumulator" };
hooReg_		acumex_reg =				{REGISTER_ARG, "%eax",		"%accumulator" };
hooReg_		acum1_reg =					{REGISTER_ARG, "%ah",		"%accumulator" };
hooReg_		acum2_reg =					{REGISTER_ARG, "%rax",		"%accumulator" };

hooReg_		data1_reg =					{REGISTER_ARG, "%dx",		"%data" };
hooReg_		data2_reg =					{REGISTER_ARG, "%dl",		"%data" };
hooReg_		data3_reg =					{REGISTER_ARG, "%dh",		"%data" };
hooReg_		data4_reg =					{REGISTER_ARG, "%edx",		"%data" };
hooReg_		data5_reg =					{REGISTER_ARG, "%rdx",		"%data" };

hooReg_		count1_reg =				{REGISTER_ARG, "%cl",		"%count" };
hooReg_		count2_reg =				{REGISTER_ARG, "%cx",		"%count" };
hooReg_		count3_reg =				{REGISTER_ARG, "%ch",		"%count" };
hooReg_		count4_reg =				{REGISTER_ARG, "%ecx",		"%count" };
hooReg_		count5_reg =				{REGISTER_ARG, "%rcx",		"%count" };

hooReg_		sourceIndex1_reg =			{REGISTER_ARG, "%esi",		"%source_index" };
hooReg_		sourceIndex2_reg =			{REGISTER_ARG, "%si",		"%source_index" };
hooReg_		sourceIndex3_reg =			{REGISTER_ARG, "%rsi",		"%source_index" };

hooReg_		destinationIndex1_reg =		{REGISTER_ARG, "%edi",		"%destination_index" };
hooReg_		destinationIndex2_reg =		{REGISTER_ARG, "%di",		"%destination_index" };
hooReg_		destinationIndex3_reg =		{REGISTER_ARG, "%rdi",		"%destination_index" };

hooReg_		base1_reg =					{REGISTER_ARG, "%bx",		"%base" };
hooReg_		base2_reg =					{REGISTER_ARG, "%bl",		"%base"};
hooReg_		base3_reg =					{REGISTER_ARG, "%bh",		"%base"};
hooReg_		base4_reg =					{REGISTER_ARG, "%ebx",		"%base" };
hooReg_		base5_reg =					{REGISTER_ARG, "%rbx",		"%base" };

hooReg_		codeSeg_reg =				{REGISTER_ARG, "%cs",		"code_seg_reg" };
hooReg_		stackSeg_reg =				{REGISTER_ARG, "%ss",		"stack_seg_reg" };
hooReg_		rip_reg =					{REGISTER_ARG, "%rip",		"the_infamous_rip_reg" };

hooReg_		dataSeg1_reg =				{REGISTER_ARG, "%es",		"string_operation_dest_seg_reg" };
hooReg_		dataSeg2_reg =				{REGISTER_ARG, "%es",		"data_seg_reg" };
hooReg_		dataSeg3_reg =				{REGISTER_ARG, "%ds",		"data_seg_reg" };
hooReg_		dataSeg4_reg =				{REGISTER_ARG, "%fs",		"data_seg_reg" };
hooReg_		dataSeg5_reg =				{REGISTER_ARG, "%gs",		"data_seg_reg" };
hooReg_		unknown1_reg =				{REGISTER_ARG, "%?6",		"%??Reg" };
hooReg_		unknown2_reg =				{REGISTER_ARG, "%?7",		"%??Reg" };

hooReg_		spt1_reg =					{REGISTER_ARG, "%sp",		"%stackPointer_top" };
hooReg_		spt2_reg =					{REGISTER_ARG, "%esp",		"%stackPointer_top" };
hooReg_		spt3_reg =					{REGISTER_ARG, "%rsp",		"%stackPointer_top" };

hooReg_		spb1_reg =					{REGISTER_ARG, "%bp",		"%stackPointer_base" };
hooReg_		spb2_reg =					{REGISTER_ARG, "%ebp",		"%stackPointer_base"};
hooReg_		spb3_reg =					{REGISTER_ARG, "%rbp",		"%stackPointer_base" };

hooReg_		fp0_reg =					{REGISTER_ARG, "%st(0)",	"%floatReg0" };
hooReg_		fp1_reg =					{REGISTER_ARG, "%st(1)",	"%floatReg1" };
hooReg_		fp2_reg =					{REGISTER_ARG, "%st(2)",	"%floatReg2" };
hooReg_		fp3_reg =					{REGISTER_ARG, "%st(3)",	"%floatReg3" };
hooReg_		fp4_reg =					{REGISTER_ARG, "%st(4)",	"%floatReg4" };
hooReg_		fp5_reg =					{REGISTER_ARG, "%st(5)",	"%floatReg5" };
hooReg_		fp6_reg =					{REGISTER_ARG, "%st(6)",	"%floatReg6" };
hooReg_		fp7_reg =					{REGISTER_ARG, "%st(7)",	"%floatReg7" };
hooReg_		fp_reg =					{REGISTER_ARG, "%st",		"%floatReg" };

hooReg_		r08_1_reg =					{REGISTER_ARG, "%r8b",		"%reg8" };
hooReg_		r08_2_reg =					{REGISTER_ARG, "%r8d",		"%reg8" };
hooReg_		r08_3_reg =					{REGISTER_ARG, "%r8",		"%reg8" };
hooReg_		r09_1_reg =					{REGISTER_ARG, "%r9b",		"%reg9" };
hooReg_		r09_2_reg =					{REGISTER_ARG, "%r9d",		"%reg9" };
hooReg_		r09_3_reg =					{REGISTER_ARG, "%r9",		"%reg9" };
hooReg_		r10_1_reg =					{REGISTER_ARG, "%r10b",		"%reg10" };
hooReg_		r10_2_reg =					{REGISTER_ARG, "%r10d",		"%reg10" };
hooReg_		r10_3_reg =					{REGISTER_ARG, "%r10",		"%reg10" };
hooReg_		r11_1_reg =					{REGISTER_ARG, "%r11b",		"%reg11" };
hooReg_		r11_2_reg =					{REGISTER_ARG, "%r11d",		"%reg11" };
hooReg_		r11_3_reg =					{REGISTER_ARG, "%r11",		"%reg11" };
hooReg_		r12_1_reg =					{REGISTER_ARG, "%r12b",		"%reg12" };
hooReg_		r12_2_reg =					{REGISTER_ARG, "%r12d",		"%reg12" };
hooReg_		r12_3_reg =					{REGISTER_ARG, "%r12",		"%reg12" };
hooReg_		r13_1_reg =					{REGISTER_ARG, "%r13b",		"%reg13" };
hooReg_		r13_2_reg =					{REGISTER_ARG, "%r13d",		"%reg13" };
hooReg_		r13_3_reg =					{REGISTER_ARG, "%r13",		"%reg13" };
hooReg_		r14_1_reg =					{REGISTER_ARG, "%r14b",		"%reg14" };
hooReg_		r14_2_reg =					{REGISTER_ARG, "%r14d",		"%reg14" };
hooReg_		r14_3_reg =					{REGISTER_ARG, "%r14",		"%reg14" };
hooReg_		r15_1_reg =					{REGISTER_ARG, "%r15b",		"%reg15" };
hooReg_		r15_2_reg =					{REGISTER_ARG, "%r15d",		"%reg15" };
hooReg_		r15_3_reg =					{REGISTER_ARG, "%r15",		"%reg15" };

hooReg_		xmm0_reg =					{REGISTER_ARG, "%xmm0",		"%xmm0" };
hooReg_		xmm1_reg =					{REGISTER_ARG, "%xmm1",		"%xmm1" };
hooReg_		xmm2_reg =					{REGISTER_ARG, "%xmm2",		"%xmm2" };
hooReg_		xmm3_reg =					{REGISTER_ARG, "%xmm3",		"%xmm3" };
hooReg_		xmm4_reg =					{REGISTER_ARG, "%xmm4",		"%xmm4" };
hooReg_		xmm5_reg =					{REGISTER_ARG, "%xmm5",		"%xmm5" };
hooReg_		xmm6_reg =					{REGISTER_ARG, "%xmm6",		"%xmm6" };
hooReg_		xmm7_reg =					{REGISTER_ARG, "%xmm7",		"%xmm7" };

hooReg_		mm0_reg =					{REGISTER_ARG, "%mm0",		"%mm0" };
hooReg_		mm1_reg =					{REGISTER_ARG, "%mm1",		"%mm1" };
hooReg_		mm2_reg =					{REGISTER_ARG, "%mm2",		"%mm2" };
hooReg_		mm3_reg =					{REGISTER_ARG, "%mm3",		"%mm3" };
hooReg_		mm4_reg =					{REGISTER_ARG, "%mm4",		"%mm4" };
hooReg_		mm5_reg =					{REGISTER_ARG, "%mm5",		"%mm5" };
hooReg_		mm6_reg =					{REGISTER_ARG, "%mm6",		"%mm6" };
hooReg_		mm7_reg =					{REGISTER_ARG, "%mm7",		"%mm7" };

hooReg_		empty_reg =					{REGISTER_ARG, "",			"" };
hooReg_		null_reg =					{NULL_ARG,		"",			"" };