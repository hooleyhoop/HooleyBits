//
//  BBQTStreamPlayer.h
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
@interface BBQTStreamPlayer : QCPatch {

	QCStringPort*		inputMOVPath;
	QCNumberPort*		inputVolume;
	
	
	QCGLImagePort*		outputImage; // QCGLCVImage, CVImageBuffer
	QCNumberPort*		outputError;
	QCBooleanPort*		outputIsRunning;
	QCNumberPort*		outputMovieTime;

	
	QTVisualContextRef	_qtContext;
	Movie				_loadedMovie;
	BOOL				_prerolling;
	double				_lastTime;
	TimeScale			_movieTimeScale;

//	QTMovie*			_mov;
	NSThread*			_executionThread;

	NSTimer				*_loadingTimer, *_renderingDidEndTimer;
	CVOpenGLTextureRef _cvTexture;
	TimeValue			movieTime;
}


- (void)createNewMovie;
- (void)destroyCurrentMovie;

- (Movie)loadedMovie;
- (QTMovie *)mov;
- (QTVisualContextRef)qtContext;

@end
