//
//  MachoLoader.m
//  MachoLoader
//
//  Created by steve hooley on 03/04/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "MachoLoader.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import "Hex.h"
#import "FileMapView.h"

// Standard C includes.
#import <stdio.h>
#import <stdlib.h>
#import <fcntl.h>
#import <unistd.h>
#import <sys/mman.h>
#import <sys/stat.h>
#import <sys/types.h>
#import <mach/mach.h>
#import <mach-o/stab.h>
// Dynamic linker (dyld) stuff
#import <mach-o/fat.h>
#import <mach-o/arch.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/nlist.h>
#import <mach-o/reloc.h>
#import <signal.h>
//#import <cxxabi.h>

#import <mach/machine.h>
#import <mach-o/arch.h>
#import <mach-o/loader.h>

// http://developer.apple.com/samplecode/Carbon/idxRuntimeArchitecture-date.html

@interface MachoLoader (PrivateMethods) 
- (void)doIt:(NSString *)aPath;
- (void)parseLoadCommands;
- (void)addFunction:(NSString *)name line:(int)line address:(uint64_t)address section:(int)section;

@end

@implementation MachoLoader

- (id)initWithPath:(NSString *)aPath {

	self = [super init];
	if(self){
		_loadCommands = [[NSMutableArray array] retain];
		[self doIt:aPath];
		
		addresses_ = [[NSMutableDictionary alloc] init];

		[self parseLoadCommands];
	}
	return self;
}

void readHeaderFlags( uint32_t flags ) {
	
	if( flags & MH_NOUNDEFS ){
		// MH_NOUNDEFS—The object file contained no undefined references when it was built.
		NSLog(@"MH_NOUNDEFS");
	} if( flags & MH_INCRLINK ){
		// MH_INCRLINK—The object file is the output of an incremental link against a base file and cannot be linked again.
		NSLog(@"MH_INCRLINK");
	} if( flags & MH_DYLDLINK ){
		// MH_DYLDLINK—The file is input for the dynamic linker and cannot be statically linked again.
		NSLog(@"MH_DYLDLINK");
	} if( flags & MH_BINDATLOAD ){
		// MH_BINDATLOAD—The dynamic linker should bind the undefined references when the file is loaded.
		NSLog(@"MH_BINDATLOAD");
	} if( flags & MH_PREBOUND ){
		// MH_PREBOUND—The file’s undefined references are prebound.
		NSLog(@"MH_PREBOUND");
	} if( flags & MH_SPLIT_SEGS ){
		// MH_SPLIT_SEGS—The file has its read-only and read-write segments split.
		NSLog(@"MH_SPLIT_SEGS");
	} if( flags & MH_TWOLEVEL ){
		// MH_TWOLEVEL—The image is using two-level namespace bindings.
		NSLog(@"MH_TWOLEVEL");
	} if( flags & MH_FORCE_FLAT ){
		// MH_FORCE_FLAT—The executable is forcing all images to use flat namespace bindings.
		NSLog(@"MH_FORCE_FLAT");
	} if( flags & MH_SUBSECTIONS_VIA_SYMBOLS ){
		// MH_SUBSECTIONS_VIA_SYMBOLS—The sections of the object file can be divided into individual blocks. These blocks are dead-stripped if they are not used by other code. See “Dead-Code Stripping” in Xcode Build System for details.
		NSLog(@"MH_SUBSECTIONS_VIA_SYMBOLS");
	}
}

- (void)addFunction:(NSString *)name line:(int)line address:(uint64_t)address section:(int)section {
	
	NSLog(@"Function %@ - Line %i - Address %i - Section %i", name, line, address, section);
	
	//-- try in the file
	char *func_pointer = ((char *)codeAddr) + address;
	NSData *sectionData = [NSData dataWithBytes:func_pointer length:16];
	NSLog(@"Copied section.. %@", sectionData); // [sectionData hexString]		

	
	
//	NSNumber *addressNum = [NSNumber numberWithUnsignedLongLong:address];
//	
//	if (!address)
//		return;
//	
//	// If the function starts with "_Z" or "__Z" then demangle it.
//	BOOL isCPP = NO;
//	
//	if ([name hasPrefix:@"__Z"]) {
//		// Remove the leading underscore
//		name = [name substringFromIndex:1];
//		isCPP = YES;
//	} else if ([name hasPrefix:@"_Z"]) {
//		isCPP = YES;
//	}
//	
//	// Filter out non-functions
//	if ([name hasSuffix:@".eh"])
//		return;
//	
//	if ([name hasSuffix:@"__func__"])
//		return;
//	
//	if ([name hasSuffix:@"GCC_except_table"])
//		return;
//	
//	if (isCPP) {
//		// OBJCPP_MANGLING_HACK
//		// There are cases where ObjC++ mangles up an ObjC name using quasi-C++ 
//		// mangling:
//		// @implementation Foozles + (void)barzles {
//		//    static int Baz = 0;
//		// } @end
//		// gives you _ZZ18+[Foozles barzles]E3Baz
//		// c++filt won't parse this properly, and will crash in certain cases. 
//		// Logged as radar:
//		// 5129938: c++filt does not deal with ObjC++ symbols
//		// If 5129938 ever gets fixed, we can remove this, but for now this prevents
//		// c++filt from attempting to demangle names it doesn't know how to handle.
//		// This is with c++filt 2.16
//		NSCharacterSet *objcppCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-+[]: "];
//		NSRange emptyRange = { NSNotFound, 0 };
//		NSRange objcppRange = [name rangeOfCharacterFromSet:objcppCharSet];
//		isCPP = NSEqualRanges(objcppRange, emptyRange);
//	} else if ([name characterAtIndex:0] == '_') {
//		// Remove the leading underscore
//		name = [name substringFromIndex:1];
//	}
//	
//	// If there's already an entry for this address, check and see if we can add
//	// either the symbol, or a missing line #
//	NSMutableDictionary *dict = [addresses_ objectForKey:addressNum];
//	
//	if (!dict) {
//		dict = [[NSMutableDictionary alloc] init];
//		[addresses_ setObject:dict forKey:addressNum];
//		[dict release];
//	}
//	
//	if (name && ![dict objectForKey:kAddressSymbolKey]) {
//		[dict setObject:name forKey:kAddressSymbolKey];
//		
//		// only functions, not line number addresses
//		[functionAddresses_ addObject:addressNum];
//	}
//	
//	if (isCPP) {
//		// try demangling
//		NSString *demangled = [self convertCPlusPlusSymbol:name];
//		if (demangled != nil)
//			[dict setObject:demangled forKey:kAddressConvertedSymbolKey];
//	}
//	
//	if (line && ![dict objectForKey:kAddressSourceLineKey])
//		[dict setObject:[NSNumber numberWithUnsignedInt:line]
//				 forKey:kAddressSourceLineKey];
	
}

