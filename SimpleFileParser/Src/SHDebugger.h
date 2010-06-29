//
//  SHDebugger.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 17/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "SHDebugger.h"
#import <LLDB/LLDB.h>


@interface SHDebugger : NSObject {

	lldb::SBDebugger *m_debugger;

}

- (void)goforit;

@end
