//
//  SpokeDiagram_AppDelegate.m
//  SpokeDiagram
//
//  Created by steve hooley on 20/10/2008.
//  Copyright BestBefore Ltd 2008 . All rights reserved.
//

#import "SpokeDiagram_AppDelegate.h"
#import <FScript/FScript.h>
#import "RadialView.h"


@implementation SpokeDiagram_AppDelegate

@synthesize currentSpokes, currentAdjustments;
@synthesize adjustEventsSelectionIndexes;

/**
 Implementation of dealloc, to release the retained variables.
 */

- (void) dealloc {

	[self removeObserver:radialView forKeyPath:@"currentSpokes"];
    [self removeObserver:radialView forKeyPath:@"currentAdjustments"];
    self.currentSpokes = nil;
    self.currentAdjustments = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (void)awakeFromNib {

    /* load FScript */
	[[NSApp mainMenu] addItem:[[[FScriptMenuItem alloc] init] autorelease]];

    [self performSelector:@selector(recalcCurrentSpokes) withObject:nil afterDelay:1.0];

    NSAssert(radialView!=nil, @"need to hook up the view");
    [self addObserver:radialView forKeyPath:@"currentSpokes" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context: @"SpokeDiagram_AppDelegate"];
    [self addObserver:radialView forKeyPath:@"currentAdjustments" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context: @"SpokeDiagram_AppDelegate"];
}

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "SpokeDiagram" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"SpokeDiagram"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"SpokeDiagram.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {

    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}

- (IBAction)addEvent:(id)sender {

	NSString *side = [[eventSide selectedItem] title];
	int spokeInt = [[[eventSpoke selectedItem] title] intValue];
	NSAssert1(spokeInt>0 && spokeInt<19, @"cant have a spoke %i", spokeInt );
	NSNumber *spoke = [NSNumber numberWithInt:spokeInt];
	NSString *kind = [[eventKind selectedItem] title];
	NSLog(@"add event %@ %@ %@", side, spoke, kind );
	
	NSManagedObject *newAdjustment = [NSEntityDescription insertNewObjectForEntityForName:@"AdjustmentEvent" inManagedObjectContext:[self managedObjectContext]];
	[newAdjustment setValue:[NSDate date] forKey:@"date"];
	[newAdjustment setValue:side forKey:@"side"];
	[newAdjustment setValue:spoke forKey:@"spoke"];
	[newAdjustment setValue:kind forKey:@"kind"];

    [self recalcCurrentSpokes];
}

- (IBAction)addReading:(id)sender {
//	IBOutlet NSTextField *;

	NSString *side = [[readingSide selectedItem] title];
	int spokeInt = [[[readingSpoke selectedItem] title] intValue];
	NSAssert1(spokeInt>0 && spokeInt<19, @"cant have a spoke %i", spokeInt );
	NSNumber *spoke = [NSNumber numberWithInt:spokeInt];
    
#warning -- we must not have a reading for this spoke
#warning -- and we must be on the latest event
        
	float floatTension = [readIngTension floatValue];
	if(floatTension>0 && floatTension<1000)
	{
		NSNumber *tension = [NSNumber numberWithFloat:floatTension];
		//	NSLog(@"add reading %@ %@ %@", side, spoke, tension );
		
		NSManagedObject *newObservation = [NSEntityDescription insertNewObjectForEntityForName:@"ObservationEvent" inManagedObjectContext:[self managedObjectContext]];
		[newObservation setValue:[NSDate date] forKey:@"date"];
		[newObservation setValue:side forKey:@"side"];
		[newObservation setValue:spoke forKey:@"spoke"];
		[newObservation setValue:tension forKey:@"tension"];
	}
    
    [self recalcCurrentSpokes];
	
	// increment the gui pop-up
	int newSelectedIndex = [readingSpoke indexOfSelectedItem] + 1;
	newSelectedIndex >= [readingSpoke numberOfItems] ? newSelectedIndex=0: newSelectedIndex;
	[readingSpoke selectItemAtIndex:newSelectedIndex];

}

- (IBAction)removeEvent:(id)sender {
	
	// get selected events
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSArray *selectedObjects = [eventController selectedObjects];
	for(NSManagedObject *ob in selectedObjects){
		[moc deleteObject:ob];
	}
    [self recalcCurrentSpokes];
}

- (IBAction)removeReading:(id)sender {
	
	// get selected spokeies
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSArray *selectedObjects = [readingController selectedObjects];
	for(NSManagedObject *ob in selectedObjects){
		[moc deleteObject:ob];
	}
    [self recalcCurrentSpokes];
}

