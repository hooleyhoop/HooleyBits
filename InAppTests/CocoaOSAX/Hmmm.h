/*
 *  Hmmm.h
 *  CocoaOSAX
 *
 *  Created by steve hooley on 21/01/2010.
 *  Copyright 2010 BestBefore Ltd. All rights reserved.
 *
 */

//#import <CoreServices/CoreServices.h>
//#import <ApplicationServices/ApplicationServices.h>

OSErr monkeeeeHandler( const AppleEvent *message, AppleEvent *reply, long refCon );
OSErr mouseDoubleClick_Handler( const AppleEvent *message, AppleEvent *reply, long refCon );
OSErr mouseClick_Handler( const AppleEvent *message, AppleEvent *reply, long refCon );
OSErr mouseDownAt_upAt_Handler( const AppleEvent *message, AppleEvent *reply, long refCon );