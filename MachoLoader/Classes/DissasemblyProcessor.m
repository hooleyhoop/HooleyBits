//
//  DissasemblyProcessor.m
//  MachoLoader
//
//  Created by Steven Hooley on 21/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DissasemblyProcessor.h"
#import "FunctionEnumerator.h"
#import "Instructions.h"
#import "Registers.h"
#import "MachoLoader.h"
#import <unistd.h>
#import <sys/syscall.h>

@implementation DissasemblyProcessor

- (id)initWithFunctionEnumerator:(FunctionEnumerator *)f_enum {

	self = [super init];
	if(self){
		_functionEnumerator = [f_enum retain];
	}
	return self;
}

- (void)dealloc {

	[_functionEnumerator release];
	[super dealloc];
}

- (void)printLinesToFile {
	
	static int counter = 0;

    FILE *outFile = NULL;
	NSString *outPath = [[NSString stringWithFormat:@"~/testoutput_%i.txt", counter++] stringByExpandingTildeInPath];
	outFile = fopen( [outPath UTF8String], "w");
    SInt32  fileNum = fileno(outFile);

	char outLine[1024];

	struct hooleyFuction *aFunc = [_functionEnumerator firstFunction];
	for( NSUInteger i=0; i<[_functionEnumerator count]; i++ )
	{
		if( aFunc->firstLine==0 ){
			NSLog(@"function wityh no lines?????");
			aFunc = [_functionEnumerator nextFunction];			
			continue;
		}
		
		//TODO: i dont think the labels are uniwue at this point?
		
		// enumerte labels
//		if( aFunc->labels ) {
//			struct label *label = aFunc->labels;
//			do {
//				sprintf( outLine, "%p\t%s\n", line->address, line->instr->name );				
//			} while( label = label->prev );				
//		}
		
		// enumerate lines
		struct hooleyCodeLine *line = aFunc->firstLine;
		do {
			
			//TODO:-- get inputs and outputs from line
			//const struct instable *instr = line->instr;
			//struct InstrArgStruct *args = line->args
			//struct ArgMap *argMap = instr->class->argMap;
			
			sprintf( outLine, "%p\t%s\n", line->address, line->instr->name );
			int result = syscall( SYS_write, fileNum, outLine, strlen(outLine) );
			
			if( result==-1 )
			{
				perror("otx: unable to write to output file");
				break;
			}
			
		} while( line = line->next );
		
		aFunc = [_functionEnumerator nextFunction];
	}
	
	if( fclose(outFile)!=0 ) {
		perror("otx: unable to close output file");
	}
}

- (void)processApp {

	//TODO: -- each function needs to be sorted into inner blocks
	
	//TODO: -- process each inner block
	
	//TODO: -- this is just a test
	[self printLinesToFile];
	
}



@end
