//
//  SHPammer.m
//  SHPammer
//
//  Created by Steve Hooley on 26/06/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SHPammer.h"
#import <Message/NSMailDelivery.h>

@implementation SHPammer

//=========================================================== 
// - init:
//=========================================================== 
- (id)init 
{
    if ((self = [super init]) != nil) 
	{
		[self setSubject:@"Refund"];
		[self setMessage:[[[NSAttributedString alloc] initWithString:@"Could i please have a refund for the £60 cheque from me that you cashed on the 12th April in paymnet for an oscilloscope which has never been delivered.\n\nthankyou, \n \nSteven Hooley"] autorelease]];
		[self setSenderAddress:@"stevehooley@hotmail.com"];
		[self setRecipientAddress:@"compulectest@hotmail.co.uk"]; // compulectest@hotmail.co.uk
		[self setSentCount:0];
		[self setIsPlaying:NO];
		[self setRate_secs:1*60]; //1200
	}
	return self;
}

- (IBAction)start:(id)sender
{
	if(![self isPlaying]){
		[self setIsPlaying:YES];
		[self setSentCount:0];
		NSLog(@"playing");
		
		if([self timer]==nil){
			[self setTimer:[NSTimer scheduledTimerWithTimeInterval:_rate_secs target:self selector:@selector(sendEmail) userInfo:nil repeats:YES]];
			[[NSRunLoop currentRunLoop] addTimer:[self timer] forMode:NSEventTrackingRunLoopMode];
		}
	}
}

- (IBAction)stop:(id)sender
{
	if([self isPlaying]){
		[self setIsPlaying:NO];
		NSLog(@"stopppjn g");
		[_timer invalidate];
		[self setTimer:nil];
	}
}

- (void)sendEmail
{
	NSLog(@"sending email");
	[self setSentCount:_sentCount+1];
	
	BOOL mailSent=NO;
    mailSent = [NSMailDelivery deliverMessage:[[self message] string] subject:[self subject] to:[self recipientAddress]];
    if (!mailSent)
		 NSBeep();
}

- (NSString *)subject {
    return [[_subject retain] autorelease];
}

- (void)setSubject:(NSString *)newSubject {
    if (_subject != newSubject) {
        [_subject release];
        _subject = [newSubject copy];
    }
}

- (NSAttributedString *)message {
    return [[_message retain] autorelease];
}

- (void)setMessage:(NSAttributedString *)newMessage {
    if (_message != newMessage) {
        [_message release];
        _message = [newMessage copy];
    }
}

- (NSString *)senderAddress {
    return [[_senderAddress retain] autorelease];
}

- (void)setSenderAddress:(NSString *)newSenderAddress {
    if (_senderAddress != newSenderAddress) {
        [_senderAddress release];
        _senderAddress = [newSenderAddress copy];
    }
}

- (NSString *)recipientAddress {
    return [[_recipientAddress retain] autorelease];
}

- (void)setRecipientAddress:(NSString *)newRecipientAddress {
    if (_recipientAddress != newRecipientAddress) {
        [_recipientAddress release];
        _recipientAddress = [newRecipientAddress copy];
    }
}

- (int)sentCount {
    return _sentCount;
}

- (void)setSentCount:(int)newSentCount {
    if (_sentCount != newSentCount) {
        _sentCount = newSentCount;
    }
}

- (BOOL)isPlaying {
    return _isPlaying;
}

- (void)setIsPlaying:(BOOL)newIsPlaying {
    if (_isPlaying != newIsPlaying) {
        _isPlaying = newIsPlaying;
    }
}

- (int)rate_secs {
    return _rate_secs;
}

- (void)setRate_secs:(int)value {
    if (_rate_secs != value) {
        _rate_secs = value;
    }
}

- (NSTimer *)timer {
    return _timer;
}

- (void)setTimer:(NSTimer *)newTimer {
    if (_timer != newTimer) {
        [_timer release];
        _timer = [newTimer retain];
    }
}




@end