- (void)recalcCurrentSpokes {

	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *adjEntityDescription = [NSEntityDescription entityForName:@"AdjustmentEvent" inManagedObjectContext:moc];
	NSEntityDescription *obEntityDescription = [NSEntityDescription entityForName:@"ObservationEvent" inManagedObjectContext:moc];
	NSMutableArray *adjustmentEvents = [NSMutableArray array];
	
	// get date of selected start ADJUSTMENT event
	NSArray *selectedObjects = [eventController selectedObjects];
	NSAssert1([selectedObjects count]==1, @"oops %i", [selectedObjects count]);
	NSManagedObject *adjustmentEvent = [selectedObjects lastObject];
	[adjustmentEvents addObject:adjustmentEvent];
	
	NSDate *adjustmentDate = [adjustmentEvent valueForKey:@"date"];
	NSAssert(adjustmentDate!=nil, @"");
	
	NSFetchRequest *adjRequest = [[[NSFetchRequest alloc] init] autorelease];
	[adjRequest setEntity:adjEntityDescription];
	
	// get all the events after this date
	NSPredicate *adjPredicate = [NSPredicate predicateWithFormat: @"(date > %@)", adjustmentDate];
	[adjRequest setPredicate:adjPredicate];
	NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease];
	[adjRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	NSError *error = nil;
	NSArray *laterAdjutmentsArray = [moc executeFetchRequest:adjRequest error:&error];
	if(laterAdjutmentsArray == nil)
	{
		// Deal with error...
		NSLog(@"Error - %@", error);
	}
	// NSLog(@"we have %i later than this", [laterAdjutmentsArray count]);
	
	NSDate *futureDate = nil;
	NSFetchRequest *obRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSArray *readingsArray = nil;
	NSPredicate *obPredicate = nil;
	
	/* If more than one adjustment was done without taking any readings then we need to conflate these Adjustments */
	// now we can get all the readings between these two events. That is:- after the selected adjustment event but before the next adjustment event
	[obRequest setEntity:obEntityDescription];
	
	// go thru each later adjustment event until we find some readings - basically grouping multiple adjustment events with no readings
	for(int i=0; i<[laterAdjutmentsArray count]; i++)
	{
		NSManagedObject *futureAdjustmentEvent = [laterAdjutmentsArray objectAtIndex:i];
		[adjustmentEvents addObject:futureAdjustmentEvent];
		futureDate = [futureAdjustmentEvent valueForKey:@"date"];
		obPredicate = [NSPredicate predicateWithFormat: @"(date > %@) && (date < %@)", adjustmentDate, futureDate];
		[obRequest setPredicate:obPredicate];
		[obRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		readingsArray = [moc executeFetchRequest:obRequest error:&error];
		if([readingsArray count]>0)
			break;
	}
	
	// if we didn't find any readings between events try between selected adjustment and distant future
	if(readingsArray==nil || [readingsArray count]==0)
	{
		futureDate = [NSDate distantFuture];
		obPredicate = [NSPredicate predicateWithFormat: @"(date > %@) && (date < %@)", adjustmentDate, futureDate];
		[obRequest setPredicate:obPredicate];
		readingsArray = [moc executeFetchRequest:obRequest error:&error];
	}

    self.currentAdjustments = adjustmentEvents;
    self.currentSpokes = readingsArray;
}

- (NSArray *)sideLabels {
	return [NSArray arrayWithObjects:@"Drive", @"Non-Drive", nil];
}
- (NSArray *)spokeLabels {
	return [NSArray arrayWithObjects:@"1", @"2", @"3",@"4", @"5", @"6",@"7", @"8", @"9",@"10", @"11", @"12",@"13", @"14", @"15",@"16", @"17", @"18", nil];
}
- (NSArray *)kindLabels {
	return [NSArray arrayWithObjects:@"Tighter", @"Looser", nil];
}
- (NSArray *)displayModes {
	return [NSArray arrayWithObjects:@"Drive", @"Non-Drive", @"Both", nil];
}

- (void)setAdjustEventsSelectionIndexes:(NSIndexSet *)value {
	
    if(adjustEventsSelectionIndexes!=value){
        [value retain];
        [adjustEventsSelectionIndexes release];
        adjustEventsSelectionIndexes = value;
        if([adjustEventsSelectionIndexes count]>0)
            [self recalcCurrentSpokes];
    }
}

- (int)currentDisplayMode {
	
	return currentDisplayMode;
}

- (void)setCurrentDisplayMode:(int)value {
	
	currentDisplayMode = value;
	[self recalcCurrentSpokes];
}

@end
