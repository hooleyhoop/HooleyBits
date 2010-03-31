//
//  BBQTSSPlayer.h
//  BBExtras

#import <Cocoa/Cocoa.h>
#import <Quicktime/Quicktime.h>
#import <QTKit/QTKit.h>
#import "QCClasses.h"


@class QTMovie, ImageCache;

@class QCIndexPort, QCNumberPort, QCStringPort,
        QCBooleanPort, QCVirtualPort, QCColorPort,
        QCGLImagePort, QCStructurePort, QCPatch, FSInterpreter;


/*
 *
*/
@interface BBQTSSPlayer : QCPatch {

	QCStringPort*		inputMOVPath;
	QCGLImagePort*		outputImage; // QCGLCVImage, CVImageBuffer
	
	QTVisualContextRef	_qtContext;
	Movie				_loadedMovie;
	BOOL				_prerolling;
	double				_lastTime;

	QTMovie* mov;
	NSThread*	_executionThread;
}


@end
