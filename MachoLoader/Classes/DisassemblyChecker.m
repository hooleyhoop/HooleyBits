//
//  DisassemblyChecker.m
//  MachoLoader
//
//  Created by Steven Hooley on 01/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DisassemblyChecker.h"
#import "DebugCodeLine.h"
#import "InstrArgStruct.h"
#import "TokenArray.h"
#import "ArgumentScanner.h"
#import <sys/param.h>

@interface DisassemblyChecker ()
- (BOOL)populateLineList:(NSObject **)inList verbosely:(BOOL)inVerbose fromSection:(char *)inSectionName afterLine:(NSObject **)inLine includingPath:(BOOL)inIncludePath;
- (NSString *)pathForTool:(NSString *)toolName;
@end

@implementation DisassemblyChecker

- (id)initWithPath:(NSString *)aPath isFAT:(BOOL)fatFlag {
	
	self = [super init];
	if(self) {
		_filePath = [aPath retain];
		_fat = fatFlag;
	}
	return self;
}

- (void)dealloc {
	[_filePath release];
	[super dealloc];
}

- (void)assertNextAdress:(char *)memAddress argCount:(struct InstrArgStruct *)args {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	DebugCodeLine *line = [self nextLine:(char *)&_theCLine];
	if( line && line->_address==(NSUInteger)memAddress ) {
	} else {
		NSLog(@"Bollocks");
		goto balk;
	}
	
	NSUInteger numberOfArgs = args!=NULL ? args->numberOfArgs : 0;
	if( line->_numberOfArgs==numberOfArgs ) {
	} else {
		NSLog(@"Bollocks - wrong number of args");
		goto balk;
	}

balk:
	[pool release];
}

- (void)skipNextAdress:(char *)memAddress {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	DebugCodeLine *line = [self nextLine:(char *)&_theCLine];
	[pool release];
}