- (BOOL)processSymbolItem:(struct nlist_64 *)list stringTable:(char *)table {
	
	uint32_t lastStartAddress_;
	uint32_t n_strx = list->n_un.n_strx;
	BOOL result = NO;

//	if(n_type & N_STAB){
//		NSLog(@"N_STAB");
//	}
//	if(n_type & N_PEXT) {
//		NSLog(@"N_PEXT");
//	} 
//	if(n_type & N_TYPE) {
//		NSLog(@"N_TYPE");
//	}
//	if(n_type & N_EXT) {
//		NSLog(@"N_EXT");
//	}
	
	// We don't care about non-section specific information except function length
	if (list->n_sect == 0 && list->n_type != N_FUN )
		return NO;
	
	if (list->n_type == N_FUN) {
		if (list->n_sect != 0) {
			// we get the function address from the first N_FUN
			lastStartAddress_ = list->n_value;
		}
		else {
			// an N_FUN from section 0 may follow the initial N_FUN
			// giving us function length information
			NSMutableDictionary *dict = [addresses_ objectForKey: [NSNumber numberWithUnsignedLong:lastStartAddress_]];
			
//			assert(dict);
			
			// only set the function size the first time
			// (sometimes multiple section 0 N_FUN entries appear!)
//			if (![dict objectForKey:@"size"]) {
//				[dict setObject:[NSNumber numberWithUnsignedLongLong:list->n_value] forKey:@"size"];
//			}
		}
	}
	
	int line = list->n_desc;
	
	// __TEXT __text section
//	NSMutableDictionary *archSections = [sectionData_ objectForKey:architecture_];
	
//	uint32_t mainSection = [[archSections objectForKey:@"__TEXT__text" ] sectionNumber];
	
	// Extract debugging information:
	// Doc: http://developer.apple.com/documentation/DeveloperTools/gdb/stabs/stabs_toc.html
	// Header: /usr/include/mach-o/stab.h:
	if (list->n_type == N_SO)  {
		NSString *src = [NSString stringWithUTF8String:&table[n_strx]];
		NSString *ext = [src pathExtension];
		NSNumber *address = [NSNumber numberWithUnsignedLongLong:list->n_value];
		
		// Leopard puts .c files with no code as an offset of 0, but a
		// crash can't happen here and it throws off our code that matches
		// symbols to line numbers so we ignore them..
		// Return YES because this isn't an error, just something we don't
		// care to handle.
		if ([address unsignedLongValue] == 0) {
			return YES;
		}
		// TODO(waylonis):Ensure that we get the full path for the source file
		// from the first N_SO record
		// If there is an extension, we'll consider it source code
		if ([ext length]) {
//			if (!sources_)
//				sources_ = [[NSMutableDictionary alloc] init];
//			// Save the source associated with an address
//			[sources_ setObject:src forKey:address];
//			result = YES;
		}
	} else if (list->n_type == N_FUN) {
		NSString *fn = [NSString stringWithUTF8String:&table[n_strx]];
		NSRange range = [fn rangeOfString:@":" options:NSBackwardsSearch];
		
		if (![fn length])
			return NO;
		
		if (range.length > 0) {
			// The function has a ":" followed by some stuff, so strip it off
			fn = [fn substringToIndex:range.location];
		}
		
		[self addFunction:fn line:line address:list->n_value section:list->n_sect ];
		
		result = YES;
//	} else if (list->n_type == N_SLINE && list->n_sect == mainSection) {
//		[self addFunction:nil line:line address:list->n_value section:list->n_sect ];
//		result = YES;
	} else if (((list->n_type & N_TYPE) == N_SECT) && !(list->n_type & N_STAB)) {
		// Regular symbols or ones that are external
		NSString *fn = [NSString stringWithUTF8String:&table[n_strx]];
		
		[self addFunction:fn line:0 address:list->n_value section:list->n_sect ];
		result = YES;
	}
	
	return result;
}


