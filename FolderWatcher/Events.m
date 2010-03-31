/*
 *  $Id: Events.m 45 2009-11-27 01:04:03Z stuart $
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

#import "SCEvents.h"
#import "Controller.h"

int main(int argc, const char *argv[]) 
{
    /**
	 * Please note that this program is merely an example of using the 
	 * SCEvents wrapper and so the run loop created will run forever until
     * it is terminated. 
     *
     * This program's contollrer (Controller.m) simply implements
     * SCEventListenerProtocol and prints the events that SCEvents notifies
     * it off. As an example, to generate some events simply run some appliacations 
     * or create/edit some files under the root directory that is being
     * watached (your home directory by default).
     */
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    Controller *controller = [[[Controller alloc] init] autorelease];
    
    [controller setupEventListener];
    
    [[NSRunLoop currentRunLoop] run];
    
    [pool release];
    
    return 0;
}
