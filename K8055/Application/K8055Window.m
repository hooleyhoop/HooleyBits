/* $Id: K8055Window.m,v 1.5 2005/09/18 23:42:50 andy Exp $
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

#import "K8055Window.h"

@interface K8055Window (Private)

- (void) analogChanged: (NSNotification *) notification;
- (void) inputChanged: (NSNotification *) notification;
    
@end

@implementation K8055Window (Private)

- (void) analogChanged: (NSNotification *) notification {
    //NSLog(@"Analog changed");
    [analog1 setLevel: [k8055 getAnalog: 0]];
    [analog2 setLevel: [k8055 getAnalog: 1]];
}

- (void) inputChanged: (NSNotification *) notification {
    int bits = [k8055 getInput];
    //NSLog(@"Input changed");
    [input1 setState: (bits >> 0) & 1];
    [input2 setState: (bits >> 1) & 1];
    [input3 setState: (bits >> 2) & 1];
    [input4 setState: (bits >> 3) & 1];
    [input5 setState: (bits >> 4) & 1];
    [count1 setIntValue: (int) [k8055 getCount: 0]];
    [count2 setIntValue: (int) [k8055 getCount: 1]];
    [count3 setIntValue: (int) [k8055 getCount: 2]];
    [count4 setIntValue: (int) [k8055 getCount: 3]];
    [count5 setIntValue: (int) [k8055 getCount: 4]];
}

@end

@implementation K8055Window

- (id) initWithContentRect: (NSRect) contentRect 
                 styleMask: (unsigned int) styleMask 
                   backing: (NSBackingStoreType) backingType 
                     defer: (BOOL) flag {
    if (self = [super initWithContentRect: contentRect
                                styleMask: styleMask
                                  backing: backingType
                                    defer: flag]) {
        int avail = [K8055 findDevices];
        if (avail != 0) {
            int device = 0;
            while ((avail & 1) == 0) {
                device++;
                avail >>= 1;
            }
            
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(analogChanged:)
                                                         name: @"AnalogChanged"
                                                       object:nil];

            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(inputChanged:)
                                                         name: @"InputChanged"
                                                       object:nil];
            
            k8055 = [[K8055 alloc] initWithDevice: device];

            //[self analogChanged: nil];
            //[self inputChanged: nil];
        }
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [k8055 release];
    [super dealloc];
}

- (IBAction) outputChanged: (id) sender {
    NSButton *button = (NSButton *) sender;
    int mask = 1 << [button tag];
    int bit  = [button state] << [button tag];
    int op   = [k8055 getOutput];
    [k8055 setOutput: (op & ~mask) | bit];
}

- (IBAction) pwmChanged: (id) sender {
    NSSlider *slider = (NSSlider *) sender;
    int channel = [slider tag];
    int level   = [slider intValue];
    [k8055 setAnalog: level
           onChannel: channel];
}

- (IBAction) resetCounts: (id) sender {
    [k8055 resetCounts];
}

- (IBAction) switchOff: (id) sender {
    [output1 setIntValue: 0];
    [output2 setIntValue: 0];
    [output3 setIntValue: 0];
    [output4 setIntValue: 0];
    [output5 setIntValue: 0];
    [output6 setIntValue: 0];
    [output7 setIntValue: 0];
    [output8 setIntValue: 0];
    [pwm1 setIntValue: 0];
    [pwm2 setIntValue: 0];
    [k8055 switchOff];
}

@end
