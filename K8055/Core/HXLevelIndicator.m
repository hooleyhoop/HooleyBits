/* $Id: HXLevelIndicator.m,v 1.1 2005/09/18 23:42:34 andy Exp $
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

#import "HXLevelIndicator.h"

static NSString *imgName[] = {
    @"bar", @"left", @"trough", @"right"
};

enum {
     BAR, LEFT, TROUGH, RIGHT, MAX
};

@implementation HXLevelIndicator

- (void) drawRect: (NSRect) rect {
    int i;
    NSImage *img[MAX];
    NSSize  size[MAX];
    for (i = 0; i < MAX; i++) {
        img[i] = [NSImage imageNamed: imgName[i]];
        size[i] = [img[i] size];
        [img[i] setFlipped: [self isFlipped]];
    }
    
    NSRect bounds = [self bounds];
    float barLen = bounds.size.width - size[LEFT].width - size[RIGHT].width;
    
    [img[LEFT] drawInRect: NSMakeRect(0, 0, size[LEFT].width, bounds.size.height)
                 fromRect: NSMakeRect(0, 0, size[LEFT].width, size[LEFT].height)
                operation: NSCompositeSourceOver
                 fraction: 1.0];
    
    [img[TROUGH] drawInRect: NSMakeRect(size[LEFT].width, 0, barLen, bounds.size.height)
                   fromRect: NSMakeRect(0, 0, size[TROUGH].width, size[TROUGH].height)
                  operation: NSCompositeSourceOver
                   fraction: 1.0];
    
    [img[RIGHT] drawInRect: NSMakeRect(size[LEFT].width + barLen, 0, size[RIGHT].width, bounds.size.height)
                  fromRect: NSMakeRect(0, 0, size[RIGHT].width, size[RIGHT].height)
                 operation: NSCompositeSourceOver
                  fraction: 1.0];
    
    barLen = barLen * level / 255;
    float shift = (bounds.size.height - size[BAR].height) / 2;
    
    [img[BAR] drawInRect: NSMakeRect(size[LEFT].width, shift, barLen, size[BAR].height)
                fromRect: NSMakeRect(0, 0, size[BAR].width, size[BAR].height)
               operation: NSCompositeSourceOver
                fraction: 1.0];
    
//    bounds.size.width = bounds.size.width * level / 255;
//    
//    [img drawInRect: bounds
//           fromRect: NSMakeRect(0, 0, size.width, size.height)
//          operation: NSCompositeSourceOver
//           fraction: 1.0];
}

- (int) getLevel {
    return level;
}

- (void) setLevel: (int) l {
    if (l > 255) {
        l = 255;
    } else if (l < 0) {
        l = 0;
    }
    if (level != l) {
        level = l;
        [self setNeedsDisplay: YES];
    }
}

@end
