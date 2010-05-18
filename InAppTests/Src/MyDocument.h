//
//  MyDocument.h
//  InAppTests
//
//  Created by Steven Hooley on 06/01/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

@interface MyDocument : NSDocument
{
	// pop up
	NSArray						*genders;
	NSString						*selectedGender;
	IBOutlet NSArrayController	*popupArrayController;
	
	// table
	NSMutableArray				*employees;
	IBOutlet NSArrayController	*tableArrayController;
	IBOutlet NSTableView			*tableView;

}
@property (nonatomic, copy) NSString *selectedGender;

- (IBAction)doSearch:(id)sender;

@end
