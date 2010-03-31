//
//  ViewController_Base.m
//  iphonePlay
//
//  Created by steve hooley on 20/02/2009.
//  Copyright 2009 BestBefore Ltd. All rights reserved.
//

#import "ViewController_Base.h"


@implementation ViewController_Base

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
    }
    return self;
}

- (id)init {

    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	self=[super initWithCoder:aDecoder];
    if(self) {
    }
    return self;
}

- (void)dealloc {

    [super dealloc];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
