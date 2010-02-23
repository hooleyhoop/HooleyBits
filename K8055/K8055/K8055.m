/* $Id: K8055.m,v 1.8 2005/09/18 14:41:23 andy Exp $
 *
 * Unless otherwise *explicitly* stated the following text
 * describes the licensed conditions under which the
 * contents of this module release may be distributed:
 *
 * --------------------------------------------------------
 * Redistribution and use in source and binary forms of
 * this module, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain any
 *    existing copyright notice, and this entire permission
 *    notice in its entirety, including the disclaimer of
 *    warranties.
 *
 * 2. Redistributions in binary form must reproduce all
 *    prior and current copyright notices, this list of
 *    conditions, and the following disclaimer in the
 *    documentation and/or other materials provided with
 *    the distribution.
 *
 * 3. The name of any author may not be used to endorse or
 *    promote products derived from this software without
 *    their specific prior written permission.
 *
 * ALTERNATIVELY, this product may be distributed under the
 * terms of the GNU General Public License, in which case
 * the provisions of the GNU GPL are required INSTEAD OF
 * the above restrictions.  (This clause is necessary due
 * to a potential conflict between the GNU GPL and the
 * restrictions contained in a BSD-style copyright.)
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
 * IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * --------------------------------------------------------
 *
 * Copyright Andy Armstrong, andy@hexten.net, 2005
 */

#import "K8055.h"

#import <stdio.h>
#import <unistd.h>
#import <stdlib.h>
#import <ctype.h>
#import <sys/errno.h>
#import <sysexits.h>
#import <mach/mach.h>
#import <mach/mach_error.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/hid/IOHIDLib.h>
#import <IOKit/hid/IOHIDKeys.h>
// #import <Carbon/Carbon.h>
#import <IOKit/usb/IOUSBLib.h>
#import <CoreFoundation/CFNumber.h>
#import <CoreFoundation/CoreFoundation.h>

#define K8055VENDOR         0x10CF
#define K8055PRODUCT        0x5500

#define K8055INPUTCOOKIE    0x02
#define K8055ANALOGCOOKIE   0x04        // and 0x05

#define K8055OUTPUTCOOKIE   0x0A
#define K8055OUTPUTCOOKIES  0x08

#define K8055INPUTBIT0      0x10
#define K8055INPUTBIT1      0x20
#define K8055INPUTBIT2      0x01
#define K8055INPUTBIT3      0x40
#define K8055INPUTBIT4      0x80

static void queueCallback(void *target, IOReturn result, void *ref, void *sender);

@interface K8055 (Private)

+ (io_iterator_t) getIteratorForDevice: (int) device;
+ (io_iterator_t) getIterator;
- (void) syncDeviceOutput;
- (int) translateInput: (int) input;
- (void) gotEvent;
- (int) readRaw: (int) cookie;

@end

@implementation K8055 (Private)

+ (io_iterator_t) getIteratorForDevice: (int) device {
    NSMutableDictionary *matcher        = nil;
    IOReturn            rc;
    io_iterator_t       iter;

    matcher = (NSMutableDictionary *) IOServiceMatching(kIOHIDDeviceKey);
    if (matcher == nil) {
        [NSException raise: NSGenericException 
                    format: @"Can't create matching dictionary"];
    }
    
    [matcher setObject: [NSNumber numberWithInt: K8055VENDOR]
                forKey: [NSString stringWithCString: kIOHIDVendorIDKey]];
    
    if (device != -1) {
        // If the device is specified add it to the matching dictionary. If
        // no device is specified this will return an iterator that matches
        // all devices with the Velleman vendor id.
        
        if (device < 0 || device >= MAXDEVICE) {
            [NSException raise: NSGenericException 
                        format: @"Illegal device id: %d (0 to %d allowed)",
                                device, MAXDEVICE];
        }
        
        [matcher setObject: [NSNumber numberWithInt: K8055PRODUCT + device]
                    forKey: [NSString stringWithCString: kIOHIDProductIDKey]];
        
    }

    rc = IOServiceGetMatchingServices(kIOMasterPortDefault, (CFMutableDictionaryRef) matcher, &iter);
    if (rc != kIOReturnSuccess) {
        [NSException raise: NSGenericException 
                    format: @"Failed to get iterator (0x%lx)", (long) rc];
    }
    
    return iter;
}

