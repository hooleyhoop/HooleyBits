/*
 *  ThreadedApp
 *
 *  Copyright (c) 2004 Satimage. All rights reserved.
 *
 */
#include <Carbon/Carbon.h>
#include "AEDescUtils.h"
#include "SimpleOSL.h"

#include "compute.h"

DescType gPropertyList[]={'a   '};
int gPropertyListCount=sizeof(gPropertyList)/sizeof(DescType);

//the debuging variables
float *pdebugfloat=0;
char *pdebugstring=0;
long debugsize1=0;// ncols of pdebugmatrix or size of pdebugarray
long debugsize2=0;//not used in this sample, nrows of pdebugmatrixg
float *pdebugarray=0;
float *pdebugmatrix=0;//not used in this sample

OSErr gAEGetProc(DescType selectedProperty,AEDesc & data){
/*
 * For an example of how to declare the properties below in the dictionary,
 * see Threaded.sdef.
 */ 
    OSErr err=errAENoSuchObject;
    switch(selectedProperty){
    case 'a   ':
		err=data<<theInt;
	break;
    case 'dbg1':
		if(!pdebugfloat)
			return errAENoSuchObject;
		err=data<<*pdebugfloat;
	break;
    case 'dbg2':
		if(!pdebugstring)
			return errAENoSuchObject;
		err=AECreateDesc(typeChar,pdebugstring,strlen(pdebugstring),& data);
	break;
    case 'dbg3':
		if(!pdebugarray)
			return errAENoSuchObject;
		err=FloatArrayToDesc(&data, debugsize1,pdebugarray);
	break;
    case 'dbg4':
		if(!pdebugmatrix)
			return errAENoSuchObject;
		err=FloatMatrixToDesc(&data, debugsize1,debugsize2,pdebugmatrix);
	break;
	}
    return err;
}


OSErr gAESetProc(DescType selectedProperty,AEDesc & data){
    OSErr err=errAENoSuchObject;
    switch(selectedProperty){
    case 'a   ':
	err=data>>theInt;
	break;
    }
    return err;
}

pascal OSErr AECompute(const AppleEvent* message,AppleEvent* reply, long threaded){
	OSErr err=0;
	AEDesc d;
	err=AEGetParamDesc(message, keyDirectObject,typeLongFloat, &d);
	if(err)
		return err;
	long n;
	d>>n;
	AEDisposeDesc(&d);
	if(n>20){
		char* s="direct parameter out of range";
		AEPutParamPtr(reply,keyErrorString,typeChar,s,strlen(s));
		return 3;
	}
	n=Run(n);
	AEPutParamPtr(reply,keyAEResult,typeLongInteger,&n,sizeof(n));
	return 0;
}

int main(int argc, char* argv[]){
    IBNibRef 		nibRef;
    OSStatus		err;
    err = CreateNibReference(CFSTR("main"), &nibRef);
    err = SetMenuBarFromNib(nibRef, CFSTR("MenuBar"));
    DisposeNibReference(nibRef);
/* 
 * Install here as many event handlers as required
 * Don't forget to define them in the scripting definitions file (.sdef) so that they appear in the application dictionary.
 * For an example see SampleApp.sdef.
 * All your handlers should have the same interface as the "AECompute" example.
 */
    //AEInstallEventHandler('SAMP', 'COMP',NewAEEventHandlerUPP(AECompute), 0, false);
	//here we use AEInstallThreadedEventHandler defined in SimpleOSL.h
    AEInstallThreadedEventHandler('SAMP', 'COMP',NewAEEventHandlerUPP(AECompute), 0, false);
    InstallOSL(); /* This installs your gAEGetProc and gAESetProc routines */
    RunApplicationEventLoop();
    return 0;
}

