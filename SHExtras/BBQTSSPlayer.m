//
//  BBQTSSPlayer.m
//  BBExtras

#import "BBQTSSPlayer.h"
#include  <CoreAudio/CoreAudio.h>

static NSThread *_mainThread;

/*
 *
*/
@implementation BBQTSSPlayer

#pragma mark -
#pragma mark class methods
+ (void)_setMainThread {
    _mainThread = [NSThread currentThread];
}

static pascal void prePrerollCompleteProc (Movie theMovie, OSErr thePrerollErr, void *theRefcon) {
	id from = (id)theRefcon;
	// [from mainThread_preprerollComplete:thePrerollErr];
    [from performSelectorOnMainThread:@selector(mainThread_preprerollComplete:) withObject:nil waitUntilDone:YES];
}

//=========================================================== 
// + initialize
//=========================================================== 
+ (void)initialize
{
	[super initialize];
    [self performSelectorOnMainThread:@selector(_setMainThread) withObject:nil waitUntilDone:YES];
	/* NB. Corresponding ExitMovies() is never called */
//	if([NSThread currentThread]==_mainThread)
		EnterMovies();
//	else
//		EnterMoviesOnThread(0);
}

+ (int)executionMode {return 3;}
+ (int)timeMode {return 1;}

//=========================================================== 
// + allowsSubpatches:
//=========================================================== 
+ (BOOL)allowsSubpatches {
	return NO;
}

#pragma mark init methods
//=========================================================== 
// - initWithIdentifier:
//=========================================================== 
- (id)initWithIdentifier:(id)fp8
{
	if ((self = [super initWithIdentifier:fp8]) != nil)
	{	
		// set input defaults
		[inputMOVPath setStringValue:@"http://movies.apple.com/movies/us/apple/iphone/2007/tips/iphone-tip-compilation_560x316.mov"];
		_qtContext = NULL;
		_loadedMovie = NULL;
		_prerolling = NO;
	}
	return self;
}

//=========================================================== 
// - dealloc:
//=========================================================== 
- (void)dealloc
{
	[self destroyCurrentMovie];
	if(_qtContext)
		QTVisualContextRelease(_qtContext);	
	_qtContext = NULL;
	[super dealloc];
}

//=========================================================== 
// - setup:
//=========================================================== 
- (id)setup:(id)p
{
	if(!_qtContext){
		OSStatus err = noErr;
		// use a QuickTime OpenGL texture context that uses the same OpenGL context and pixel format as a the ones used to render the composition		
		QCPatchRuntime* runtime = [self _executionRuntime];
		CGLContextObj cgl_ctx = [[runtime context] CGLContextObj];
		CGLPixelFormatObj cglPixelFormat = [[runtime context] CGLPixelFormatObj];
		err = QTOpenGLTextureContextCreate( NULL, cgl_ctx, cglPixelFormat, NULL, &_qtContext );		
		if(err) {
			@throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		}
	}
	return p;
}

//=========================================================== 
// - cleanup:
//=========================================================== 
- (id)cleanup:(id)p
{
	[self destroyCurrentMovie];
 	return p;
}

//=========================================================== 
// - nodeDidAddToGraph:
//=========================================================== 
- (void)nodeDidAddToGraph:(id)fp8
{
	NSLog(@"BBVideoStreaming.m: nodeDidAddToGraph **");
	[super nodeDidAddToGraph:fp8];
}

