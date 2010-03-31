// (C) best before/Anatol Ulrich

#import "QCClasses.h"

@interface BBInverseMultiplexer : QCPatch
{
	QCIndexPort *inputIndex;
	QCVirtualPort *inputData;
	@private
		int numPorts;
		NSMutableArray* ports;
}

// misc public methods

- (void) addOutputPort;
- (void) removeOutputPort;

// private

@end