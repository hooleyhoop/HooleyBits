

#ifndef FLAC__PRIVATE__CPU_H
#define FLAC__PRIVATE__CPU_H

#include "ordinals.h"

typedef enum {
	FLAC__CPUINFO_TYPE_IA32,
	FLAC__CPUINFO_TYPE_PPC,
	FLAC__CPUINFO_TYPE_UNKNOWN
} FLAC__CPUInfo_Type;

typedef struct {
	FLAC__bool cpuid;
	FLAC__bool bswap;
	FLAC__bool cmov;
	FLAC__bool mmx;
	FLAC__bool fxsr;
	FLAC__bool sse;
	FLAC__bool sse2;
	FLAC__bool sse3;
	FLAC__bool ssse3;
	FLAC__bool _3dnow;
	FLAC__bool ext3dnow;
	FLAC__bool extmmx;
} FLAC__CPUInfo_IA32;

typedef struct {
	FLAC__bool altivec;
	FLAC__bool ppc64;
} FLAC__CPUInfo_PPC;

typedef struct {
	FLAC__bool use_asm;
	FLAC__CPUInfo_Type type;
	union {
		FLAC__CPUInfo_IA32 ia32;
		FLAC__CPUInfo_PPC ppc;
	} data;
} FLAC__CPUInfo;

void FLAC__cpu_info(FLAC__CPUInfo *info);


#endif
