//
//  SHNodeListView_C.m
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNodeListView_C.h"
#import "SHNodeListView_M.h"
#import "SHNodeListView_V.h"
#import "testValueTransformer.h"
#import "classToStringValueTransformer.h"
#import "exeTimeTransform.h"
#import <FScript/FScript.h>
#import "SHViewport.h"
#import "SHAuxWindow.h"

/*
 *
*/
@implementation SHNodeListView_C

static SHNodeListView_C* _controller;

#pragma mark -
#pragma mark class methods
//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	NSLog(@"initialize SHNodeListView_C");
	_controller = [[SHNodeListView_C alloc] init];
	
    
	// create an autoreleased instance of our testValueTransformer transformer
	testValueTransformer *trans1 = [[[testValueTransformer alloc] init] autorelease];
	classToStringValueTransformer *trans2 = [[[classToStringValueTransformer alloc] init] autorelease];
	exeTimeTransform *trans3 = [[[exeTimeTransform alloc] init] autorelease];

	// register it with the name that we refer to it with
	[NSValueTransformer setValueTransformer:trans1 forName:@"testTransformer"];
	[NSValueTransformer setValueTransformer:trans2 forName:@"classToStringTransformer"];
	[NSValueTransformer setValueTransformer:trans3 forName:@"exeTime"];
}

//=========================================================== 
// + defaultController:
//=========================================================== 
+ (SHNodeListView_C*) defaultController
{
	return _controller;
}

#pragma mark init methods
// ===========================================================
// - init:
// ===========================================================
- (id)init
{	
	if(self=[super init])
	{
		[self setModel: [[SHNodeListView_M alloc] initWithController:self]];
		_swapableView = [[SHNodeListView_V alloc] initWithController:self];
		
		/* move this to the menu bar */
		NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
		NSMenuItem* windowMenu = [mainMenu itemWithTitle:@"Editor"];
		NSMenu* windowSubMenu = [windowMenu submenu];
		NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"all patches" action:@selector(menuAction:) keyEquivalent:@""];
		[menuItem setTarget: self];
		// NSLog(@"window menu is %@", windowSubMenu);
		[windowSubMenu addItem:menuItem];
		
///		[self show:nil];
	} 
	return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {

    [super dealloc];
}

#pragma mark action methods

// ===========================================================
// - menuAction
// ===========================================================
- (void) menuAction:(id)sender
{
	if(!_enabled)
		[self show:sender];
//	else
//		[self hide:sender];
}

// ===========================================================
// - show
// ===========================================================
- (void) show:(id)sender
{
	NSLog(@"SHNodeListView_C: calling show");
	[_model initBindings];
//	[_swapableView setFrame: [[_swapableView superview] frame]];
	SHViewport* v= [[(SHNodeListView_V*)_swapableView savedWindow] viewport];
	[v setTheViewController:self];

	[(SHNodeListView_V*)_swapableView show];
	[self hasBeenLaunchedInWindow];

	// temp
	[[FSInterpreter interpreter] browse];
	// end temp
}

// ===========================================================
// - willBeRemovedFromViewPort
// ===========================================================
- (void) willBeRemovedFromViewPort
{
	[super willBeRemovedFromViewPort];
	NSLog(@"SHNodeListView_C: calling hide");
	[_model unBind];
	[(SHNodeListView_V*)_swapableView hide];
}


// ===========================================================
// - updateSelectionInView:
// ===========================================================
- (void) updateSelectionInView{
	[(SHNodeListView_V*)_swapableView updateSelectionTableView];
}

#pragma mark accessor methods

- (SHNodeListView_M *)model {
    return [[_model retain] autorelease];
}

- (void)setModel:(SHNodeListView_M *)value {
    if (_model != value) {
		[value retain];
        [_model release];
        _model = value;
    }
}


//=========================================================== 
// view
//=========================================================== 
- (SHNodeListView_V*) view {
	return _swapableView;
}


- (NSString*) name
{
	return _name;
}
- (void) setName:(NSString*)value
{
    if (_name != value) {
		[value retain];
        [_name release];
        _name = value;
    }
}

@end
