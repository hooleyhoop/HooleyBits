#include "cpu.h"
#include "hooHacks.h"
#include <stdio.h>

extern FILE *_logFile;

/* these are flags in EDX of CPUID AX=00000001 */
static const unsigned FLAC__CPUINFO_IA32_CPUID_CMOV = 0x00008000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_MMX = 0x00800000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_FXSR = 0x01000000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_SSE = 0x02000000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_SSE2 = 0x04000000;
/* these are flags in ECX of CPUID AX=00000001 */
static const unsigned FLAC__CPUINFO_IA32_CPUID_SSE3 = 0x00000001;
static const unsigned FLAC__CPUINFO_IA32_CPUID_SSSE3 = 0x00000200;
/* these are flags in EDX of CPUID AX=80000001 */
static const unsigned FLAC__CPUINFO_IA32_CPUID_EXTENDED_AMD_3DNOW = 0x80000000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_EXTENDED_AMD_EXT3DNOW = 0x40000000;
static const unsigned FLAC__CPUINFO_IA32_CPUID_EXTENDED_AMD_EXTMMX = 0x00400000;


void FLAC__cpu_info(FLAC__CPUInfo *info)
{
    hooFileLog( "FLAC__cpu_info()\n" );

/*
 * IA32-specific
 */
	info->type = FLAC__CPUINFO_TYPE_IA32;
	info->use_asm = false;
}
