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
    
	[active_state addTransitionOn:drawerOpened_event toState:[waitingForLight_state ];
	[active_state addTransitionOn:lightOn_event toState:waitingForDrawer_state];
    
	[waitingForLight_state addTransitionOn:lightOn_event toState:unlockedPanel_state];
    
	[waitingForDrawer_state addTransitionOn:drawerOpened_event toState:unlockedPanel_state];
    
	unlockedPanel_state.addEntryAction( unlockPanelCmd );
	unlockedPanel_state.addEntryAction( lockDoorCmd );
	unlockedPanel_state addTransitionOn:( panelClosed_event, idle_state );
    
	var resetEvents = new Array();
	resetEvents.push( doorOpened_event );
	stateMachineInstance.addResetEvents( resetEvents );
    
	var testReciever = HooStateMachine_testCommandChannel alloc]();
	var controller = HooStateMachine_controller alloc]( { currentState: idle_state, machine: stateMachineInstance, commandsChannel: testReciever } );
    
	equals( controller.currentState.name, "idle", "!" );
    
	controller.handle( "doorClosed" );
	equals( controller.currentState.name, "active", "!" );
    
	controller.handle( "drawerOpened" );
	equals( controller.currentState.name, "waitingForLight", "!" );
    
	controller.handle( "lightOn" );
	equals( controller.currentState.name, "unlockedPanel", "!" );
});

test("the simplest state machine example with json", function() {
    
	var simplestSM_config = {
		"states": [
                   "st_idle",
                   "st_active",
                   "st_waitingForLight",
                   "st_waitingForDrawer",
                   "st_unlockedPanel"
                   ],
		"events": [
                   "ev_doorClosed",
                   "ev_drawerOpened",
                   "ev_lightOn",
                   "ev_doorOpened",
                   "ev_panelClosed"
                   ],
		"commands": [
                     "cmd_unlockPanel",
                     "cmd_lockPanel",
                     "cmd_lockDoor",
                     "cmd_unlockDoor"
                     ],
		"transitions": [
                        { "state": "st_idle",					"event": "ev_doorClosed", 	"nextState": "st_active" },
                        { "state": "st_active", 				"event": "ev_drawerOpened",	"nextState": "st_waitingForLight" },
                        { "state": "st_active", 				"event": "ev_lightOn", 		"nextState": "st_waitingForDrawer" },
                        { "state": "st_waitingForLight",		"event": "ev_lightOn", 		"nextState": "st_unlockedPanel" },
                        { "state": "st_waitingForDrawer", 		"event": "ev_drawerOpened", "nextState": "st_unlockedPanel" },
                        { "state": "st_unlockedPanel", 			"event": "ev_panelClosed", 	"nextState": "st_idle" }
                        ],
		"actions": [
                    {"state": "st_idle", 			"entryAction": "cmd_unlockDoor", 	"exitAction": null },
                    {"state": "st_idle", 			"entryAction": "cmd_lockPanel", 	"exitAction": null },
                    {"state": "st_unlockedPanel", 	"entryAction": "cmd_unlockPanel", 	"exitAction": null },
                    {"state": "st_unlockedPanel", 	"entryAction": "cmd_lockDoor",		"exitAction": null }
                    ],
		"resetEvents": [
                        "doorOpened_event"
                        ]
	};
    
	var simpleStateMachineParser = HooStateMachineConfigurator alloc]({config: simplestSM_config });
	var stateMachineInstance = HooStateMachine alloc]( {startState: simpleStateMachineParser.state("st_idle") } );
	var testReciever = HooStateMachine_testCommandChannel alloc]();
	var controller = HooStateMachine_controller alloc]( { currentState: simpleStateMachineParser.state("st_idle"), machine: stateMachineInstance, commandsChannel: testReciever } );
    
	equals( controller.currentState.name, "st_idle", "!" );
    
	controller.handle( "ev_doorClosed" );
	equals( controller.currentState.name, "st_active", "!" );
    
	controller.handle( "ev_drawerOpened" );
	equals( controller.currentState.name, "st_waitingForLight", "!" );
    
	controller.handle( "ev_lightOn" );
	equals( controller.currentState.name, "st_unlockedPanel", "!" );
});

