//
//  SHPammer.h
//  SHPammer
//
//  Created by Steve Hooley on 26/06/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SHPammer : NSObject {

	NSString*	_subject;
	NSAttributedString*	_message;
	NSString*	_senderAddress;
	NSString*	_recipientAddress;

	int			_sentCount;
	int			_rate_secs;
	BOOL		_isPlaying;
	
	NSTimer*	_timer;
}

- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;

- (NSString *)subject;
- (void)setSubject:(NSString *)value;

- (NSAttributedString *)message;
- (void)setMessage:(NSAttributedString *)value;

- (NSString *)senderAddress;
- (void)setSenderAddress:(NSString *)value;

- (NSString *)recipientAddress;
- (void)setRecipientAddress:(NSString *)value;

- (int)sentCount;
- (void)setSentCount:(int)value;

- (BOOL)isPlaying;
- (void)setIsPlaying:(BOOL)value;

- (int)rate_secs;
- (void)setRate_secs:(int)newRate_secs;

- (NSTimer *)timer;
- (void)setTimer:(NSTimer *)newTimer;



@end
