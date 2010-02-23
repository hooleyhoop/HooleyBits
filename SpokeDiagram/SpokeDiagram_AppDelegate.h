//
//  SpokeDiagram_AppDelegate.h
//  SpokeDiagram
//
//  Created by steve hooley on 20/10/2008.
//  Copyright BestBefore Ltd 2008 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RadialView;

@interface SpokeDiagram_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
    NSArray *currentSpokes, *currentAdjustments;
    NSIndexSet *adjustEventsSelectionIndexes;
    
	/* GUI Elements */
	IBOutlet NSPopUpButton *eventSide, *readingSide, *eventSpoke, *readingSpoke, *eventKind;
	IBOutlet NSTextField *readIngTension;
	IBOutlet NSArrayController *eventController, *readingController;
	IBOutlet RadialView	*radialView;
	
	int currentDisplayMode;
}

@property (retain) NSArray *currentSpokes;
@property (retain) NSArray *currentAdjustments;
@property (retain) NSIndexSet *adjustEventsSelectionIndexes;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

- (IBAction)addEvent:(id)sender;
- (IBAction)addReading:(id)sender;

- (IBAction)removeEvent:(id)sender;
- (IBAction)removeReading:(id)sender;

- (void)recalcCurrentSpokes;

- (int)currentDisplayMode;

@end
