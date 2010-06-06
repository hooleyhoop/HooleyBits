//
//  RunLoopContext.h
//  iPhoneFFT
//
//  Created by Steven Hooley on 05/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@class RunLoopSource;

// RunLoopContext is a container object used during registration of the input source.
@interface RunLoopContext : NSObject
{
    CFRunLoopRef			runLoop;
    RunLoopSource			*source;
}
@property (readonly) CFRunLoopRef runLoop;
@property (readonly) RunLoopSource *source;

- (id)initWithSource:(RunLoopSource *)src andLoop:(CFRunLoopRef)loop;

@end

