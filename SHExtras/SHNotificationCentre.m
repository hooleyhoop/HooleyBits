//
//  SHNotificationCentre.m
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNotificationCentre.h"

/*
 *
*/
@implementation SHNotificationCentre

static SHNotificationCentre *notificationObserver;

// ===========================================================
// - init:
// ===========================================================
+ (void) initialize
{
	if (![[[NSBundle mainBundle] bundleIdentifier] hasPrefix:@"com.apple.QuartzComposer"])		//Make sure we're only running for Quartz Composer.
		return;
	notificationObserver = [[SHNotificationCentre alloc] init];
}

// ===========================================================
// - init:
// ===========================================================
- (id) init
{	
	if(self=[super init])
	{
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter addObserver:self selector:@selector(receiveAllNotifications:) name:nil object:nil];
		// [defaultCenter addObserver:self selector:@selector(GFGraphLayoutDidChangeNotification:) name:@"GFGraphLayoutDidChangeNotification" object:nil];
		// [defaultCenter addObserver:self selector:@selector(GFGraphEditorViewContentDidChangeNotification:) name:@"GFGraphEditorViewContentDidChangeNotification" object:nil];
		// [defaultCenter addObserver:self selector:@selector(GFGraphViewContentDidChangeNotification:) name:@"GFGraphViewContentDidChangeNotification" object:nil];
	} 
	return self;
}

// ===========================================================
// - receiveNotification:
// ===========================================================
- (void) receiveAllNotifications:(NSNotification*) note
{
	static  NSMutableDictionary* calledNotifiactionsStore;
	if(!calledNotifiactionsStore)
		calledNotifiactionsStore = [[NSMutableDictionary alloc] initWithCapacity:20];
		
	NSString *name = [note name];
//	if([calledNotifiactionsStore valueForKey:name]==nil)
//	{
	id object = [note object];
		// NSDictionary *userInfo	= [note userInfo];
	
//		[calledNotifiactionsStore setValue:object forKey:name]; 
		NSLog(@"Received Unique Notification %@, %@, ", name, [object description]);

//	}
}

// ===========================================================
// - GFGraphLayoutDidChangeNotification:
// ===========================================================
- (void) GFGraphLayoutDidChangeNotification:(NSNotification*) note
{
//	NSString *name = [note name];
//	id object = [note object];	// currrent parent node
//	NSDictionary *userInfo	= [note userInfo];
	// NSLog(@"Received Notification %@, %@, %@, ", name, object, [userInfo description] );
}

// ===========================================================
// - GFGraphLayoutDidChangeNotification:
// ===========================================================
- (void) GFGraphEditorViewContentDidChangeNotification:(NSNotification*) note
{
//	NSString *name = [note name];
//	id object = [note object];	// QCPatchEditorView
//	NSDictionary *userInfo	= [note userInfo];
	// NSLog(@"Received Notification %@, %@, %@, ", name, object, [userInfo description] );
}

// ===========================================================
// - GFGraphViewContentDidChangeNotification:
// ===========================================================
- (void) GFGraphViewContentDidChangeNotification:(NSNotification*) note
{
//	NSString *name = [note name];
//	id object = [note object];	// QCPatchView
//	NSDictionary *userInfo	= [note userInfo];
	// NSLog(@"Received Notification %@, %@, %@, ", name, object, [userInfo description] );
}



@end

// 2006-10-10 13:54:53.394 Quartz Composer[8678] Received Notification GFNodeManagerDidUpdateNotification, <QCNodeManager | namespace = "com.apple.QuartzComposer" | 254 nodes>, 


// GFNodeManagerView = [aGFGraphEditorView nodeManager]

//2006-10-09 12:04:10.131 Quartz Composer[827] Received Notification QCPatchParametersViewDidUpdateNotification, <QCPatchParametersView: 0x1733d440>, 

//2006-10-09 12:04:10.132 Quartz Composer[827] Received Notification GFStateDidChangeNotification, <QCPatch = 0x160BA9D0 "(null)">, 

//2006-10-09 12:04:10.132 Quartz Composer[827] Received Notification GFGraphEditorViewSelectionDidChangeNotification, <QCPatchEditorView: 0x15e17d90>, 

//2006-10-09 12:04:10.132 Quartz Composer[827] Received Notification GFGraphViewSelectionDidChangeNotification, <QCPatchView: 0x17337010>, 

//GFGraphBrowserViewNodeDidSelectNotification, <QCPatchBrowserView: 0x15e13530>, 
//2006-10-09 12:06:59.519 Quartz Composer[827] Received Notification GFGraphEditorViewGraphDidChangeNotification, <QCPatchEditorView: 0x15e17d90>, 
//2006-10-10 13:54:53.216 Quartz Composer[8678] Received Notification QCPatchDidStartRenderingNotification, <QCPatch = 0x17403960 "(null)">, 
//2006-10-10 13:54:53.216 Quartz Composer[8678] Received Notification QCViewDidStartRenderingNotification, <QCView: 0x15efd360>, 

//2006-10-10 13:54:53.139 Quartz Composer[8678] Received Notification _NSWindowWillChangeWindowNumber, <NSWindow: 0x15e19fd0>, 
//2006-10-10 13:54:53.139 Quartz Composer[8678] Received Notification _NSWindowDidChangeWindowNumber, <NSWindow: 0x15e19fd0>, 
//2006-10-10 13:54:53.141 Quartz Composer[8678] Received Notification NSWindowDidBecomeKeyNotification, <NSWindow: 0x15e19fd0>, 
//
//2006-10-10 13:54:53.145 Quartz Composer[8678] Received Notification QCPatchParametersViewDidUpdateNotification, <QCPatchParametersView: 0x17409450>, 
//
//2006-10-10 13:54:53.146 Quartz Composer[8678] Received Notification NSMenuDidRemoveItemNotification, <NSMenu: 0x3a8aa0>
//
//2006-10-10 13:54:53.174 Quartz Composer[8678] Received Notification _NSWindowDidBecomeVisible, <NSWindow: 0x15e19fd0>, 
//2006-10-10 13:54:53.180 Quartz Composer[8678] Received Notification NSWindowDidBecomeMainNotification, <NSWindow: 0x17400b90>, 
//
//2006-10-10 13:55:25.297 Quartz Composer[8678] Received Notification NSApplicationWillResignActiveNotification, <MyApplication: 0x31c2b0>, 
//2006-10-10 13:55:25.299 Quartz Composer[8678] Received Notification NSMenuDidChangeItemNotification, <NSMenu: 0x328a50>
//	Title: Window
//	Supermenu: 0x3943d0 (MainMenu), autoenable: YES, change messages enabled: YES
//	Items: (
//        <MenuItem: 0x3287c0 Minimize>, 
//        <MenuItem: 0x328c30 Zoom>, 
//        <MenuItem: 0x3299f0 >, 
//        <MenuItem: 0x329a90 Bring All to Front>, 
//        <MenuItem: 0x3d9320 Arrange in Front>, 
//        <MenuItem: 0x15efaf40 >, 
//        <MenuItem: 0x15efab80 All Patches in composition>
//    ), 
//2006-10-10 13:55:25.299 Quartz Composer[8678] Received Notification NSWindowDidResignKeyNotification, <NSWindow: 0x1601de80>, 
//2006-10-10 13:55:25.342 Quartz Composer[8678] Received Notification NSWindowDidResignMainNotification, <NSWindow: 0x1601de80>, 
//2006-10-10 13:55:25.344 Quartz Composer[8678] Received Notification NSApplicationDidResignActiveNotification, <MyApplication: 0x31c2b0>, 
//


