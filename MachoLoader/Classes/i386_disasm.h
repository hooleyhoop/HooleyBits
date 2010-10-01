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
//#import <stuff/bytesex.h>
//#import <mach-o/reloc.h>
//#import <mach-o/nlist.h>
//#import <stuff/bool.h>
//#include "stuff/symbol.h"

extern NSUInteger i386_disassemble(

	struct hooleyFuction **currentFuncPtr,
    char *sect,
    uint64 left,
    uint64_t addr,
    uint64_t sect_addr,
//    enum byte_sex object_byte_sex,
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

);