+ (io_iterator_t) getIterator {
    return [self getIteratorForDevice: -1];
}

- (void) syncDeviceOutput {
    int cmd[4], i;
    IOReturn rc = kIOReturnSuccess;

    cmd[0] = 0x05;
    cmd[1] = output;
    cmd[2] = pwm[0];
    cmd[3] = pwm[1];
    
    for (i = 0; rc == kIOReturnSuccess && i < sizeof(cmd) / sizeof(cmd[0]); i++) {
        IOHIDElementCookie cookie = (IOHIDElementCookie) (i + K8055OUTPUTCOOKIE);
        IOHIDEventStruct ev;
        memset(&ev, 0, sizeof(ev));
        ev.elementCookie = cookie;
        ev.value = cmd[i];
        rc = (*transaction)->setElementValue(transaction, cookie, &ev);
    }
    
    if (rc == kIOReturnSuccess) {
        rc = (*transaction)->commit(transaction, 1000, nil, nil, nil);
    }

    if (rc != kIOReturnSuccess) {
        [NSException raise: NSGenericException 
                    format: @"Transaction failed (0x%08lx)",
            (long) rc];
    }
}

- (int) translateInput: (int) inp {
    return ((inp & K8055INPUTBIT0) ? (1 << 0) : 0) |
           ((inp & K8055INPUTBIT1) ? (1 << 1) : 0) |
           ((inp & K8055INPUTBIT2) ? (1 << 2) : 0) |
           ((inp & K8055INPUTBIT3) ? (1 << 3) : 0) |
           ((inp & K8055INPUTBIT4) ? (1 << 4) : 0);
}

- (void) gotEvent {
	IOHIDEventStruct    event;
    IOReturn            rc          = kIOReturnSuccess;
    AbsoluteTime		zeroTime    = { 0, 0 };
    int                 got         = 0;

    while (rc = (*queue)->getNextEvent(queue, &event, zeroTime, 0), rc == kIOReturnSuccess) {
        int bumped, i;
        got |= 1 << (int) event.elementCookie;
        switch ((int) event.elementCookie) {
            case K8055INPUTCOOKIE:
                bumped = input;
                input = [self translateInput: (int) event.value];
                bumped = (input ^ bumped) & input;
                for (i = 0; i < MAXINPUT; i++) {
                    if (bumped & (1 << i)) {
                        inputCount[i]++;
                    }
                }
                break;
            case K8055ANALOGCOOKIE + 0:
                analog[0] = (int) event.value;
                break;
            case K8055ANALOGCOOKIE + 1:
                analog[1] = (int) event.value;
                break;
        }
    }
    
    if (got & (1 << K8055INPUTCOOKIE)) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName: @"InputChanged" object:self];
    }
        
    if (got & (3 << K8055ANALOGCOOKIE + 0)) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName: @"AnalogChanged" object:self];
    }
        
    eventMask |= got;
}

- (int) readRaw: (int) cookie {
	IOHIDEventStruct    event;
    IOReturn            rc;
    
    rc = (*interface)->getElementValue(interface,
                       (IOHIDElementCookie) cookie, &event);

    if (rc != kIOReturnSuccess) {
        [NSException raise: NSGenericException 
                    format: @"Device read failed (0x%08lx)",
            (long) rc];
    }
    
    return (int) event.value;
}

@end

@implementation K8055

