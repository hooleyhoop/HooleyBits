//
//  SHUTubePatch.m
//  SHExtras
//
//  Created by Steven Hooley on 30/11/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHUTubePatch.h"
#import "SHFakeView.h"
// #import "SHInvisibleWindow.h"
// #import "BBWebView.h"

/*
 *
*/
@implementation SHUTubePatch


//=========================================================== 
// + executionMode:
//=========================================================== 
+ (int)executionMode {
	return 2;
}

//=========================================================== 
// - timeMode:
//=========================================================== 
+ (int)timeMode {
	return 0;
}

//=========================================================== 
// - allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return FALSE;
}

#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if (![super initWithIdentifier:fp8])
		return nil;
	[self setLastLookUpString:@""];
	_loadingFlag=NO;
	_playFlag=NO;
	_errorFlag=NO;
	[outputLoadProgress setDoubleValue:0.0];
	
//	[inputScale setDoubleValue:1.0];
//	_lastScale = 1.0;
	
	_webView = [[WebView alloc] initWithFrame:NSMakeRect(0,0, 800, 600) frameName:@"hooley" groupName:@"hooley"];
	[[_webView enclosingScrollView] setHasVerticalScroller:NO];
	[[_webView enclosingScrollView] setHasHorizontalScroller:NO];
	[_webView setFrameLoadDelegate:self];
	
	/* register for notifications */
	if(!_notificationsDisabled && !_notificationsPaused)
	{
		/* maybe here we need to overide - (void)resumeNotifications;, etc.. */
		
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter addObserver:self selector:@selector(receiveAllNotifications:) name:@"QCPatchDidStartRenderingNotification" object:nil];
		[defaultCenter addObserver:self selector:@selector(receiveAllNotifications:) name:@"QCViewDidStopRenderingNotification" object:nil];
	}		
	/* flash and javascript control */
	//id win = [webView windowScriptObject];
	//id location = [win valueForKey:@”location”];
	//NSString *href = [location valueForKey:@”href”];
	//NSString *href = [win evaluateWebScript:@”location.href”];
	//NSArray *args = [NSArray arrayWithObjects: @”sample_graphic.jpg”, [NSNumber numberWithInt:320], [NSNumber numberWithInt:240], nil];
	//[win callWebScriptMethod:@"addImage" withArguments:args];	
	//[win evaluateWebScript: @"addImage(’sample_graphic.jpg’, ‘320’, ‘240’)"];

	_lastUseTransparentWindow = NO;
	return self;
}


//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc 
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
	[self cleanUp];
	[_webView setHostWindow:nil];
	
	/* memory leak here! quartz dealocs all winds when you close the app */
//	if(_hiddenWindow){
//		NSLog(@"hidden window retain count is %i", [_hiddenWindow retainCount]);
//		[_hiddenWindow release];
//	}
	[_webView release];
	[self setLastLookUpString:nil];
	[self setStringAttemptingToLoad:nil];

	_hiddenWindow = nil;
	_webView = nil;
	[super dealloc];
}

// ===========================================================
// - receiveNotification:
// ===========================================================
- (void) receiveAllNotifications:(NSNotification*) note
{
	NSString *name = [note name];
	// id object = [note object];
	// NSDictionary *userInfo	= [note userInfo];
	if([name isEqualToString:@"QCPatchDidStartRenderingNotification"])
	{
		[self play:YES];

	} else if([name isEqualToString:@"QCViewDidStopRenderingNotification"]){
		[self play:NO];
	}
}


