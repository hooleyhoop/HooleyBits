//
//  BBQTStreamPlayer.m
//  BBExtras

#import "BBQTStreamPlayer.h"

static NSThread *_mainThread;

/*
 *
*/
@implementation BBQTStreamPlayer

static pascal void MoviePrePrerollCompleteProc (Movie theMovie, OSErr thePrerollErr, void *theRefcon) {
	id from = (id)theRefcon;
	// get error ?
	if( thePrerollErr != noErr ) {
		printf("Preroll error: %i", (int)thePrerollErr);
		return;
	}
    [from performSelectorOnMainThread:@selector(preprerollComplete:) withObject:nil waitUntilDone:YES];
}


#pragma mark -
#pragma mark class methods
+ (void)_setMainThread {
    _mainThread = [NSThread currentThread];
}

//=========================================================== 
// + initialize
//=========================================================== 
+ (void)initialize
{
	[super initialize];
    [self performSelectorOnMainThread:@selector(_setMainThread) withObject:nil waitUntilDone:YES];
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
		
		[inputVolume setMaxDoubleValue:10.0];
		[inputVolume setMinDoubleValue:0.0];
		[inputVolume setDoubleValue:1.0];
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
	/* being a bit paranoid */
	[_renderingDidEndTimer invalidate];
	[_renderingDidEndTimer release];
	_renderingDidEndTimer = nil;
	[_loadingTimer invalidate];
	[_loadingTimer release];
	_loadingTimer = nil;
	DisposeMovie(_loadedMovie);
	_loadedMovie = nil;
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
			[outputError setValue:[NSNumber numberWithInt:err]];
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


//=========================================================== 
// - execute: time: arguments:
//=========================================================== 
- (BOOL)execute:(QCOpenGLContext*)fp8 time:(double)fp12 arguments:(id)fp20 
{
	if([inputMOVPath wasUpdated]){
		[self destroyCurrentMovie];
		[self createNewMovie];
	} else if( _prerolling==NO && fp12>_lastTime ){

		OSStatus err = noErr;

//		CVTimeStamp cvTimestamp;
//		bzero(&cvTimestamp, sizeof(cvTimestamp));
//		cvTimestamp.videoTimeScale = GetMovieTimeScale(_loadedMovie);
//		cvTimestamp.videoTime = 0;
//		cvTimestamp.flags = kCVTimeStampVideoTimeValid;
//		cvTimestamp.hostTime = CVGetCurrentHostTime();
//		cvTimestamp.flags |= kCVTimeStampHostTimeValid;

		SInt32 rate = GetMovieRate(_loadedMovie);
		movieTime = GetMovieTime(_loadedMovie, nil);
		if( (int)movieTime < 1 || rate<1){
			StartMovie(_loadedMovie);
		}
		MoviesTask(_loadedMovie, 1);
		
		/*
		 * Potentially slower this way, movie should be playing asynchron**** for best performance 
		*/
//		double quartzTimeMilliseconds = (int)(fp12*1000);
//		[_mov setCurrentTime:QTMakeTime(quartzTimeMilliseconds, 1000)];
		
		// NSLog(@"Time is %i, %i",  timeStampTime, quartzTimeMilliseconds);

		// pass current time as nil to get current frame - hopefully we are getting some performance benefit from playing asynchronously
		if(QTVisualContextIsNewImageAvailable(_qtContext, NULL)) 
		{
			// double timeTaken = fp12-_lastTime;
			// NSLog(@"fps = %f", (float)(1.0/timeTaken));
			// CGLLockContext([fp8 CGLContextObj]);
			// create CVImageBuffers with QTVisualContextCopyImageForTime	
			err = QTVisualContextCopyImageForTime(_qtContext, NULL, NULL, &_cvTexture);
			if(err==kCVReturnSuccess){
				// set CVImageBuffers to the output
				[outputImage setValue:(id)_cvTexture];
				CVOpenGLTextureRelease(_cvTexture);
				// CGLUnlockContext([fp8 CGLContextObj]);
				
				[outputMovieTime setDoubleValue:(float)movieTime/(float)_movieTimeScale];
				_lastTime = fp12;
				
				if(!_renderingDidEndTimer)
					_renderingDidEndTimer = [[NSTimer scheduledTimerWithTimeInterval:1./2 target:self selector:@selector( renderingDidEnd ) userInfo:nil repeats:NO] retain];
				else
					[_renderingDidEndTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:1./2]];
			}

		} else if(fp12==0.0){
// err = AttachMovieToCurrentThread(_loadedMovie);
			GoToBeginningOfMovie(_loadedMovie);
			_lastTime = -1;
		}

		/* set volume */
		if( [inputVolume wasUpdated] ) 
			if(_loadedMovie)
				SetMovieAudioGain( _loadedMovie, (Float32)[inputVolume doubleValue], 0 );
	
	}

	return YES;
}

