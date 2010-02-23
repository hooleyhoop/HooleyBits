//
//  SHNodeListView_V.h
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import "SHSwapableView.h"
//#import <Shared/Shared.h>"

@class SHNodeListView_C, SHAuxWindow;

@interface SHNodeListView_V : SHSwapableView {
		
	IBOutlet SHAuxWindow*		_savedWindow;
	IBOutlet NSView*		_contents;
	IBOutlet NSScrollView*	_tableViewContainer;
	IBOutlet NSTableView*	_tableView;
	IBOutlet NSArrayController*	_arrayController;
	
}

#pragma mark -
#pragma mark init methods
- (id) initWithController:(SHNodeListView_C*)aController;

#pragma mark action methods
// - (IBAction) upButtonClicked:(id)sender;
// - (IBAction) downButtonClicked:(id)sender;

- (void) show;
- (void) hide;
 
- (IBAction) updateSelectionInModel:(id)sender;
- (void) updateSelectionTableView;

#pragma mark accessor methods
- (SHNodeListView_C*) controller;

- (NSView*) contents;
- (void) setContents:(NSView *)aContents;

- (NSScrollView*) tableViewContainer;
- (void) setTableViewContainer:(NSScrollView *)aTableViewContainer;

- (NSTableView*) tableView;
- (void) setTableView:(NSTableView *)aTableView;

- (SHAuxWindow*) savedWindow;
- (void) setSavedWindow:(NSWindow *)aWindow;

- (NSString*) name;

@end
