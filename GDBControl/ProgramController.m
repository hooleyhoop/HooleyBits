//
//  ProgramController.m
//  GDBControl
//
//  Created by Steven Hooley on 06/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ProgramController.h"


@implementation ProgramController

- (void)tryGDB
{
    NSDictionary *defaultEnvironment = [[NSProcessInfo processInfo] environment];
    NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithDictionary:defaultEnvironment];
    gdbTask = [[NSTask alloc] init];
	
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    NSString *toolPath = @"/usr/bin/gdb";
    NSArray *arguments = [[NSArray alloc] initWithObjects:@"/Applications/Chess.app/", nil];

    [defaultCenter addObserver:self selector:@selector(taskCompleted:) name:NSTaskDidTerminateNotification object:gdbTask];
    [gdbTask setLaunchPath:toolPath];
    [gdbTask setArguments:arguments];
    [environment setObject:@"YES" forKey:@"NSUnbufferedIO"];
    [gdbTask setEnvironment:environment];
    outputPipe = [NSPipe pipe];
    taskOutput = [outputPipe fileHandleForReading];
    [defaultCenter addObserver:self selector:@selector(taskDataAvailable:) name:NSFileHandleReadCompletionNotification object:taskOutput];
    [gdbTask setStandardOutput:outputPipe];
    [gdbTask setStandardError:outputPipe];
    
    inputPipe = [NSPipe pipe];
    taskInput = [inputPipe fileHandleForWriting];
    [gdbTask setStandardInput:inputPipe];
    
    [gdbTask launch];
    [taskOutput readInBackgroundAndNotify];
    
    [arguments release];
    [environment release];
}

- (void)killTask
{
    if ([gdbTask isRunning])
        [gdbTask terminate];
}

- (void)taskCompleted:(NSNotification *)notif
{
    int exitCode = [[notif object] terminationStatus];
    
    if (exitCode != 0)
        NSLog(@"Error: Task exited with code %d", exitCode);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Do whatever else you need to do when the task finished
}

- (void)taskDataAvailable:(NSNotification *)notif
{
    NSData *incomingData = [[notif userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (incomingData && [incomingData length])
    {
        NSString *incomingText = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
        // Do whatever with incomingText, the string that has some text in it
        [taskOutput readInBackgroundAndNotify];
        [incomingText release];
        return;
    }
}


- (void)sendData:(NSString *)dataString
{
    [taskInput writeData:[dataString dataUsingEncoding:[NSString defaultCStringEncoding]]];
}

- (void)awakeFromNib
{
	NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/ls"];
	
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"-l", @"-a", @"-t", nil];
    [task setArguments: arguments];
	[task setCurrentDirectoryPath:NSHomeDirectory()];
	 
	NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	[task setStandardError: pipe];

    NSFileHandle *file;
    file = [pipe fileHandleForReading];
	
    [task launch];
	
    NSData *data;
    data = [file readDataToEndOfFile];
	
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"got\n%@", string);
	
	[self tryGDB];
}

@end
