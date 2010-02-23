//
//  SHNodeListView_V.m
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNodeListView_V.h"


static NSNib* _SHNodeListViewNib;


@implementation SHNodeListView_V


#pragma mark -
#pragma mark class methods
//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	// unarchive the view from the nib
    _SHNodeListViewNib = [[NSNib alloc] initWithNibNamed:@"NodeListView" bundle:[NSBundle bundleForClass:[self class]] ];
	if(_SHNodeListViewNib==nil){
		NSLog(@"SHNodeListView_V: ERROR SHNodeListView_V cant find it's nib.");
	}
}


#pragma mark init methods
// ===========================================================
// - initWithController:
// ===========================================================
- (id) initWithController:(SHNodeListView_C*)aController
{	
    if ((self = [super initWithFrame:NSMakeRect(0,0,100,100)]) != nil)
    {
		_controller = aController;
		[_SHNodeListViewNib instantiateNibWithOwner:self topLevelObjects:nil];
		NSAssert(_savedWindow != nil && _contents != nil, @"IBOutlets were not set correctly in NodeListView.nib");
		
	//	[self layOutAtNewSize];
	//	[self show];
		
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
//=========================================================== 
// - show:
//=========================================================== 
- (void) show 
{
	// NSLog(@"SHNodeListView_V.m: about to show window");
//	[_savedWindow setContentView:self];
	[self addSubview: _contents];
	// NSLog(@"content view is %@", _contents);
	[_savedWindow display];
	[_savedWindow orderFront:self];
	
//	[self setFrame: [[self superview] frame]];
}

//=========================================================== 
// - hide:
//=========================================================== 
- (void) hide 
{
	// NSLog(@"SHNodeListView_V.m: about to hide window");
	// [_savedWindow setContentView:self];
	[_contents removeFromSuperview];

//	[_savedWindow close];
}


//=========================================================== 
// - layOutAtNewSize:
//=========================================================== 
- (void) layOutAtNewSize
 { 
	// NSLog(@"SHObjectListView: layOutAtNewSize");
	
	[super layOutAtNewSize];
	NSRect rect = [self frame];
	[_contents setFrame:rect];
	// hack, make sure the table view is aligner left
	//[_tableViewContainer setFrame:NSMakeRect(8,8,rect.size.width-85, rect.size.height-58)];

	[_contents setNeedsDisplay:YES];
	[_tableViewContainer setNeedsDisplay:YES];
	[_tableView setNeedsDisplay:YES];

}

// - (IBAction) upButtonClicked:(id)sender;
// - (IBAction) downButtonClicked:(id)sender;

//=========================================================== 
// - updateSelectionInModel:
//=========================================================== 
- (IBAction)updateSelectionInModel:(id)sender{
	// [(SHObjectListControl*)_controller updateSelectionInModel];
}


//=========================================================== 
// - updateSelectionTableView:
//=========================================================== 
- (void)updateSelectionTableView
{
	// when a node is added to the model the table doesnt seem to notice it automatically
	// NSLog(@"arranged objects is %@", [[_arrayController arrangedObjects] class]);
	
	id ob = [self valueForKeyPath:@"controller.model.qcPatchArray"];
	// NSLog(@"identifier of first element is %@", [[ob objectAtIndex:0] identifier]);

	[_tableView deselectAll:nil];
	[_tableView reloadData];
}

// ===========================================================
// - drawRect
// ===========================================================
- (void)drawRect:(NSRect)rect 
{
	[[NSColor whiteColor] set];
	NSRectFill(rect);
}
[NSResponder res

#pragma mark delegate methods
// Handling double-clicks
// Use NSTableView's -setDoubleAction: method, and supply it a standard IBAction-style method selector.
// You may need to also do -setTarget:. double-clicks get sent if the column isn't editable, so you may need to grab the column and do a -setEditable: NO on it.


//- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex{}

//- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn
- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    int row;
    row = [tableView selectedRow];

    if (row == -1) {
        do stuff for the no-rows-selected case
    } else {
        do stuff for the selected row
    }

} // tableViewSelectionDidChange

//- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification

//- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
            id_table = [aTable tag];
            id_column = [aCol identifier];
	NSLog(@"shouldEditTableColumn? %@, %@", aTableColumn, rowIndex);
}

//- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTable{
//          loc_row = [aTable selectedRow];
 //         loc_col = [aTable selectedColumn];
//}

// need to make a custom motherfucking table view
- (void) textDidEndEditing: (NSNotification *) notification
{
    NSDictionary *userInfo;
    userInfo = [notification userInfo];

    NSNumber *textMovement;
    textMovement = [userInfo objectForKey: @"NSTextMovement"];

    int movementCode;
    movementCode = [textMovement intValue];

    // see if this a 'pressed-return' instance

    if (movementCode == NSReturnTextMovement) {
        // hijack the notification and pass a different textMovement
        // value

        textMovement = [NSNumber numberWithInt: NSIllegalTextMovement];

        NSDictionary *newUserInfo;
        newUserInfo = [NSDictionary dictionaryWithObject: textMovement
                                    forKey: @"NSTextMovement"];

        notification = [NSNotification notificationWithName:
                                           [notification name]
                                       object: [notification object]
                                       userInfo: newUserInfo];
    }

    [super textDidEndEditing: notification];

} // textDidEndEditing

#pragma mark accessor methods
//=========================================================== 
// - controller:
//=========================================================== 
// - (SHNodeListView_C*) controller {return _controller;}

//=========================================================== 
// - contents:
//=========================================================== 
- (NSView *)contents { return _contents; }

//=========================================================== 
// - setContents:
//=========================================================== 
- (void)setContents:(NSView *)aContents{
    if (_contents != aContents) {
        [aContents retain];
        [_contents release];
        _contents = aContents;
		[_tableView deselectAll:nil];
		// NSLog(@"SHObjectListView:Setting content");
    }
}

- (NSScrollView*)tableViewContainer { return _tableViewContainer; }
- (void)setTableViewContainer:(NSScrollView *)aTableViewContainer{
    if (_tableViewContainer != aTableViewContainer) {
        [aTableViewContainer retain];
        [_tableViewContainer release];
        _tableViewContainer = aTableViewContainer;
    }
}

- (NSTableView*)tableView { return _tableView; }
- (void)setTableView:(NSTableView *)aTableView{
    if (_tableView != aTableView) {
        [aTableView retain];
        [_tableView release];
        _tableView = aTableView;
    }
}


//=========================================================== 
// - savedWindow:
//=========================================================== 
- (SHAuxWindow *)savedWindow { return _savedWindow; }

//=========================================================== 
// - setSavedWindow:
//=========================================================== 
- (void)setSavedWindow:(NSWindow *)aWindow{
    if (_savedWindow != aWindow) {
        [aWindow retain];
        [_savedWindow release];
        _savedWindow = aWindow;
    }
}


- (NSString*) name
{
	return @"steve";
}
@end