NSUInteger hexStringToInt( NSString *hexString ) {
	
	static unsigned char HEX_LOOKUP[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 
		6, 7, 8, 9, 0, 0, 0, 0, 0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	
	if ([hexString length] % 2 == 1)  {
		hexString = [NSString stringWithFormat:@"0%@", hexString]; 
	}
	NSUInteger size = [hexString length] / 2;
	const char * stringBuffer = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
	char current;
	NSUInteger result=0;
	for( NSUInteger i=0; i<size; i++) {
		current = stringBuffer[i * 2];
		NSUInteger highBits = HEX_LOOKUP[(int)current] << 4;
		current = stringBuffer[(i * 2) + 1];
		NSUInteger lowBits = HEX_LOOKUP[(int)current];
		result = result<<8 | highBits | lowBits;
	}
	return result;
}

NSArray *worderize( NSString *aLine ) {
	
	NSArray *components = [aLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *betterComponents = [NSMutableArray array];
	//	for(NSString *each in components){
	//		if([each isEqualToString:@""]==NO)
	//			[betterComponents addObject:each];
	//	}
	[components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
		if([obj isEqualToString:@""])
			return;
		[betterComponents addObject:obj];
	}];
	return betterComponents;
}

- (DebugCodeLine *)nextLine:(char *)theCLine {
	
	char *result;
	DebugCodeLine *newLine = nil;

	while( result=fgets( theCLine, MAX_LINE_LENGTH, _otoolPipe )) {
		NSString *justToSee = [NSString stringWithUTF8String:theCLine];
		NSString *strippedline = [justToSee stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([strippedline length]==0) {

		} else {
			// is it a code line?
			char char1 = [strippedline characterAtIndex:0];
			char char2 = [strippedline characterAtIndex:1];
			if( char1>47 && char1<58 && char2>47 && char2<58 ) {

				NSArray *components = worderize( strippedline );
				
				// contreversal, ignore nop opcodes
				if( [[components objectAtIndex:1] isEqualToString:@"nop"]==NO )
				{
					NSString *address = [components objectAtIndex:0];
					//Instruction *instr = nil;
					NSArray *allArgs = nil;
					if([components count]>=3)
					{
						NSString *arguments = [components objectAtIndex:2];
						TokenArray *tkns1 = [TokenArray tokensWithString:arguments];
						[tkns1 secondPass];
						ArgumentScanner *scanner = [ArgumentScanner scannerWithTokens:tkns1];
						allArgs = [[scanner.allArguments copy] autorelease];
						//for(Argument *arg in allArgs){
						//	NSLog(@"String is %@    pattern is %@", [arg output], [arg pattern]);
						//}
					}
					
					NSUInteger addressInt = hexStringToInt(address);
					newLine = [DebugCodeLine lineWithAddress:addressInt instruction:nil args:allArgs];
					break;
				} else {
//TODO					NSLog(@"Skipping nop");
				}
			}
		}
	}

	return newLine;
}

- (BOOL)openOTOOL {
	
	// Call otool and have the output piped a line at a time
    return [self populateLineList:nil verbosely:NO fromSection:(char *)"__text" afterLine:nil includingPath:YES];
}

#define MAX_ARCH_STRING_LENGTH      20      // "ppc", "i386" etc.
#define MAX_UNIBIN_OTOOL_CMD_SIZE   MAXPATHLEN + MAX_ARCH_STRING_LENGTH + 7 // strlen(" -arch ")

// parse OTool output a line at a time
- (BOOL)populateLineList:(NSObject **)inList verbosely:(BOOL)inVerbose fromSection:(char *)inSectionName afterLine:(NSObject **)inLine includingPath:(BOOL)inIncludePath {
		
    char cmdString[MAX_UNIBIN_OTOOL_CMD_SIZE] = "";
    NSString* otoolPath = [self pathForTool: @"otool"];
    NSUInteger otoolPathLength = [otoolPath length];
	
    char iArchString[MAX_ARCH_STRING_LENGTH];    // "ppc", "i386" etc.	
    size_t archStringLength = strlen(iArchString);
	
    // otool freaks out when somebody says -arch and it's not a unibin.
    if(_fat)
    {
        // Bail if it won't fit.
        if ((otoolPathLength + archStringLength + 7 /* strlen(" -arch ") */) >= MAX_UNIBIN_OTOOL_CMD_SIZE)
            return NO;
		
        snprintf(cmdString, MAX_UNIBIN_OTOOL_CMD_SIZE, "%s -arch %s", [otoolPath UTF8String], iArchString);

    } else {
        // Bail if it won't fit.
        if (otoolPathLength >= MAX_UNIBIN_OTOOL_CMD_SIZE)
            return NO;
		
        strncpy(cmdString, [otoolPath UTF8String], otoolPathLength);
    }
	
    NSString* oPath = _filePath; //[iOFile path];
    NSString* otoolString = [NSString stringWithFormat:@"%s %s -s __TEXT %s \"%@\"%s", cmdString, (inVerbose) ? "-V" : "-v", inSectionName, oPath, (inIncludePath) ? "" : " | sed '1 d'"];
	
    _otoolPipe = popen([otoolString UTF8String], "r");
    if (!_otoolPipe) {
        fprintf(stderr, "otx: unable to open %s otool pipe\n", (inVerbose) ? "verbose" : "plain");
        return NO;
    }
	return YES;
}	

- (BOOL)close {
	
    if( pclose(_otoolPipe) == -1 ) {
        perror( "otx: unable to close plain otool pipe" );
        return NO;
    }
	
    return YES;
}

- (NSString *)pathForTool:(NSString *)toolName {
	
    NSString* relToolBase = [NSString pathWithComponents: [NSArray arrayWithObjects: @"/", @"usr", @"bin", nil]];
    NSString* relToolPath = [relToolBase stringByAppendingPathComponent: toolName];
    NSString* selectToolPath = [relToolBase stringByAppendingPathComponent: @"xcode-select"];
    NSTask* selectTask = [[[NSTask alloc] init] autorelease];
    NSPipe* selectPipe = [NSPipe pipe];
    NSArray* args = [NSArray arrayWithObject: @"--print-path"];
	
    [selectTask setLaunchPath: selectToolPath];
    [selectTask setArguments: args];
	
    [selectTask setStandardOutput: selectPipe];
	
	//The magic line that keeps your log where it belongs
	[selectTask setStandardInput:[NSPipe pipe]];
	
    [selectTask launch];
    [selectTask waitUntilExit];
	
    int selectStatus = [selectTask terminationStatus];
	
    if (selectStatus == -1)
        return relToolPath;
		
    NSData* selectData = [[selectPipe fileHandleForReading] availableData];
    NSString* absToolPath = [[[NSString alloc] initWithBytes:[selectData bytes] length:[selectData length] encoding:NSUTF8StringEncoding] autorelease];
	
    return [[absToolPath stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingPathComponent: relToolPath];
}

@end
