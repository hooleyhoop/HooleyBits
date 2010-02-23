//
//  Rest.h
//  Señor Staff
//
//  Created by Konstantine Prevas on 7/26/06.
//  Copyright 2006 Konstantine Prevas. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NoteBase.h"

@interface Rest : NoteBase { //<NSCopying> {

}

- (id)initWithDuration:(int)_duration dotted:(BOOL)_dotted onStaff:(Staff *)_staff;

@end
