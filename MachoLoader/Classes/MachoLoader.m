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
#import "SymbolicInfo.h"
#import "IntKeyDictionary.h"
#import "MemoryBlockStore.h"
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
#import "MemoryMap.h"
#import "Segment.h"
#import "Section.h"

// http://developer.apple.com/samplecode/Carbon/idxRuntimeArchitecture-date.html

@interface MachoLoader (PrivateMethods) 
- (void)doIt:(NSString *)aPath;
- (void)parseLoadCommands;
- (void)addFunction:(NSString *)name line:(int)line address:(uint64_t)address section:(int)section;

@end

@implementation MachoLoader

void system_fatal( const char *format,  ...) {
    va_list ap;
	va_start(ap, format);
	fprintf(stderr, "%s: ", "Hoo");
	vfprintf(stderr, format, ap);
	fprintf(stderr, " (%s)\n", strerror(errno));
	va_end(ap);
	exit(1);
}

void * allocate( size_t size ) {
    void *p;
	
	if(size == 0)
	    return(NULL);
	if((p = malloc(size)) == NULL)
	    system_fatal("virtual memory exhausted (malloc failed)");
	return(p);
}

void * reallocate( void *p, size_t size ) {
	if(p == NULL)
	    return(allocate(size));
	if((p = realloc(p, size)) == NULL)
	    system_fatal("virtual memory exhausted (realloc failed)");
	return(p);
}


static void print_cstring_char( char c ) {
	
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

// -- see cctools-782 otool ofile_print.c
void print_cstring_section(char *sect, uint32_t sect_size, uint32_t sect_addr ) {
		
	for( uint32_t i=0; i<sect_size; i++ )
	{
		NSUInteger cStringAddress = (NSUInteger)(sect_addr + i);
		printf("%08x  ", cStringAddress );

	    for( ; i<sect_size && sect[i] !='\0'; i++ ){
			print_cstring_char(sect[i]);
		}
		
		if(i<sect_size && sect[i]=='\0' )
			printf("\n");
	}
}

// -- see cctools-782 otool ofile_print.c
- (void)save_cstring_section:(char *)sect :(uint32_t)sect_size :(uint32_t)sect_addr {
	
	char aCstring[256];
	memset ( aCstring, 0, 256 );
	uint32_t length = 0;

	for( uint32_t i=0; i<sect_size; i++ )
	{
		NSUInteger cStringAddress = (NSUInteger)(sect_addr + i);
		// printf("%08x  ", cStringAddress );

		memset ( aCstring, 0, length );
		length = 0;
		
	    for( ; i<sect_size && sect[i] !='\0'; i++ ){
//			print_cstring_char(sect[i]);
			aCstring[length] = sect[i];
			length++;
		}
		NSString *strVal = [NSString stringWithCString:aCstring encoding:NSUTF8StringEncoding];
		if(strVal==nil)
			strVal = @"";
		[self addCstring:strVal forAddress:cStringAddress];
		
//	    if(i<sect_size && sect[i]=='\0' )
//			printf("\n");
	}
}

extern char *__cxa_demangle(const char* __mangled_name, char* __output_buffer, size_t* __length, int* __status);
/*
 * Print the indirect symbol table.
 */
- (void)print_indirect_symbols:(struct load_command *)load_commands :(uint32_t)ncmds :(uint32_t)sizeofcmds :(cpu_type_t)cputype
							//					   enum byte_sex load_commands_byte_sex,
							:(uint32_t *)indirect_symbols
							:(uint32_t)nindirect_symbols
							:(struct nlist *)symbols
							:(struct nlist_64 *)symbols64
							:(uint32_t)nsymbols
							:(char *)strings
							:(uint32_t)strings_size //,
							//					   enum bool verbose

{
	//    enum byte_sex host_byte_sex;
	//    enum bool swapped;
    uint32_t i, j, k, left, size, nsects, n, count, stride, section_type;
    uint64_t bigsize, big_load_end;
    char *p;
    struct load_command *lc, l;
    struct segment_command sg;
    struct section s;
    struct segment_command_64 sg64;
    struct section_64 s64;
    struct section_indirect_info {
		char segname[16];
		char sectname[16];
		uint64_t size;
		uint64_t addr;
		uint32_t reserved1;
		uint32_t reserved2;
		uint32_t flags;
    } *sect_ind;
    uint32_t n_stringIndex;
	
	sect_ind = NULL;
	//	host_byte_sex = get_host_byte_sex();
	//	swapped = host_byte_sex != load_commands_byte_sex;
	
	/*
	 * Create an array of section structures in the host byte sex so it
	 * can be processed and indexed into directly.
	 */
	k = 0;
	nsects = 0;
	lc = load_commands;
	big_load_end = 0;
	for( i=0; i<ncmds; i++ )
	{
	    memcpy((char *)&l, (char *)lc, sizeof(struct load_command));
		//	    if(swapped)
		//			swap_load_command(&l, host_byte_sex);
	    if(l.cmdsize % sizeof(int32_t) != 0)
			printf("load command %u size not a multiple of sizeof(int32_t)\n", i);
	    big_load_end += l.cmdsize;
	    if(big_load_end > sizeofcmds)
			printf("load command %u extends past end of load commands\n", i);
	    left = sizeofcmds - ((char *)lc - (char *)load_commands);
		
	    switch(l.cmd)
		{
			case LC_SEGMENT:
				memset((char *)&sg, '\0', sizeof(struct segment_command));
				size = left < sizeof(struct segment_command) ?
				left : sizeof(struct segment_command);
				left -= size;
				memcpy((char *)&sg, (char *)lc, size);
				//				if(swapped)
				//					swap_segment_command(&sg, host_byte_sex);
				bigsize = sg.nsects;
				bigsize *= sizeof(struct section);
				bigsize += size;
				if(bigsize > sg.cmdsize){
					printf("number of sections in load command %u extends past end of load commands\n", i);
					sg.nsects = (sg.cmdsize-size) / sizeof(struct section);
				}
				nsects += sg.nsects;
				sect_ind = reallocate(sect_ind, nsects * sizeof(struct section_indirect_info));
				memset((char *)(sect_ind + (nsects - sg.nsects)), '\0', sizeof(struct section_indirect_info) * sg.nsects);
				p = (char *)lc + sizeof(struct segment_command);
				for(j = 0 ; j < sg.nsects ; j++)
				{
					left = sizeofcmds - (p - (char *)load_commands);
					size = left < sizeof(struct section) ?
					left : sizeof(struct section);
					memcpy((char *)&s, p, size);
					//					if(swapped)
					//						swap_section(&s, 1, host_byte_sex);
					
					if(p + sizeof(struct section) >
					   (char *)load_commands + sizeofcmds)
						break;
					p += size;
					memcpy(sect_ind[k].segname, s.segname, 16);
					memcpy(sect_ind[k].sectname, s.sectname, 16);
					sect_ind[k].size = s.size;
					sect_ind[k].addr = s.addr;
					sect_ind[k].reserved1 = s.reserved1;
					sect_ind[k].reserved2 = s.reserved2;
					sect_ind[k].flags = s.flags;
					k++;
				}
				break;
			case LC_SEGMENT_64:
				memset((char *)&sg64, '\0', sizeof(struct segment_command_64));
				size = left < sizeof(struct segment_command_64) ? left : sizeof(struct segment_command_64);
				memcpy((char *)&sg64, (char *)lc, size);
				//				if(swapped)
				//					swap_segment_command_64(&sg64, host_byte_sex);
				bigsize = sg64.nsects;
				bigsize *= sizeof(struct section_64);
				bigsize += size;
				if(bigsize > sg64.cmdsize){
					printf("number of sections in load command %u extends past end of load commands\n", i);
					sg64.nsects = (sg64.cmdsize-size) / sizeof(struct section_64);
				}
				nsects += sg64.nsects;
				sect_ind = reallocate(sect_ind, nsects * sizeof(struct section_indirect_info));
				memset((char *)(sect_ind + (nsects - sg64.nsects)), '\0', sizeof(struct section_indirect_info) * sg64.nsects);
				p = (char *)lc + sizeof(struct segment_command_64);
				for( j=0 ; j<sg64.nsects; j++ )
				{
					left = sizeofcmds - (p - (char *)load_commands);
					size = left < sizeof(struct section_64) ? left : sizeof(struct section_64);
					memcpy((char *)&s64, p, size);
					//					if(swapped)
					//						swap_section_64(&s64, 1, host_byte_sex);
					
					if(p + sizeof(struct section) >
					   (char *)load_commands + sizeofcmds)
						break;
					p += size;
					memcpy(sect_ind[k].segname, s64.segname, 16);
					memcpy(sect_ind[k].sectname, s64.sectname, 16);
					sect_ind[k].size = s64.size;
					sect_ind[k].addr = s64.addr;
					sect_ind[k].reserved1 = s64.reserved1;
					sect_ind[k].reserved2 = s64.reserved2;
					sect_ind[k].flags = s64.flags;
					k++;
				}
				break;
	    }
	    if(l.cmdsize == 0){
			printf("load command %u size zero (can't advance to other load commands)\n", i);
			break;
	    }
	    lc = (struct load_command *)((char *)lc + l.cmdsize);
	    if((char *)lc > (char *)load_commands + sizeofcmds)
			break;
	}
	if((char *)load_commands + sizeofcmds != (char *)lc)
	    printf("Inconsistent sizeofcmds\n");
	
	for( i=0; i<nsects; i++ )
	{
	    section_type = sect_ind[i].flags & SECTION_TYPE;
	    if(section_type == S_SYMBOL_STUBS)
		{
			stride = sect_ind[i].reserved2;
			if(stride == 0){
				printf("Can't print indirect symbols for (%.16s,%.16s) (size of stubs in reserved2 field is zero)\n", sect_ind[i].segname, sect_ind[i].sectname);
				continue;
			}
	    }
		else if(section_type == S_LAZY_SYMBOL_POINTERS || section_type == S_NON_LAZY_SYMBOL_POINTERS || section_type == S_LAZY_DYLIB_SYMBOL_POINTERS)
		{
			if(cputype & CPU_ARCH_ABI64)
				stride = 8;
			else
				stride = 4;
	    }
	    else
			continue;
		
	    count = sect_ind[i].size / stride;
//	    printf("Indirect symbols for (%.16s,%.16s) %u entries", sect_ind[i].segname, sect_ind[i].sectname, count);
		
	    n = sect_ind[i].reserved1;
//	    if(n > nindirect_symbols)
//			printf(" (entries start past the end of the indirect symbol table) (reserved1 field greater than the table size)");
//	    else if(n + count > nindirect_symbols)
//			printf(" (entries extends past the end of the indirect symbol table)");
//	    if(cputype & CPU_ARCH_ABI64)
//			printf("\naddress            index");
//	    else
//			printf("\naddress    index");
		//	    if(verbose)
//		printf(" name\n");
		//	    else
		//			printf("\n");
		
	    for( j=0; j<count && n+j<nindirect_symbols; j++ )
		{
			SymbolicInfo *symbolInfo = [[[SymbolicInfo alloc] init] autorelease];
			symbolInfo.segmentName = [NSString stringWithCString:sect_ind[i].segname encoding:NSUTF8StringEncoding];
			symbolInfo.sectionName = [NSString stringWithCString:sect_ind[i].sectname encoding:NSUTF8StringEncoding];
			
			if(cputype & CPU_ARCH_ABI64) {
				symbolInfo.address = sect_ind[i].addr + j * stride;
				// printf("0x%016llx ", sect_ind[i].addr + j * stride);
			} else {
				symbolInfo.address = (uint32_t)(sect_ind[i].addr + j * stride);
				// printf("0x%08x ",(uint32_t)(sect_ind[i].addr + j * stride));
			}
			
			if( indirect_symbols[j + n]==INDIRECT_SYMBOL_LOCAL)
			{
				// Doesn't have an index into the string table
				// printf("LOCAL\n");
				symbolInfo.stringValue = @"LOCAL";
				[_indirectSymbolLookup addObject:symbolInfo forIntKey:symbolInfo.address];
				continue;
			}
			if(indirect_symbols[j + n] == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)){
				// printf("LOCAL ABSOLUTE\n");
				symbolInfo.stringValue = @"LOCAL ABSOLUTE";
				[_indirectSymbolLookup addObject:symbolInfo forIntKey:symbolInfo.address];
				continue;
			}
			if(indirect_symbols[j + n] == INDIRECT_SYMBOL_ABS){
				/* 
				 * Used for unused slots in the i386 __jump_table 
				 * and for image-loader-cache slot for new lazy
				 * symbol binding in Mac OS X 10.6 and later
				 */ 
				// printf("ABSOLUTE\n");
				symbolInfo.stringValue = @"ABSOLUTE";
				[_indirectSymbolLookup addObject:symbolInfo forIntKey:symbolInfo.address];
				continue;
			}
			NSUInteger symbolIndex = indirect_symbols[j+n];
			
//			printf("%5u ", indirect_symbols[j + n]);
			//			if(verbose){
//			if(indirect_symbols[j + n] >= nsymbols || (symbols == NULL && symbols64 == NULL) || strings == NULL)
//				printf("?\n");
//			else {
				if( symbols!= NULL ) {
					
					struct nlist symb = symbols[indirect_symbols[j+n]];
					
					n_stringIndex = symb.n_un.n_strx;
					uint32_t n_value = symb.n_value;				/* value of this symbol (or stab offset) */
					uint8_t n_type = symb.n_type;					/* type flag, see below */
					uint8_t n_sect = symb.n_sect;					/* section number or NO_SECT */
					int16_t n_desc = symb.n_desc;					/* see <mach-o/stab.h> */
						
					struct nlist_64 nlist64;
					nlist64.n_un.n_strx = n_stringIndex;
					nlist64.n_type = n_type;
					nlist64.n_sect = n_sect;
					nlist64.n_desc = n_desc;
					nlist64.n_value = (uint64_t)(n_value);

					uint32_t libraryIndex = GET_LIBRARY_ORDINAL(nlist64.n_desc);
					if( libraryIndex!=0 )
					{
						if( libraryIndex==EXECUTABLE_ORDINAL)
							symbolInfo.libraryName = @"(from executable)";
						else if( libraryIndex==DYNAMIC_LOOKUP_ORDINAL)
							symbolInfo.libraryName = @"(dynamically looked up)";
						else { 
							NSString *libraryInstallName = [self lookupLibrary:libraryIndex];
							symbolInfo.libraryName = libraryInstallName;
						}
					}

//					[self processSymbolItem:&nlist64 stringTable:strings];
						
				} else {
					struct nlist_64 symb = symbols64[indirect_symbols[j+n]];
					n_stringIndex = symb.n_un.n_strx;
					
//					[self processSymbolItem:&symb stringTable:strings];
					
					// TODO: 64bit support
				}
				
//				if( n_stringIndex >= strings_size ) {
//					printf("?\n");
//				} else {
			
					// assert first char is _ the remove it
					char *symbolString = strings+n_stringIndex;
					size_t len = strlen(symbolString);
					NSAssert(len>1, @"Function name seems wrong");
					char firstChar = symbolString[0];
					NSAssert(firstChar=='_', @"Function name seems wrong");
					// remove first char
					symbolString++;
			
					int demangledStat;
					char demangledOutput[256];
					size_t demangledLength;
			
					char *demangledName = __cxa_demangle( (const char *)symbolString, demangledOutput, &demangledLength, &demangledStat );
					switch (demangledStat) {
						case 0:
							symbolInfo.stringValue = [NSString stringWithCString:demangledName encoding:NSUTF8StringEncoding];
							//free(demangledName);
							// TODO: we may want to record the fact that it is c++
							break;
						case -1:
							[NSException raise:@"Memory Error" format:@""];
							break;
						case -2:
							symbolInfo.stringValue = [NSString stringWithCString:symbolString encoding:NSUTF8StringEncoding];
							break;
						case -3:
							[NSException raise:@"invalid argument" format:@""];
							break;
						default:
							break;
					}
				
					[_indirectSymbolLookup addObject:symbolInfo forIntKey:symbolInfo.address];
//				}
	
//			}
			//			}
			//			else
			//				printf("\n");
	    }
	    n += count;
	}
}


