//
//  SHNodeListView_C.h
//  SHExtras
//
//  Created by Steven Hooley on 09/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QCClasses.h"
#import "SHCustomViewController.h"
#import "SHViewControllerProtocol.h"
//#import <Shared/Shared.h>"

@class SHNodeListView_M, SHNodeListView_V;

@interface SHNodeListView_C : SHCustomViewController <SHViewControllerProtocol>  {

	SHNodeListView_M	*_model;
	NSString*			_name;
//	SHNodeListView_V	*_view;

}

#pragma mark -
#pragma mark class methods
+ (SHNodeListView_C*) defaultController;

#pragma mark action methods
- (void) menuAction:(id)sender;
- (void) show:(id)sender;
// - (void) hide:(id)sender;

- (void) updateSelectionInView;

#pragma mark accessor methods
- (SHNodeListView_M *)model;
- (void)setModel:(SHNodeListView_M *)value;

- (SHNodeListView_V*) view;


- (NSString*) name;
- (void) setName:(NSString*)aName;

@end
