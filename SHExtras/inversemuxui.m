
#import "inversemuxui.h"
#import "inversemux.h"

@implementation BBInverseMultiplexerUI : QCInspector

+ (id) viewNibName {
	return @"BBInverseMultiplexerUI";
}

- (void) addOutputPort:(id)fp8 {
	[[self patch] addOutputPort];
}
- (void) removeOutputPort:(id)fp8 {
	[[self patch] removeOutputPort];
}

-(BOOL)respondsToSelector:(SEL)selector
{
	NSLog(@"Responds to %@?", NSStringFromSelector(selector));
	return [super respondsToSelector:selector];
}
@end