// (C) best before/Anatol Ulrich

#import "QCClasses.h"

@interface BBExperimental : QCPatch
{
	QCGLImagePort *inputImage;
	QCStructurePort *outputPoints;
	@private
		NSMutableArray* points;
}

// misc public methods

// private

@end