//=========================================================== 
// - nodeWillRemoveFromGraph
//=========================================================== 
- (void)nodeWillRemoveFromGraph
{
	NSLog(@"BBVideoStreaming.m: nodeWillRemoveFromGraph Notification **");
	[super nodeWillRemoveFromGraph];
}
int tt = 0;
//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(QCOpenGLContext*)fp8 time:(double)fp12 arguments:(id)fp20 
{
	if([inputMOVPath wasUpdated]){
		[self destroyCurrentMovie];
		[self createNewMovie];
	} else if( _prerolling==NO && fp12>_lastTime ){


//		TimeValue movieTime = GetMovieTime(_loadedMovie, nil);
//		NSLog(@"timevalue is %i", (int)movieTime);
//		if( (int)movieTime<0.01){
//			[mov play];
//			NSLog(@"playing movie");
//		}
//		[mov play];

		double rate = [mov rate];

		TimeValue movieTime = GetMovieTime(_loadedMovie, nil);
//		QTTime t = [_mov currentTime];
		NSLog(@"timevalue is %f", (float)movieTime);
		if( rate < 1.0 ){
			StartMovie(_loadedMovie);
			NSLog(@"playing movie");
		}
		MoviesTask(_loadedMovie, 10);
		
		OSStatus err = noErr;

		CVTimeStamp cvTimestamp;
		bzero(&cvTimestamp, sizeof(cvTimestamp));
		cvTimestamp.videoTimeScale = GetMovieTimeScale(_loadedMovie);
		cvTimestamp.videoTime = 0;
		cvTimestamp.flags = kCVTimeStampVideoTimeValid;
		cvTimestamp.hostTime = CVGetCurrentHostTime();
		cvTimestamp.flags |= kCVTimeStampHostTimeValid;
		// cvTimestamp.hostTime = (int)tt++;
//		int timeStampTime = CVGetCurrentHostTime()-tt;


		/*
		 * Potentially slower this way, movie should be playing asynchron**** for best performance 
		*/
//		double quartzTimeMilliseconds = (int)(fp12*1000);
//		[mov setCurrentTime:QTMakeTime(quartzTimeMilliseconds, 1000)];
//		
//		NSLog(@"Time is %i, %i",  timeStampTime, quartzTimeMilliseconds);

		if(QTVisualContextIsNewImageAvailable(_qtContext, &cvTimestamp)) {
			CGLLockContext([fp8 CGLContextObj]);
			// create CVImageBuffers with QTVisualContextCopyImageForTime
			CVOpenGLTextureRef _cvTexture;
			err = QTVisualContextCopyImageForTime(_qtContext, NULL, &cvTimestamp, &_cvTexture);
			if(err==kCVReturnSuccess){
				// set CVImageBuffers to the output
				[outputImage setValue:_cvTexture];
				CVOpenGLTextureRelease(_cvTexture);
				CGLUnlockContext([fp8 CGLContextObj]);
			}

		} else if(fp12==0.0){
		//	AttachMovieToCurrentThread(_loadedMovie);
			GoToBeginningOfMovie(_loadedMovie);
			_lastTime = -1;
		}

		_lastTime = fp12;
	}
	return YES;
}

//=========================================================== 
// - createNewMovie
//=========================================================== 
- (void)createNewMovie
{
	OSStatus err = noErr;
	CFURLRef urlRef = CFURLCreateWithString( kCFAllocatorDefault, (CFStringRef)[inputMOVPath stringValue], NULL );
    Boolean active = TRUE; 
	Boolean dontAskUnresolved = TRUE; 
	Boolean dontInteract = TRUE; 
	QTNewMoviePropertyElement properties[] = {
		{kQTPropertyClass_DataLocation, kQTDataLocationPropertyID_CFURL, sizeof(urlRef), (void*)&urlRef, 0},
//		{kQTPropertyClass_Context, kQTContextPropertyID_VisualContext, sizeof(_qtContext), &_qtContext, 0}, 
		{kQTPropertyClass_NewMovieProperty, kQTNewMoviePropertyID_Active, sizeof(active), &active, 0},  
		{kQTPropertyClass_NewMovieProperty, kQTNewMoviePropertyID_DontInteractWithUser, sizeof(dontInteract), &dontInteract, 0},  
		{kQTPropertyClass_MovieInstantiation, kQTMovieInstantiationPropertyID_DontAskUnresolvedDataRefs, sizeof(dontAskUnresolved), &dontAskUnresolved, 0},  
	};
	
	/* Create the movie */
	err = NewMovieFromProperties( sizeof(properties) / sizeof(QTNewMoviePropertyElement), properties, 0, NULL, &_loadedMovie );

	CFRelease(urlRef);
	if(err) {
		if(err==componentNotThreadSafeErr)
			NSLog(@"NewMovieFromProperties ERROR %i", componentNotThreadSafeErr);
		else
			NSLog(@"NewMovieFromProperties ERROR %i", err);
		// @throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
	}
	err = SetMovieVisualContext(_loadedMovie, _qtContext);
	if(err) {
		@throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
	}
	long loadState = GetMovieLoadState(_loadedMovie);
	if( loadState == kMovieLoadStateError || loadState == kMovieLoadStateLoading) {
		NSLog(@"bugger");
	}
	_prerolling = YES;
	int readAheadValue = 5;
	CFNumberRef ovlNumber = CFNumberCreate(NULL, kCFNumberSInt64Type, &readAheadValue);
	QTVisualContextSetAttribute(_qtContext, kQTVisualContextExpectedReadAheadKey, ovlNumber);
	CFRelease(ovlNumber);
	// GetMoviePreferredRate(_loadedMovie)
	_executionThread = [NSThread currentThread];
	PrePrerollMovie( _loadedMovie, 0, 0, NewMoviePrePrerollCompleteUPP(prePrerollCompleteProc), (void*)self);
	MoviesTask(_loadedMovie, 0);

bail:
	return;
}