+ (int) findDevices {
    io_iterator_t iter;
    int devices = 0;
    
    iter = [self getIterator];
    if (iter != nil) {
        io_object_t dev;
        while (dev = IOIteratorNext(iter), dev != nil) {
            kern_return_t rc;
            NSMutableDictionary *props;

            rc = IORegistryEntryCreateCFProperties(dev, 
                                                   (CFMutableDictionaryRef *) &props,
                                                   kCFAllocatorDefault, kNilOptions); 
            if (rc != KERN_SUCCESS) {
                [NSException raise: NSGenericException 
                            format: @"Failed to get properties (0x%lx)", (long) rc];
            }
            
            if (props != nil) {
                NSString *prod = [props objectForKey: 
                    [NSString stringWithCString: kIOHIDProductIDKey]];
                int device = [prod intValue];
                // Check that it's a K8055
                if (device >= K8055PRODUCT && device < K8055PRODUCT + MAXDEVICE) {
                    devices |= (1 << (device - K8055PRODUCT));
                }
                
                CFRelease(props);
            }
        }
        
		IOObjectRelease(iter);
    }
        
    return devices;
}

- (id) initWithDevice: (int) device {
    if (self = [super init]) {
        IOCFPlugInInterface     **plugIn;
        CFRunLoopSourceRef 		eventSource;
        SInt32                  score       = 0;
        IOReturn                rc;
        HRESULT                 prc;
        io_iterator_t           iter;
        io_object_t             dev;
        int                     i;
        
        static IOHIDElementCookie inputCookies[] = {
            (IOHIDElementCookie) K8055INPUTCOOKIE,
            (IOHIDElementCookie) K8055ANALOGCOOKIE + 0,
            (IOHIDElementCookie) K8055ANALOGCOOKIE + 1
        };

        if (device < 0 || device >= MAXDEVICE) {
            [NSException raise: NSGenericException 
                        format: @"Illegal device id: %d (0 to %d allowed)",
                device, MAXDEVICE];
        }
        
        dev = nil;
        iter = [K8055 getIteratorForDevice: device];
        if (iter != nil) {
            dev = IOIteratorNext(iter);
            IOObjectRelease(iter);
        }
        
        if (dev == nil) {
            [NSException raise: NSGenericException 
                        format: @"Device %d unavailable",
                        device];
        }
        
        rc = IOCreatePlugInInterfaceForService(dev,
                                               kIOHIDDeviceUserClientTypeID,
                                               kIOCFPlugInInterfaceID,
                                               &plugIn, &score);
        if (rc != kIOReturnSuccess) {
            [NSException raise: NSGenericException 
                        format: @"Failed to create plugin interface (%lx)",
                        (long) rc];
        }

        prc = (*plugIn)->QueryInterface(plugIn,
                                         CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID),
                                         (LPVOID) &interface);
        (*plugIn)->Release(plugIn);

        if (prc != S_OK) {
            [NSException raise: NSGenericException 
                        format: @"Failed to query plugin interface (%lx)",
                (long) prc];
        }

        rc = (*interface)->open(interface, 0);
        if (rc != kIOReturnSuccess) {
            (*interface)->Release(interface);
            interface = nil;
            [NSException raise: NSGenericException 
                        format: @"Failed to open interface (%lx)",
                        (long) rc];
        }
        
        // Since we're on a roll create the transaction too.
        transaction = (*interface)->allocOutputTransaction(interface);
        if (transaction == nil) {
            [NSException raise: NSGenericException 
                        format: @"Failed to create transaction"];
        }
        
        rc = (*transaction)->create(transaction);

        for (i = 0; rc == kIOReturnSuccess && i < K8055OUTPUTCOOKIES; i++) {
            IOHIDElementCookie cookie = (IOHIDElementCookie) (i + K8055OUTPUTCOOKIE);
            rc = (*transaction)->addElement(transaction, cookie);
            if (rc == kIOReturnSuccess) {
                IOHIDEventStruct ev;
                memset(&ev, 0, sizeof(ev));
                ev.elementCookie = cookie;
                ev.value = 0;
                rc = (*transaction)->setElementDefault(transaction, cookie, &ev);
            }
            
        }

        if (rc != kIOReturnSuccess) {
            [NSException raise: NSGenericException 
                        format: @"Failed to create transaction (%lx)",
                (long) rc];
        }
        
        // Reset the output state of the device
        [self syncDeviceOutput];
        
        // Make the queue
        queue = (*interface)->allocQueue(interface);
        if (queue == nil) {
            [NSException raise: NSGenericException 
                        format: @"Failed to create input queue"];
            
        }

        rc = (*queue)->create(queue, 0, 8);
        for (i = 0; rc == kIOReturnSuccess &&
                    i < sizeof(inputCookies) / sizeof(inputCookies[0]); i++) {
            rc = (*queue)->addElement(queue, inputCookies[i], 0);
        }
        
        if (rc == kIOReturnSuccess) {
            rc = (*queue)->start(queue);
        }

        if (rc == kIOReturnSuccess) {
            rc = (*queue)->createAsyncEventSource(queue, &eventSource);
        }

        if (rc == kIOReturnSuccess) {
            rc = (*queue)->setEventCallout(queue, queueCallback, NULL, self);
        }
        
        if (rc != kIOReturnSuccess) {
            [NSException raise: NSGenericException 
                        format: @"Failed to build input queue (%lx)",
                (long) rc];
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), eventSource,
                           kCFRunLoopDefaultMode);

        // Send notifications
        [[NSNotificationCenter defaultCenter]
            postNotificationName: @"InputChanged" object:self];

        [[NSNotificationCenter defaultCenter]
            postNotificationName: @"AnalogChanged" object:self];
        
    }
    
    return self;
}

