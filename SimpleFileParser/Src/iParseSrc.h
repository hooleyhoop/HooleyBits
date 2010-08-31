//
//  iParseSrc.h
//  SimpleFileParser
//
//  Created by Steven Hooley on 30/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@protocol iParseSrc

- (void)processSrcLine:(NSString *)lineText type:(enum srcLineType)arg;
- (void)noMoreLinesComing;

@end