- (id)initWithPath:(NSString *)aPath {

	self = [super init];
	if(self) {
		_filePath = [aPath retain];

		_loadCommandsArray = [[NSMutableArray array] retain];
		addresses_ = [[NSMutableDictionary alloc] init];
		_memoryMap = [[MemoryMap alloc] init];
		_uncodedMemoryMap = [[MemoryMap alloc] init];
		
		_indirectSymbolLookup	= [[IntKeyDictionary alloc] init];
		_cStringLookup			= [[IntKeyDictionary alloc] init];

		_libraries = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
		
	[_filePath release];
	[_memoryMap release];
	[_uncodedMemoryMap release];
	[addresses_ release];
	[_indirectSymbolLookup release];
	[_cStringLookup release];
	[_libraries release];
	[super dealloc];
}

- (void)readFile {

	[self doIt:_filePath];
	[self parseLoadCommands];
	[self print_indirect_symbols:_startOfLoadCommandsPtr 
								:_ncmds 
								:_sizeofcmds 
								:_cputype
								:_indirectSymbolTable
								:_nindirect_symbols
								:_symtable_ptr
								:_UNUSED_symbols64
								:_nsymbols
								:_strtable
								:_strings_size];	
}

- (SymbolicInfo *)symbolicInfoForAddress:(NSUInteger)memAddr {

	Segment *seg = [_memoryMap segmentForAddress:memAddr];
	Section *sec = [_memoryMap sectionForAddress:memAddr];
	SymbolicInfo *si=nil;
	
	if( seg==nil && sec==nil )
	{
	// TODO:
	// is this address in the app? where is it jumping to?
	// jne 0x100002b3d
		NSAssert( memAddr>[_memoryMap lastAddress], @"value seems to be in a hole");
		
		// so what about all the other parts of the macho file? are they loaded into memory?
		NSAssert( memAddr> _codeSize, @"value is within app");

	}
	
	// NSLog(@"%@ %@", [seg name], [sec name]);
	
	// think these are function pointers
	if( [[seg name] isEqualToString:@"__IMPORT"] ) {
		
		si = (SymbolicInfo *)[_indirectSymbolLookup objectForIntKey:memAddr];
		NSAssert( [[seg name] isEqualToString:[si segmentName]], nil ); 
		NSAssert( [[sec name] isEqualToString:[si sectionName]], nil );
		
	//	NSLog( @"INDIRECT SYMBOL: %@ %@",  si.libraryName, si.stringValue );
		return si;
		
		// (undefined) external _mach_init_routine (from libSystem)
		// (undefined) external __cthread_init_routine (from libSystem)
		// (undefined [lazy bound]) external ___keymgr_dwarf2_register_sections (from libSystem)
	}
	
	// Read Only
	else if( [[seg name] isEqualToString:@"__TEXT"] ) {
		
		si = (SymbolicInfo *)[_indirectSymbolLookup objectForIntKey:memAddr];
		NSAssert(si==nil, @"didnt know this could be an indirect symbol");
		
		if( [[sec name] isEqualToString:@"__eh_frame"] ) {
			si = [[[SymbolicInfo alloc] init] autorelease];
			si.segmentName = [seg name];
			si.sectionName = [sec name];
			return si;

		} else if( [[sec name] isEqualToString:@"__text"] ) {
			
		} else if( [[sec name] isEqualToString:@"__StaticInit"] ) {

		} else if( [[sec name] isEqualToString:@"__const"] ) {
			
		} else if( [[sec name] isEqualToString:@"__literal4"] ) {
			// 4 byte literals
			UInt8 *memPtr = (UInt8 *)sec.startAddr;
			UInt8 *locPtr = (UInt8 *)sec.sect_pointer;
			NSUInteger newSectSize = sec.length;
			UInt8 *a4ByteLiteralAddress = locPtr+((UInt8 *)memAddr-memPtr);
			NSAssert( a4ByteLiteralAddress<(((UInt8 *)sec.sect_pointer)+newSectSize), @"out of bounds");
			float a4ByteLiteralFloat;
			memcpy((char *)&a4ByteLiteralFloat, a4ByteLiteralAddress, sizeof(float));
//			NSLog(@"%f", a4ByteLiteralFloat);
			si = [[[SymbolicInfo alloc] init] autorelease];
			si.segmentName = [seg name];
			si.sectionName = [sec name];
			si.floatValue = a4ByteLiteralFloat;
			return si;
//			00ba9d98  0xfffffff9 (non-signaling Not-a-Number)

			return si;
			
		} else if( [[sec name] isEqualToString:@"__cstring"] ) {
			si = [[[SymbolicInfo alloc] init] autorelease];
			si.segmentName = [seg name];
			si.sectionName = [sec name];
			si.stringValue = [self CStringForAddress:memAddr];
//			NSLog(@"hmm %@", si.stringValue);
			return si;
	
		} else if( [[sec name] isEqualToString:@"__literal8"] ) {
			UInt8 *memPtr = (UInt8 *)sec.startAddr;
			UInt8 *locPtr = (UInt8 *)sec.sect_pointer;
			NSUInteger newSectSize = sec.length;
			UInt8 *a4ByteLiteralAddress = locPtr+((UInt8 *)memAddr-memPtr);
			NSAssert( a4ByteLiteralAddress<(((UInt8 *)sec.sect_pointer)+newSectSize), @"out of bounds");
			double a4ByteLiteralDouble;
			memcpy((char *)&a4ByteLiteralDouble, a4ByteLiteralAddress, sizeof(double));
			si = [[[SymbolicInfo alloc] init] autorelease];
			si.segmentName = [seg name];
			si.sectionName = [sec name];
			si.floatValue = a4ByteLiteralDouble;
			return si;
			//  0xfffff8f7 0x3fefffff (non-signaling Not-a-Number)

		} else if( sec==nil ) {
			
			NSAssert( [self CStringForAddress:memAddr]==nil, @"Hmm" );

			// why is this showing up as pushl $ __TEXT:(null) = 4096 so i thing that this could well be Null!, but maybe not!
			// pushl $0x00001000 
//			NSLog(@"Text Null %0x", memAddr); // 1000, 17e4, 17e0, 2000, 1fff, 1818, 104d, 1fb1, 1f5e
		} else {
			[NSException raise:@"Unknown request" format:@"%@", [sec name]];
		}
	
	} 
	
	
	return nil;
	
	if( [[seg name] isEqualToString:@"__DATA"] ) {
		// Read and write - we have a problemo!
		if( [[sec name] isEqualToString:@"__data"] ) {
			// return NO;
		}

	} else if( [[seg name] isEqualToString:@"__DATA"] ) {

	} else if( [[seg name] isEqualToString:@"__PAGEZERO"] ) {

	} else {
		[NSException raise:@"Unknown request" format:@"%@ %@", [seg name], [sec name]];
	}

	 
//	if(si) {
//		// lets see if the indirect symbol table is only for __jump_table & __pointers
//		NSAssert( [[seg name] isEqualToString:@"__IMPORT"] && ([[sec name] isEqualToString:@"__pointers"] || [[sec name] isEqualToString:@"__jump_table"]), @"seems like indirect symbol table is more than IMPORT");
//	}
		
	if( seg ) {
		if(si==nil) {

		}
		if(sec) {
			if( [si sectionName] ) {
			} else {
			}
		}
	}
	return si;
}

// record positions of file sections
- (void)addSegment:(NSString *)title memAddress:(NSUInteger)offset length:(uint32_t)size {
	
	Segment *newSeg = [Segment name:title start:offset length:size];
	[_memoryMap insertSegment:newSeg];
}

- (void)addSection:(NSString *)title seg:(NSString *)segTitle start:(NSUInteger)offset length:(uint32_t)size filePtr:(NSUInteger)filePtr {

	Section *newSec = [Section name:title segment:segTitle start:offset length:size fileAddr:filePtr];
	[_memoryMap insertSection:newSec];
}

- (void)readHeaderFlags:(uint32_t)flags {
	
	if( flags & MH_NOUNDEFS ){
		// MH_NOUNDEFS—The object file contained no undefined references when it was built.
//		NSLog(@"MH_NOUNDEFS");
	} if( flags & MH_INCRLINK ){
		// MH_INCRLINK—The object file is the output of an incremental link against a base file and cannot be linked again.
//		NSLog(@"MH_INCRLINK");
	} if( flags & MH_DYLDLINK ){
		// MH_DYLDLINK—The file is input for the dynamic linker and cannot be statically linked again.
//		NSLog(@"MH_DYLDLINK");
	} if( flags & MH_BINDATLOAD ){
		// MH_BINDATLOAD—The dynamic linker should bind the undefined references when the file is loaded.
//		NSLog(@"MH_BINDATLOAD");
	} if( flags & MH_PREBOUND ){
		// MH_PREBOUND—The file’s undefined references are prebound.
//		NSLog(@"MH_PREBOUND");
	} if( flags & MH_SPLIT_SEGS ){
		// MH_SPLIT_SEGS—The file has its read-only and read-write segments split.
//		NSLog(@"MH_SPLIT_SEGS");
	} if( flags & MH_TWOLEVEL ){
		// MH_TWOLEVEL—The image is using two-level namespace bindings.
		_MH_TWOLEVEL = YES;

	} if( flags & MH_FORCE_FLAT ){
		// MH_FORCE_FLAT—The executable is forcing all images to use flat namespace bindings.
		_MH_FORCE_FLAT = YES;

	} if( flags & MH_SUBSECTIONS_VIA_SYMBOLS ){
		// MH_SUBSECTIONS_VIA_SYMBOLS—The sections of the object file can be divided into individual blocks. These blocks are dead-stripped if they are not used by other code. See “Dead-Code Stripping” in Xcode Build System for details.
//		NSLog(@"MH_SUBSECTIONS_VIA_SYMBOLS");
	}
}

- (void)addFunction:(NSString *)name line:(int)line address:(uint64_t)address section:(int)section {
	
//	NSLog(@"Function %@ - Line %i - Address %x - Section %i", name, line, address, section);
	
	//-- try in the file
	char *func_pointer = ((char *)_codeAddr) + address;
	NSData *sectionData = [NSData dataWithBytes:func_pointer length:16];
//	NSLog(@"Copied section.. %@", sectionData); // [sectionData hexString]		

	
	
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
	uint32_t n_stringIndex = list->n_un.n_strx;
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
	
	// TODO - use this TWOLEVEL STUFF
	if( (((list->n_type & N_TYPE)==N_UNDF && list->n_value == 0) || (list->n_type & N_TYPE) == N_PBUD)) // ((mh_flags & MH_TWOLEVEL)==MH_TWOLEVEL) && 
	{
		uint32_t library_ordinal = GET_LIBRARY_ORDINAL(list->n_desc);
		if(library_ordinal != 0)
		{
			if( library_ordinal==EXECUTABLE_ORDINAL)
				printf(" (from executable)");
			else if( library_ordinal==DYNAMIC_LOOKUP_ORDINAL)
				printf(" (dynamically looked up)");
			else { 
				
//				NSLog(@"shit! this tells us the library? %i", library_ordinal);
//				if(library_ordinal-1 >= process_flags->nlibs)
//				printf(" (from bad library ordinal %u)", library_ordinal);
//			else
//				printf(" (from %s)", process_flags->lib_names[library_ordinal-1]);
			}
		}
	}
	
	// We don't care about non-section specific information except function length
//	if( list->n_sect==0 && list->n_type != N_FUN )
//		return NO;
	
	if (list->n_type == N_FUN) {
		if (list->n_sect != 0) {
			// we get the function address from the first N_FUN
			lastStartAddress_ = list->n_value;
		}
		else {
			// an N_FUN from section 0 may follow the initial N_FUN
			// giving us function length information
			NSNumber *key = [NSNumber numberWithUnsignedLong:(unsigned long)lastStartAddress_];
			NSMutableDictionary *dict = [addresses_ objectForKey:key];
			
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
		NSString *src = [NSString stringWithUTF8String:&table[n_stringIndex]];
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
		NSString *fn = [NSString stringWithUTF8String:&table[n_stringIndex]];
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
		NSString *fn = [NSString stringWithUTF8String:&table[n_stringIndex]];
		
		[self addFunction:fn line:0 address:list->n_value section:list->n_sect ];
		result = YES;
	}
	
	return result;
}

- (void)addLibrary:(NSString *)libraryInstallName {
	
//	NSLog( @"LC_LOAD_DYLIB - %@", libraryInstallName );
	[_libraries addObject:libraryInstallName];
}

- (NSString *)lookupLibrary:(NSUInteger)libraryIndex {
	
	NSParameterAssert( libraryIndex>0 );
	NSAssert( libraryIndex <= [_libraries count], @"library fuck up" );
	return [_libraries objectAtIndex:libraryIndex-1];
}

- (void)addCstring:(NSString *)aCstring forAddress:(NSUInteger)cStringAddress {

	[_cStringLookup addObject:aCstring forIntKey:cStringAddress];
}

- (NSString *)CStringForAddress:(NSUInteger)addr {

	return (NSString *)[_cStringLookup objectForIntKey:addr];
}

//- (void)addUnDecodedBlock:(char *)sect_pointer size:(uint32_t)len withName:(NSString *)nm {
//	
//	Segment *newSeg = [Segment name:nm start:(NSUInteger)sect_pointer length:len];
//	[_uncodedMemoryMap insertSegment:newSeg];
//}

//- (BOOL)scanUnDecodedBlocks:(NSUInteger)test {
//	
//	NSMutableArray *allSegs = _uncodedMemoryMap->_segmentStore->_memoryBlockStore;
//	for(Segment *eachSeg in allSegs){
//		UInt8 *sect_pointer = (UInt8 *)eachSeg.startAddr;
//		UInt8 *locPtr = (UInt8 *)eachSeg.startAddr;
//		NSUInteger newSectSize = eachSeg.length;
//		while( (locPtr)<(((UInt8 *)sect_pointer)+newSectSize) ) {
//			UInt16 val1 = *((UInt16 *)locPtr);
//			locPtr = locPtr + (sizeof val1)/2;
//			if(test==val1)
//				NSLog(@"Have we really achieved what we think we have?");
//		}
//	}
//}

// http://serenity.uncc.edu/web/ADC/2005/Developer_DVD_Series/April/ADC%20Reference%20Library/documentation/DeveloperTools/Conceptual/MachORuntime/FileStructure/chapter_4_section_1.html#//apple_ref/doc/uid/20001298/BAJBDBBC
- (void)parseLoadCommands {
	
	for( NSNumber *segmentAddress_Number in _loadCommandsArray )
	{		
		const struct load_command *cmd = (struct load_command *)[segmentAddress_Number unsignedIntegerValue];

		if( cmd->cmd==LC_UUID ){
			// Specifies the 128-bit UUID for an image or its corresponding dSYM file.
			struct uuid_command *seg = (struct uuid_command *)cmd;
//			NSLog(@"LC_UUID");
			
		} else if( cmd->cmd==LC_SEGMENT || cmd->cmd==LC_SEGMENT_64 ) {

			char *segname;
			NSUInteger vmaddr, vmsize, nsects;
			
			// Defines a segment of this file to be mapped into the address space of the process that loads this file. It also includes all the sections contained by the segment.
			if( cmd->cmd==LC_SEGMENT ) {
				const struct segment_command *seg = (struct segment_command *)cmd;
				segname = (char *)seg->segname;
				vmaddr = seg->vmaddr;
				vmsize = seg->vmsize;
				nsects = seg->nsects;
				
			} else if( cmd->cmd==LC_SEGMENT_64 ) {
				const struct segment_command_64 *seg = (struct segment_command_64 *)cmd;
				segname = (char *)seg->segname;
				vmaddr = seg->vmaddr;
				vmsize = seg->vmsize;
				nsects = seg->nsects;
			}
	
			NSString *segmentName = [NSString stringWithCString:segname encoding:NSUTF8StringEncoding];
//			NSLog(@"segment name %@", segmentName);

//			NSInteger segmentOffset = (NSInteger)((NSInteger *)seg)-(NSInteger)((NSInteger *)_codeAddr);
//			[[FileMapView sharedMapView] addRegionAtOffset:segmentOffset withSize:seg->cmdsize label:[NSString stringWithFormat:@"LC_SEGMENT:%@ %i", segmentName, seg->cmdsize]];	
			
			[self addSegment:segmentName memAddress:vmaddr length:vmsize];
				
			// __PAGEZERO	--  where you end up when dereferencing a 0 pointer.
			// __TEXT		-- The text segment is where our code lives.
			// __DATA		-- The data segment holds our “Hello world!” string.
			// __IMPORT		-- The IMPORT segment holds our jump table, the stubs for printf and exit.
			// __LINKEDIT	-- The LINKEDIT segment holds the symbol table.

			// each segment is divided into sections.  eg __PAGEZERO segment takes up no space on disk but has space in memory
			
			// If there are sections - The sections follow the segment
	//		struct section_64 // TODO: 64
		
            struct section *sects = (struct section *)((struct segment_command *)cmd+1);	// hey look - this is a good way to advance past segment
			struct section *newSec_ptr = sects;
			
			for( NSUInteger i=0; i<nsects; i++ )
			{
				NSUInteger memoryAddressOfSection = newSec_ptr->addr; // In otx dump this is address of first line  :start: +0	--00002704--  7c3a0b78	or r26,r1,r1
				if(memoryAddressOfSection)
				{
//					NSLog(@"i=%i, numberOfSections=%i", i, nsects);
					char *containingSegmentName = newSec_ptr->segname;
					char *thisSectionName = newSec_ptr->sectname;

//					NSLog(@"segment2 name %s", containingSegmentName );
//					NSLog(@"section2 name %s", thisSectionName );

					char *sect_pointer = ((char *)_codeAddr) + newSec_ptr->offset; // ((char *) (_codeAddr)) + bestFatArch->offset

					struct relocation_info *sect_relocs = (struct relocation_info *)(_codeAddr + newSec_ptr->reloff);
					uint32_t sect_nrelocs = newSec_ptr->nreloc;
					uint32_t sect_addr = newSec_ptr->addr;
					uint32_t sect_flags = newSec_ptr->flags;
					
					uint32_t section_type = sect_flags & SECTION_TYPE;
					NSUInteger stride=0;
					if(section_type == S_SYMBOL_STUBS){
						stride = newSec_ptr->reserved2;
					} else if(section_type == S_LAZY_SYMBOL_POINTERS || section_type == S_NON_LAZY_SYMBOL_POINTERS || section_type == S_LAZY_DYLIB_SYMBOL_POINTERS) {
						if(_cputype & CPU_ARCH_ABI64)
							stride = 8;
						else
							stride = 4;
					}
					if(stride!=0){
						NSUInteger count = newSec_ptr->size / stride;
						NSUInteger n = newSec_ptr->reserved1;

//						NSLog(@"Indirect symbols for (%.16s,%.16s) %u entries", containingSegmentName, thisSectionName, count);
						for( NSUInteger j=0; j<count && n+j<_nindirect_symbols; j++ )
						{
//							NSLog(@"MuthaFucker");
						}
					}
					
					uint32_t newSectSize = newSec_ptr->size;
//					void *newSectAddr = NULL;

					NSInteger sectionOffset = (NSInteger)((NSInteger *)sect_pointer)-(NSInteger)((NSInteger *)_codeAddr);

					NSString *secName = [NSString stringWithCString:thisSectionName encoding:NSUTF8StringEncoding];

					NSString *label = [NSString stringWithFormat:@"section:%@ %i", secName, newSectSize];
//					[[FileMapView sharedMapView] addRegionAtOffset:sectionOffset withSize:newSectSize label:label];	

					
					[self addSection:secName seg:segmentName start:sect_addr length:newSectSize filePtr:(NSUInteger)sect_pointer];
					
//					int err = (int) vm_allocate(mach_task_self(), (vm_address_t *) &newSectAddr, newSectSize, true);
//					if (err==0) {
//						NSData *sectionData = [NSData dataWithBytes:sect_pointer length:newSectSize];
//						NSLog(@"Copied section.. %@", sectionData); // [sectionData hexString]
//						memcpy(newSectAddr, sect_pointer, newSectSize);
//					}
					

					// TEXT Segment sections
					if ( strcmp(thisSectionName, "__text")==0 ) {
						// print_text_section( char *sect, uint32_t sect_size, uint32_t sect_addr ) {
			
					// otool -s __TEXT __cstring -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader
					} else if ( strcmp(thisSectionName, "__cstring")==0 ) {
						[self save_cstring_section:sect_pointer :newSectSize :sect_addr];

					// otool -s __TEXT __const -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader	
					} else if ( strcmp(thisSectionName, "__const")==0 ) {

						// 00006d90	00 00 f0 41 cd cc 4c 3f 33 33 33 3f 00 00 00 00 
						// 00006da0	00 00 80 3f 00 00 20 41 00 00 48 43 00 00 04 42 
						// 00006db0	00 00 10 41 00 00 a0 40 00 00 00 00 00 00 00 00 
						// 00006dc0	00 00 00 00 00 00 e0 41 00 00 00 00 00 00 00 00
					
					// otool -s __TEXT __symbol_stub -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader	
					} else if ( strcmp(thisSectionName, "__symbol_stub")==0 ) {
						
						// This Follows the form (ie our val1 needs disassembling)
						//00006dd0	jmp	*0x0000703c
						//00006dd6	jmp	*0x00007040

						// This needs to be UInt8 so we can advance by a specific number of bytes?
						UInt8 *locPtr = (UInt8 *)sect_pointer;
						UInt8 *memPtr = (UInt8 *)sect_addr;
						
						while( (locPtr)<(((UInt8 *)sect_pointer)+newSectSize) ) {
		
							UInt16 val1 = *((UInt16 *)locPtr);
							locPtr = locPtr + sizeof val1;
							
							UInt32 val2 = *((UInt32 *)locPtr);
							locPtr = locPtr + sizeof val2;

//							NSLog(@"%x %x %x", memPtr, val1, val2 );
							memPtr = memPtr + sizeof val1 + sizeof val2;
						}

					// otool -s __TEXT __stub_helper -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader
					} else if ( strcmp(thisSectionName, "__stub_helper")==0 ) {
																	
//						[self addUnDecodedBlock:sect_pointer size:newSectSize withName:@"__stub_helper"];
//						NSUInteger test = 0x0000701c;
//						BOOL wasFound = [self scanUnDecodedBlocks:test];
//						NSAssert(wasFound, @"scan failed");

						//00006e48	cmpl	$0x00,0x0000701c
						//00006e4f	jne	0x00006e5e
						//00006e51	movl	%eax,0x04(%esp)
						//00006e55	popl	%eax
						//00006e56	xchgl	(%esp),%eax
						//00006e59	jmpl	0x100002ac8
						//00006e5e	addl	$0x04,%esp
						//00006e61	pushl	$0x00007020
						//00006e66	jmp	*0x0000701c
						//00006e6c	pushl	$0x000000a3
						//00006e71	pushl	$0x0000705c
						//00006e76	jmpl	0x100006e48
						//00006e7b	nop
						//00006e7c	pushl	$0x00000097
						//00006e81	pushl	$0x00007058
						//00006e86	jmpl	0x100006e48
						//00006e8b	nop
						//00006e8c	pushl	$0x0000007f
						//00006e91	pushl	$0x00007054
						//00006e96	jmpl	0x100006e48
						//00006e9b	nop
						//00006e9c	pushl	$0x000000ba
						//00006ea1	pushl	$0x00007060
						//00006ea6	jmpl	0x100006e48
						//00006eab	nop
						//00006eac	pushl	$0x000000cd
						//00006eb1	pushl	$0x00007064
						//00006eb6	jmpl	0x100006e48
						//00006ebb	nop
						//00006ebc	pushl	$0x000000db
						//00006ec1	pushl	$0x00007068
						//00006ec6	jmpl	0x100006e48
						//00006ecb	nop
						//00006ecc	pushl	$0x000000e9
						//00006ed1	pushl	$0x0000706c
						//00006ed6	jmpl	0x100006e48
						//00006edb	nop
						//00006edc	pushl	$0x00000109
						//00006ee1	pushl	$0x00007070
						//00006ee6	jmpl	0x100006e48
						//00006eeb	nop
						//00006eec	pushl	$0x0000011d
						//00006ef1	pushl	$0x00007074
						//00006ef6	jmpl	0x100006e48
						//00006efb	nop
						//00006efc	pushl	$0x00000136
						//00006f01	pushl	$0x00007078
						//00006f06	jmpl	0x100006e48
						//00006f0b	nop
						//00006f0c	pushl	$0x00000150
						//00006f11	pushl	$0x0000707c
						//00006f16	jmpl	0x100006e48
						//00006f1b	nop
						//00006f1c	pushl	$0x0000015e
						//00006f21	pushl	$0x00007080
						//00006f26	jmpl	0x100006e48
						//00006f2b	nop
						//00006f2c	pushl	$0x0000016e
						//00006f31	pushl	$0x00007084
						//00006f36	jmpl	0x100006e48
						//00006f3b	nop
						//00006f3c	pushl	$0x0000017d
						//00006f41	pushl	$0x00007088
						//00006f46	jmpl	0x100006e48
						//00006f4b	nop
						//00006f4c	pushl	$0x0000006d
						//00006f51	pushl	$0x00007050
						//00006f56	jmpl	0x100006e48
						//00006f5b	nop
						//00006f5c	pushl	$0x00000059
						//00006f61	pushl	$0x0000704c
						//00006f66	jmpl	0x100006e48
						//00006f6b	nop
						//00006f6c	pushl	$0x0000003f
						//00006f71	pushl	$0x00007048
						//00006f76	jmpl	0x100006e48
						//00006f7b	nop
						//00006f7c	pushl	$0x00000026
						//00006f81	pushl	$0x00007044
						//00006f86	jmpl	0x100006e48
						//00006f8b	nop
						//00006f8c	pushl	$0x00000019
						//00006f91	pushl	$0x00007040
						//00006f96	jmpl	0x100006e48
						//00006f9b	nop
						//00006f9c	pushl	$0x00000000
						//00006fa1	pushl	$0x0000703c
						//00006fa6	jmpl	0x100006e48
						//00006fab	nop
						
						// otool -s __TEXT __literal4 -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__literal4")==0 ) {
						// 00ba9ce8  0x47800000 (6.5536000000000000e+04)
						// 00ba9cec  0x42c80000 (1.0000000000000000e+02)
						// 00ba9cf0  0x437f0000 (2.5500000000000000e+02)
						// 00ba9cf4  0x410db22d (8.8559999465942383e+00)
						// 00ba9cf8  0x4461d2b0 (9.0329199218750000e+02)						
						
						// otool -s __TEXT __literal8 -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser																																								
					} else if ( strcmp(thisSectionName, "__literal8")==0 ) {
//						NSLog(@"eh");
						// otool -s __TEXT __StaticInit /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__StaticInit")==0 ) {
//						NSLog(@"eh");
				
						// otool -s __TEXT __eh_frame /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__eh_frame")==0 ) {
						// dubug info? Todo with exceptions
			
						// otool -s __TEXT __const_coal /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__const_coal")==0 ) {
						
					} else if ( strcmp(thisSectionName, "__unwind_info")==0 ) {
//						NSLog(@"eh");
						//00006fb0	01 00 00 00 1c 00 00 00 00 00 00 00 1c 00 00 00 
						//00006fc0	00 00 00 00 1c 00 00 00 02 00 00 00 00 00 00 00 
						//00006fd0	34 00 00 00 34 00 00 00 f9 5f 00 00 00 00 00 00 
						//00006fe0	34 00 00 00 03 00 00 00 0c 00 01 00 10 00 01 00 
						//00006ff0	00 00 00 00 00 00 00 00 
						
					// DATA Segment sections
					// otool -s __DATA __dyld -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader
					} else if ( strcmp(thisSectionName, "__dyld")==0 ) {
						// 00007000	00 10 e0 8f 08 10 e0 8f 00 10 00 00 48 75 00 00 
						// 00007010	44 75 00 00 40 75 00 00 3c 75 00 00 

					// otool -s __DATA __nl_symbol_ptr -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__nl_symbol_ptr")==0 ) {
						// 0000701c	00 00 00 00 00 00 00 00 49 64 00 00 00 00 00 00 
						// 0000702c	00 00 00 00 00 00 00 00 50 75 00 00 00 00 00 00 
						
					// otool -s __DATA __la_symbol_ptr -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__la_symbol_ptr")==0 ) {
						
					// otool -s __DATA __cfstring -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__cfstring")==0 ) {

// TODO: PUTBACK! Shouldnt have bastardized the print_cstring_section()
						print_cstring_section( sect_pointer, newSectSize, sect_addr );
				
					// otool -s __DATA __data -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__data")==0 ) {

					// otool -s __DATA __bss -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__bss")==0 ) {

					// otool -s __DATA __datacoal_nt /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__datacoal_nt")==0 ) {

					// otool -s __DATA __mod_init_func /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__mod_init_func")==0 ) {
					
					// otool -s __DATA __gcc_except_tab__DATA /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__gcc_except_tab__DATA")==0 ) {
					
					// otool -s __DATA __gcc_except_tab__DATA /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__gcc_except_tab__DATA")==0 ) {
						
					// otool -s __DATA __common /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser						
					} else if ( strcmp(thisSectionName, "__common")==0 ) {

					// otool -s __DATA __program_vars /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser
					} else if ( strcmp(thisSectionName, "__program_vars")==0 ) {

					// OBJC Segment sections
					// otool -s __OBJC __message_refs -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__message_refs")==0 ) {
						//00008000  __TEXT:__cstring:addObject:
						//00008004  __TEXT:__cstring:numberWithUnsignedInteger:
						//00008008  __TEXT:__cstring:setTotalBoundsWithSize:label:
						//0000800c  __TEXT:__cstring:bytes
						//00008010  __TEXT:__cstring:dataWithContentsOfFile:
						//00008014  __TEXT:__cstring:countByEnumeratingWithState:objects:count:
						//00008018  __TEXT:__cstring:processSymbolItem:stringTable:
						//0000801c  __TEXT:__cstring:raise:format:
						//00008020  __TEXT:__cstring:addRegionAtOffset:withSize:label:
						//00008024  __TEXT:__cstring:stringWithFormat:
						//00008028  __TEXT:__cstring:sharedMapView
						//0000802c  __TEXT:__cstring:stringWithCString:length:
						//00008030  __TEXT:__cstring:unsignedIntValue
						//00008034  __TEXT:__cstring:addFunction:line:address:section:
						//00008038  __TEXT:__cstring:substringToIndex:
						//0000803c  __TEXT:__cstring:rangeOfString:options:
						//00008040  __TEXT:__cstring:length
						//00008044  __TEXT:__cstring:unsignedLongValue
						//00008048  __TEXT:__cstring:numberWithUnsignedLongLong:
						//0000804c  __TEXT:__cstring:pathExtension
						//00008050  __TEXT:__cstring:stringWithUTF8String:
						//00008054  __TEXT:__cstring:objectForKey:
						//00008058  __TEXT:__cstring:numberWithUnsignedLong:
						//0000805c  __TEXT:__cstring:dataWithBytes:length:
						//00008060  __TEXT:__cstring:parseLoadCommands
						//00008064  __TEXT:__cstring:alloc
						//00008068  __TEXT:__cstring:doIt:
						//0000806c  __TEXT:__cstring:retain
						//00008070  __TEXT:__cstring:array
						//00008074  __TEXT:__cstring:init
						//00008078  __TEXT:__cstring:frame
						//0000807c  __TEXT:__cstring:bezierPathWithRect:
						//00008080  __TEXT:__cstring:addSubview:
						//00008084  __TEXT:__cstring:setFont:
						//00008088  __TEXT:__cstring:labelFontOfSize:
						//0000808c  __TEXT:__cstring:setSelectable:
						//00008090  __TEXT:__cstring:setDrawsBackground:
						//00008094  __TEXT:__cstring:setBordered:
						//00008098  __TEXT:__cstring:setBezeled:
						//0000809c  __TEXT:__cstring:setBackgroundColor:
						//000080a0  __TEXT:__cstring:clearColor
						//000080a4  __TEXT:__cstring:setStringValue:
						//000080a8  __TEXT:__cstring:autorelease
						//000080ac  __TEXT:__cstring:count
						//000080b0  __TEXT:__cstring:fill
						//000080b4  __TEXT:__cstring:set
						//000080b8  __TEXT:__cstring:colorWithDeviceRed:green:blue:alpha:
						//000080bc  __TEXT:__cstring:initWithFrame:
						//000080c0  __TEXT:__cstring:initWithPath:
						//000080c4  __TEXT:__cstring:executablePath
						//000080c8  __TEXT:__cstring:mainBundle
						//000080cc  __TEXT:__cstring:release
						//000080d0  __TEXT:__cstring:stringWithString:
						//000080d4  __TEXT:__cstring:appendFormat:
						//000080d8  __TEXT:__cstring:initWithData:
						//000080dc  __TEXT:__cstring:dataWithHexString:
						//000080e0  __TEXT:__cstring:dataWithData:
						//000080e4  __TEXT:__cstring:mutableBytes
						//000080e8  __TEXT:__cstring:dataWithLength:
						//000080ec  __TEXT:__cstring:cStringUsingEncoding:
						
					// otool -s __OBJC __cls_refs -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__cls_refs")==0 ) {
						//000080f0  __TEXT:__cstring:NSMutableArray
						//000080f4  __TEXT:__cstring:NSMutableDictionary
						//000080f8  __TEXT:__cstring:NSData
						//000080fc  __TEXT:__cstring:NSNumber
						//00008100  __TEXT:__cstring:NSString
						//00008104  __TEXT:__cstring:FileMapView
						//00008108  __TEXT:__cstring:NSException
						//0000810c  __TEXT:__cstring:NSColor
						//00008110  __TEXT:__cstring:NSTextField
						//00008114  __TEXT:__cstring:NSFont
						//00008118  __TEXT:__cstring:NSBezierPath
						//0000811c  __TEXT:__cstring:NSBundle
						//00008120  __TEXT:__cstring:MachoLoader
						//00008124  __TEXT:__cstring:NSMutableData
						//00008128  __TEXT:__cstring:NSMutableString

					// otool -s __OBJC __property -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader											
					} else if ( strcmp(thisSectionName, "__property")==0 ) {

					// otool -s __OBJC __class -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader						
					} else if ( strcmp(thisSectionName, "__class")==0 ) {
						//0000812c	bc 81 00 00 53 68 00 00 47 68 00 00 00 00 00 00 
						//0000813c	01 00 00 00 1c 00 00 00 e8 82 00 00 4c 82 00 00 
						//0000814c	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
						//0000815c	ec 81 00 00 51 6b 00 00 77 6a 00 00 00 00 00 00 
						//0000816c	01 00 00 00 5c 00 00 00 34 83 00 00 90 82 00 00 
						//0000817c	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
						//0000818c	1c 82 00 00 53 68 00 00 8a 6c 00 00 00 00 00 00 
						//0000819c	01 00 00 00 04 00 00 00 00 00 00 00 d4 82 00 00 
						//000081ac	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 

					// otool -s __OBJC __meta_class -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader												
					} else if ( strcmp(thisSectionName, "__meta_class")==0 ) {
						//000081bc	53 68 00 00 53 68 00 00 47 68 00 00 00 00 00 00 
						//000081cc	02 00 00 00 30 00 00 00 00 00 00 00 00 00 00 00 
						//000081dc	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
						//000081ec	53 68 00 00 51 6b 00 00 77 6a 00 00 00 00 00 00 
						//000081fc	02 00 00 00 30 00 00 00 00 00 00 00 dc 83 00 00 
						//0000820c	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
						//0000821c	53 68 00 00 53 68 00 00 8a 6c 00 00 00 00 00 00 
						//0000822c	02 00 00 00 30 00 00 00 00 00 00 00 00 00 00 00 
						//0000823c	00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

					// otool -s __OBJC __inst_meth -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader												
					} else if ( strcmp(thisSectionName, "__inst_meth")==0 ) {
						//0000824c	00 00 00 00 05 00 00 00 91 67 00 00 97 67 00 00 
						//0000825c	e1 45 00 00 a1 67 00 00 b3 67 00 00 f3 30 00 00 
						//0000826c	ba 67 00 00 d9 67 00 00 ae 2d 00 00 fa 67 00 00 
						//0000827c	1c 68 00 00 02 2d 00 00 2f 68 00 00 3d 68 00 00 
						//0000828c	0c 2b 00 00 00 00 00 00 05 00 00 00 b2 6a 00 00 
						//0000829c	bc 6a 00 00 68 58 00 00 f7 68 00 00 c3 6a 00 00 
						//000082ac	17 53 00 00 82 68 00 00 d3 6a 00 00 c3 52 00 00 
						//000082bc	e0 6a 00 00 ea 6a 00 00 27 51 00 00 16 6b 00 00 
						//000082cc	25 6b 00 00 66 50 00 00 00 00 00 00 01 00 00 00 
						//000082dc	6b 6c 00 00 97 67 00 00 7b 58 00 00

					// otool -s __OBJC __instance_vars -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																		
					} else if ( strcmp(thisSectionName, "__instance_vars")==0 ) {
						//000082e8	06 00 00 00 fc 66 00 00 0a 67 00 00 04 00 00 00 
						//000082f8	1c 67 00 00 25 67 00 00 08 00 00 00 28 67 00 00 
						//00008308	31 67 00 00 0c 00 00 00 33 67 00 00 3e 67 00 00 
						//00008318	10 00 00 00 55 67 00 00 62 67 00 00 14 00 00 00 
						//00008328	86 67 00 00 8f 67 00 00 18 00 00 00 03 00 00 00 
						//00008338	8f 6a 00 00 0a 67 00 00 50 00 00 00 98 6a 00 00 
						//00008348	9e 6a 00 00 54 00 00 00 a0 6a 00 00 31 67 00 00 
						//00008358	58 00 00 00 

					// otool -s __OBJC __module_info -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																								
					} else if ( strcmp(thisSectionName, "__module_info")==0 ) {

					// otool -s __OBJC __symbols -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																								
					} else if ( strcmp(thisSectionName, "__symbols")==0 ) {

					// otool -s __OBJC __cls_meth -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																													
					} else if ( strcmp(thisSectionName, "__cls_meth")==0 ) {

					// otool -s __OBJC __cat_cls_meth -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																																			
					} else if ( strcmp(thisSectionName, "__cat_cls_meth")==0 ) {

					// otool -s __OBJC __cat_inst_meth -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																																									
					} else if ( strcmp(thisSectionName, "__cat_inst_meth")==0 ) {

					// otool -s __OBJC __category -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																																									
					} else if ( strcmp(thisSectionName, "__category")==0 ) {

					// otool -s __OBJC __image_info -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																																									
					} else if ( strcmp(thisSectionName, "__image_info")==0 ) {

					// otool -s __OBJC __class_ext -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Debug/MachoLoader.app/Contents/MacOS/MachoLoader																																									
					} else if ( strcmp(thisSectionName, "__class_ext")==0 ) {
						
					// otool -s __IMPORT __pointers /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/SimpleFileParser/build/Debug/SimpleFileParser.app/Contents/MacOS/SimpleFileParser						
					} else if ( strcmp(thisSectionName, "__pointers")==0 ) {

					// otool -s __IMPORT __jump_table -v -V /Applications/6-386.app/Contents/MacOS/Sibelius\ 6						
					} else if ( strcmp(thisSectionName, "__jump_table")==0 ) {	
						// The jump table is somehow re-written at run time by the dyld
						
						// It seems that these are in the other sections as well.

					} else {
						[NSException raise:@"Unkown section in this segment" format:@"%s - %s", containingSegmentName, thisSectionName];
					}
//					NSLog(@"why not stop for a while and see what we copied?");
				}
				newSec_ptr = newSec_ptr+1;
			}
			
			
		} else if( cmd->cmd==LC_SYMTAB ) {
			
			// This segment describes our symbol table, including where the symbols and the strings naming them are located. I believe it’s mostly for the benefit of the debugger.
				
			// Specifies the symbol table for this file. This information is used by both static and dynamic linkers when linking the file, and also by debuggers 
			// to map symbols to the original source code files from which the symbols were generated.
			const struct symtab_command *symtab = (struct symtab_command*)cmd;
			uint32_t symoff	= symtab->symoff;	// An integer containing the byte offset from the start of the file to the location of the symbol table entries. The symbol table is an array of nlist data structures.
			_nsymbols		= symtab->nsyms;	// An integer indicating the number of entries in the symbol table.
			uint32_t stroff	= symtab->stroff;	// An integer containing the byte offset from the start of the image to the location of the string table.
			_strings_size	= symtab->strsize;	// An integer indicating the size (in bytes) of the string table.

			_symtable_ptr = (struct nlist *)(symoff + _codeAddr);
			_strtable = (char *)(stroff + _codeAddr);

			for( NSInteger i=0; i<_nsymbols; i++ )
			{
				struct nlist symbol = _symtable_ptr[i];
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
					nlist64.n_desc = n_desc;
					nlist64.n_value = (uint64_t)(n_value);
					
//					if ([self processSymbolItem:&nlist64 stringTable:_strtable])					
//					{
//					}
					
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
//			NSLog(@"LC_SYMTAB - number of table entries %i", _nsymbols );
			
		} else if(cmd->cmd==LC_DYSYMTAB) {

			// This load command describes the dynamic symbol table. This is how the dynamic linker knows to plug the stubs (indirect).
			const struct dysymtab_command* dsymtab = (struct dysymtab_command*)cmd;
//			NSLog(@"LC_DYSYMTAB");
//
//	The dynamic symbol table in Mach-O is surprisingly simple. Each entry in the table is just a 32bit index into the symbol table. The dynamic symbol table is just a list of indexes and nothing else.
//
//
//	Take a look at the definition for a Mach-O section:
//
//	struct section_64 { /* for 64-bit architectures */
//	char    sectname[16]; /* name of this section */
//	char    segname[16];  /* segment this section goes in */
//	uint64_t  addr;   /* memory address of this section */
//	uint64_t  size;   /* size in bytes of this section */
//	uint32_t  offset;   /* file offset of this section */
//	uint32_t  align;    /* section alignment (power of 2) */
//	uint32_t  reloff;   /* file offset of relocation entries */
//	uint32_t  nreloc;   /* number of relocation entries */
//	uint32_t  flags;    /* flags (section type and attributes)*/
//	uint32_t  reserved1;  /* reserved (for offset or index) */
//	uint32_t  reserved2;  /* reserved (for count or sizeof) */
//	uint32_t  reserved3;  /* reserved */
//	};
//	It turns out that the fields reserved1 and reserved2 are useful too.
//
//	If a section_64 structure is describing a symbol_stub or __la_symbol_ptr sections (read the previous post to learn about these sections), then the reserved1 field hold the index into the dynamic symbol table for the sections entries in the table.
//
//	symbol_stub sections also make use of the reserved2 field; the size of a single stub entry is stored in reserved2 otherwise, the field is set to 0.

			
			
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
//			NSLog( @"-- Index to local symbols %i", dsymtab->ilocalsym );
//			NSLog( @"-- Number of local symbols %i", dsymtab->nlocalsym );
			
			for( int i=dsymtab->ilocalsym; i<(dsymtab->ilocalsym+dsymtab->nlocalsym); i++)
			{
				struct nlist symbol = _symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&_strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
//				NSLog(@"Local Symbol > %@ - %@", src, address);
			}
// This is exactly what i want! http://www.google.com/codesearch/p?hl=en#G0qjcaxpHTc/sedarwin8/darwin/cctools/otool/ofile_print.c&q=ilocalsym%20nlocalsym			
			
			// uint32_t iextdefsym;/* index to externally defined symbols */
			// uint32_t nextdefsym;/* number of externally defined symbols */
//			NSLog(@"-- Index of externally defined symbols %i", dsymtab->iextdefsym);
//			NSLog(@"-- Number of externally defined symbols %i", dsymtab->nextdefsym);
			for( int i=dsymtab->iextdefsym; i<(dsymtab->iextdefsym+dsymtab->nextdefsym); i++)
			{
				struct nlist symbol = _symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&_strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
//				NSLog(@"External Symbol > %@ - %x", src, symbol.n_value);
			}
			
			// uint32_t iundefsym;	/* index to undefined symbols */
			//uint32_t nundefsym;	/* number of undefined symbols */
//			NSLog(@"-- Index of externally undefined symbols %i", dsymtab->iundefsym);
//			NSLog(@"-- Number of externally undefined symbols %i", dsymtab->nundefsym);
			
			// TODO: use the indirect symbol table to match this index (i) to an address in the dissasembly 
			for( int i=dsymtab->iundefsym; i<(dsymtab->iundefsym+dsymtab->nundefsym); i++)
			{
				struct nlist symbol = _symtable_ptr[i];
				NSString *src = [NSString stringWithUTF8String:&_strtable[symbol.n_un.n_strx]];
				NSString *ext = [src pathExtension];
				NSNumber *address = [NSNumber numberWithUnsignedLongLong: symbol.n_value];
//				NSLog(@"External Undefined Symbol > %@ - %@", src, address);
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
//			NSLog(@"-- Number of entries in table of contents %i", dsymtab->ntoc);
			
			// should this be offset from file? guess so
			struct dylib_table_of_contents *tocs_ptr = (struct dylib_table_of_contents *)(_codeAddr + dsymtab->tocoff);
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
//			NSLog(@"-- Number of module table entries %i", dsymtab->nmodtab);
			if(dsymtab->nmodtab>0){
				struct dylib_reference *libRefer1 = (struct dylib_reference *)(_codeAddr + dsymtab->modtaboff);
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
//			NSLog(@"-- Number of referenced symbol table entries %i", dsymtab->nextrefsyms);
			if(dsymtab->nextrefsyms>0){
				struct dylib_reference *libRefer2 = (struct dylib_reference *)(_codeAddr + dsymtab->extrefsymoff);
				for( int i=0; i<dsymtab->nextrefsyms; i++){
//					NSLog(@"DO THIS!");
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

			// The indirect symbol table tells the dynamic linker that elements 2 and 3 of the symbol table need to be looked up and their stubs plugged
			_nindirect_symbols = dsymtab->nindirectsyms;
//			NSLog( @"-- Number of indirect symbol table entries %i", _nindirect_symbols );

			if( _nindirect_symbols>0 )
			{
				_indirectSymbolTable = (uint32_t *)(_codeAddr + dsymtab->indirectsymoff);
				for( NSUInteger i=0; i<_nindirect_symbols; i++ ){
					uint32_t indirectSymbol = _indirectSymbolTable[i];
					
					//TODO: where does this address come from?
//					uint32_t address = 0;
//					if( indirectSymbol==INDIRECT_SYMBOL_LOCAL )
//						NSLog(@"IndirectSymbol %i, INDEX:Local", address );
//					else if( indirectSymbol==INDIRECT_SYMBOL_ABS ) {
//						NSLog(@"IndirectSymbol %i, INDEX:Absolute", address );
//					} else {
//						NSLog(@"IndirectSymbol %x, INDEX:%i", &(_indirectSymbolTable[i]), indirectSymbol);
//					}
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
//			NSLog(@"-- Number of external relocation entries %i", dsymtab->nextrel);
			if(dsymtab->nextrel>0){
				struct relocation_info *ext_relocs = (struct relocation_info *)(_codeAddr + dsymtab->extreloff);
				int32_t addressOfSymbol = ext_relocs->r_address;
//				NSLog(@"Relocate symbol %i", addressOfSymbol);
			}
			
			/*
			 * All the local relocation entries are grouped together (they are not
			 * grouped by their module since they are only used if the object is moved
			 * from it staticly link edited address).
			 */
			// uint32_t locreloff;	/* offset to local relocation entries */
			// uint32_t nlocrel;	/* number of local relocation entries */			
//			NSLog(@"-- Number of of local relocation entries %i", dsymtab->nlocrel);
			if(dsymtab->nlocrel>0){
				struct relocation_info *loc_relocs = (struct relocation_info *)(_codeAddr + dsymtab->locreloff);
				int32_t addressOfSymbol = loc_relocs->r_address;
//				NSLog(@"Relocate symbol %i", addressOfSymbol);
			}
		
		} else if(cmd->cmd==LC_THREAD || cmd->cmd==LC_UNIXTHREAD) {
			
			// This load command specifies the contents of the registers at startup. I haven’t seen anything other than EIP populated, though. The program will not run unless this load command is present!
			// For an executable file, the LC_UNIXTHREAD command defines the initial thread state of the main thread of the process. LC_THREAD is similar to LC_UNIXTHREAD but does not cause the kernel to allocate a stack.
			const struct thread_command* threadtab = (struct thread_command*)cmd;
//			NSLog(@"LC_THREAD");
			
		} else if(cmd->cmd==LC_LOAD_DYLIB) {
			// Defines the name of a dynamic shared library that this file links against.
			const struct dylib_command* seg = (struct dylib_command*)cmd;
			struct dylib dylib = seg->dylib;
			char *install_name = (char*)cmd + dylib.name.offset;
			// also got timestamp, version, compatibility version
			[self addLibrary: [NSString stringWithCString:install_name encoding:NSUTF8StringEncoding]];
			
		} else if(cmd->cmd==LC_ID_DYLIB) {
			// Specifies the install name of a dynamic shared library.
			const struct dylib_command* seg = (struct dylib_command*)cmd;

//			NSLog(@"LC_ID_DYLIB");

		} else if(cmd->cmd==LC_PREBOUND_DYLIB) {
			// For a shared library that this executable is linked prebound against, specifies the modules in the shared library that are used.
			const struct prebound_dylib_command* seg = (struct prebound_dylib_command*)cmd;
//			NSLog(@"LC_PREBOUND_DYLIB");

		} else if(cmd->cmd==LC_LOAD_DYLINKER) {
			// Specifies the dynamic linker that the kernel executes to load this file.
			const struct dylinker_command* linkertab = (struct dylinker_command*)cmd;
			const char* dylibName = (char*)cmd + linkertab->name.offset;

//			NSLog(@"LC_LOAD_DYLINKER %s", dylibName );

		} else if(cmd->cmd==LC_ID_DYLINKER) {
			// Identifies this file as a dynamic linker.
			const struct dylinker_command* linkertab = (struct dylinker_command*)cmd;
//			NSLog(@"LC_ID_DYLINKER");
			
		} else if( cmd->cmd==LC_ROUTINES || cmd->cmd==LC_ROUTINES_64 ) {
			// Contains the address of the shared library initialization routine (specified by the linker’s -init option).
			if( cmd->cmd==LC_ROUTINES ) {
				const struct routines_command* seg = (struct routines_command*)cmd;
			} else {
				const struct routines_command_64* seg = (struct routines_command_64*)cmd;
			}
			
		} else if(cmd->cmd==LC_TWOLEVEL_HINTS){
			// Contains the two-level namespace lookup hint table.
			const struct twolevel_hints_command* seg = (struct twolevel_hints_command*)cmd;
//			NSLog(@"LC_TWOLEVEL_HINTS");
			
		} else if(cmd->cmd==LC_SUB_FRAMEWORK){
			// Identifies this file as the implementation of a subframework of an umbrella framework. The name of the umbrella framework is stored in the string parameter.
			struct sub_framework_command *subf = (struct sub_framework_command *)cmd;
			const char* exportThruName = (char*)cmd + subf->umbrella.offset;
//			NSLog(@"LC_SUB_FRAMEWORK");
			
		} else if(cmd->cmd==LC_SUB_UMBRELLA){
			// Specifies a file that is a subumbrella of this umbrella framework.
			const struct sub_umbrella_command* seg = (struct sub_umbrella_command *)cmd;
//			NSLog(@"LC_SUB_UMBRELLA");
			
		} else if(cmd->cmd==LC_SUB_LIBRARY){
			// Defines the attributes of the LC_SUB_LIBRARY load command. Identifies a sublibrary of this framework and marks this framework as an umbrella framework.
			const struct sub_library_command* seg = (struct sub_library_command *)cmd;
//			NSLog(@"LC_SUB_LIBRARY");
			
		} else if(cmd->cmd==LC_SUB_CLIENT){
			// A subframework can explicitly allow another framework or bundle to link against it by including an LC_SUB_CLIENT load command containing the name of the framework or a client name for a bundle.
			const struct sub_client_command* seg = (struct sub_client_command *)cmd;
//			NSLog(@"LC_SUB_CLIENT");
			
		} else if(cmd->cmd==LC_DYLD_INFO_ONLY) {
//			NSLog(@"LC_DYLD_INFO_ONLY"); // The new compressed stuff?
	
		} else if(cmd->cmd==LC_RPATH){ /* runpath additions */
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_CODE_SIGNATURE){
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_SEGMENT_SPLIT_INFO){
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_REEXPORT_DYLIB){
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_LAZY_LOAD_DYLIB){
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_ENCRYPTION_INFO){
//			NSLog(@"which one?");
//		} else if(cmd->cmd==LC_DYLD_INFO){
//			NSLog(@"which one?");
			
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

// http://developer.apple.com/documentation/DeveloperTools/Conceptual/MachORuntime/Reference/reference.html

- (void)doIt:(NSString *)aPath {

	// path to this app
	NSData *allFile = [NSData dataWithContentsOfFile:aPath];
	if(!allFile)
		[NSException raise:@"App Not Found" format:@"%@", aPath];

	_codeAddr = [allFile bytes];
	_codeSize = [allFile length];

//	[[FileMapView sharedMapView] setTotalBoundsWithSize:_codeSize label:[NSString stringWithFormat:@"total file size %i", _codeSize]];
	
	/* Is the executable a FAT? */
	// FAT is always Big Endian - Extract relevant architecture and convert to native
	if( OSSwapBigToHostInt32(((struct fat_header *)_codeAddr)->magic)==FAT_MAGIC ) {
		
		struct fat_arch *fatArchArray;
		struct fat_header *fatHeader = (struct fat_header *)_codeAddr;
		assert( _codeSize >= sizeof(*fatHeader) );
		fatHeader->magic     = OSSwapBigToHostInt32(fatHeader->magic);
		fatHeader->nfat_arch = OSSwapBigToHostInt32(fatHeader->nfat_arch);

		assert(fatHeader->magic == FAT_MAGIC);
		assert(fatHeader->nfat_arch > 0);
		assert( _codeSize >= (sizeof(*fatHeader) + (sizeof(*fatArchArray) * fatHeader->nfat_arch)) );

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
			assert(bestFatArch->size <= _codeSize);
			assert(bestFatArch->offset <= _codeSize);
			assert( (bestFatArch->size + bestFatArch->offset) <= _codeSize );
			
			uint32_t newCodeSize = bestFatArch->size;
			void *newCodeAddr = NULL;
			
			int err = (int) vm_allocate(mach_task_self(), (vm_address_t *) &newCodeAddr, newCodeSize, true);
			if (err == 0) {
				memcpy(newCodeAddr, ((char *) (_codeAddr)) + bestFatArch->offset , newCodeSize);
			}
			_codeAddr = newCodeAddr;
			_codeSize = newCodeSize;
		}
	}
	
	// just the bits common between 32bit and 64bit! Dont even think of doing sizeof
	const struct mach_header *universalMachHeader = (struct mach_header *)_codeAddr;
	
//hmm	NSInteger mach_headerOffset = (NSInteger)((NSInteger *)machHeader)-(NSInteger)((NSInteger *)_codeAddr);
//hmm	NSUInteger mach_headerSize = sizeof(*machHeader);
//hmm	[[FileMapView sharedMapView] addRegionAtOffset:mach_headerOffset withSize:mach_headerSize label:[NSString stringWithFormat:@"Header %i", mach_headerSize]];
//hmm	[self addSection:@"Header" start:mach_headerOffset length:machHeader->sizeofcmds];
	 
	/* Is the architecture correct for this machine? */
	if( universalMachHeader->magic==MH_MAGIC ) // 32bit
	{
		const struct mach_header *machHeader = (struct mach_header *)_codeAddr;
		_startOfLoadCommandsPtr = (struct load_command *)(machHeader+1); /* Move on past the header */
		_sizeofcmds = machHeader->sizeofcmds;

	} else if( universalMachHeader->magic==MH_MAGIC_64 ) { // 64bit

		const struct mach_header_64 *machHeader = (struct mach_header_64 *)_codeAddr;
		_startOfLoadCommandsPtr = (struct load_command *)(machHeader+1); /* Move on past the header */
		_sizeofcmds = machHeader->sizeofcmds;

	} else {
		[NSException raise:@"Unknown Format" format:@""];
	}
	_cputype = universalMachHeader->cputype;
	if( _cputype==CPU_TYPE_POWERPC )
		NSLog(@"PPC");
	else if( _cputype==CPU_TYPE_I386 )
		NSLog(@"INTEL - 32bit");
	else if( _cputype==CPU_TYPE_X86_64 )
		NSLog(@"INTEL - 64bit");
	else
		NSLog(@"UNKNOWN ARCHITECTURE");
		
	// cpusubtype = CPU_SUBTYPE_POWERPC_ALL || CPU_SUBTYPE_I386_ALL
	// filetype = MH_OBJECT || MH_EXECUTE || MH_BUNDLE || MH_DYLIB || MH_PRELOAD || MH_CORE || MH_DYLINKER || MH_DSYM
	if( universalMachHeader->filetype==MH_EXECUTE ){
//		NSLog(@"Inside the guts of an executable");
	}

	[self readHeaderFlags:universalMachHeader->flags]; // MH_FORCE_FLAT etc
		
//		NSInteger loadCommandsOffset = (NSInteger)((NSInteger *)cmds1)-(NSInteger)((NSInteger *)_codeAddr);
//		[[FileMapView sharedMapView] addRegionAtOffset:loadCommandsOffset withSize:sizeofcmds_bytes label:[NSString stringWithFormat:@"Load Commands %i", sizeofcmds_bytes]];		
		
	const struct load_command *cmd = _startOfLoadCommandsPtr;
	_ncmds = universalMachHeader->ncmds;
	for( NSUInteger i=0; i<_ncmds; i++ ) {
		[_loadCommandsArray addObject:[NSNumber numberWithUnsignedInteger:(NSUInteger)cmd]];
		cmd = (struct load_command *)((uintptr_t)cmd+(uint32_t)cmd->cmdsize);
	}
	
}



@end
