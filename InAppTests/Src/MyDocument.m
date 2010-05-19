//
//  MyDocument.m
//  InAppTests
//
//  Created by Steven Hooley on 06/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import "MyDocument.h"
#import <SHShared/SHShared.h>

@implementation MyDocument

@synthesize selectedGender;


- (id)init
{
    self = [super init];
    if (self) {
    
		selectedGender = @"male";
		genders = [[NSArray alloc] initWithObjects:
				   [NSDictionary dictionaryWithObjectsAndKeys:@"male", @"name", @"m", @"value", nil],
				   [NSDictionary dictionaryWithObjectsAndKeys:@"female", @"name", @"f", @"value", nil], 
				   nil];
		
		
		 employees = [[NSMutableArray alloc] initWithObjects:
							[NSDictionary dictionaryWithObjectsAndKeys:@"Steven", @"name", @"m", @"value", nil],
							[NSDictionary dictionaryWithObjectsAndKeys:@"Gavin", @"name", @"f", @"value", nil],
							[NSDictionary dictionaryWithObjectsAndKeys:@"Clara", @"name", @"f", @"value", nil], 
					 [NSDictionary dictionaryWithObjectsAndKeys:@"Clara2", @"name", @"f", @"value", nil], 
						
					 nil];  
    }
    return self;
}

- (IBAction)doSearch:(id)sender {
	NSLog(@"yay");
}

NSString *MovedRowsType = @"MOVED_ROWS_TYPE";

- (void)awakeFromNib {

	[popupArrayController setContent:genders];
	
	[tableArrayController setContent:employees];
	
	[tableView registerForDraggedTypes:[NSArray arrayWithObjects:MovedRowsType, NSFilenamesPboardType, nil]];
	[tableView setDraggingSourceOperationMask:NSDragOperationCopy|NSDragOperationMove forLocal:YES];
	[tableView setVerticalMotionCanBeginDrag: YES];
}

//- (int)numberOfRowsInTableView:(NSTableView *)tableViewArg {
//
//	if(tableView==tableViewArg){
//		return [[tableArrayController arrangedObjects] count];
//	}
//	return 0;
//} 

//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {
//	return nil;
//}
//- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
//	NSLog(@"boo");
//}

// tableView: methods indicates delegate method
/* If you are in 'All' mode we only support drags of one type at a time */
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
	
	// Read mod flags
//	BOOL alt_pressed = [NSApp altKeyDown];
	
	/* what shall we copy to the pasteboard? */
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	// if we have a node we can also drag it to the desktop
	/* NSFilesPromisePboardType allows you to drag to the desktop. Finder will call //tableView:namesOfPromisedFilesDroppedAtDestination:forDraggedRowsWithIndexes: */
	NSArray* writeTypes;
	
//		if(alt_pressed)
//			writeTypes = [NSArray arrayWithObjects:@"ALTKEY_PRESSED", MovedRowsType, nil];
//		else
			writeTypes = [NSArray arrayWithObjects:MovedRowsType, nil];
		[pboard declareTypes:writeTypes owner:self];

    [pboard setData:data forType:MovedRowsType];
    return YES;
}

/* if we are dragging to the same table (ie. reordering) each row must be of the same type, and if mode is 'All' you can only drop to the same destination type */
- (NSDragOperation)_validateSameTableDrop:(id <NSDraggingInfo>)info proposedRow:(int)proposedRow proposedDropOperation:(NSTableViewDropOperation)op {
	
    int result = NSDragOperationNone;
	NSPasteboard* pb = [info draggingPasteboard];
	NSData* rowData = [pb dataForType:MovedRowsType];
//	NSIndexSet* draggedRowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	result = NSDragOperationMove;
		 
	return result;
}

- (void)moveObjects:(NSArray *)children atIndexes:(NSIndexSet *)objectIndexes toIndexes:(NSIndexSet *)indexes {
	
	NSParameterAssert( [children count] );
	NSParameterAssert( [children count]==[indexes count] );
	NSParameterAssert( [indexes lastIndex]<[employees count] );
	
//	NSIndexSet *objectIndexes = [self indexesOfObjects:children];
//	// dont bother if not moving anywhere
//	if([objectIndexes isEqualToIndexSet:indexes] )
//		return;
	
//	NSArray *selectedObjects=nil;
//	if([_selection count]){
//		selectedObjects = [_array objectsAtIndexes:_selection];
//		
//		// this doesnt trigger a notification
//		//		[_selection removeAllIndexes];
//		
//		// i think we must trigger a deselct or proxy selection will get out of sync
//		[self setSelection:[NSIndexSet indexSet]];
//		
//	}
	
	[employees removeObjectsAtIndexes:objectIndexes];
	[employees insertObjects:children atIndexes:indexes];
}

