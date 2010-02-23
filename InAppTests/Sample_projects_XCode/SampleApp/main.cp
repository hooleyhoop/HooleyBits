/*
 *  HeatEquation
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */
#include <Carbon/Carbon.h>
#include "Heat.h"
#include "AEDescUtils.h"
#include "SimpleOSL.h"

DescType gPropertyList[]={'ncol','nrow','sigm','dt  '};
int gPropertyListCount=sizeof(gPropertyList)/sizeof(DescType);

OSErr gAEGetProc(DescType selectedProperty,AEDesc & data){
/*
 * For an example of how to declare the properties below in the terminology resource,
 * see HeatDict.r.
 */ 
    OSErr err=errAENoSuchObject;
    switch(selectedProperty){
    case 'ncol':
	err=data<<gHeatEqn.ncols;
	break;
    case 'nrow':
	err=data<<gHeatEqn.nrows;
	break;
    case 'sigm':
	err=data<<gHeatEqn.sigma;
	break;
    case 'dt  ':
	err=data<<gHeatEqn.dt;
	break;
    case 'Temp':
	err=FloatMatrixToDesc(&data, gHeatEqn.ncols,gHeatEqn.nrows,gHeatEqn.p);
	break;
    }
    return err;
}


OSErr gAESetProc(DescType selectedProperty,AEDesc & data){
    OSErr err=errAENoSuchObject;
    switch(selectedProperty){
    case 'sigm':
	err=data>>gHeatEqn.sigma;
	break;
    case 'dt  ':
	err=data>>gHeatEqn.dt;
	break;
    case 'Temp':
	gHeatEqn.free();
	err=FloatMatrixFromDesc(&data,&gHeatEqn.ncols,&gHeatEqn.nrows,&gHeatEqn.p);
	break;
    case 'ncol':
    case 'nrow':
	return errAEWriteDenied;
    }
    return err;
}

pascal OSErr AECompute(const AppleEvent* message,AppleEvent* reply, long ){
    char* s="No intial conditions";
    OSErr err=0;
    if(!gHeatEqn.p){
	AEPutParamPtr(reply,keyErrorString,typeChar,s,strlen(s));
	return -1;
    }
    int steps=1;
/*
 * Retrieve the direct parameter of the command: here, an integer that specifies the
 * number of iterations to perform.
 */
    AEDesc d;
    err=AEGetParamDesc(message, keyDirectObject,typeLongInteger, &d);
    if(err)
	return err;
    d>>steps;
    AEDisposeDesc(&d);
/*
 * Finally, run your computational code.
 */
    return gHeatEqn.Run( steps);
}

int main(int argc, char* argv[]){
    IBNibRef 		nibRef;
    OSStatus		err;
    err = CreateNibReference(CFSTR("main"), &nibRef);
    err = SetMenuBarFromNib(nibRef, CFSTR("MenuBar"));
    DisposeNibReference(nibRef);
/* 
 * Install here as many event handlers as required
 * Don't forget to define them in the terminology resource so that they appear in the dictionary.
 * For an example see HeatDict.r.
 * All your handlers should have the same interface as the "AECompute" example.
 */
    AEInstallEventHandler('CPHO', 'COMP',NewAEEventHandlerUPP(AECompute), 0, false);
    InstallOSL(); /* This installs your gAEGetProc and gAESetProc routines */
    RunApplicationEventLoop();
    return 0;
}