// http://serenity.uncc.edu/web/ADC/2005/Developer_DVD_Series/April/ADC%20Reference%20Library/documentation/DeveloperTools/Conceptual/MachORuntime/FileStructure/chapter_4_section_1.html#//apple_ref/doc/uid/20001298/BAJBDBBC
- (void)parseLoadCommands {
	
	for( NSNumber *segmentAddress_Number in _loadCommands)
	{		
		const struct load_command* cmd = (struct load_command *)[segmentAddress_Number unsignedIntValue];

		if(cmd->cmd==LC_UUID){
			// Specifies the 128-bit UUID for an image or its corresponding dSYM file.
			struct uuid_command *seg = (struct uuid_command *)cmd;
			NSLog(@"LC_UUID");
			
		} else if(cmd->cmd==LC_SEGMENT){
			// Defines a segment of this file to be mapped into the address space of the process that loads this file. It also includes all the sections contained by the segment.
			struct segment_command *seg = (struct segment_command *)cmd;				
			char *segname= seg->segname;
			NSString *segmentName = [NSString stringWithCString:segname length:16];
			NSLog(@"segment name %@", segmentName);

			NSInteger segmentOffset = (NSInteger)((NSInteger *)seg)-(NSInteger)((NSInteger *)codeAddr);
			[[FileMapView sharedMapView] addRegionAtOffset:segmentOffset withSize:seg->cmdsize label:[NSString stringWithFormat:@"LC_SEGMENT:%@ %i", segmentName, seg->cmdsize]];	

			// __PAGEZERO	--  where you end up when dereferencing a 0 pointer.
			// __TEXT		-- The text segment is where our code lives.
			// __DATA		-- The data segment holds our “Hello world!” string.
			// __IMPORT		-- The IMPORT segment holds our jump table, the stubs for printf and exit.
			// __LINKEDIT	-- The LINKEDIT segment holds the symbol table.
			if ( strcmp(segname, "__PAGEZERO")==0 ) {
				NSLog(@"Processing __PAGEZERO"); // vmsize 4096

			} else if ( strcmp(segname, "__TEXT")==0 ) {
				NSLog(@"Processing page __TEXT");
				// 4 sections x86
			} else if ( strcmp(segname, "__DATA")==0 ) {
				NSLog(@"Processing __DATA");
				// 4 sections x86
			} else if ( strcmp(segname, "__IMPORT")==0 ) {
				NSLog(@"Processing __IMPORT");
				// 2 sections x86
			} else if ( strcmp(segname, "__LINKEDIT")==0 ) {
				NSLog(@"Processing __LINKEDIT");
			
			} else if ( strcmp(segname, "__OBJC")==0 ) {
				NSLog(@"Processing	__OBJC");
				// 13 sections x86
			} else {
				[NSException raise:@"chimpo" format:@""];
			}
			// each segment is divided into sections.  eg __PAGEZERO segment takes up no space on disk but has space in memory
			uint32_t numberOfSections1 = seg->nsects; // works on ppc
			
			// If there are sections - The sections follow the segment
            struct section *sects = (struct section *)(seg+1);	// hey look - this is a good way to advance past segment
			
			// struct section *endOfSections_addr = &startOfSections_addr[numberOfSections1];
			struct section *newSec_ptr = sects;

			for( int i=0; i<numberOfSections1; i++ )
			{
				uint32_t sec_address1 = newSec_ptr->addr; // In otx dump this is address of first line  :start: +0	--00002704--  7c3a0b78	or r26,r1,r1
				if(sec_address1){
					NSLog(@"i=%i, numberOfSections=%i", i, numberOfSections1);
					char *segmentName_2 = newSec_ptr->segname;
					char *sectionName = newSec_ptr->sectname;

					NSLog(@"segment2 name %@", [NSString stringWithCString:segmentName_2 length:16]);
					NSLog(@"section2 name %@", [NSString stringWithCString:sectionName length:16]);
					
					char *sect_pointer = ((char *)codeAddr) + newSec_ptr->offset; // ((char *) (codeAddr)) + bestFatArch->offset
					
					struct relocation_info *sect_relocs = (struct relocation_info *)(codeAddr + newSec_ptr->reloff);
					uint32_t sect_nrelocs = newSec_ptr->nreloc;
					uint32_t sect_addr = newSec_ptr->addr;
					uint32_t sect_flags = newSec_ptr->flags;
					
					uint32_t newSectSize = newSec_ptr->size;
					void *newSectAddr = NULL;

					NSInteger sectionOffset = (NSInteger)((NSInteger *)sect_pointer)-(NSInteger)((NSInteger *)codeAddr);
					[[FileMapView sharedMapView] addRegionAtOffset:sectionOffset withSize:newSectSize label:[NSString stringWithFormat:@"section:%@ %i", [NSString stringWithCString:sectionName length:16], newSectSize]];	

					int err = (int) vm_allocate(mach_task_self(), (vm_address_t *) &newSectAddr, newSectSize, true);
					if (err==0) {
						NSData *sectionData = [NSData dataWithBytes:sect_pointer length:newSectSize];
						NSLog(@"Copied section.. %@", sectionData); // [sectionData hexString]
						memcpy(newSectAddr, sect_pointer, newSectSize);

					}
					NSLog(@"why not stop for a while and see what we copied?");
				}
				newSec_ptr = newSec_ptr+1;
			}
			
		} else if(cmd->cmd==LC_SEGMENT_64){
			// Defines a 64-bit segment of this file to be mapped into the address space of the process that loads this file. It also includes all the sections contained by the segment.
			struct segment_command_64 *seg = (struct segment_command_64 *)cmd;				
			NSLog(@"LC_SEGMENT_64");
			
		} else if(cmd->cmd==LC_SYMTAB){
			
			// This segment describes our symbol table, including where the symbols and the strings naming them are located. I believe it’s mostly for the benefit of the debugger.
				
			// Specifies the symbol table for this file. This information is used by both static and dynamic linkers when linking the file, and also by debuggers 
			// to map symbols to the original source code files from which the symbols were generated.
			const struct symtab_command* symtab = (struct symtab_command*)cmd;
			uint32_t symoff	= symtab->symoff;	// An integer containing the byte offset from the start of the file to the location of the symbol table entries. The symbol table is an array of nlist data structures.
			uint32_t nsyms	= symtab->nsyms;	// An integer indicating the number of entries in the symbol table.

			uint32_t stroff	= symtab->stroff;	// An integer containing the byte offset from the start of the image to the location of the string table.
			uint32_t strsize = symtab->strsize;	// An integer indicating the size (in bytes) of the string table.
			symtable_ptr = (struct nlist *)(symoff + codeAddr);
			strtable = (char *)(stroff + codeAddr);

//todo			[[FileMapView sharedMapView] addRegionAtOffset:symoff withSize:strsize label:[NSString stringWithFormat:@"LC_SYMTAB:symbols %i", strsize]];	
//todo			[[FileMapView sharedMapView] addRegionAtOffset:stroff withSize:strsize label:[NSString stringWithFormat:@"LC_SYMTAB:strings %i", strsize]];	
			
			for( NSInteger i=0; i<nsyms; i++)
			{
				struct nlist symbol = symtable_ptr[i];
				uint32_t n_value = symbol.n_value;	/* value of this symbol (or stab offset) */
				if(n_value){
					
					uint32_t stringIndex = (symbol.n_un.n_strx); // SwapLongIfNeeded
					uint8_t n_type = symbol.n_type;		/* type flag, see below */
					uint8_t n_sect = symbol.n_sect;		/* section number or NO_SECT */
					int16_t n_desc = symbol.n_desc;		/* see <mach-o/stab.h> */
					
					struct nlist_64 nlist64;
					nlist64.n_un.n_strx = stringIndex;
					nlist64.n_type = n_type;
					nlist64.n_sect = n_sect;
					nlist64.n_desc = n_desc; //SwapShortIfNeeded
					nlist64.n_value = (uint64_t)(n_value); //SwapLongIfNeeded

					if ([self processSymbolItem:&nlist64 stringTable:strtable])					
					{
					}
					
				}
				http://mhda.asiaa.sinica.edu.tw/mhda/apps/nemo-3.2.3-i386-intel9/src/kernel/loadobj/loadobjNEXT.c
				// see svn checkout http://iphone-dev.googlecode.com/svn/trunk/ iphone-dev-read-only

			/* Ignore the following kinds of Symbols */
			//					if ((!symtable->n_value)        /* Undefined */
			//						|| (symtable->n_type >= N_PEXT) /* Debug symbol */
			//						|| (!(symtable->n_type & N_EXT))        /* Local Symbol */
			//						)
			//					{
			//						symtable++;
									continue;
			//					}
			//					if ((addr >= symtable->n_value) && (diff >= (symtable->n_value - addr)))
			//					{
			//						diff = (unsigned long)symtable->n_value - addr;
			//						nearest = symtable;
			//					}
			//symtable++;
			}
			NSLog(@"LC_SYMTAB - number of table entries %i", symtab->nsyms );
			
		} else if(cmd->cmd==LC_DYSYMTAB){

			// This load command describes the dynamic symbol table. This is how the dynamic linker knows to plug the stubs (indirect).
			const struct dysymtab_command* dsymtab = (struct dysymtab_command*)cmd;
			NSLog(@"LC_DYSYMTAB");
			
			/*
			 * The symbols indicated by symoff and nsyms of the LC_SYMTAB load command
			 * are grouped into the following three groups:
			 *    local symbols (further grouped by the module they are from)
			 *    defined external symbols (further grouped by the module they are from)
			 *    undefined symbols
			 *
			 * The local symbols are used only for debugging.  The dynamic binding
			 * process may have to use them to indicate to the debugger the local
			 * symbols for a module that is being bound.
			 *
			 * The last two groups are used by the dynamic binding process to do the
			 * binding (indirectly through the module table and the reference symbol
			 * table when this is a dynamically linked shared library file).
			 */
			// uint32_t ilocalsym;	/* index to local symbols */
			// uint32_t nlocalsym;	/* number of local symbols */
			NSLog( @"-- Index to local symbols %i", dsymtab->ilocalsym );
			NSLog( @"-- Number of local symbols %i", dsymtab->nlocalsym );
			for( int i=dsymtab->ilocalsym; i<(dsymtab->ilocalsym+dsymtab->nlocalsym); i++)
			{
				struct nlist symbol = symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
				NSLog(@"Local Symbol > %@ - %@", src, address);
			}
// This is exactly what i want! http://www.google.com/codesearch/p?hl=en#G0qjcaxpHTc/sedarwin8/darwin/cctools/otool/ofile_print.c&q=ilocalsym%20nlocalsym			
			
			// uint32_t iextdefsym;/* index to externally defined symbols */
			// uint32_t nextdefsym;/* number of externally defined symbols */
			NSLog(@"-- Index of externally defined symbols %i", dsymtab->iextdefsym);
			NSLog(@"-- Number of externally defined symbols %i", dsymtab->nextdefsym);
			for( int i=dsymtab->iextdefsym; i<(dsymtab->iextdefsym+dsymtab->nextdefsym); i++)
			{
				struct nlist symbol = symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
				NSLog(@"External Symbol > %@ - %@", src, address);
			}
			
			// uint32_t iundefsym;	/* index to undefined symbols */
			//uint32_t nundefsym;	/* number of undefined symbols */
			NSLog(@"-- Index of externally undefined symbols %i", dsymtab->iundefsym);
			NSLog(@"-- Number of externally undefined symbols %i", dsymtab->nundefsym);
			for( int i=dsymtab->iundefsym; i<(dsymtab->iundefsym+dsymtab->nundefsym); i++)
			{
				struct nlist symbol = symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
				NSLog(@"External Undefined Symbol > %@ - %@", src, address);
			}
			
			/*
			 * For the for the dynamic binding process to find which module a symbol
			 * is defined in the table of contents is used (analogous to the ranlib
			 * structure in an archive) which maps defined external symbols to modules
			 * they are defined in.  This exists only in a dynamically linked shared
			 * library file.  For executable and object modules the defined external
			 * symbols are sorted by name and is use as the table of contents.
			 */
			// uint32_t tocoff;	/* file offset to table of contents */
			// uint32_t ntoc;	/* number of entries in table of contents */
			NSLog(@"-- Number of entries in table of contents %i", dsymtab->ntoc);
			
			// should this be offset from file? guess so
			struct dylib_table_of_contents *tocs_ptr = (struct dylib_table_of_contents *)(codeAddr + dsymtab->tocoff);
            for( int i=0; i<dsymtab->ntoc; i++){
				uint32_t si = tocs_ptr[i].symbol_index;
				uint32_t mi = tocs_ptr[i].module_index;
			}
			
			
			/*
			 * To support dynamic binding of "modules" (whole object files) the symbol
			 * table must reflect the modules that the file was created from.  This is
			 * done by having a module table that has indexes and counts into the merged
			 * tables for each module.  The module structure that these two entries
			 * refer to is described below.  This exists only in a dynamically linked
			 * shared library file.  For executable and object modules the file only
			 * contains one module so everything in the file belongs to the module.
			 */
			// uint32_t modtaboff;	/* file offset to module table */
			//uint32_t nmodtab;	/* number of module table entries */
			NSLog(@"-- Number of module table entries %i", dsymtab->nmodtab);
			if(dsymtab->nmodtab>0){
				struct dylib_reference *libRefer1 = (struct dylib_reference *)(codeAddr + dsymtab->modtaboff);
				for( int i=0; i<dsymtab->nmodtab; i++){
	//				uint32_t indirectSymbol = libRefer1[i];
	//				NSLog(@"DO THIS! IndirectSymbol %i", indirectSymbol);
				}
			}
			
			/*
			 * To support dynamic module binding the module structure for each module
			 * indicates the external references (defined and undefined) each module
			 * makes.  For each module there is an offset and a count into the
			 * reference symbol table for the symbols that the module references.
			 * This exists only in a dynamically linked shared library file.  For
			 * executable and object modules the defined external symbols and the
			 * undefined external symbols indicates the external references.
			 */
			// uint32_t extrefsymoff;	/* offset to referenced symbol table */
			//uint32_t nextrefsyms;	/* number of referenced symbol table entries */
			NSLog(@"-- Number of referenced symbol table entries %i", dsymtab->nextrefsyms);
			if(dsymtab->nextrefsyms>0){
				struct dylib_reference *libRefer2 = (struct dylib_reference *)(codeAddr + dsymtab->extrefsymoff);
				for( int i=0; i<dsymtab->nextrefsyms; i++){
					NSLog(@"DO THIS!");
				}
			}
			
			/*
			 * The sections that contain "symbol pointers" and "routine stubs" have
			 * indexes and (implied counts based on the size of the section and fixed
			 * size of the entry) into the "indirect symbol" table for each pointer
			 * and stub.  For every section of these two types the index into the
			 * indirect symbol table is stored in the section header in the field
			 * reserved1.  An indirect symbol table entry is simply a 32bit index into
			 * the symbol table to the symbol that the pointer or stub is referring to.
			 * The indirect symbol table is ordered to match the entries in the section.
			 */
			// uint32_t indirectsymoff; /* file offset to the indirect symbol table */
			//uint32_t nindirectsyms;  /* number of indirect symbol table entries */
			
			// The indirect symbol table tells the dynamic linker that elements 2 and 3 of the symbol table need to be looked up and their stubs plugged.
			NSLog(@"-- Number of indirect symbol table entries %i", dsymtab->nindirectsyms);
			// 19 x86
			if(dsymtab->nindirectsyms>0){
				const uint32_t* indirectTable = (uint32_t*)(codeAddr + dsymtab->indirectsymoff);
				for( int i=0; i<dsymtab->nindirectsyms; i++){
					uint32_t indirectSymbol = indirectTable[i];
					NSLog(@"DO THIS! IndirectSymbol %i", indirectSymbol);
				}
			}
			
			/*
			 * To support relocating an individual module in a library file quickly the
			 * external relocation entries for each module in the library need to be
			 * accessed efficiently.  Since the relocation entries can't be accessed
			 * through the section headers for a library file they are separated into
			 * groups of local and external entries further grouped by module.  In this
			 * case the presents of this load command who's extreloff, nextrel,
			 * locreloff and nlocrel fields are non-zero indicates that the relocation
			 * entries of non-merged sections are not referenced through the section
			 * structures (and the reloff and nreloc fields in the section headers are
			 * set to zero).
			 *
			 * Since the relocation entries are not accessed through the section headers
			 * this requires the r_address field to be something other than a section
			 * offset to identify the item to be relocated.  In this case r_address is
			 * set to the offset from the vmaddr of the first LC_SEGMENT command.
			 * For MH_SPLIT_SEGS images r_address is set to the the offset from the
			 * vmaddr of the first read-write LC_SEGMENT command.
			 *
			 * The relocation entries are grouped by module and the module table
			 * entries have indexes and counts into them for the group of external
			 * relocation entries for that the module.
			 *
			 * For sections that are merged across modules there must not be any
			 * remaining external relocation entries for them (for merged sections
			 * remaining relocation entries must be local).
			 */
			// uint32_t extreloff;	/* offset to external relocation entries */
			// uint32_t nextrel;	/* number of external relocation entries */
			NSLog(@"-- Number of external relocation entries %i", dsymtab->nextrel);
			if(dsymtab->nextrel>0){
				struct relocation_info *ext_relocs = (struct relocation_info *)(codeAddr + dsymtab->extreloff);
				int32_t addressOfSymbol = ext_relocs->r_address;
				NSLog(@"Relocate symbol %i", addressOfSymbol);
			}
			
			/*
			 * All the local relocation entries are grouped together (they are not
			 * grouped by their module since they are only used if the object is moved
			 * from it staticly link edited address).
			 */
			// uint32_t locreloff;	/* offset to local relocation entries */
			// uint32_t nlocrel;	/* number of local relocation entries */			
			NSLog(@"-- Number of of local relocation entries %i", dsymtab->nlocrel);
			if(dsymtab->nlocrel>0){
				struct relocation_info *loc_relocs = (struct relocation_info *)(codeAddr + dsymtab->locreloff);
				int32_t addressOfSymbol = loc_relocs->r_address;
				NSLog(@"Relocate symbol %i", addressOfSymbol);
			}
		
		} else if(cmd->cmd==LC_THREAD || cmd->cmd==LC_UNIXTHREAD){
			
			// This load command specifies the contents of the registers at startup. I haven’t seen anything other than EIP populated, though. The program will not run unless this load command is present!
			// For an executable file, the LC_UNIXTHREAD command defines the initial thread state of the main thread of the process. LC_THREAD is similar to LC_UNIXTHREAD but does not cause the kernel to allocate a stack.
			const struct thread_command* threadtab = (struct thread_command*)cmd;
			NSLog(@"LC_THREAD");
			
		} else if(cmd->cmd==LC_LOAD_DYLIB){
			// Defines the name of a dynamic shared library that this file links against.
			const struct dylib_command* seg = (struct dylib_command*)cmd;
			struct dylib dylib = seg->dylib;
			char *install_name = (char*)cmd + dylib.name.offset;
			// also got timestamp, version, compatibility version
			NSLog(@"LC_LOAD_DYLIB - %s", install_name);
			
		} else if(cmd->cmd==LC_ID_DYLIB){
			// Specifies the install name of a dynamic shared library.
			const struct dylib_command* seg = (struct dylib_command*)cmd;

			NSLog(@"LC_ID_DYLIB");
			
		} else if(cmd->cmd==LC_PREBOUND_DYLIB){
			// For a shared library that this executable is linked prebound against, specifies the modules in the shared library that are used.
			const struct prebound_dylib_command* seg = (struct prebound_dylib_command*)cmd;
			NSLog(@"LC_PREBOUND_DYLIB");
			
		} else if(cmd->cmd==LC_LOAD_DYLINKER){
			// Specifies the dynamic linker that the kernel executes to load this file.
			const struct dylinker_command* linkertab = (struct dylinker_command*)cmd;
			const char* dylibName = (char*)cmd + linkertab->name.offset;

			NSLog(@"LC_LOAD_DYLINKER %s", dylibName );
			
		} else if(cmd->cmd==LC_ID_DYLINKER){
			// Identifies this file as a dynamic linker.
			const struct dylinker_command* linkertab = (struct dylinker_command*)cmd;
			NSLog(@"LC_ID_DYLINKER");
			
		} else if(cmd->cmd==LC_ROUTINES){
			// Contains the address of the shared library initialization routine (specified by the linker’s -init option).
			const struct routines_command* seg = (struct routines_command*)cmd;
			NSLog(@"LC_ROUTINES");
			
		} else if(cmd->cmd==LC_ROUTINES_64){
			// Contains the address of the shared library 64-bit initialization routine (specified by the linker’s -init option).
			const struct routines_command_64* seg = (struct routines_command_64*)cmd;
			NSLog(@"LC_ROUTINES_64");
			
		} else if(cmd->cmd==LC_TWOLEVEL_HINTS){
			// Contains the two-level namespace lookup hint table.
			const struct twolevel_hints_command* seg = (struct twolevel_hints_command*)cmd;
			NSLog(@"LC_TWOLEVEL_HINTS");
			
		} else if(cmd->cmd==LC_SUB_FRAMEWORK){
			// Identifies this file as the implementation of a subframework of an umbrella framework. The name of the umbrella framework is stored in the string parameter.
			struct sub_framework_command *subf = (struct sub_framework_command *)cmd;
			const char* exportThruName = (char*)cmd + subf->umbrella.offset;
			NSLog(@"LC_SUB_FRAMEWORK");
			
		} else if(cmd->cmd==LC_SUB_UMBRELLA){
			// Specifies a file that is a subumbrella of this umbrella framework.
			const struct sub_umbrella_command* seg = (struct sub_umbrella_command *)cmd;
			NSLog(@"LC_SUB_UMBRELLA");
			
		} else if(cmd->cmd==LC_SUB_LIBRARY){
			// Defines the attributes of the LC_SUB_LIBRARY load command. Identifies a sublibrary of this framework and marks this framework as an umbrella framework.
			const struct sub_library_command* seg = (struct sub_library_command *)cmd;
			NSLog(@"LC_SUB_LIBRARY");
			
		} else if(cmd->cmd==LC_SUB_CLIENT){
			// A subframework can explicitly allow another framework or bundle to link against it by including an LC_SUB_CLIENT load command containing the name of the framework or a client name for a bundle.
			const struct sub_client_command* seg = (struct sub_client_command *)cmd;
			NSLog(@"LC_SUB_CLIENT");
			
		} else {
			if ( (cmd->cmd & LC_REQ_DYLD) != 0 ){
				NSLog(@"unknown required load command 0x%08X", cmd->cmd);
			}
		}

//		const struct load_command* nextCmd3 = (const struct load_command*)((uint32_t)cmd+(uint32_t)cmd->cmdsize);
//		const struct load_command* nextCmd4 = (struct load_command *)cmd+1;
//		cmd = nextCmd3;
	}
}

