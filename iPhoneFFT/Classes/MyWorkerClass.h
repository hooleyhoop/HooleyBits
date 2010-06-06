//
//  MyWorkerClass.h
//  iPhoneFFT
//
//  Created by Steven Hooley on 05/06/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface MyWorkerClass : NSObject <NSPortDelegate> {

	NSPort		*_remotePort;
}

- (void)sendCheckinMessage:(NSPort *)outPort;

@end