test("a hierarchical state machine example", function() {
    
	var hierarchicalSM_config = {
		"states": [
                   "st_off",
                   "st_on",
                   ["st_loading", "st_on"],
                   ["st_playing", "st_on"]
                   ],
		"events": [
                   "ev_load",
                   "ev_play",
                   "ev_turnOff"
                   ],
		"commands": [
                     "cmd_showOff",
                     "cmd_showOn",
                     "cmd_showLoad",
                     "cmd_showPlay"
                     ],
		"transitions": [
                        { "state": "st_off",		"event": "ev_load", 	"nextState": "st_loading" },
                        { "state": "st_off", 		"event": "ev_play",		"nextState": "st_playing" },
                        { "state": "st_loading", 	"event": "ev_play",		"nextState": "st_playing" }
                        ],
		"actions": [
                    {"state": "st_off", 		"entryAction": "cmd_showOff", 	"exitAction": null },
                    {"state": "st_on", 			"entryAction": "cmd_showOn", 	"exitAction": null },
                    {"state": "st_loading", 	"entryAction": "cmd_showLoad", 	"exitAction": null },
                    {"state": "st_playing", 	"entryAction": "cmd_showPlay",	"exitAction": null }
                    ],
		"resetEvents": ["ev_turnOff"]
	};
    
	var resultCommands = new Array();
	var TestCommandChannel = SC.Object.extend({
    send: function( command ) {
        resultCommands.push( command.name );
    }
	});
    
	var cmdChl = TestCommandChannel alloc]();
	var hierarchicalStateMachineParser = HooStateMachineConfigurator alloc]({ config: hierarchicalSM_config });
	var stateMachineInstance = HooStateMachine alloc]( { startState: hierarchicalStateMachineParser.state("st_off"), resetEvents: hierarchicalStateMachineParser._resetEvents } );
	var controller = HooStateMachine_controller alloc]( { currentState: hierarchicalStateMachineParser.state("st_off"), machine: stateMachineInstance, commandsChannel: cmdChl } );
    
	equals( controller.currentState.name, "st_off", "!" );
	controller.handle( "ev_load" );
	equals( controller.currentState.name, "st_loading", "!" );
	controller.handle( "ev_play" );
	equals( controller.currentState.name, "st_playing", "!" );
	controller.handle( "ev_turnOff" );
	equals( controller.currentState.name, "st_off", "!" );
    
	// -- test result commands
    
});

test("ThreeStateButtonStateMachine", function() {
    
	var ninja = new Mock();
    
	var threeButtonSM = ThreeStateButtonStateMachine alloc]({ _controller: ninja });
	equals( threeButtonSM.currentStateName(), "st_disabled", "!" );
    
	ninja.expects(1).method('cmd_enableButton');
	ninja.expects(1).method('cmd_showMouseUp1');
	threeButtonSM.processInputSignal( "ev_showState1" );
	equals( threeButtonSM.currentStateName(), "st_active1", "!" );
	ok(ninja.verify(), "!");
    
	ninja.expects(1).method('cmd_showMouseDown1');
	threeButtonSM.processInputSignal( "ev_buttonPressed" );
	equals( threeButtonSM.currentStateName(), "st_active_down1", "!" );
	ok(ninja.verify(), "!");
    
	ninja.expects(1).method('cmd_showMouseDownOut1');
	threeButtonSM.processInputSignal( "ev_mouseDraggedOutside" );
	equals( threeButtonSM.currentStateName(), "st_active_down_out1", "!" );
	ok(ninja.verify(), "!");
    
	var ninja = new Mock();
	ninja.expects(1).method('cmd_showMouseDown1');
	threeButtonSM._controller = ninja;
	threeButtonSM.processInputSignal( "ev_mouseDraggedInside" );
	equals( threeButtonSM.currentStateName(), "st_active_down1", "!" );
	ok(ninja.verify(), "!");
    
	ninja.expects(1).method('cmd_fireButtonAction1');
	threeButtonSM.processInputSignal( "ev_buttonReleased" );
	equals( threeButtonSM.currentStateName(), "st_clicked1", "!" );
	ok(ninja.verify(), "!");
    
	ninja.expects(1).method('cmd_disableButton');
	threeButtonSM.processInputSignal( "ev_disable" );
	equals( threeButtonSM.currentStateName(), "st_disabled", "!" );
	ok(ninja.verify(), "!");
    
	//threeButtonSM.processInputSignal( "ev_error" );
	//equals( threeButtonSM.currentStateName(), "st_off", "!" );
    
	//threeButtonSM.processInputSignal( "ev_clickAbortCompleted" );
	//equals( threeButtonSM.currentStateName(), "st_off", "!" );
});

test("FiveStateButtonStateMachine", function() {
    
	var ninja = new Mock();
    
	var fiveButtonSM = FiveStateButtonStateMachine alloc]({ _controller: ninja });
});

HooStateMachine_testCommandChannel = SC.Object.extend({
send: function( command ) {
    //alert( command.name );
}
});

// ok( true, "this test is fine" );
// var value = "hello";
// equals( "hello", value, "We expect value to be hello" );




@end