#pragma mark action methods
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(id)fp8 time:(double)compositionTime arguments:(id)fp20	
{
	// state 0 - nothing
	// state 1 - loading a movie
	// state 2 - movie load error
	// state 3 - playing a movie and loading a new one
	// state 4 - playing a movie and movie load error
//	if(_lastUseTransparentWindow!=[inputUseTransparentWindow booleanValue])
//	{
//		_lastUseTransparentWindow = [inputUseTransparentWindow booleanValue];
//		NSLog(@"setting transparent %i", _lastUseTransparentWindow);
//
//		[_webView setDrawsBackground:_lastUseTransparentWindow];
//		[_webView setNeedsDisplay:YES];
//	}
	
	/* set progress indicator */
	if(_loadingFlag){
		[outputLoadProgress setDoubleValue:[_webView estimatedProgress]];
	} 
	
	/* have dimensions changed since we made the context? */
//	if( ((int)[inputScale doubleValue])!=_lastScale ) {
//		[self setStageDimensions];
//	}
	
	/* initiate a new load */
	NSString* inputString = [inputURLPort stringValue];
	if([inputString isEqualToString:_stringAttemptingToLoad]==NO && [inputString isEqualToString:_lastLookUpString]==NO) {
		[self loadNewURL:self];
	}

	/* have we got a load error? */
	if(_errorFlag)
	{
	
	}
	
	/* are we playing? */
	if(_playFlag) {
		[self refreshCurrentPage];
	}
	
	return YES;
}

//=========================================================== 
// - loadNewURL:
//=========================================================== 
- (void)loadNewURL:(id)sender
{
	if(_loadingFlag){
		[[_webView  mainFrame] stopLoading];
	}
	_loadingFlag = YES;

	[outputLoadProgress setDoubleValue:0.0];
		
	// we convert the search string into percent-escaped string
	[self setStringAttemptingToLoad:[inputURLPort stringValue]];
	NSString *inputstr = [_stringAttemptingToLoad stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];	
	if([inputstr isEqualToString:@""]) 
		return;
		
	/* make offscreen window */
	if(_hiddenWindow==nil){
		[self play:YES];
	}
	
	/* initiate download */	
	NSURL* theURL = [NSURL URLWithString:inputstr];
	NSURLRequest* request = [NSURLRequest requestWithURL:theURL];
	// NSLog(@"NSURLRequest request %@", request);
	[[_webView mainFrame] loadRequest:request];
	_errorFlag = NO;
}

//=========================================================== 
// - refreshCurrentPage:
//=========================================================== 
- (void)refreshCurrentPage
{
	[_webView lockFocus];
	
	/* make NSImage */
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[_webView bounds]];
	
//    [[NSColor clearColor] set];
//    NSRectFill([self frame]);
		
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:rep];
	
	/* set output */
	[outputImage setValue:image];
	
	[_webView unlockFocus];
	[rep release];
	[image release];
}

