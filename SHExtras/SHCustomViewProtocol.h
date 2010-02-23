#import <Cocoa/Cocoa.h>

// [object conformsToProtocol: @protocol( SomeProtocol )] 
// returns a BOOL if the object conforms to that protocol. 
// This works the same for classes as well: 
// [SomeClass conformsToProtocol: @protocol( SomeProtocol )]

/*
 * 
 * 
 *
*/

@protocol SHCustomViewProtocol <NSObject>

// - (void) setHasBeenResized:(NSRect)newSize;

- (void) layOutAtNewSize;

- (NSRect)frame;

- (void)setFrame:(NSRect)frameRect;

- (NSView*) superview;

//- (id)initWithParentScript:(id<ScriptNodeProtocol>)ps;

//- (int)uniqueID;
//- (void)setUniqueID:(int)anUniqueID;

//-(NSString *) name;
//- (BOOL)setName:(NSString *)aName;

//- (NSString *) category;
//- (void) setCategory: (NSString *) aCategory;

//- (id<ScriptNodeProtocol>) parentScript;
//- (void) setParentScript: (id<ScriptNodeProtocol>) aParentScript;

//- (void) deleteNode;

@end