//=========================================================== 
// - destroyCurrentMovie
//=========================================================== 
- (void)destroyCurrentMovie
{
	if(_loadedMovie)
	{
		OSStatus err = noErr;
		if( _prerolling ) 
			AbortPrePrerollMovie( _loadedMovie, 0 );
		err = SetMovieVisualContext(_loadedMovie, NULL);
		if(err)
			@throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		StopMovie(_loadedMovie);
		DetachMovieFromCurrentThread(_loadedMovie);

		[mov release];
		mov = nil;
		DisposeMovie(_loadedMovie);
		_loadedMovie = nil;
	}
}

//=========================================================== 
// - mainThread_preprerollComplete:
//=========================================================== 
- (void)mainThread_preprerollComplete:(OSErr)theError
{
	OSStatus err = noErr;

	NSLog(@"mainThread_preprerollComplete");
	_prerolling = NO;

	// get error ?
	if( theError != noErr ) {
		NSLog(@"Preroll error: %i", theError);
//		[outputError setValue:[NSNumber numberWithInt:theError]];
		return;
	}
	
	// prepre-roll complete - awesome have live video now
	// [outputIsRunning setValue:[NSNumber numberWithBool:YES]];

//	_movieTimeScale = GetMovieTimeScale(_loadedMovie);
//	_fpsCounter = 0;
//	_tmpFpsCounter = 1;
//	_lastFpsSecond = 0;

	// reset the movie to its natural size
	Rect boundsRect;
	GetMovieNaturalBoundsRect(_loadedMovie, &boundsRect);
	SetMovieBox(_loadedMovie, &boundsRect );

	NSError *qtMovieError = nil;
	
	/* lets attach a movie controller */
	mov = [[QTMovie movieWithQuickTimeMovie:_loadedMovie disposeWhenDone:NO error:&qtMovieError] retain];
    if ([mov respondsToSelector:@selector(setIdling:)])
        [mov setIdling:NO];
		
	// play!
	GoToBeginningOfMovie(_loadedMovie);
	_lastTime = -1;
	
//	[self beginAudioExtraction];

}


- (void)beginAudioExtraction
{
	OSStatus err = noErr;

	MovieAudioExtractionRef extractionSessionRef = nil;
	err = MovieAudioExtractionBegin(_loadedMovie, 0, &extractionSessionRef); 

	AudioChannelLayout *layout  = NULL;
	UInt32 size = 0;

	// First get the size of the extraction output layout
	err = MovieAudioExtractionGetPropertyInfo(extractionSessionRef, kQTPropertyClass_MovieAudioExtraction_Audio, kQTMovieAudioExtractionAudioPropertyID_AudioChannelLayout, NULL, &size, NULL);
	if (err == noErr)
	{
		// Allocate memory for the channel layout
		layout = (AudioChannelLayout *) calloc(1, size);
		if (layout == nil) 
		{
			err = memFullErr;
			goto bail;
		}

		// Get the layout for the current extraction configuration.
		// This will have already been expanded into channel descriptions.
		err = MovieAudioExtractionGetProperty(extractionSessionRef, kQTPropertyClass_MovieAudioExtraction_Audio, kQTMovieAudioExtractionAudioPropertyID_AudioChannelLayout, size, layout, nil);
	}

	AudioStreamBasicDescription asbd;
	// Get the default audio extraction ASBD
	err = MovieAudioExtractionGetProperty(extractionSessionRef, kQTPropertyClass_MovieAudioExtraction_Audio, kQTMovieAudioExtractionAudioPropertyID_AudioStreamBasicDescription, sizeof (asbd), &asbd, nil);	
bail:
	return;
}

- (void)endAudioExtraction
{
//	OSStatus err;
//	err = MovieAudioExtractionEnd(extractionSessionRef);
}

@end