//=========================================================== 
// - setStageDimensions:
//=========================================================== 
- (BOOL) setStageDimensions
{
	id docView = [[[_webView mainFrame] frameView] documentView];
	
	/* get the pages natural bounds */
	// NSRect viewRect = [docView frame];	// documentView == WebHTMLView
	
	/* hacky way to work out how big the page is */
	if(docView)
	{
		if(_timer )
			[_timer invalidate]; 
			
		// documentView == WebHTMLView, WebNetscapePluginDocumentView
		NSRect selectionRectsh;
		if([docView respondsToSelector:@selector(selectAll)])
		{
			// probably a WebHTMLView
			[docView selectAll];
			selectionRectsh = [docView _selectionRect];	
			[docView deselectAll];
		} else if([docView respondsToSelector:@selector(visibleRect)])
		{
			selectionRectsh = [docView visibleRect];
			if([docView respondsToSelector:@selector(plugin)])
			{	
				if([[[docView plugin] name] isEqualToString:@"Shockwave Flash"])
				{
				// praobably a WebNetscapePluginDocumentView
					NSLog(@"Found a shockwave Flash isStartd %i", [docView isStarted]);
					[docView start];
					// _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fakeClick) userInfo:nil repeats:YES ];
				}
			}
		} else {
			selectionRectsh = [docView frame];	
		}
		// NSRect selectionRect = [[[[_webView mainFrame] frameView] documentView] frame];	// documentView == WebHTMLView
		
		// double newScale = [inputScale doubleValue];
		double newScale = 1.0;	
		int newWidth = (int)selectionRectsh.size.width * newScale;
		int newHeight = (int)selectionRectsh.size.height * newScale;
		
		[_webView setFrameSize:NSMakeSize(newWidth,newHeight)];
		// [[[[_webView mainFrame] frameView] documentView] setFrameSize:NSMakeSize(newWidth,newHeight)];

		if(_hiddenWindow)
			[_hiddenWindow setFrame:NSMakeRect(-1000,0,newWidth,newHeight) display:YES];
		
		/* jesus - do it again */
		selectionRectsh = [(NSClipView*)[(id)[[_webView mainFrame] frameView] _contentView] documentRect];
		newWidth = (int)selectionRectsh.size.width * newScale;
		newHeight = (int)selectionRectsh.size.height * newScale;
		[_webView setFrameSize:NSMakeSize(newWidth,newHeight)];

		if(_hiddenWindow)
			[_hiddenWindow setFrame:NSMakeRect(-1000,0,newWidth,newHeight) display:YES];
		
	//	_lastScale = newScale;

		// turn off scroll bars - WebDynamicScrollBarsView
		[[_webView enclosingScrollView] setHasVerticalScroller:NO];
		[[_webView enclosingScrollView] setHasHorizontalScroller:NO];
		
		id scrollView = [[[[_webView mainFrame] frameView] documentView] enclosingScrollView];
		[scrollView setAllowsScrolling:NO];
		// [scrollView setScrollingMode:NO]; // 
	//	[scrollView setAlwaysShowVerticalScroller:NO];
	//	[scrollView setAlwaysShowHorizontalScroller:NO];
		[scrollView _setHorizontalScrollerHidden:YES];
		[scrollView _setVerticalScrollerHidden:YES];

		[[[_webView mainFrame] frameView] setAllowsScrolling:NO];
	//	[docView setAllowsScrolling:NO];
		return YES;
	} else {
		if(!_timer){
			NSLog(@"launching a muthafucking timer");
			_timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setStageDimensions:) userInfo:nil repeats:YES ];
		}
	}
	return NO;
}

//- (void)SimulateMouseClick:(NSPoint)where
//{
//	NSGraphicsContext *context = [NSGraphicsContext currentContext];
//	NSEvent* mouseDownEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:where
//	modifierFlags:nil timestamp:GetCurrentEventTime() windowNumber: 0 context:context eventNumber: nil clickCount:1 pressure:nil];
//	NSEvent* mouseUpEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:where
//	modifierFlags:nil timestamp:GetCurrentEventTime() windowNumber: 0 context:context eventNumber: nil clickCount:1 pressure:nil];
//
//	// -hitTest: returns the deepest subview under the point specified.
//	// As I'm using the same point for both events, I only call - hitTest: once.
//	NSView* subView= [theView hitTest: [mouseUpEvent locationInWindow]];
//	if(subView) {
//	[subView mouseDown: mouseDownEvent];
//	[subView mouseUp: mouseUpEvent];
//	}
//	else
//	NSLog(@"hitTest returned nil");
//}

//=========================================================== 
// - play:
//=========================================================== 
- (void) play:(BOOL)flag
{
	if(flag) {
		// make the window and play
		if(!_hiddenWindow)
		{
			// NSRect screenBounds = [_webView bounds];
			_hiddenWindow = [[NSWindow alloc] initWithContentRect: NSMakeRect( -1000,0, 1000, 1000 ) styleMask: NSBorderlessWindowMask backing:NSBackingStoreNonretained defer:NO]; // if you pass YES for this it won't do any drawing until the window is onscreen, not good for this situation!
			[[_hiddenWindow contentView] addSubview:_webView];
			[_webView setHostWindow:_hiddenWindow];
		}
	} else {
		// kill the window
		// NSLog(@"killing the mother fucking window");
		[_webView setHostWindow:nil];
		[_webView removeFromSuperview];
		// kill the window

		[_hiddenWindow release];
		_hiddenWindow = nil;		
	}
}

				
//=========================================================== 
// - cleanUp:
//=========================================================== 
- (void)cleanUp
{
	[[_webView  mainFrame] stopLoading];

	//if(_hiddenWindow)
	//	[_hiddenWindow close];
	// _hiddenWindow = nil;
	// _lookUpIsBusy = NO;
}