- (void)doIt:(NSString *)aPath {

	// path to this app
	NSData *allFile = [NSData dataWithContentsOfFile:aPath];
	codeAddr = [allFile bytes];
	codeSize = [allFile length];

	[[FileMapView sharedMapView] setTotalBoundsWithSize:codeSize label:[NSString stringWithFormat:@"total file size %i", codeSize]];

	/* Is the executable a FAT? */
	// FAT is always Big Endian - Extract relevant architecture and convert to native
	if( OSSwapBigToHostInt32(((const struct fat_header *) codeAddr)->magic)==FAT_MAGIC ) {
		
		struct fat_arch *fatArchArray;
		struct fat_header *fatHeader = (struct fat_header *)codeAddr;
		assert( codeSize >= sizeof(*fatHeader) );
		fatHeader->magic     = OSSwapBigToHostInt32(fatHeader->magic);
		fatHeader->nfat_arch = OSSwapBigToHostInt32(fatHeader->nfat_arch);
		
		assert(fatHeader->magic == FAT_MAGIC);
		assert(fatHeader->nfat_arch > 0);
		assert( codeSize >= (sizeof(*fatHeader) + (sizeof(*fatArchArray) * fatHeader->nfat_arch)) );

		// Convert each element of the fat arch array to host byte order.
		
		fatArchArray = (struct fat_arch *) (fatHeader + 1);
		for( uint32_t archIndex = 0; archIndex<fatHeader->nfat_arch; archIndex++ ) {
			fatArchArray[archIndex].cputype    = OSSwapBigToHostInt32(fatArchArray[archIndex].cputype);
			fatArchArray[archIndex].cpusubtype = OSSwapBigToHostInt32(fatArchArray[archIndex].cpusubtype);
			fatArchArray[archIndex].offset     = OSSwapBigToHostInt32(fatArchArray[archIndex].offset);
			fatArchArray[archIndex].size       = OSSwapBigToHostInt32(fatArchArray[archIndex].size);
			fatArchArray[archIndex].align      = OSSwapBigToHostInt32(fatArchArray[archIndex].align);
		}
		
		// Get the currently running architecture.
		const NXArchInfo *ourArch = NXGetLocalArchInfo();
		assert(ourArch != NULL);
		
		// Find the best match within the bundle's list of architectures.
		struct fat_arch *bestFatArch = NXFindBestFatArch( ourArch->cputype, ourArch->cpusubtype, fatArchArray, fatHeader->nfat_arch );
		
		// Create a new buffer with a copy of the best match.
		if (bestFatArch == NULL) {
			fprintf(stderr, "There is no appropriate architecture within the fat file.\n");
		} else {
			// We don't handle special alignments.  If the code we're going to use needs 
			// to be more aligned that page aligned, we're in trouble.
			assert( (1 << bestFatArch->align) <= getpagesize() );
			
			// The code we're going to use must actually be within the code buffer, 
			// otherwise we're really in the weeds.
			assert(bestFatArch->size <= codeSize);
			assert(bestFatArch->offset <= codeSize);
			assert( (bestFatArch->size + bestFatArch->offset) <= codeSize );
			
			uint32_t newCodeSize = bestFatArch->size;
			void *newCodeAddr = NULL;
			
			int err = (int) vm_allocate(mach_task_self(), (vm_address_t *) &newCodeAddr, newCodeSize, true);
			if (err == 0) {
				memcpy(newCodeAddr, ((char *) (codeAddr)) + bestFatArch->offset , newCodeSize);
			}
			codeAddr = newCodeAddr;
			codeSize = newCodeSize;
		}
	}
	struct mach_header *machHeader = (struct mach_header *)codeAddr;
	NSInteger mach_headerOffset = (NSInteger)((NSInteger *)machHeader)-(NSInteger)((NSInteger *)codeAddr);
	NSInteger mach_headerSize = sizeof(*machHeader);
	[[FileMapView sharedMapView] addRegionAtOffset:mach_headerOffset withSize:mach_headerSize label:[NSString stringWithFormat:@"Header %i", mach_headerSize]];
	
	/* Is the architecture correct for this machine? */
	if( machHeader->magic==MH_MAGIC )
	{
		if(machHeader->cputype==CPU_TYPE_POWERPC)
			NSLog(@"PPC");
		else if(machHeader->cputype==CPU_TYPE_I386)
			NSLog(@"INTEL");
		else
			NSLog(@"UNKNOWN ARCHITECTURE");
		
		// cpusubtype = CPU_SUBTYPE_POWERPC_ALL || CPU_SUBTYPE_I386_ALL
		// filetype = MH_OBJECT || MH_EXECUTE || MH_BUNDLE || MH_DYLIB || MH_PRELOAD || MH_CORE || MH_DYLINKER || MH_DSYM
		if(machHeader->filetype==MH_EXECUTE){
			NSLog(@"Inside the guts of an executable");
		}
		uint32_t ncmds = machHeader->ncmds;
		uint32_t sizeofcmds_bytes = machHeader->sizeofcmds;
		NSLog(@"sizeofcmds_bytes: %u", sizeofcmds_bytes);
		uint32_t flags = machHeader->flags; // MH_FORCE_FLAT etc
		readHeaderFlags(flags);
		
		/* Move on past the header */
		const struct load_command* const cmds1 = (struct load_command *)&codeAddr[sizeof(struct mach_header)];
		NSInteger loadCommandsOffset = (NSInteger)((NSInteger *)cmds1)-(NSInteger)((NSInteger *)codeAddr);
		[[FileMapView sharedMapView] addRegionAtOffset:loadCommandsOffset withSize:sizeofcmds_bytes label:[NSString stringWithFormat:@"Load Commands %i", sizeofcmds_bytes]];		
		
		const struct load_command* cmd = cmds1;
		// http://developer.apple.com/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html
		for(int i=0; i<ncmds; i++)
		{
			[_loadCommands addObject:[NSNumber numberWithUnsignedInteger:(NSUInteger)cmd]];
			cmd = (const struct load_command*)((uint32_t)cmd+(uint32_t)cmd->cmdsize);
		}
	}
}


