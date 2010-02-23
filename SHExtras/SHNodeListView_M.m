//
//  SHNodeListView_M.m
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "SHNodeListView_M.h"
#import "SHNodeListView_C.h"
#import "SHNodeListView_V.h"
#import "SHPatch.h"
/*
 *
*/
@implementation SHNodeListView_M


#pragma mark -
#pragma mark class methods
//=========================================================== 
// + initialize:
//=========================================================== 
+ (void) initialize 
{ 
	NSLog(@"initialize SHNodeListView_M");
}


#pragma mark init methods
// ===========================================================
// - initWithController:
// ===========================================================
- (id)initWithController:(SHNodeListView_C*) controller
{	
	if(self=[super init])
	{
		NSLog(@"SHNodeListView_M: init");
		_controller = controller;
		_QCPatchEditorView = nil;
		_rootPatch = nil;
		_isBound = NO;
	} 
	return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc {
	[self unBind];

	_controller = nil;
    [super dealloc];
}

//=========================================================== 
// - initBindings:
//=========================================================== 
- (void) initBindings
{
	// This can easily be called twice so its best to protect
	if(!_isBound)
	{
		NSLog(@"SHNodeListView_M: initing bindings"); // yes, if you rebind the doneAdded and deleted
		// SHObjectGraphModel* graphModel	= [SHObjectGraphModel graphModel];
		// NSAssert(graphModel != nil, @"SHNodeListView_M: ERROR: There is no GraphModel To Connect to.");
		// [graphModel addObserver:self forKeyPath:@"theCurrentNodeGroup" options:NSKeyValueObservingOptionNew context:NULL];
		// [graphModel addObserver:self forKeyPath:@"theCurrentNodeGroup.nodesAndConnectletsInside" options:NSKeyValueObservingOptionNew context:NULL];
		
		[self addAsObserver];
		_isBound = YES;
	} 
}

//=========================================================== 
// - unBind:
//=========================================================== 
- (void) unBind
{
	if(_isBound)
	{
		// SHObjectGraphModel* graphModel	= [SHObjectGraphModel graphModel];
		// [graphModel removeObserver:self forKeyPath:@"theCurrentNodeGroup"];
		// [graphModel removeObserver:self forKeyPath:@"theCurrentNodeGroup.nodesAndConnectletsInside"];
	//	[_QCPatchEditorView removeObserver:self forKeyPath:@"patch"];

		// observe notifications from the model
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		_isBound = NO;
	}
}

//=========================================================== 
// - addAsObserver:
//=========================================================== 
- (void) addAsObserver
{
	// observe notifications from the model
	// basically you have to redo this evrytime current nodegroup changes
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self];
	
	NSLog(@"SHNodeListView_M: addAsObserver" );
	[defaultCenter addObserver:self selector:@selector(GFGraphLayoutDidChangeNotification:) name:@"GFGraphLayoutDidChangeNotification" object:nil];
	[defaultCenter addObserver:self selector:@selector(GFGraphEditorViewContentDidChangeNotification:) name:@"GFGraphEditorViewContentDidChangeNotification" object:nil];
	[defaultCenter addObserver:self selector:@selector(GFGraphEditorViewSelectionDidChangeNotification:) name:@"GFGraphEditorViewSelectionDidChangeNotification" object:nil];
	
	// [nc addObserver: self selector:@selector(updateList:) name:@"SHNodeAdded" object: [self theCurrentNodeGroup] ];
	// [nc addObserver: self selector:@selector(updateList:) name:@"SHNodeDeleted" object: [self theCurrentNodeGroup] ];
}

// ===========================================================
// - GFGraphLayoutDidChangeNotification:
// ===========================================================
- (void) GFGraphLayoutDidChangeNotification:(NSNotification*) note
{
//	NSString *name = [note name];
///	id object = [note object];	// currrent parent node
//	NSDictionary *userInfo	= [note userInfo];
	NSLog(@"GFGraphLayoutDidChangeNotification" );
	

//	[self setRootPatch:object];
	
	/* update any bound objects */
	[self updateList:nil];
}

