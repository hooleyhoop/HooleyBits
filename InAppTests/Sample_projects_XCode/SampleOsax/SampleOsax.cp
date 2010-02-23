/*
 *  SampleOsax.cp
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>
#include "Osax.h"
#include "AEDescUtils.h"

/* Here you may want to include your own C files */
#include "mandelbrot.h"

/* See Osax.h for instructions  */
EventDescription gEventDescriptionList[]={{'SAMP','MAND',0}};
int gEventDescriptionCount=sizeof(gEventDescriptionList)/sizeof(EventDescription);

OSErr FractalHandler(const AppleEvent* message, AppleEvent* reply){
    OSErr err=0;
    float*x=0;
    float*y=0;
    float*result=0;

    long depth=255;
    // Get the direct parameter
    AEDesc depthDesc;
    err=AEGetParamDesc(message, keyDirectObject, typeLongInteger, &depthDesc);
    if(!err){
        AEDescToLong(depthDesc, &depth);
        AEDisposeDesc(&depthDesc);
    }
	if(err && err!=errAEDescNotFound)
		return err;
	
    // Get the 'xdata' parameter (cf the resource file SampleOsax.r)
    AEDesc xDesc;
    err = AEGetParamDesc(message, 'x$$$', typeListOfLongFloat, &xDesc);
    if(err) goto cleanup;
    long width;
    err=FloatArrayFromDesc(&xDesc, &width,&x);
    AEDisposeDesc(&xDesc);
    if(err) goto cleanup;

    // Get the 'ydata' parameter 
    AEDesc yDesc;
    err = AEGetParamDesc(message, 'y$$$', typeListOfLongFloat, &yDesc);
    if(err) goto cleanup;
    long height;
    err=FloatArrayFromDesc(&yDesc, &height,&y);
    AEDisposeDesc(&yDesc);
    if(err) goto cleanup;
    
    result=(float*)malloc(width*height*sizeof(float));
    DoFractal(x, y, width, height, depth, result);

    // Set the appleEvent result
    AEDesc resultDesc;
    err=FloatMatrixToDesc(&resultDesc, width, height, result);
    if(result) free(result);
    if(!err){
        err=AEPutParamDesc(reply, keyAEResult, &resultDesc);
        AEDisposeDesc(&resultDesc);
    }

cleanup:
    if(x) free(x);
    if(y) free(y);
    return err;
}

pascal OSErr OsaxEventHandler(const AppleEvent* message, AppleEvent* reply, long refCon){
    switch(refCon){
    case 0: return FractalHandler( message, reply);
    //insert here other cases as needed.
    default:return errAEEventNotHandled;
    }
}
