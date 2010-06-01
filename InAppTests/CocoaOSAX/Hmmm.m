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
#include <IOKit/hidsystem/event_status_driver.h>

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

>> SEE CGEventPostToPSN <<

OSErr mouseClickAt_Handler( const AppleEvent *message, AppleEvent *reply, long refCon ){

	OSErr result = noErr;
	
	CGEventRef shiftUpEvent = NULL;
	CGEventRef shiftDownEvent = NULL;

	NSUInteger MAXPTS = 10;
	struct CGPointList *allPts;
	allPts = malloc( sizeof allPts + (MAXPTS-1) * sizeof allPts->pts[0] ); // malloc enough space for 10 pts
	// parse the incoming arguments
	AEDesc theDirectParamDesc;

	result=AEGetParamDesc(message, keyDirectObject, typeAEList, &theDirectParamDesc);
	if(!result){
		long numberOfItems;
		AECountItems( &theDirectParamDesc, &numberOfItems );
		NSCAssert1( numberOfItems>0 && numberOfItems%2==0, @"wrong number of terms %i", numberOfItems );
		
		allPts->numberOfPts = numberOfItems/2;
		for( NSUInteger i=0; i<allPts->numberOfPts; i++ )
		{
			int32_t xPoint, yPoint;
			NSUInteger pIndexx = i*2+1;
			NSUInteger pIndexy = i*2+2;
			AEGetNthPtr( &theDirectParamDesc, pIndexx, typeSInt32, NULL, NULL, &xPoint, sizeof(xPoint), NULL );
			AEGetNthPtr( &theDirectParamDesc, pIndexy, typeSInt32, NULL, NULL, &yPoint, sizeof(yPoint), NULL );
			allPts->pts[i].x = (CGFloat)xPoint;
			allPts->pts[i].y = (CGFloat)yPoint;
		}

		AEDisposeDesc(&theDirectParamDesc);
	}
	
	CGEventSourceRef source = CGEventSourceCreate( kCGEventSourceStatePrivate );
	
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
		
		shiftDownEvent = CGEventCreateKeyboardEvent( source, (CGKeyCode)56, true );
		shiftUpEvent = CGEventCreateKeyboardEvent( source, (CGKeyCode)56, false );
		
		//		CGEventSetIntegerValueField( shiftDownEvent, kCGKeyboardEventKeycode, new_keycode);
		
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
	result = noErr;
	
	NXEventHandle evs = NXOpenEventStatus();
	double clickTime = NXClickTime(evs);
	useconds_t safeClickTime = (useconds_t)(clickTime*1*1000000.0f);
	
	CGAssociateMouseAndMouseCursorPosition(false);

	// shift down
	if(shiftDownEvent)
		CGEventPost( kCGHIDEventTap, shiftDownEvent );  
	
	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime);
	
	// Send clicks
	for( NSUInteger i=0; i<allPts->numberOfPts; i++ )
	{
		CGPoint p1 = allPts->pts[i];
		
		// move to down pt
		CGEventRef theMoveEvent = CGEventCreateMouseEvent( NULL, kCGEventMouseMoved, p1, kCGMouseButtonLeft ); 
		CGEventSetType( theMoveEvent, kCGEventMouseMoved);
		CGEventSetFlags( theMoveEvent,0 ); // Cancel any of the modifier keys - this caused me a day of bug-hunting!
		CGEventSetFlags( theMoveEvent, kCGEventFlagMaskShift );
		CGEventPost( kCGHIDEventTap, theMoveEvent );  
		
		FlushEventQueue(GetMainEventQueue());
		FlushEventQueue(GetCurrentEventQueue());
		usleep(safeClickTime);
		
		// click down
		CGEventRef theClickEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );
		CGEventSetType( theClickEvent, kCGEventLeftMouseDown );
		CGEventSetIntegerValueField( theClickEvent, kCGMouseEventClickState, 1 );
		CGEventSetFlags( theClickEvent,0 ); // Cancel any of the modifier keys - this caused me a day of bug-hunting!
		CGEventSetFlags( theClickEvent, kCGEventFlagMaskShift );
		CGEventPost( kCGHIDEventTap, theClickEvent );  
		
		FlushEventQueue(GetMainEventQueue());
		FlushEventQueue(GetCurrentEventQueue());
		usleep(safeClickTime);

		// click up
		CGEventSetType( theClickEvent, kCGEventLeftMouseUp );
//		CGEventSetLocation( theClickEvent, p1 );
		CGEventPost( kCGHIDEventTap, theClickEvent );
		
		FlushEventQueue(GetMainEventQueue());
		FlushEventQueue(GetCurrentEventQueue());
		usleep(safeClickTime*2);
		
		CFRelease(theMoveEvent);
		CFRelease(theClickEvent);
	}
	
	// shift UP
	if(shiftUpEvent)
		CGEventPost( kCGHIDEventTap, shiftUpEvent );  
	
	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime);
	
	free(allPts);	
	CFRelease(source);
	
	if(shiftDownEvent)
		CFRelease(shiftDownEvent);
	if(shiftUpEvent)
		CFRelease(shiftUpEvent);
	
	CGAssociateMouseAndMouseCursorPosition(true);
	
	return result;
}

