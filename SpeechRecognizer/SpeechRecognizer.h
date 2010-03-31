//
//  SpeechRecognizer.h
//  SpeechRecognizer
//
//  Created by Steven Hooley on 10/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SpeechRecognizer : NSObject {

}


NSSpeechRecognizer *listen;
NSArray *cmds = [NSArray arrayWithObjects:@"next song",@"last song",nil];
listen = [[NSSpeechRecognizer alloc] init];
[listen setCommands:cmds];
[listen setDelegate:self];
[listen setListensInForegroundOnly:NO];
[listen startListening];
[listen setBlocksOtherRecognizers:YES];
This is the method that runs when a command is recognized. Does anyone know a method that will run if the command is not recognized or the speech recognizer cannot understand what is being said.


- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
    if ([(NSString *)aCmd isEqualToString:@"next song"]) {
		NSLog(@"next song");
		[self performSelector:@selector(NextSong:)];
    }
	
    if ([(NSString *)aCmd isEqualToString:@"last song"]) {
		NSLog(@"last song");
		[self performSelector:@selector(LastSong:)];
    }
}


@end