- (BOOL)_acceptSameTableDrop:(id <NSDraggingInfo>)info row:(int)row proposedDropOperation:(NSTableViewDropOperation)op {
	
	NSLog(@"Drop on Row %i", row);
	BOOL result = false;
	
	NSPasteboard *pb = [info draggingPasteboard];
	NSData *rowData = [pb dataForType:MovedRowsType];
	NSIndexSet *draggedRowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];

	id obsToDrag = [[tableArrayController arrangedObjects] objectsAtIndexes:draggedRowIndexes];

	NSParameterAssert( [obsToDrag count] );
	//NSIndexSet *currentIndexes = [targetArray indexesOfObjects:obsToDrag];
	
	NSIndexSet *currentIndexesLessThanInsertionPt = [draggedRowIndexes indexesLessThan:row];
	NSIndexSet *currentIndexesGreaterThanEqualInsertionPt = [draggedRowIndexes indexesGreaterThanOrEqualTo:row];
	NSAssert([currentIndexesLessThanInsertionPt count]+[currentIndexesGreaterThanEqualInsertionPt count]==[draggedRowIndexes count], @"my indexset dividing has gone wrong");
	
	NSIndexSet *newIndexesLessThanSplit = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row-[currentIndexesLessThanInsertionPt count], [currentIndexesLessThanInsertionPt count])];
	NSIndexSet *newIndexesGreaterThanSplit = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, [currentIndexesGreaterThanEqualInsertionPt count])];
	NSMutableIndexSet *combined = [NSMutableIndexSet indexSet];
	[combined addIndexes:newIndexesLessThanSplit];
	[combined addIndexes:newIndexesGreaterThanSplit];
	NSAssert([combined count]==[obsToDrag count], @"number of indexes has got out of whack somewhere");
	[self moveObjects:obsToDrag atIndexes:draggedRowIndexes toIndexes:combined];
	
	return YES;
	

}


// tableView: methods indicates delegate method
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	
	BOOL result = false;
	
	if (operation == NSTableViewDropAbove) 
	{
		NSPasteboard* pboard = [info draggingPasteboard];
		NSString* firstType = [pboard availableTypeFromArray:[NSArray arrayWithObjects:MovedRowsType, nil]];
		if (row < 0)
			row = 0;
		
	
//			SHRootNodeListTableView* sourceTable = [info draggingSource];
//			SHRootNodeListTableView* destTable = (SHRootNodeListTableView*)aTableView;
////			
//			if(sourceTable==destTable)
//			{
//				[self disableTableUpdates];
				result = [self _acceptSameTableDrop:info row:row proposedDropOperation:operation];
//				[self enableTableUpdates];
				
	//		} else if([[destTable delegate] isKindOfClass:[self class]]) {
//				
//				result = [self _acceptDifferentTableDrop:info row:row proposedDropOperation:operation];
//			}

		// And refresh the table.  (Ideally, we should turn off any column highlighting)
		//dec09		[self deSelectAllChildren];
		//dec0		[displayedNodesTableView reloadData];	
    }
	return result;
} 

// tableView: methods indicates delegate method
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)proposedRow proposedDropOperation:(NSTableViewDropOperation)op 
{
	// logInfo(@"TableView validateDrop %i", op);
	NSUInteger result = NSDragOperationNone;
	
	/* Limiting it to only accept drops 'between' rows */
	if(op == NSTableViewDropAbove) 
	{	
		NSPasteboard* pb = [info draggingPasteboard];
	//	id sourceTable = [info draggingSource];
		//	NSWindow *draggingDestinationWindow = [info draggingDestinationWindow];
		//	NSDragOperation draggingSourceOperationMask = [info draggingSourceOperationMask];
		//- (NSPoint)draggingLocation;
		//- (NSPoint)draggedImageLocation;
		//- (NSImage *)draggedImage;
		//- (id)draggingSource;
		//- (NSInteger)draggingSequenceNumber;
		//- (void)slideDraggedImageTo:(NSPoint)screenPoint;
		//- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination;
		
		NSString* firstType = [pb availableTypeFromArray:[NSArray arrayWithObjects:MovedRowsType, nil]];
	//	NSTableView* destTable = (NSTableView *)tableView;
		
		// Are we dragging between SHRootNodeListTableViews ?
		// if( [[info draggingSource] class]==[displayedNodesTableView class] )
		if([firstType isEqualToString: MovedRowsType])
		{		
			/* are we reordering the same table ? */
//			if(sourceTable==destTable){
				result = [self _validateSameTableDrop:info proposedRow:proposedRow proposedDropOperation:op ];
//			} else {
//				result = [self _validateDifferentTableDrop:info proposedRow:proposedRow proposedDropOperation:op ];
//			}
			// }
			//	return NSDragOperationCopy;
		}// else if([firstType isEqualToString: NSFilenamesPboardType]){
//			
//			result = [self _validateFileDrop:info];
//		}
	}
    return result;
}


- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}


//mTapPort = CGEventTapCreate(kCGSessionEventTap, kCGTailAppendEventTap, 0x00000000,
//							CGEventMaskBit(kCGEventLeftMouseDown) | CGEventMaskBit(kCGEventLeftMouseUp) |
//							CGEventMaskBit(kCGEventRightMouseDown) | CGEventMaskBit(kCGEventRightMouseUp) |
//							CGEventMaskBit(kCGEventMouseMoved) | CGEventMaskBit(kCGEventLeftMouseDragged) |
//							CGEventMaskBit(kCGEventRightMouseDragged) | CGEventMaskBit(kCGEventKeyDown) |
//							CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventFlagsChanged) |
//							CGEventMaskBit(kCGEventScrollWheel) | CGEventMaskBit(kCGEventOtherMouseDown) |
//							CGEventMaskBit(kCGEventOtherMouseUp) | CGEventMaskBit(kCGEventOtherMouseDragged),
//							EventTapCallbackTramp, this);

@end
