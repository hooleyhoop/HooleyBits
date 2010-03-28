/*
 *  Hmmm.c
 *  CocoaOSAX
 *
 *  Created by steve hooley on 21/01/2010.
 *  Copyright 2010 BestBefore Ltd. All rights reserved.
 *
 */

#import "Hmmm.h"
#import <Carbon/Carbon.h>

//__attribute__((constructor))
//static void initialize_navigationBarImages() {
//	//	NSApplicationLoad();
//}
//
//__attribute__((destructor))
//static void destroy_navigationBarImages() {
//	
//}

//		Size theLength = AEGetDescDataSize(&theDesc);
//		Ptr theData = malloc(theLength);		
//		result = AEGetDescDataRange( &theDesc, theData, 16, 4) ;
//		result = AEGetDescData( &theDesc, theData, theLength );
//		if ( result==noErr ) {
//			int32_t *intData = theData;
//			int32_t p1 = (intData[0]);
//			uint32 p2 = intData[1];
//		}

// get al args
// for( SInt32 i=1; i!=numberOfItems+1; ++i){
// AEGetNthPtr( &theDesc, i, typeSInt32, NULL, NULL, &outTemp, sizeof(outTemp), NULL );
// }

void gerParam( const AppleEvent *message, uint32 thingy, CGPoint *p ) {
	
	AEDesc theDesc;
	OSErr result = noErr;
    result=AEGetParamDesc(message, thingy, typeAEList, &theDesc);
	if(!result){
		long numberOfItems;
		AECountItems( &theDesc, &numberOfItems );
		NSCAssert( numberOfItems, @"wrong number of terms" );
		
		int32_t xPoint, yPoint;
		AEGetNthPtr( &theDesc, 1, typeSInt32, NULL, NULL, &xPoint, sizeof(xPoint), NULL );
		AEGetNthPtr( &theDesc, 2, typeSInt32, NULL, NULL, &yPoint, sizeof(yPoint), NULL );
		p->x = (CGFloat)xPoint;
		p->y = (CGFloat)yPoint;
		
		AEDisposeDesc(&theDesc);
	}
}

void getDirectParamPoint( const AppleEvent *message, CGPoint *p ) {
	
	gerParam( message, keyDirectObject, p);
}

void getFirstParamPoint( const AppleEvent *message, CGPoint *p ) {
	
	gerParam( message, 'x$$$', p);
}

// fill in *reply to send data 
//1) Use AECreateList to create an empty list
//2) Use AEPutPtr or AEPutDesc to add items to the list
//3) Use AEPutKeyDesc to put the list into the reply input parameter of the
//Apple event handler, using the AEKeyword keyDirectObject
//>>Despite the fact that their constants are the same, I recommend keyAEResult instead. ;)

OSErr mouseClickAt_Handler( const AppleEvent *message, AppleEvent *reply, long refCon ){

	OSErr result = noErr;
	
	CGPoint p1;
	getDirectParamPoint( message, &p1 );

	AEDesc theDesc;
    result=AEGetParamDesc( message, 'x$$3', typeAEList, &theDesc );
	if(!result){
		
		// Using Shift Down
		long numberOfItems;
		AECountItems( &theDesc, &numberOfItems );
		NSCAssert( numberOfItems, @"wrong number of terms" );

		AEKeyword aekw='x$$3';
		
		Size dataSize;
		result = AESizeOfParam( message, aekw, NULL, &dataSize );
		
		int32_t val;
		result = AEGetParamPtr( message, aekw, typeWildCard, NULL, &val, dataSize, NULL );		
		
//		val = EndianS32_NtoB(val);

		
//
//		AEDesc argumentDescription;
//		result = AEGetNthDesc( &theDesc, 1, typeWildCard, &aekw, &argumentDescription );
//		
//		Size dataSize2; // 4
//		result = AESizeOfNthItem( &theDesc, 1, NULL, &dataSize2 );		
//		
//		int32_t xPoint, yPoint;
//		result = noErr;
//		result = AEGetNthPtr( &theDesc, 1, typeSInt32, NULL, NULL, &xPoint, sizeof(xPoint), NULL );
//		
		
		
//		AEGetNthPtr( &theDesc, 1, typeSInt32, NULL, NULL, &val, 1024, NULL );
//		AEGetNthPtr( &theDesc, 2, typeSInt32, NULL, NULL, &yPoint, sizeof(yPoint), NULL );
//		p->x = (CGFloat)xPoint;
//		p->y = (CGFloat)yPoint;
		
		AEDisposeDesc(&theDesc);
	}
		
	
	// Send clicks
	CGEventRef theEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );  
	CGEventSetIntegerValueField( theEvent, kCGMouseEventClickState, 2 );
	CGEventPost(kCGHIDEventTap, theEvent);  
	
	CGEventSetType(theEvent, kCGEventLeftMouseUp);
	CGEventPost(kCGHIDEventTap, theEvent);
	
	CFRelease(theEvent); 
	NSBeep();
	return result;
}

