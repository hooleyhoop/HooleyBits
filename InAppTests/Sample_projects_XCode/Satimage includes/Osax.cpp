/*
 *  Osax.cpp
 *  SampleOSAX
 *
 *  Created by François Delyon on Wed Sep 24 2003.
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */

#include "Osax.h"

AEEventHandlerUPP SampleHandlerUPP=0;
UInt32 gAdditionReferenceCount=0;
CFBundleRef additionBundle=0;

extern "C" Boolean SAIsBusy(void) {
    return (gAdditionReferenceCount != 0);
}


pascal OSErr MyLocalSampleHandler(const AppleEvent* message, AppleEvent* reply, long refCon){
	gAdditionReferenceCount++;
	OSErr err=OsaxEventHandler(message, reply, refCon);
	gAdditionReferenceCount--;
	return err;
}

/* The 10.4 Entry point */
extern "C" OSErr SAInitialize(CFBundleRef b) {

	OSErr err=0;
	additionBundle=b;
	SampleHandlerUPP = NewAEEventHandlerUPP(MyLocalSampleHandler);
	for(int i=0;i<gEventDescriptionCount;i++){
	    err=AEInstallEventHandler( gEventDescriptionList[i].theAEEventClass, gEventDescriptionList[i].theAEEventID, SampleHandlerUPP, gEventDescriptionList[i].refCon, true);
	    if(err)
			return err;
	}
	return err;
}

extern "C" void SATerminate(void){
	if(SampleHandlerUPP){
		for(int i=0;i<gEventDescriptionCount;i++){
		    AERemoveEventHandler(gEventDescriptionList[i].theAEEventClass,gEventDescriptionList[i].theAEEventID,SampleHandlerUPP, true);
		}
		DisposeAEEventHandlerUPP(SampleHandlerUPP);
		SampleHandlerUPP=0;
	}
}

extern "C" void InstallEventDebug(){
	SampleHandlerUPP = NewAEEventHandlerUPP(MyLocalSampleHandler);
	for(int i=0;i<gEventDescriptionCount;i++)
	    AEInstallEventHandler(gEventDescriptionList[i].theAEEventClass,gEventDescriptionList[i].theAEEventID,
			SampleHandlerUPP, gEventDescriptionList[i].refCon, false);
}
