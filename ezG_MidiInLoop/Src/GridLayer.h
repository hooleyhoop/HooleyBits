//
//  GridLayer.h
//  MidiInLoop
//
//  Created by steve hooley on 15/09/2008.
//  Copyright 2008 BestBefore Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface GridLayer : CALayer {

	int		_numberOfCols;
	NSTimer	*_addColTimer;
}

@end
