//
//  MachoLoader.h
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

// TODO: does what i need
// check out this
// http://d.hatena.ne.jp/mteramoto/20070121/p2

// eg, dump cstrings otool -s __TEXT __cstring -v test    

@class MemoryMap, SymbolicInfo;
@class IntKeyDictionary, IntHash;
@class DisassemblyChecker;

// How to install libiberty
//> port variants binutils
//> sudo port install binutils +universal
struct symbol {
    char *name;
    char *indr_name;
    char *n_value;
    int is_thumb;
};

struct hooleyCodeLine {
	struct hooleyCodeLine *prev;
	struct hooleyCodeLine *next;	
	const struct instable *instr;
};

struct hooleyFuction {
	struct hooleyFuction *prev;
	struct hooleyFuction *next;
	struct hooleyCodeLine *firstLine;	
	struct hooleyCodeLine *lastLine;
};

@interface MachoLoader : NSObject {

	NSData						*_allFile;
	NSString					*_filePath;

	struct load_command			*_startOfLoadCommandsPtr;
	NSUInteger					_sizeofcmds;
	NSUInteger					_ncmds;
	NSMutableArray				*_loadCommandsArray;
	
	char						*_codeAddr;
	size_t						_codeSize;
	cpu_type_t					_cputype;
	
	NSMutableDictionary			*_addresses_;    // Addresses and symbols (STRONG)
	
	// Symbol table
	struct nlist				*_symtable_ptr32;
	struct nlist_64				*_symtable_ptr64;
	
	NSUInteger					_nsymbols;
	NSUInteger					_strings_size;
	
	char						*_strtable;
	
	// Indirect Symbol Table
	NSUInteger					_nindirect_symbols;
	char*						_indirectSymbolTable;
	
	IntKeyDictionary			*_indirectSymbolLookup, *_cStringLookup;
	IntHash						*_cls_refsLookup;
	IntHash						*_temporaryExperiment;

	MemoryMap					*_memoryMap;
	MemoryMap					*_uncodedMemoryMap;

	BOOL						_MH_TWOLEVEL, _MH_FORCE_FLAT;
	NSMutableArray				*_libraries;
	
	// text section bodge - stuff needed to get the code lifted straight from otool to work
	char						*_text_sect_pointer;
	char						*_text_sect_addr;
	struct relocation_info		*_text_relocs;
	NSUInteger					_text_nsorted_relocs;
	NSUInteger					_textSectSize;
	
	// ok - the results of the disasembly
	struct hooleyFuction		*_headFunction;
	
	DisassemblyChecker			*_dc;
}

- (id)initWithPath:(NSString *)aPath checker:(DisassemblyChecker *)ch;

- (void)readFile;

- (SymbolicInfo *)symbolicInfoForAddress:(char *)memAddr;

- (BOOL)processSymbolItem:(struct nlist_64 *)list stringTable:(char *)table;

- (NSString *)lookupLibrary:(NSUInteger)libraryIndex;
- (void)addCstring:(NSString *)aCstring forAddress:(const char *)cStringAddress;
- (NSString *)CStringForAddress:(char *)addr;

const char * guess_symbol( const char *value,	/* the value of this symbol (in) */
			 const struct symbol *sorted_symbols,
			 const uint32_t nsorted_symbols,
			 int verbose);

const char * guess_indirect_symbol(
								   const uint64_t value,	/* the value of this symbol (in) */
								   const uint32_t ncmds,
								   const uint32_t sizeofcmds,
								   const struct load_command *load_commands,
								   //	  const enum byte_sex load_commands_byte_sex,
								   const uint32_t *indirect_symbols,
								   const uint32_t nindirect_symbols,
								   const struct nlist *symbols,
								   const struct nlist_64 *symbols64,
								   const uint32_t nsymbols,
								   const char *strings,
								   const uint32_t strings_size);
@end