// ===========================================================
// - GFGraphEditorViewContentDidChangeNotification:
// ===========================================================
- (void) GFGraphEditorViewContentDidChangeNotification:(NSNotification*) note
{
	// NSString *name = [note name];
	id object = [note object];	// QCPatchView
	// NSDictionary *userInfo	= [note userInfo];
	NSLog(@"GFGraphEditorViewContentDidChangeNotification %@", object );
	
	/* not the best hook into quartz data model! */
	if(object!=_QCPatchEditorView){
		[self setQCPatchEditorView:object];
		[self setRootPatch:[_QCPatchEditorView patch]];
		[self setQcPatchArray:[_rootPatch subpatches]];
	}
	[self updateList:nil];

	// NSLog(@"_QCPatchEditorView is %@, patch is %@", _QCPatchEditorView, [[_QCPatchEditorView patch] description] );
	// NSLog(@"Received Notification %@, %@, %@, ", name, object, [userInfo description] );
}

// ===========================================================
// - GFGraphEditorViewSelectionDidChangeNotification:
// ===========================================================
- (void) GFGraphEditorViewSelectionDidChangeNotification:(NSNotification*) note
{
	// NSString *name = [note name];
	// id object = [note object];	// QCPatchView
	// NSDictionary *userInfo	= [note userInfo];
	// NSLog(@"selection changed %@, %@, %@", name, object, userInfo );
	
	NSMutableIndexSet* selectedNodes = [[[NSMutableIndexSet alloc] init] autorelease];;

	NSArray* allPatches =  [self qcPatchArray];

	id patch;
	int i, count=[allPatches count];
	for(i=0;i<count;i++)
	{
		patch = [allPatches objectAtIndex:i];
		BOOL flag = [patch isSelected];
		if(flag)
		 [selectedNodes addIndex:i];
	}
	[self setSelectedNodeIndexes:selectedNodes];


}



//=========================================================== 
// - observeValueForKeyPath:  ofObject change context
//=========================================================== 
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSLog(@"SHNodeListView_M: CurrentNodeGroup Changed !!!!!!!!!!!!!!!!!!!!! %@", keyPath);

	if ([keyPath isEqual:@"_QCPatchEditorView.patch"])
	{
		NSLog(@"SHNodeListView_M: CurrentNodeGroup Changed !!!!!!!!!!!!!!!!!!!!!");
	//	[self setTheCurrentNodeGroup: (SHNodeGroup*)[change objectForKey:NSKeyValueChangeNewKey]];
//		[self bindNodeAddedAndDeleted];
//	//	[self syncWithNodeGraphModel];
//		[_theSHObjectListControl updateSelectionInView];
//	} else if ([keyPath isEqual:@"theCurrentNodeGroup.nodesAndConnectletsInside"])
//	{
//		@try {
//				// we need this for when we re order the nodes
//				//NSLog(@"SHNodeListView_M: nodesAndConnectletsInside_Array Changed !!!!!!!!!!!!!!!!!!");
//				id newOb = [change objectForKey:NSKeyValueChangeNewKey];
//				if([newOb isKindOfClass:[NSArray class]])
//				{
//					// NSLog(@"SHNodeListView_M: okay so far...");
//					[self setNodesInCurrentNodeGroup_Array: newOb];
//					// NSLog(@"SHNodeListView_M: even okay this far...");
//				}
//		} @catch (NSException *exception) {
//				NSLog(@"SHNodeListView_M: ERROR: Caught %@: %@", [exception name], [exception reason]);
//				NSLog(@"SHNodeListView_M: ERROR: change is %@", change);
//		} @finally {
//
//		}
    }
}

#pragma mark action methods

//=========================================================== 
// - updateList
//=========================================================== 
- (void)updateList:(NSNotification*)note
{
	// NSLog(@"SHNodeListView_M:"); // yes, if you rebind the doneAdded and deleted
	// NSLog(@"SHNodeListView_M: Updating List:Does this work when we swap node groups? eh?"); // yes, if you rebind the doneAdded and deleted
//bb	[self setNodesInCurrentNodeGroup_Array: [[self theCurrentNodeGroup] nodesAndConnectletsInside]];
	[self setQcPatchArray:nil];
	[_controller updateSelectionInView];
}


//=========================================================== 
// - syncWithNodeGraphModel:
//=========================================================== 
- (void) syncWithNodeGraphModel
{
//bb	SHObjectGraphModel* graphModel	= [SHObjectGraphModel graphModel];
//bb	[self setTheCurrentNodeGroup: [graphModel theCurrentNodeGroup]];
//bb	[self updateList:nil];
	// NSLog(@"SHNodeListView_M: the current node list contents are %@", [[graphModel theCurrentNodeGroup] nodesAndConnectletsInside]);

//bb	[self unBind];
//bb	[self initBindings];
}

#pragma mark accessor methods

//=========================================================== 
// - setQcPatchArray:
//=========================================================== 
- (void) setQcPatchArray:(NSMutableArray *)value {
	/* These are just stubs to prompt the bindings to update */
}

