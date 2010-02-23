//
//  SHNodeListView_M.h
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
//#import <Shared/Shared.h>"

@class SHNodeListView_C, QCPatchView;

@interface SHNodeListView_M : NSObject {
	
	SHNodeListView_C*	_controller;
	BOOL				_isBound;
	QCPatchEditorView*	_QCPatchEditorView;
	QCPatch				*_rootPatch;
	NSMutableArray*		_qcPatchArray;
	
	NSMutableIndexSet* _selectedNodeIndexes;

}


#pragma mark -
#pragma mark class methods


#pragma mark init methods
- (id)initWithController:(SHNodeListView_C*) controller;

- (void) initBindings;
- (void) unBind;
- (void) addAsObserver;

#pragma mark action methods
- (void)updateList:(NSNotification*)note;

- (void) syncWithNodeGraphModel;

#pragma mark accessor methods
/* These are just stubs to prompt the bindings to update */
- (NSArray *)qcPatchArray;
- (void) setQcPatchArray:(NSMutableArray *)value;

- (unsigned)countOfQcPatchArray;
- (id)objectInQcPatchArrayAtIndex:(unsigned)theIndex;
- (void)getQcPatchArray:(id *)objsPtr range:(NSRange)range;
- (void)insertObject:(id)obj inQcPatchArrayAtIndex:(unsigned)theIndex;
- (void)removeObjectFromQcPatchArrayAtIndex:(unsigned)theIndex;
- (void)replaceObjectInQcPatchArrayAtIndex:(unsigned)theIndex withObject:(id)obj;

/* a little helper function to recursively add content patches to an array */
void addSubPatches( NSArray* dest, QCPatch* aPatch );


- (NSMutableIndexSet *)selectedNodeIndexes;
- (void)setSelectedNodeIndexes:(NSMutableIndexSet *)value;


// - (QCPatch *) theCurrentPatch;
// - (void) setTheCurrentPatch:(QCPatch*)aPatch;

- (QCPatchEditorView *)QCPatchEditorView;
- (void)setQCPatchEditorView:(QCPatchEditorView *)value;

- (QCPatch *)rootPatch;
- (void)setRootPatch:(QCPatch *)value;

- (NSString*) name;

@end