// -- see cctools-782 otool ofile_print.c
void
print_cstring_section(
					  char *sect,
					  uint32_t sect_size,
					  uint32_t sect_addr,
					  enum bool print_addresses)
{
    uint32_t i;
	
	for(i = 0; i < sect_size ; i++){
	    if(print_addresses == TRUE)
			printf("%08x  ", (unsigned int)(sect_addr + i));
		
	    for( ; i < sect_size && sect[i] != '\0'; i++)
			print_cstring_char(sect[i]);
	    if(i < sect_size && sect[i] == '\0')
			printf("\n");
	}
}

static
void
print_cstring_char(
				   char c)
{
	if(isprint(c)){
	    if(c == '\\')	/* backslash */
			printf("\\\\");
	    else		/* all other printable characters */
			printf("%c", c);
	}
	else{
	    switch(c){
			case '\n':		/* newline */
				printf("\\n");
				break;
			case '\t':		/* tab */
				printf("\\t");
				break;
			case '\v':		/* vertical tab */
				printf("\\v");
				break;
			case '\b':		/* backspace */
				printf("\\b");
				break;
			case '\r':		/* carriage return */
				printf("\\r");
				break;
			case '\f':		/* formfeed */
				printf("\\f");
				break;
			case '\a':		/* audiable alert */
				printf("\\a");
				break;
			default:
				printf("\\%03o", (unsigned int)c);
	    }
	}
}

@end