OSErr mouseDownAt_upAt_Handler( const AppleEvent *message, AppleEvent *reply, long refCon ){
	
	OSErr result = noErr;
	
	CGPoint p1, p2;
	getDirectParamPoint( message, &p1 );
	getFirstParamPoint( message, &p2 );
	CGPoint midPt = CGPointMake( p1.x + (p2.x - p1.x)/2.0f, p1.y + (p2.y - p1.y)/2.0f );

	NXEventHandle evs = NXOpenEventStatus();
	double clickTime = NXClickTime(evs);
	useconds_t safeClickTime = (useconds_t)(clickTime*1*1000000.0f);
	
	CGAssociateMouseAndMouseCursorPosition(false);

	// move to down pt
	CGEventRef theMoveEvent = CGEventCreateMouseEvent( NULL, kCGEventMouseMoved, p1, kCGMouseButtonLeft ); 
	CGEventSetType( theMoveEvent, kCGEventMouseMoved);
	CGEventSetFlags( theMoveEvent,0 ); // Cancel any of the modifier keys - this caused me a day of bug-hunting!
	CGEventPost( kCGHIDEventTap, theMoveEvent );  

	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime);

	// click down
	CGEventRef theClickEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );
	CGEventSetType( theClickEvent, kCGEventLeftMouseDown );
	CGEventSetIntegerValueField( theClickEvent, kCGMouseEventClickState, 1 );
	CGEventPost( kCGHIDEventTap, theClickEvent );  

	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime);

	// drag to midpoint	
	CGEventRef theDragEvent2 = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDragged, midPt, kCGMouseButtonLeft ); 
	CGEventSetType( theDragEvent2, kCGEventLeftMouseDragged );
	CGEventPost( kCGHIDEventTap, theDragEvent2 );  
	
	CGWarpMouseCursorPosition(midPt);
	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
//	usleep(safeClickTime*1);
	
	// drag to up pt
	CGEventRef theDragEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDragged, p2, kCGMouseButtonLeft ); 
	CGEventSetType( theDragEvent, kCGEventLeftMouseDragged );
	CGEventPost( kCGHIDEventTap, theDragEvent );  

	CGWarpMouseCursorPosition(p2);

	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime*5);

	// click up - has to be the same event as the mouse down?
	CGEventSetType( theClickEvent, kCGEventLeftMouseUp );
	CGEventSetLocation( theClickEvent, p2 );
	CGEventPost( kCGHIDEventTap, theClickEvent );

	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());
	usleep(safeClickTime);

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
	
	
	CGAssociateMouseAndMouseCursorPosition(true);

	CFRelease (theDragEvent2);
	CFRelease( theMoveEvent );
	CFRelease( theClickEvent ); 
	CFRelease( theDragEvent ); 
	
	return result;
}

// looks useful
static int eventNumber = 1;
...
if (mouseType == kCGEventLeftMouseDown)
++eventNumber;
...
CGEventSetIntegerValueField(event, kCGMouseEventNumber, eventNumber);




OSErr mouseDouble_ClickAtHandler( const AppleEvent *message, AppleEvent *reply, long refCon ){
	
	OSErr result = noErr;
	
	CGPoint p1;
	getDirectParamPoint( message, &p1 );

	CGAssociateMouseAndMouseCursorPosition(false);

	// Send clicks
	CGEventRef theEvent = CGEventCreateMouseEvent( NULL, kCGEventLeftMouseDown, p1, kCGMouseButtonLeft );  
	CGEventSetIntegerValueField( theEvent, kCGMouseEventClickState, 1 );
	CGEventPost( kCGHIDEventTap, theEvent );  
	
	CGEventSetType( theEvent, kCGEventLeftMouseUp );
	CGEventPost( kCGHIDEventTap, theEvent );

	NXEventHandle evs = NXOpenEventStatus();
	double clickTime = NXClickTime(evs);
	useconds_t safeClickTime = (useconds_t)(clickTime*0.5f*1000000.0f);
	usleep(safeClickTime);

	
	CGEventSetIntegerValueField( theEvent, kCGMouseEventClickState, 2 );
	CGEventSetType( theEvent, kCGEventLeftMouseDown );  
	CGEventPost( kCGHIDEventTap, theEvent ); 
	
	CGEventSetType( theEvent, kCGEventLeftMouseUp ); 
	CGEventPost( kCGHIDEventTap, theEvent ); 
	CFRelease( theEvent ); 
	
	CGAssociateMouseAndMouseCursorPosition(true);
	FlushEventQueue(GetMainEventQueue());
	FlushEventQueue(GetCurrentEventQueue());

	return result;
}

OSErr monkeeeeHandler( const AppleEvent *message, AppleEvent *reply, long refCon ){

	OSErr ignorableError = noErr;
	printf("oh my god %i \n", (int)refCon);
	return ignorableError;
}