#pragma mark delegate methods
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
	// NSLog(@"SHUTubePatch.m: starting a new web grab!");
}

//=========================================================== 
// - webView: didFinishLoadForFrame:
//=========================================================== 
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
	// NSLog(@"SHUTubePatch.m: - (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame");
	[outputLoadProgress setDoubleValue:1.0];

	[self setLastLookUpString: _stringAttemptingToLoad];
	_loadingFlag = NO;
	_playFlag=YES;
	
	/* set the size */
	BOOL flag = [self setStageDimensions];
	[self refreshCurrentPage];
	
			
	if(![self isRendering])
		[self play:NO];
}

- (void)fakeClick
{
	NSLog(@"clierty click");
	NSRect webSize = [_webView frame];
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
	NSEvent* mouseDownEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:NSMakePoint(webSize.size.width/2, webSize.size.height/2) modifierFlags:nil timestamp:GetCurrentEventTime() windowNumber:[_hiddenWindow windowNumber] context:context eventNumber:1 clickCount:2 pressure:nil ];
	NSEvent* mouseUpEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:NSMakePoint(webSize.size.width/2, webSize.size.height/2) modifierFlags:nil timestamp:GetCurrentEventTime() windowNumber:[_hiddenWindow windowNumber] context:context eventNumber:2 clickCount:2 pressure:nil ];
	[_webView mouseDown:mouseDownEvent];
	[_webView mouseUp:mouseUpEvent];
	NSView* subView= [_webView hitTest: [mouseUpEvent locationInWindow]];
	if(subView) {
		[subView mouseDown: mouseDownEvent];
		[subView mouseUp: mouseUpEvent];
	}
}

- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
	// NSLog(@"SHUTubePatch.m: webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender willCloseFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender willCloseFrame:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender didChangeLocationWithinPageForFrame:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame");

}

- (void)webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender didReceiveIcon:(NSImage *)image forFrame:(WebFrame *)frame");

}

//=========================================================== 
// - webView: didFailProvisionalLoadWithError: forFrame:
//=========================================================== 
- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR. %@", error);
	_errorFlag = YES;
	[[_webView  mainFrame] stopLoading];
	_loadingFlag = NO;
}

//=========================================================== 
// - webView: didFailLoadWithError: forFrame:
//=========================================================== 
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	NSLog(@"ERROR. %@", error);
	_errorFlag = YES;
	[[_webView  mainFrame] stopLoading];
	_loadingFlag = NO;
}

- (void)webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender didCancelClientRedirectForFrame:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender serverRedirectedForDataSource:(WebFrame *)frame
{
	// NSLog(@"webView:(WebView *)sender serverRedirectedForDataSource:(WebFrame *)frame");
}

- (void)webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject
{
	// NSLog(@"webView:(WebView *)sender windowScriptObjectAvailable:(WebScriptObject *)windowScriptObject");
}


#pragma mark accessor methods

- (WebView*) webView {
	return _webView;
}

- (NSWindow*) hiddenWindow {
	return _hiddenWindow;
}

//=========================================================== 
// - setLastLookUpString:
//=========================================================== 
- (void) setLastLookUpString:(NSString*) aString {
    // NSLog(@"in -setAbsolutePath:, old value of _absolutePath: %@, changed to: %@", _absolutePath, anAbsolutePath);
    if (_lastLookUpString != aString) {
        [aString retain];
        [_lastLookUpString release];
        _lastLookUpString = aString;
    }
}

//=========================================================== 
// - setLastLookUpString:
//=========================================================== 
- (void) setStringAttemptingToLoad:(NSString*) aString{
    // NSLog(@"in -setAbsolutePath:, old value of _absolutePath: %@, changed to: %@", _absolutePath, anAbsolutePath);
    if (_stringAttemptingToLoad != aString) {
        [aString retain];
        [_stringAttemptingToLoad release];
        _stringAttemptingToLoad = aString;
    }
}


@end
