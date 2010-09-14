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

// How to install libiberty
//> port variants binutils
//> sudo port install binutils +universal
struct symbol {
    char *name;
    char *indr_name;
    uint64_t n_value;
    int is_thumb;
};


@interface MachoLoader : NSObject {

	NSData						*_allFile;
	NSString					*_filePath;

	struct load_command		*_startOfLoadCommandsPtr;
	NSUInteger					_sizeofcmds;
	NSUInteger					_ncmds;
	NSMutableArray			*_loadCommandsArray;
	const void					*_codeAddr;
	size_t						_codeSize;
	cpu_type_t					_cputype;
	
	NSMutableDictionary		*addresses_;    // Addresses and symbols (STRONG)
	
	// Symbol table
	struct nlist				*_symtable_ptr;
	struct nlist_64			*_UNUSED_symbols64;
	NSUInteger					_nsymbols;
	NSUInteger					_strings_size;
	
	char						*_strtable;
	
	// Indirect Symbol Table
	NSUInteger					_nindirect_symbols;
	const uint32_t*			_indirectSymbolTable;
	
	IntKeyDictionary			*_indirectSymbolLookup, *_cStringLookup;
	IntHash					*_cls_refsLookup;
	IntHash					*_temporaryExperiment;

	MemoryMap					*_memoryMap;
	MemoryMap					*_uncodedMemoryMap;

	BOOL						_MH_TWOLEVEL, _MH_FORCE_FLAT;
	NSMutableArray			*_libraries;
	
	// text section bodge
	UInt8						*_text_sect_pointer;
	UInt8						*_text_sect_addr;
	struct relocation_info	*_text_sorted_relocs;
	uint32_t					_text_nsorted_relocs;
	NSUInteger					_textSectSize;
}

- (id)initWithPath:(NSString *)aPath;

- (void)readFile;

- (SymbolicInfo *)symbolicInfoForAddress:(NSUInteger)memAddr;

- (BOOL)processSymbolItem:(struct nlist_64 *)list stringTable:(char *)table;

- (NSString *)lookupLibrary:(NSUInteger)libraryIndex;
- (void)addCstring:(NSString *)aCstring forAddress:(NSUInteger)cStringAddress;
- (NSString *)CStringForAddress:(NSUInteger)addr;

const char * guess_symbol( const uint64_t value,	/* the value of this symbol (in) */
			 const struct symbol *sorted_symbols,
			 const uint32_t nsorted_symbols,
			 int verbose);
@end