OSErr mouseDownAt_upAt_Handler( const AppleEvent *message, AppleEvent *reply, long refCon ){
	
	OSErr result = noErr;
	
	CGPoint p1, p2;
	getDirectParamPoint( message, &p1 );
	getFirstParamPoint( message, &p2 );
	
	CGAssociateMouseAndMouseCursorPosition(false);

	// move to down pt
	CGEventRef theMoveEvent = CGEventCreateMouseEvent( NULL, kCGEventMouseMoved, p1, kCGMouseButtonLeft ); 
	CGEventSetType( theMoveEvent, kCGEventMouseMoved);
	CGEventSetFlags( theMoveEvent,0 ); // Cancel any of the modifier keys - this caused me a day of bug-hunting!
	CGEventPost( kCGHIDEventTap, theMoveEvent );  

	// click down
	CGEventRef theClickEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );
	CGEventSetType( theClickEvent, kCGEventLeftMouseDown );
	CGEventSetIntegerValueField( theClickEvent, kCGMouseEventClickState, 1 );
	CGEventPost( kCGHIDEventTap, theClickEvent );  

	// drag to up pt
	CGEventRef theDragEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDragged, p2, kCGMouseButtonLeft ); 
	CGEventSetType( theDragEvent, kCGEventLeftMouseDragged );
	CGEventPost( kCGHIDEventTap, theDragEvent );  

	// click up - has to be the same event as the mouse down?
	CGEventSetType( theClickEvent, kCGEventLeftMouseUp );
	CGEventSetLocation( theClickEvent, p2 );
	CGEventPost( kCGHIDEventTap, theClickEvent );

//	AXUIElementCopyElementAtPosition
//	AXUIElementGetPid

//	CGEventRef theEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p2, kCGMouseButtonLeft );  
//	CGEventSetIntegerValueField( theEvent, kCGMouseEventClickState, 1 );
//	CGEventPost(kCGHIDEventTap, theEvent);  
//	
//	CGEventSetType(theEvent, kCGEventLeftMouseUp);
//	CGEventPost(kCGHIDEventTap, theEvent);

	// v2
//	CGEventRef theClickEvent = CGEventCreateMouseEvent( NULL, kCGEventMouseMoved, p1, kCGMouseButtonLeft );
//	CGEventSetType( theClickEvent, kCGEventMouseMoved);
//	CGEventSetFlags( theClickEvent, 0 ); // Cancel any of the modifier keys - this caused me a day of bug-hunting!
//	CGEventPost( kCGHIDEventTap, theClickEvent );  
//	usleep(100000); // wait 0.1 sec
//
//	CGEventSetType( theClickEvent, kCGEventLeftMouseDown );
//	CGEventSetIntegerValueField( theClickEvent, kCGMouseEventClickState, 1 );
//	CGEventSetLocation( theClickEvent, p1 );
//	CGEventPost( kCGHIDEventTap, theClickEvent );  
//	usleep(100000); // wait 0.1 sec
//
//	CGEventSetType( theClickEvent, kCGEventLeftMouseDragged );
//	CGEventSetLocation( theClickEvent, p2 );
//	CGEventPost( kCGHIDEventTap, theClickEvent );
//	usleep(200000); // wait 0.1 sec
//
//	CGEventSetType( theClickEvent, kCGEventLeftMouseUp );
//	CGEventSetLocation( theClickEvent, p2 );
//	CGEventPost( kCGHIDEventTap, theClickEvent );
//	usleep(300000); // wait 0.1 sec
	
	CGWarpMouseCursorPosition(p2);
	
	CGAssociateMouseAndMouseCursorPosition(true);
	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	
	CFRelease( theMoveEvent );
	CFRelease( theClickEvent ); 
	CFRelease( theDragEvent ); 
	
	return result;
}

OSErr mouseDouble_ClickAtHandler( const AppleEvent *message, AppleEvent *reply, long refCon ){
	
	OSErr result = noErr;
	
	CGPoint p1;
	getDirectParamPoint( message, &p1 );
	
	// Send clicks
	CGEventRef theEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );  
	CGEventSetIntegerValueField( theEvent, kCGMouseEventClickState, 2 );
	CGEventPost(kCGHIDEventTap, theEvent);  
	
	CGEventSetType(theEvent, kCGEventLeftMouseUp);
	CGEventPost(kCGHIDEventTap, theEvent);

	CGEventSetType(theEvent, kCGEventLeftMouseDown);  
	CGEventPost(kCGHIDEventTap, theEvent); 
	
	CGEventSetType(theEvent, kCGEventLeftMouseUp); 
	CGEventPost(kCGHIDEventTap, theEvent); 
	CFRelease(theEvent); 
	
	return result;
}

OSErr monkeeeeHandler( const AppleEvent *message, AppleEvent *reply, long refCon ){

	OSErr ignorableError = noErr;
	printf("oh my god %i \n", (int)refCon);
	return ignorableError;
}
