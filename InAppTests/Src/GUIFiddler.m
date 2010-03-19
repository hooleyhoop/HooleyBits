#import <Foundation/Foundation.h>
#import <Foundation/NSObjCRuntime.h>
#import <objc/message.h>
#import <SHTestUtilities/ApplescriptGUI.h>

#define RUNLOOPMODE kCFRunLoopDefaultMode


@interface GUIFiddler : NSObject {
	
}

@end

static NSDictionary				*_data;
static CFRunLoopObserverRef		_observer;
static NSTimer					*_timer;
static GUIFiddler				*_fiddler;
static int						_parentPID;

@implementation GUIFiddler

//void genericCallback( CFNotificationCenterRef center, void *observer,CFStringRef name, const void *object, CFDictionaryRef userInfo){
//	printf("RN===>\n");
//	CFShow(name);
//}

- (id)init {

	self = [super init];
	if(self){
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRemoteRequest:) name:@"hooley_distrbuted_notification" object:nil];
	
		// lets listen to all notifications
//		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(allDNs:) name:nil object:nil];

		// CF
//		CFNotificationCenterRef distributedCenter;
//		CFStringRef observer = CFSTR("A CF OBSERVER");
//		distributedCenter = CFNotificationCenterGetDistributedCenter();
//		CFNotificationCenterAddObserver(distributedCenter, observer, genericCallback, NULL, NULL, CFNotificationSuspensionBehaviorDrop);
	}
	return self;
}

- (void)dealloc {

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"hooley_distrbuted_notification" object:nil];
	[super dealloc];
}


// Move the mouse pointer! yay
// CGDisplayMoveCursorToPoint()
// CGEventPost()
// CGPostMouseEvent()

//- (oneway void)allDNs:(NSNotification *)eh {
//	NSLog(@"N! - %@", eh );
//}
- (oneway void)receivedRemoteRequest:(NSNotification *)eh {
	
	if( [[eh object] isEqualToString:@"statusOfMenuItem"] )
	{
		NSDictionary *dict = [eh userInfo];
		NSString *processName = [dict objectForKey:@"ProcessName"];
		NSString *menuItemName = [dict objectForKey:@"MenuItemName"];
		NSString *menuName = [dict objectForKey:@"MenuName"];
		NSAssert( processName, @"Invalid process name");
		NSAssert( menuItemName, @"Invalid menuItemName name");
		NSAssert( menuName, @"Invalid menuName name");

		//-- call applescript
		id result = objc_msgSend( [ApplescriptGUI class], @selector(statusOfMenuItem:ofMenu:ofApp:), menuItemName, menuName, processName );

		// -- construct result dictionary
		NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 result, @"resultValue",
									 nil];
		// respond to original caller
		NSLog(@"Posting Response Back to Main Process %@", [NSDistributedNotificationCenter defaultCenter]);
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"hooley_distrbuted_notification_callback" 
																	   object:@"statusOfMenuItem_callback" 
																	 userInfo:resultDictionary
														   deliverImmediately:NO];
	} 
	else if( [[eh object] isEqualToString:@"openMenuItem"] ) {
	
		NSDictionary *dict = [eh userInfo];
		NSString *processName = [dict objectForKey:@"ProcessName"];
		NSString *menuName = [dict objectForKey:@"MenuName"];

		//-- call applescript
		objc_msgSend( [ApplescriptGUI class], @selector(openMainMenuItem:ofApp:), menuName, processName );

		NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"hooley_distrbuted_notification_callback" 
																	   object:@"openMenuItem_callback" 
																	 userInfo:resultDictionary
														   deliverImmediately:NO];
	}
	else if( [[eh object] isEqualToString:@"doMenuItem"] ) { 
	
		NSDictionary *dict = [eh userInfo];
		NSString *processName = [dict objectForKey:@"ProcessName"];
		NSString *menuName = [dict objectForKey:@"MenuName"];
		NSString *itemName = [dict objectForKey:@"MenuItemName"];

		//-- call applescript
		objc_msgSend( [ApplescriptGUI class], @selector(doMainMenuItem:ofMenu:ofApp:), itemName, menuName, processName );

		NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionary];
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"hooley_distrbuted_notification_callback" 
																	   object:@"doMenuItem_callback" 
																	 userInfo:resultDictionary
														   deliverImmediately:NO];
	}else {
		[NSException raise:@"sheeet" format:@"d"];
	}
}
		
