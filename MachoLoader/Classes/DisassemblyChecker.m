//
//  DisassemblyChecker.m
//  MachoLoader
//
//  Created by Steven Hooley on 01/10/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "DisassemblyChecker.h"
#import <sys/param.h>


@implementation DisassemblyChecker

- (id)initWithPath:(NSString *)aPath {
	
	self = [super init];
	if(self) {
		_filePath = [aPath retain];
		[self populateLineLists];
	}
	return self;
}

- (void)dealloc {
	[_filePath release];
	[super dealloc];
}

- (BOOL)populateLineLists {
	
	// Call otool and have the output piped a line at a time
    [self populateLineList:nil verbosely:YES fromSection:"__text" afterLine:nil includingPath:YES];
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
    if(iExeIsFat)
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
	
    NSString* oPath = [iOFile path];
    NSString* otoolString = [NSString stringWithFormat:@"%s %s -s __TEXT %s \"%@\"%s", cmdString, (inVerbose) ? "-V" : "-v", inSectionName, oPath, (inIncludePath) ? "" : " | sed '1 d'"];
    FILE* otoolPipe = popen(UTF8STRING(otoolString), "r");
	
    if (!otoolPipe)
    {
        fprintf(stderr, "otx: unable to open %s otool pipe\n", (inVerbose) ? "verbose" : "plain");
        return NO;
    }
	
    char theCLine[MAX_LINE_LENGTH];
	
    // Process each line as it comes in piped from otool
    while( fgets(theCLine, MAX_LINE_LENGTH, otoolPipe) )
    {
        //Line*   theNewLine  = calloc(1, sizeof(Line));
		
        // theNewLine->length  = strlen(theCLine);
        // theNewLine->chars   = malloc(theNewLine->length + 1);
        // strncpy(theNewLine->chars, theCLine, theNewLine->length + 1);
		
        // Add the line to the list.
        // InsertLineAfter(theNewLine, *inLine, inList);
		
        // *inLine = theNewLine;
    }
	
    if( pclose(otoolPipe) == -1 )
    {
        perror((inVerbose) ? "otx: unable to close verbose otool pipe" : "otx: unable to close plain otool pipe");
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
