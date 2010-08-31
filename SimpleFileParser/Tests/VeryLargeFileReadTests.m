//
//  VeryLargeFileReadTests.m
//  SimpleFileParser
//
//  Created by Steven Hooley on 31/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "GenericTimer.h"
#import "LinesInStringIterator.h"

@interface VeryLargeFileReadTests : SenTestCase {
	
}

@end

@implementation VeryLargeFileReadTests

- (void)eatLine:(NSString *)aLine {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	static NSCharacterSet *wsp;
	if(!wsp)
		wsp = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *strippedline = [aLine stringByTrimmingCharactersInSet:wsp];

	[pool release];
}

- (void)testHighLevelWay {

	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];

	NSError *outError;
	NSString *pathToInputFile = [@"~/Desktop/testData_huge.txt" stringByExpandingTildeInPath];
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	NSString *fileString = [NSString stringWithContentsOfURL:absoluteURL encoding:NSMacOSRomanStringEncoding error:&outError];
	LinesInStringIterator *lineIterator = [LinesInStringIterator iteratorWithString:fileString];
	[lineIterator doIt];
	[lineIterator setConsumer:self];
	
	[readTimer close];  // 12secs
}

#define        MAXLINELENGTH    1024 // Max record size 
#define        BUFSIZE			400000 

long mymin(long a1, long a2) {
	
	return a1 < a2 ? a1 : a2;
}

long ProcessData( id self, char *buf, long bytesread_sizeLeftover, int bLoopCompleted) {
	
	long pos = 0;
	char *hmm = malloc(1024);
	long prevlength = 1024;
	char *offsetBuf = buf;
	NSUInteger amountLeft;
	while( pos<bytesread_sizeLeftover )
	{
		memset(hmm,0,prevlength);
		amountLeft = bytesread_sizeLeftover-pos;
		NSUInteger limit = 1024;
		if(amountLeft<limit)
			limit = amountLeft;
		BOOL wasFound = NO;
	
		for( NSUInteger i=0; i<limit; i++ )
		{
			pos++;
			if(offsetBuf[i]=='\n')
			{
				hmm[i] = '\0';
				wasFound = YES;
				break;
			}
			hmm[i] = offsetBuf[i];
		}
		if(!wasFound) {
			if(bLoopCompleted){
//				NSLog(@"EOF (%s)", hmm);
				[self eatLine:[NSString stringWithCString:hmm encoding:NSUTF8StringEncoding]];
			} else {
//				NSLog(@"end not found? (%s)", hmm);
				pos = pos-amountLeft;
				break;
			}
		} else {
//			NSLog(@"%s", hmm);
			NSString *hmmStr = [[NSString alloc] initWithCString:hmm encoding:NSUTF8StringEncoding];
			[self eatLine:hmmStr];
			[hmmStr release];
			offsetBuf = buf + pos;
		}

	}
	free(hmm);
	return pos;
}

// read a large file
// http://www.softwareprojects.com/resources//t-1636goto.html

- (void)testLowLevelWay {
	
	GenericTimer *readTimer = [[[GenericTimer alloc] init] autorelease];

	long bytesread; 
    char buf[BUFSIZE]; 
    int sizeLeftover=0; 
    int bLoopCompleted = 0; 
    long pos = 0;
	NSString *pathToInputFile = [@"~/Desktop/testData_huge.txt" stringByExpandingTildeInPath];
//	NSString *pathToInputFile = [[NSBundle bundleForClass:[self class]] pathForResource:@"fileReadTest" ofType:@"txt"];
	
	NSURL *absoluteURL = [NSURL fileURLWithPath:pathToInputFile isDirectory:NO];
	FILE *handle = fopen([[absoluteURL path] UTF8String],"r");
	// Open source file 
    if (!handle) 
		STFail(@"Didnt get very far did we?");
    do 
    { 
		// Read next block from file and save into buf, right after the 
		// "left over" buffer 
        bytesread = fread(buf+sizeLeftover, 1, sizeof(buf)-1-sizeLeftover, handle);
        if (bytesread<1)      
        { 
            // Turn on 'loop completed' flag so that we know to exit at the bottom 
            // Still need to process any block we currently have in the 
            // leftover buffer 
            bLoopCompleted = 1; 
            bytesread  = 0; 
        }      
		
		// Add NULL terminator at the end of our buffer 
        buf[bytesread+sizeLeftover] = 0;    
		
		// Process data - Replace with your function 
		// 
		// Function should return the position in the file or -1 if failed 
		// 
		// We are also passing bLoopCompleted to let ProcessData know whether this is 
		// the last record (in which case - if no end-of-record separator, 
		// use eof and process anyway) 
        pos = ProcessData(self, buf, bytesread+sizeLeftover,  bLoopCompleted); 
		
		// If error occured, bail 
        if (pos<1)  
        { 
            bLoopCompleted = 1; 
            pos      = 0; 
        } 
		
		// Set Left over buffer size to 
		// 
		//  * The remaining unprocessed buffer that was not processed 
		//  by ProcessData (because it couldn't find end-of-line) 
		// 
		// For protection if the remaining unprocessed buffer is too big 
		// to leave sufficient room for a new line (MAXLINELENGTH), cap it 
		// at maximumsize - MAXLINELENGTH 
		long var1 = bytesread+sizeLeftover-pos;
		long var2 = sizeof(buf)-MAXLINELENGTH;
        sizeLeftover = mymin( var1, var2);
		
		// Extra protection - should never happen but you can never be too safe 
        if (sizeLeftover<1) 
			sizeLeftover=0;      
		
		// If we have a leftover unprocessed buffer, move it to the beginning of  
		// read buffer so that when reading the next block, it will connect to the 
		// current leftover and together complete a full readable line 
        if (pos!=0 && sizeLeftover!=0) 
			memmove(buf, buf+pos, sizeLeftover); 
		
    } while(!bLoopCompleted); 
	
	// Close file 
	fclose(handle);	
	
	[readTimer close];
	NSLog(@"This is what i want to knows");
}

@end
