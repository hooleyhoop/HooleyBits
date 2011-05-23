//
//  HooStateMachineTests.m
//  HooStateMachineTests
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 Tinsal Parks. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "HooStateMachine_event.h"
#import "HooStateMachine_command.h"
#import "HooStateMachine_state.h"
#import "HooStateMachine.h"
#import "HooStateMachine_controller.h"
#import "HooStateMachineConfigurator.h"
#import <JSON/JSON.h>

@interface HooStateMachineTests : SenTestCase {
@private
    
}

@end


@implementation HooStateMachineTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {    
    [super tearDown];
}

- (void)testTheSimplestStateMachineExample {
    
	// She has a secret compartment in her bedroom that is normally locked and concealed.
	// To open it, she has to close the door, then open the second drawer in her chest and turn her bedside light on—in either order.
	// Once these are done, the secret panel is unlocked for her to open.
	// The controller Communicates with devices by receiving event messages and sending command messages.
	// These are both four-letter codes sent through the communication channels.
    
	HooStateMachine_event *doorClosed_event = [[[HooStateMachine_event alloc] initWithName:@"doorClosed"] autorelease];
	HooStateMachine_event *drawerOpened_event = [[[HooStateMachine_event alloc] initWithName:@"drawerOpened"] autorelease];
	HooStateMachine_event *lightOn_event = [[[HooStateMachine_event alloc] initWithName: @"lightOn"] autorelease];
	HooStateMachine_event *doorOpened_event = [[[HooStateMachine_event alloc] initWithName:@"doorOpened"] autorelease];
	HooStateMachine_event *panelClosed_event = [[[HooStateMachine_event alloc] initWithName: @"panelClosed"] autorelease];
    
	HooStateMachine_command *unlockPanelCmd = [[[HooStateMachine_command alloc] initWithName:@"unlockPanel"] autorelease];
	HooStateMachine_command *lockPanelCmd = [[[HooStateMachine_command alloc] initWithName:@"lockPanel"] autorelease];
	HooStateMachine_command *lockDoorCmd = [[[HooStateMachine_command alloc] initWithName:@"lockDoor"] autorelease];
	HooStateMachine_command *unlockDoorCmd = [[[HooStateMachine_command alloc] initWithName:@"unlockDoor"] autorelease];
    
	HooStateMachine_state *idle_state = [[[HooStateMachine_state alloc] initWithName:@"idle"] autorelease];
	HooStateMachine_state *active_state = [[[HooStateMachine_state alloc] initWithName:@"active"] autorelease];
	HooStateMachine_state *waitingForLight_state = [[[HooStateMachine_state alloc] initWithName:@"waitingForLight"] autorelease];
	HooStateMachine_state *waitingForDrawer_state = [[[HooStateMachine_state alloc]initWithName:@"waitingForDrawer"] autorelease];
	HooStateMachine_state *unlockedPanel_state = [[[HooStateMachine_state alloc] initWithName:@"unlockedPanel"] autorelease];
    
	HooStateMachine *stateMachineInstance = [[[HooStateMachine alloc] initWithStartState:idle_state resetEvents:nil] autorelease];
    
	[idle_state addTransitionOn:doorClosed_event toState:active_state];
    [idle_state addEntryAction:unlockDoorCmd];
    [idle_state addEntryAction:lockPanelCmd];
    
    [active_state addTransitionOn:drawerOpened_event toState:waitingForLight_state];
    [active_state addTransitionOn:lightOn_event toState:waitingForDrawer_state];

    [waitingForLight_state addTransitionOn:lightOn_event toState:unlockedPanel_state];

    [waitingForDrawer_state addTransitionOn:drawerOpened_event toState:unlockedPanel_state];

    [unlockedPanel_state addEntryAction:unlockPanelCmd];
    [unlockedPanel_state addEntryAction:lockDoorCmd];
    [unlockedPanel_state addTransitionOn:panelClosed_event toState:idle_state];
    
    NSArray *resetEvents = [NSArray arrayWithObject:doorOpened_event];
    [stateMachineInstance addResetEvents:resetEvents];
    
	// HooStateMachine_testCommandChannel testReciever = HooStateMachine_testCommandChannel alloc]();
    HooStateMachine_controller *controller = [[[HooStateMachine_controller alloc] initWithCurrentState:idle_state machine:stateMachineInstance commandsChannel:self] autorelease];

    STAssertEquals( [[controller currentState] name], @"st_idle", nil );

    [controller handle:@"ev_doorClosed"];
    STAssertEquals( [[controller currentState] name], @"st_active", nil );

    [controller handle:@"ev_drawerOpened"];
    STAssertEquals( [[controller currentState] name], @"st_waitingForLight", nil );

    [controller handle:@"ev_lightOn"];
    STAssertEquals( [[controller currentState] name], @"st_unlockedPanel", nil );
}

- (void)testTheSimplestStateMachineExampleWithJson {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simplest_config_json" ofType:@"json"];
    NSString *configContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSError *error = nil;    
    NSDictionary *config = [parser objectWithString:configContents error:&error];

	HooStateMachineConfigurator *simpleStateMachineParser = [[[HooStateMachineConfigurator alloc] initWithConfig:config] autorelease];    
    HooStateMachine *stateMachineInstance = [[[HooStateMachine alloc] initWithStartState:[simpleStateMachineParser state:@"st_idle"] resetEvents:nil] autorelease];

	// var testReciever = HooStateMachine_testCommandChannel alloc]();
    HooStateMachine_controller *controller = [[[HooStateMachine_controller alloc] initWithCurrentState:[simpleStateMachineParser state:@"st_idle"] machine:stateMachineInstance commandsChannel:self] autorelease];

    STAssertEquals( [[controller currentState] name], @"st_idle", nil );
    
    [controller handle:@"ev_doorClosed"];
    STAssertEquals( [[controller currentState] name], @"st_active", nil );
    
    [controller handle:@"ev_drawerOpened"];
    STAssertEquals( [[controller currentState] name], @"st_waitingForLight", nil );
    
    [controller handle:@"ev_lightOn"];
    STAssertEquals( [[controller currentState] name], @"st_unlockedPanel", nil );
}

- (void)testAHierarchicalStateMachineExample {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"hierarchical" ofType:@"json"];
    NSString *configContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSError *error = nil;    
    NSDictionary *config = [parser objectWithString:configContents error:&error];
    
	HooStateMachineConfigurator *simpleStateMachineParser = [[[HooStateMachineConfigurator alloc] initWithConfig:config] autorelease];   

    HooStateMachine *stateMachineInstance = [[[HooStateMachine alloc] initWithStartState:[simpleStateMachineParser state:@"st_off"] resetEvents:nil] autorelease];
    
	// var testReciever = HooStateMachine_testCommandChannel alloc]();
    HooStateMachine_controller *controller = [[[HooStateMachine_controller alloc] initWithCurrentState:[simpleStateMachineParser state:@"st_off"] machine:stateMachineInstance commandsChannel:self] autorelease];

    STAssertEquals( [[controller currentState] name], @"st_off", nil );

    [controller handle:@"ev_load"];

    STAssertEquals( [[controller currentState] name], @"st_loading", nil );
    
    [controller handle:@"ev_play"];

    STAssertEquals( [[controller currentState] name], @"st_playing", nil );
    
    [controller handle:@"ev_turnOff"];

    STAssertEquals( [[controller currentState] name], @"st_off", nil );
    
    
	// -- test result commands
    
}


@end