//=========================================================== 
// - qcPatchArray:
//=========================================================== 
- (NSArray *)qcPatchArray 
{
	NSMutableArray* allPatchesArray = [NSMutableArray arrayWithCapacity:3];

	NSEnumerator *enumerator1 = [[_rootPatch subpatches] objectEnumerator];
	id patch;
	while ((patch = [enumerator1 nextObject])) 
	{
		[patch willChangeValueForKey:@"name"];
		[patch setName:@"temp"];
		[patch didChangeValueForKey:@"name"];
		[allPatchesArray addObject:patch];
		addSubPatches(allPatchesArray, patch);
		
		BOOL t = [[patch class] automaticallyNotifiesObserversForKey:@"name"];
		NSLog(@"ttttt ttttt ttttt %i", t);

	}

	// return [_rootPatch subpatches];
	return allPatchesArray;
}

//=========================================================== 
// - addSubPatches:
//=========================================================== 
void addSubPatches( NSArray* allPatchesArray, QCPatch* aPatch )
{
//	if([aPatch allowsSubpatches])
//	{
		NSEnumerator *enumerator1 = [[aPatch subpatches] objectEnumerator];
		id patch;
		while ((patch = [enumerator1 nextObject])) 
		{
			[allPatchesArray addObject:patch];
			addSubPatches(allPatchesArray, patch);
		}
//	}
}

- (NSMutableIndexSet *)selectedNodeIndexes {
    return [[_selectedNodeIndexes retain] autorelease];
}

- (void)setSelectedNodeIndexes:(NSMutableIndexSet *)value {
    if (_selectedNodeIndexes != value) {
        [_selectedNodeIndexes release];
        _selectedNodeIndexes = [value copy];
    }
}

//=========================================================== 
// - countOfQcPatchArray:
//=========================================================== 
- (unsigned)countOfQcPatchArray {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    return [_qcPatchArray count];
}

//=========================================================== 
// - objectInQcPatchArrayAtIndex:
//=========================================================== 
- (id)objectInQcPatchArrayAtIndex:(unsigned)theIndex {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    return [_qcPatchArray objectAtIndex:theIndex];
}

//=========================================================== 
// - getQcPatchArray:
//=========================================================== 
- (void)getQcPatchArray:(id *)objsPtr range:(NSRange)range {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    [_qcPatchArray getObjects:objsPtr range:range];
}

- (void)insertObject:(id)obj inQcPatchArrayAtIndex:(unsigned)theIndex {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    [_qcPatchArray insertObject:obj atIndex:theIndex];
}

- (void)removeObjectFromQcPatchArrayAtIndex:(unsigned)theIndex {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    [_qcPatchArray removeObjectAtIndex:theIndex];
}

- (void)replaceObjectInQcPatchArrayAtIndex:(unsigned)theIndex withObject:(id)obj {
    if (!_qcPatchArray) {
        _qcPatchArray = [[NSMutableArray alloc] init];
    }
    [_qcPatchArray replaceObjectAtIndex:theIndex withObject:obj];
}


- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key
{
	NSLog(@"WHOOP WHOOP!");
	return nil;
}
- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath
{
	NSLog(@"WHOOP WHOOP!");
	return nil;
}

//=========================================================== 
// - theCurrentNodeGroup:
//=========================================================== 
//bb- (SHNodeGroup *) theCurrentNodeGroup {
//bb	SHObjectGraphModel* graphModel	= [SHObjectGraphModel graphModel];	// probably should use a global object instead of singleton
//bb	return [graphModel theCurrentNodeGroup];
//bb}
//bb- (void)setTheCurrentNodeGroup:(SHNodeGroup *)a_theCurrentNodeGroup
//bb{
	/* These are just stubs to prompt the bindings to update */
//bb}

- (QCPatchEditorView *)QCPatchEditorView {
    return [[_QCPatchEditorView retain] autorelease];
}

- (void)setQCPatchEditorView:(QCPatchEditorView *)value {
    if (_QCPatchEditorView != value) {
		[value retain];
        [_QCPatchEditorView release];
        _QCPatchEditorView = value;
    }
}

- (QCPatch *)rootPatch {
    return [[_rootPatch retain] autorelease];
}

- (void)setRootPatch:(QCPatch *)value {
    if (_rootPatch != value) {
		NSLog(@"setting root patch %@", value);
		[value retain];
        [_rootPatch release];
        _rootPatch = value;
    }
}

- (NSString*) name
{
	return @"hooley";
}

@end
