//
//  TestConfig.m
//  HooStateMachine
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 AudioBoo. All rights reserved.
//

#import "TestConfig.h"


@implementation TestConfig

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}


    
 
sm_config: function() {
    
	var threeStateButtonStateMachine_config = {
		"states": [
                   "st_disabled",
                   "st_enabled",
                   
                   // ["st_error", 	"st_disabled"],
                   
                   /* The high-level states you use */
                   ["st_active1", 			"st_enabled"],
                   ["st_active_down1", 	"st_enabled"],
                   ["st_active_down_out1", "st_enabled"],
                   ["st_clicked1", 		"st_enabled"],
                   ["st_abort-click1", 	"st_enabled"]
                   ],
		"events": [
                   "ev_disable",
                   "ev_error",
                   
                   "ev_showState1",
                   "ev_buttonPressed",
                   "ev_buttonReleased",
                   "ev_mouseDraggedOutside",
                   "ev_mouseDraggedInside",
                   
                   "ev_clickAbortCompleted"
                   ],
		// Doh! you can add many commands to 1 state
		"commands": [
                     "cmd_disableButton",
                     "cmd_enableButton",
                     "cmd_showMouseUp1",
                     "cmd_showMouseDown1",
                     "cmd_showMouseDownOut1",
                     "cmd_fireButtonAction1",
                     "cmd_abortClickAction",
                     //"cmd_showError"
                     ],
        
		"transitions": [
                        
                        { "state": "st_disabled", 		"event": "ev_showState1",			"nextState": "st_active1" },
                        { "state": "st_enabled", 		"event": "ev_showState1",			"nextState": "st_active1" },
                        
                        { "state": "st_active1", 		"event": "ev_buttonPressed",		"nextState": "st_active_down1" },
                        { "state": "st_active_down1", 	"event": "ev_buttonReleased",		"nextState": "st_clicked1" },
                        { "state": "st_active_down1", 	"event": "ev_mouseDraggedOutside",	"nextState": "st_active_down_out1" },
                        { "state": "st_active_down_out1","event": "ev_mouseDraggedInside",	"nextState": "st_active_down1" },
                        { "state": "st_active_down_out1","event": "ev_buttonReleased",		"nextState": "st_abort-click1" },
                        
                        { "state": "st_abort-click1", 	"event": "ev_clickAbortCompleted",	"nextState": "st_active1"}
                        ],
        
		"actions": [
                    {"state": "st_enabled", 		"entryAction": "cmd_enableButton", 		"exitAction": null },
                    {"state": "st_active1", 		"entryAction": "cmd_showMouseUp1", 		"exitAction": null },
                    {"state": "st_active_down1", 	"entryAction": "cmd_showMouseDown1", 	"exitAction": null },
                    {"state": "st_active_down_out1","entryAction": "cmd_showMouseDownOut1",	"exitAction": null },
                    
                    {"state": "st_clicked1", 		"entryAction": "cmd_fireButtonAction1",	"exitAction": null },
                    {"state": "st_abort-click1",	"entryAction": "cmd_abortClickAction",	"exitAction": null },
                    
                    {"state": "st_disabled",		"entryAction": "cmd_disableButton",		"exitAction": null }
                    ],
		"resetEvents":[
                       "ev_disable", "ev_error"
                       ]
	};
	return threeStateButtonStateMachine_config;
}
    




@end
