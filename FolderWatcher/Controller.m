/*
 *  $Id: Controller.m 46 2009-11-28 23:14:41Z stuart $
 *
 *  SCEvents
 *
 *  Copyright (c) 2009 Stuart Connolly
 *  http://stuconnolly.com/projects/source-code/
 *
 *  Permission is hereby granted, free of charge, to any person
 *  obtaining a copy of this software and associated documentation
 *  files (the "Software"), to deal in the Software without
 *  restriction, including without limitation the rights to use,
 *  copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following
 *  conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *  OTHER DEALINGS IN THE SOFTWARE.
 */

#import "Controller.h"
#import "SCEvents.h"
#import "SCEvent.h"
#import "ApplescriptUtils.h"

@implementation Controller

/**
 * Sets up the event listener using SCEvents and sets its delegate to this controller.
 * The event stream is started by calling startWatchingPaths: while passing the paths
 * to be watched.
 */
- (void)setupEventListener
{
    SCEvents *events = [SCEvents sharedPathWatcher];
    
    [events setDelegate:self];
    
    NSMutableArray *paths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Sites/compass/my_site"]];
    NSMutableArray *excludePaths = [NSMutableArray arrayWithObject:[NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"]];
    
	// Set the paths to be excluded
	[events setExcludedPaths:excludePaths];
	
	// Start receiving events
	[events startWatchingPaths:paths];

	// Display a description of the stream
	NSLog(@"%@", [events streamDescription]);	
}

/**
 * This is the only method to be implemented to conform to the SCEventListenerProtocol.
 * As this is only an example the event received is simply printed to the console.
 */
- (void)pathWatcher:(SCEvents *)pathWatcher eventOccurred:(SCEvent *)event {

    NSLog(@"%@", event);
	
	BOOL result = NO;
	NSAppleScript *appleScript = [ApplescriptUtils applescript:@"ReloadBrowser"];
	NSDictionary *errors = [NSDictionary dictionary];
	NSAppleEventDescriptor *parameters = nil;
	NSAppleEventDescriptor* event2 = [ApplescriptUtils eventForApplescriptMethod:@"reloadWindow" arguments:parameters];
	
	// call the event in AppleScript
	NSAppleEventDescriptor *resultEvent = [appleScript executeAppleEvent:event2 error:&errors];
	if(!resultEvent)
	{
		// report any errors from 'errors'
		[NSException raise:@"Fucked up applescript" format:@""];
	}
	// successful execution
	if (kAENullEvent != [resultEvent descriptorType])
	{
		// script returned an AppleScript result
		if (cAEList == [resultEvent descriptorType])
		{
			// result is a list of other descriptors
			NSLog(@"who?");
		}
		else
		{
			// coerce the result to the appropriate ObjC type
			NSLog(@"doobie doo? %@", resultEvent);
			result = [resultEvent booleanValue];
		}
	}
}

@end