- (void) dealloc {
    
    if (queue != nil) {
        (void) (*queue)->stop(queue);
        (void) (*queue)->dispose(queue);
        (*queue)->Release(queue);
    }
    
    if (transaction != nil) {
        (*transaction)->clear(transaction);     // Necessary?
        (*transaction)->Release(transaction);
    }
    
    if (interface != nil) {
        (*interface)->close(interface);
        (*interface)->Release(interface);
    }
    
    // close device
    [super dealloc];
}

- (int) getOutput {
    return output;
}

- (void) setOutput: (int) outp {
    if (output != outp) {
        output = outp;
        [self syncDeviceOutput];
    }
}

- (int) getInput {
    if (eventMask == 0) {
        // If we haven't received any events we assume that we haven't
        // started a run loop so we read the input directly. As soon as
        // input events start we switch to event drive mode.
        input = [self translateInput: [self readRaw: K8055INPUTCOOKIE]];
    }
    
    return input;
}

- (void) setAnalog: (int) value
         onChannel: (int) channel {
    if (channel < 0 || channel >= MAXPWM) {
        [NSException raise: NSGenericException 
                    format: @"Illegal channel: %d (0 to %d allowed)",
            channel, MAXPWM];
    }
    
    if (pwm[channel] != value) {
        pwm[channel] = value;
        [self syncDeviceOutput];
    }
}

- (int) getAnalog: (int) channel {
    if (channel < 0 || channel >= MAXANALOG) {
        [NSException raise: NSGenericException 
                    format: @"Illegal channel: %d (0 to %d allowed)",
            channel, MAXPWM];
    }

    if (eventMask == 0) {
        // See comment in getInput above
        analog[channel] = [self readRaw: K8055ANALOGCOOKIE + channel];
    }
    
    return analog[channel];
}

- (long) getCount: (int) channel {
    if (channel < 0 || channel >= MAXINPUT) {
        [NSException raise: NSGenericException 
                    format: @"Illegal channel: %d (0 to %d allowed)",
            channel, MAXPWM];
    }

    return inputCount[channel];
}

- (long) resetCount: (int) channel {
    long v = [self getCount: channel];
    inputCount[channel] = 0;

    [[NSNotificationCenter defaultCenter]
            postNotificationName: @"InputChanged" object:self];

    return v;
}

- (void) resetCounts {
    int i;
    for (i = 0; i < MAXINPUT; i++) {
        (void) [self resetCount: i];
    }
}

- (void) switchOff {
    [self setOutput: 0];
    [self setAnalog: 0
          onChannel: 0];
    [self setAnalog: 0
          onChannel: 1];
}


@end

static void queueCallback(void *target, IOReturn result, void *ref, void *sender) {
    K8055 *k8055 = (K8055 *) ref;
    [k8055 gotEvent];
}