//=========================================================== 
// - renderingDidEnd
//=========================================================== 
- (void)renderingDidEnd
{
	/*	if the patch doesnt get executed for a while _renderingDidEndTimer will fire causing this method 
		to execute, stopping the movie from playing in the background */
	[_renderingDidEndTimer invalidate];
	[_renderingDidEndTimer release];
	_renderingDidEndTimer = nil;
	
	/* TODO - fade off the audio first so that you dont get a 'pop' */
	StopMovie(_loadedMovie);
	NSLog(@"HALT!");
}

//=========================================================== 
// - createNewMovie
//=========================================================== 
- (void)createNewMovie
{
	_executionThread = [NSThread currentThread];
	/* NB. Corresponding ExitMovies() is never called */
//	if(_executionThread==_mainThread)
		EnterMovies();
//	else
//		EnterMoviesOnThread(0);
		
	[outputIsRunning setBooleanValue:NO];
	[outputError setValue:[NSNumber numberWithInt:0]];
	[outputMovieTime setValue:[NSNumber numberWithInt:0]];

	OSStatus err = noErr;
	NSString* newPath = [inputMOVPath stringValue];
	if( newPath==nil || [newPath length]== 0 )
		return;
	CFURLRef urlRef = CFURLCreateWithString( kCFAllocatorDefault, (CFStringRef)newPath, NULL );
	if(urlRef)
	{
		Boolean active = TRUE; 
		Boolean dontAskUnresolved = TRUE; 
		Boolean dontInteract = TRUE; 
		QTNewMoviePropertyElement properties[] = {
			{kQTPropertyClass_DataLocation, kQTDataLocationPropertyID_CFURL, sizeof(urlRef), (void*)&urlRef, 0},
//			{kQTPropertyClass_Context, kQTContextPropertyID_VisualContext, sizeof(_qtContext), &_qtContext, 0}, 
			{kQTPropertyClass_NewMovieProperty, kQTNewMoviePropertyID_Active, sizeof(active), &active, 0},  
			{kQTPropertyClass_NewMovieProperty, kQTNewMoviePropertyID_DontInteractWithUser, sizeof(dontInteract), &dontInteract, 0},  
			{kQTPropertyClass_MovieInstantiation, kQTMovieInstantiationPropertyID_DontAskUnresolvedDataRefs, sizeof(dontAskUnresolved), &dontAskUnresolved, 0},  
		};
		
		/* Create the movie */
		err = NewMovieFromProperties( sizeof(properties) / sizeof(QTNewMoviePropertyElement), properties, 0, NULL, &_loadedMovie );

		CFRelease(urlRef);
		if(err) {
			if(err==componentNotThreadSafeErr)
				NSLog(@"NewMovieFromProperties returned ERROR %i", componentNotThreadSafeErr);
			else
				NSLog(@"NewMovieFromProperties returned ERROR %i", err);
			
			[outputError setValue:[NSNumber numberWithInt:err]];
			@throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		}
//		if(_executionThread!=_mainThread){
//			err = AttachMovieToCurrentThread(_loadedMovie);
//			if(err) {
//				[outputError setValue:[NSNumber numberWithInt:err]];
//				NSLog(@"AttachMovieToCurrentThread returned ERROR %i", err);
//			}
//		}
		err = SetMovieVisualContext(_loadedMovie, _qtContext);
		if(err) {
			[outputError setValue:[NSNumber numberWithInt:err]];
			NSLog(@"SetMovieVisualContext returned ERROR %i", err);
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
		MoviesTask(_loadedMovie, 0);

		PrePrerollMovie( _loadedMovie, 0, 0, NewMoviePrePrerollCompleteUPP(MoviePrePrerollCompleteProc), (void*)self);
		MoviesTask(_loadedMovie, 0);
	}
bail:
	return;
}

//=========================================================== 
// - destroyCurrentMovie
//=========================================================== 
- (void)destroyCurrentMovie
{
	[outputIsRunning setBooleanValue:NO];

	if(_loadedMovie)
	{
		OSStatus err = noErr;
		if( _prerolling ) 
			AbortPrePrerollMovie( _loadedMovie, 0 );
		err = SetMovieVisualContext(_loadedMovie, NULL);
		if(err)
			@throw [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
		StopMovie(_loadedMovie);
//thread		DetachMovieFromCurrentThread(_loadedMovie);

	//	[_mov release];
	//	_mov = nil;
		DisposeMovie(_loadedMovie);
		_loadedMovie = nil;
	}
}

//=========================================================== 
// - preprerollComplete:
//=========================================================== 
- (void)preprerollComplete:(OSErr)theError
{
	OSStatus err = noErr;

	// get error ?
	if( theError != noErr ) {
		NSLog(@"Preroll error: %i", theError);
		[outputError setValue:[NSNumber numberWithInt:theError]];
		return;
	}
	
	// prepre-roll complete - awesome have live video now
	[outputIsRunning setBooleanValue:YES];

	_movieTimeScale = GetMovieTimeScale(_loadedMovie);

	// reset the movie to its natural size
	Rect boundsRect;
	GetMovieNaturalBoundsRect(_loadedMovie, &boundsRect);
	SetMovieBox(_loadedMovie, &boundsRect );

	NSError *qtMovieError = nil;
	
	/* lets attach a movie controller - we aslo get effortless movietasking for free */
//	_mov = [[QTMovie movieWithQuickTimeMovie:_loadedMovie disposeWhenDone:NO error:&qtMovieError] retain];
//    if ([_mov respondsToSelector:@selector(setIdling:)])
//        [_mov setIdling:NO];
	
	_lastTime = -1;
	
	[self movieDidLoad];
}

- (void)movieDidLoad
{
	long loadState = GetMovieLoadState(_loadedMovie);
	// NSLog(@"loadState is %i", loadState);
	if( loadState <= kMovieLoadStatePlayable && _loadingTimer==nil) {
		_loadingTimer =  [[NSTimer scheduledTimerWithTimeInterval:1./20 target:self selector:@selector( movieDidLoad ) userInfo:nil repeats:YES] retain];
		
	/* TODO - add a bail if we have been trying for too long */
	
	} else {
		if(_loadingTimer){
			[_loadingTimer invalidate];
			[_loadingTimer release];
			_loadingTimer = nil;
		}
		// play asynchronously - we wont interfere with playback, just grab the current frame now and then */
		GoToBeginningOfMovie(_loadedMovie);
		NSLog(@"starting movie");
		_prerolling = NO;

	}	
}


- (Movie)loadedMovie {
	return _loadedMovie;
}

//- (QTMovie *)mov {
//	return _mov;
//}

- (QTVisualContextRef)qtContext {
	return _qtContext;
}



@end