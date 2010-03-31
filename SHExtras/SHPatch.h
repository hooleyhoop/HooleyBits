//
//  SHPatch.h
//  SHExtras
//
//  Created by Steven Hooley on 17/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"

@interface QCPatch (SHPatch)

- (NSString*) name;
- (void) setName:(NSString*)aName;

- (NSString*) classAsString;

- (BOOL) isSelected;

@end
