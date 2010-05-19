//
//  ViewController_mainScreen.m
//  iphonePlay
//
//  Created by Steven Hooley on 1/15/09.
//  Copyright Bestbefore 2009. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "ViewController_mainScreen.h"
#import "Widget_Keyboard_Simplest.h"
#import "iphonePlayAppDelegate.h"
#import "HooleyTouchEvent.h"
#import "SHooleyObject.h"
#import "GridLayout.h"
#import "SimpleViewSwitcherProtocol.h"
#import "View_Base.h"
#import "LogController.h"
#import "CustomScrollView.h"
#import "iphonePlayAppDelegate.h"
#import "TouchMeter.h"
#import "ScrollController.h"

// Constant for the number of times per second (Hertz) to sample acceleration.
#define kAccelerometerFrequency     40

@implementation ViewController_mainScreen

@synthesize cpuUsage, infoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {

		// Configure and start the accelerometer
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
		[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		
//		tlo = [[NSBundle mainBundle]loadNibNamed:@"View_main" owner:self options:nil];
//		[tlo retain];
//		[tlo makeObjectsPerformSelector: @selector(release)];
//		[self viewDidLoad];
    }
    return self;
}

- (void)dealloc {
	
	UIView *stillGotView = self.view;

	self.view = nil;
	[tlo release];
	
	int retainCount = [stillGotView retainCount];
	for(int i=0; i<retainCount; i++)
		[stillGotView release];
	
	[animationTimer release];

	[infoButton release];

	[keyBoardWidget removeFromView:(UIView *)self];
	[keyBoardWidget release];
	
	[TouchMeter clean];

    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	
//	for( NSString *familyName in [UIFont familyNames] )
//		for( NSString *fntName in [UIFont fontNamesForFamilyName:familyName] )
//			NSLog(@"%@", fntName);

			
	UIFont *f1 = [UIFont fontWithName:@"Helvetica" size:15];
	[@"Hello" sizeWithFont:f1];
	
    [super viewDidLoad];

	keyBoardWidget = [[Widget_Keyboard_Simplest alloc] init];
	[keyBoardWidget addToView:self.view];
}


- (void)viewDidAppear:(BOOL)animated {

#warning! cant leave this here!
	/* Experimental - try inserting a scrollview */
	
	_scrollController = [ScrollController new];
	UIView *contentViewParent = [self.view superview];
	[_scrollController doScrollMagicWithView:(View_main *)self.view];
	
	_touchMeter = [TouchMeter sharedTouchMeter];
	[_touchMeter addToView:contentViewParent];
	
	SHooleyObject<KeyboardProtocol> *activeKeyboard = (SHooleyObject<KeyboardProtocol> *)[(iphonePlayAppDelegate *)[[UIApplication sharedApplication] delegate] activeKeyboard];
	NSAssert(activeKeyboard && keyBoardWidget, @"No active keyboard for view to display");
	
	if(!keyBoardWidget.layoutManager){
		GridLayout *widgetLayout = [[[GridLayout alloc] init] autorelease];
		[keyBoardWidget setLayoutManager: widgetLayout]; 
		[keyBoardWidget setModel: activeKeyboard];
	}
	[keyBoardWidget relayout];
	
	/* Orientation EXperemienting */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[self setAnimating:YES];
}

- (void)didRotate:(id)sender {
	
	UIDevice *currentDevice = [UIDevice currentDevice];
	UIDeviceOrientation orientation = currentDevice.orientation;
	CustomScrollView *scrollview = (CustomScrollView *)[self.view superview];

	CGRect frame = scrollview.frame;
	CGRect windowFrame = [UIScreen mainScreen].applicationFrame;

	if(orientation==UIDeviceOrientationPortrait)
	{
		frame.size.width = windowFrame.size.width;
		frame.size.height = windowFrame.size.height;
		scrollview.orientation = UIDeviceOrientationPortrait;
		
	} else if( orientation==UIDeviceOrientationPortraitUpsideDown ){
		frame.size.width = windowFrame.size.width;
		frame.size.height = windowFrame.size.height;
		scrollview.orientation = UIDeviceOrientationPortraitUpsideDown;

	/* if you tilt down everything stays the same as previous orientation */
	} else if(orientation==UIDeviceOrientationFaceUp || orientation==UIDeviceOrientationFaceDown ) {
//		frame.size.width = windowFrame.size.height;
//		frame.size.height = windowFrame.size.width;

	} else if(orientation==UIDeviceOrientationLandscapeLeft){
		frame.size.width = windowFrame.size.height;
		frame.size.height = windowFrame.size.width;
		scrollview.orientation = UIDeviceOrientationLandscapeLeft;
		
	} else if(orientation==UIDeviceOrientationLandscapeRight){
		frame.size.width = windowFrame.size.height;
		frame.size.height = windowFrame.size.width;
		scrollview.orientation = UIDeviceOrientationLandscapeRight;

	} else {
		NSLog(@"Unknown Orientation!");
	}
	scrollview.frame = frame;
	
//	-- we need to resize content view and relayout the grid?
	CGSize neededSize = [keyBoardWidget neededSizeForScrollFrame:frame];
	
	[keyBoardWidget relayout];
	
	[[TouchMeter sharedTouchMeter] positionAtBottom];
}

// UIAccelerometerDelegate method, called when the device accelerates.
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    // Update the accelerometer graph view
   // [graphView updateHistoryWithX:acceleration.x Y:acceleration.y Z:acceleration.z];
}

/* The View Disappears when we toggle */
- (void)viewWillDisappear:(BOOL)animated {

	[self setAnimating:NO];
}

- (void)setAnimating:(BOOL)flag {

	if (flag) {
		if (!animationTimer)
			animationTimer = [[NSTimer scheduledTimerWithTimeInterval:1/10.0f target:self selector:@selector(updateGraphics) userInfo:nil repeats:YES] retain];
	} else {
		[animationTimer invalidate];
		[animationTimer release];
		animationTimer = nil;
	}
}

- (void)updateGraphics {

	Float32 uasge = [(iphonePlayAppDelegate *)[[UIApplication sharedApplication] delegate] cpuUsage];
	NSNumber *asNum = [NSNumber numberWithFloat:uasge];
	cpuUsage.text = [asNum stringValue];
}

/* HooleyTouchEvents are forwarded from the view */
- (void)touchBegan:(HooleyTouchEvent *)hTouchEvent {
	[keyBoardWidget touchBegan:hTouchEvent];
}

- (void)touchMoved:(HooleyTouchEvent *)hTouchEvent {
	[keyBoardWidget touchMoved:hTouchEvent];
}

- (void)touchEnded:(HooleyTouchEvent *)hTouchEvent {
	[keyBoardWidget touchEnded:hTouchEvent];
}

- (IBAction)infoButtonPressed:(id)sender {
	
	// -- how to msg parent view controller?
	UIView *toggleView = self.view;
	while( (toggleView=[toggleView superview]) && ([toggleView respondsToSelector:@selector(viewController)]) ){
		UIViewController *parentViewController = [(View_Base *)toggleView viewController];
		if(parentViewController){
			if([parentViewController conformsToProtocol:@protocol(SimpleViewSwitcherProtocol)]){
				[(UIViewController<SimpleViewSwitcherProtocol> *)parentViewController toggleView];
				break;
			} else
				logWarning(@"Parent View Controller is wrong type?");
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
