/*
 *  compute.cpp
 *  ThreadedApp
 *
 *  Created by François Delyon on Thu Mar 04 2004.
 *  Copyright (c) 2004 Satimage. All rights reserved.
 *
 */

#include "compute.h"
#include "SimpleOSL.h"

int theInt=0;

//
extern float *pdebugfloat;
extern char *pdebugstring;
extern long debugsize1;//ncols of pdebugmatrix or size of pdebugarray
extern long debugsize2;//not used in this sample, nrows of pdebugmatrix
extern float *pdebugarray;
extern float *pdebugmatrix;//not used in this sample

int SubRoutine1(int a){
	unsigned long finalTicks;
	float x=pi;
	a++;
	Delay(60,&finalTicks);
	pdebugfloat=&x;//publish the local variable x
    NotifySmile("wait for resume 2",true);//stop execution of the current thread and wait for resume 2
	pdebugfloat=0;
	return a;
}

int SubRoutine3(int a){
	unsigned long finalTicks;
	float f[]={0.0,1.0,4.0,9.0,16.0};
	a++;
	Delay(120,&finalTicks);
	//publish the local variable f
	debugsize1=sizeof(f)/sizeof(float);
	pdebugarray=f;
    NotifySmile("wait for  resume 5",true);//stop execution of the current thread and wait for  resume 5
	pdebugarray=0;
	return a;
}

int SubRoutine2(int a){
	unsigned long finalTicks;
	char* s="in \"SubRoutine2\"";
	a++;
	Delay(60,&finalTicks);
	pdebugstring=s;////publish the local variable s
    NotifySmile("wait for  resume 4",true);//stop execution of the current thread and wait for  resume 4
	pdebugstring=0;
	return SubRoutine3(a);
}

int Run(int a){
	unsigned long finalTicks;
    theInt=a;
	theInt++;
	Delay(300,&finalTicks);
    NotifySmile("wait for the 1st resume",true);//stop execution of the current thread and wait for the 1st resume
	theInt=SubRoutine1(theInt);
	Delay(300,&finalTicks);
    NotifySmile("wait for  resume 3",true);//stop execution of the current thread and wait for  resume 3
	theInt=SubRoutine2(theInt);
	Delay(60,&finalTicks);
	NotifySmile("The end !",false);
	return theInt;
}