- (void)timerFire:(id)value {
	ProcessSerialNumber theProcessSerialNumber;
	if( GetProcessForPID( _parentPID, &theProcessSerialNumber)!=noErr ){
		[[NSApplication sharedApplication] terminate:self];
	}
}

@end

// runloop callback
static void cf_observer_delayedNotification( CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info ) {
	
   // NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	// NSLog(@"woah");
	//	NSDictionary *data = (NSDictionary *)info;
	//	AllChildrenFilter *filter = (AllChildrenFilter *)[data objectForKey:@"key1"];
	//	NSString *methodName = (NSString *)[data objectForKey:@"key2"];
	//	DelayedNotifier *self = (DelayedNotifier*)[data objectForKey:@"key3"];
	//	
	//	NSCAssert( filter, @"dum dum" );
	//	NSCAssert( methodName, @"dum dum" );	
	//	NSCAssert( self->_controller, @"dum dum" );
	//	
	//	[filter performSelector:NSSelectorFromString(methodName)];
	//	
	//	[self->_controller notificationDidFire_callback];
	
  //  [pool drain];
}

/* add a callback to the runloop with our callback objects in an info dictionary */
void addRunloopSource(void) {
	
	NSCAssert(_data==nil, @"hmm");
	NSCAssert(_observer==nil, @"hmm");
	
	_data = nil; //[[NSDictionary dictionaryWithObjectsAndKeys: callBackObject, @"key1", NSStringFromSelector(callbackMethod), @"key2", self, @"key3", nil] retain];
	
	CFRunLoopObserverContext context = {0, _data, NULL, NULL, NULL};
	_observer = CFRunLoopObserverCreate( kCFAllocatorDefault, kCFRunLoopBeforeTimers, YES, 0, &cf_observer_delayedNotification, &context);
	NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
	CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];
	
	/* This is REALLY IMPORTANT
	 * If we use kCFRunLoopDefaultMode it will behave 'normally'
	 * If i use kCFRunLoopCommonModes it will work even when we are in a mouse drag and have hijacked the runloop, this seems better - 
	 * But i don't understand what is happening behind the scenes, which worries me
	 */
	
	CFRunLoopAddObserver( cfLoop, _observer, RUNLOOPMODE );

	BOOL shouldKeepRunning = YES; 
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
		// -- check parent process is still running
		ProcessSerialNumber theProcessSerialNumber;
		if( GetProcessForPID( _parentPID, &theProcessSerialNumber)!=noErr ){
			[[NSApplication sharedApplication] terminate:nil];
		}
	}
}

void removeRunLoopSource(void) {
	
	NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
	CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];
	CFRunLoopRemoveObserver(cfLoop, _observer, RUNLOOPMODE);
	CFRelease(_observer);
	_observer = nil;
	[_data release];
	_data = nil;
}

void fireOveride(void) {
	cf_observer_delayedNotification( _observer, kCFRunLoopEntry, _data );
}

int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSArray *args = [[NSProcessInfo processInfo] arguments];
	for( NSString *earchArg in args) {
		NSLog( @"** arg - %@ **", earchArg );
		_parentPID = [earchArg intValue];
	}
	_fiddler = [[GUIFiddler alloc] init];
	_timer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:_fiddler selector:@selector(timerFire:) userInfo:nil repeats:YES] retain];
	addRunloopSource();
	
    [pool drain];
    return 0;
}

__attribute__((destructor)) void onExit(void) {
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Closing Down the fiddler.");
	[_fiddler release];
	removeRunLoopSource();
	[_timer invalidate];
	[pool release];
}
