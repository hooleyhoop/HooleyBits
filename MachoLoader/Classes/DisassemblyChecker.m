//
//  DisassemblyChecker.m
//  MachoLoader
//
//  Created by Steven Hooley on 01/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DisassemblyChecker.h"
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

- (char *)nextLine:(char *)theCLine {
	
	char *result = fgets( theCLine, MAX_LINE_LENGTH, _otoolPipe );
	NSUInteger length = strlen(theCLine);
	NSString *justToSee = [NSString stringWithUTF8String:theCLine];

	// Process each line as it comes in piped from otool
    // while(  )
    // {
        //Line*   theNewLine  = calloc(1, sizeof(Line));
		
        // theNewLine->length  = strlen(theCLine);
        // theNewLine->chars   = malloc(theNewLine->length + 1);
        // strncpy(theNewLine->chars, theCLine, theNewLine->length + 1);
		
        // Add the line to the list.
        // InsertLineAfter(theNewLine, *inLine, inList);
		
        // *inLine = theNewLine;
		
    // }
	return result;
}

- (BOOL)openOTOOL {
	
	// Call otool and have the output piped a line at a time
    return [self populateLineList:nil verbosely:YES fromSection:(char *)"__text" afterLine:nil includingPath:YES];
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
