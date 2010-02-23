/*
 *  Heat.cpp
 *  HeatEquation
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */

#include "Heat.h"

HeatEqn gHeatEqn;
void OneStep( int ncols, int nrows, float *p, float dt,float *newp);

void HeatEqn::free(){
    if(p)
	::free(p);
    p=0;
}

OSErr HeatEqn::Run(int steps){
    float *temp=new float[ncols*nrows];
    for(int i=0;i<steps;i++){
	OneStep( ncols, nrows, p, sigma*dt,temp);
	BlockMove(temp,p,ncols*nrows*sizeof(float));
    }
    delete[]temp;
    return 0;
}


void OneStep( int ncols, int nrows, float *p, float dt,float *newp){
    int i,j;
    //bulk
    float* p0=p+1;
    float* p1=p0+ncols;
    float* p2=p1+ncols;
    float* pp=newp+1+ncols;
    for(i=1;i<(nrows-1);i++){
	for( j=1;j<(ncols-1);j++,p0++,p1++,p2++,pp++){
	    *pp=*p1+(*p0+*p2+p1[1]+p1[-1]-4.0**p1)*dt;
	}
	p0+=2,p1+=2,p2+=2,pp+=2;
    }
    //first line
    p1=p+1;
    p2=p1+ncols;
    pp=newp+1;
    for( j=1;j<(ncols-1);j++,p1++,p2++,pp++){
	*pp=*p1+(*p2+p1[1]+p1[-1]-3.0**p1)*dt;
    }
    //last line
    p1=p+(nrows-1)*ncols+1;
    p0=p1-ncols;
    pp=newp+(nrows-1)*ncols+1;
    for( j=1;j<(ncols-1);j++,p1++,p0++,pp++){
	*pp=*p1+(*p0+p1[1]+p1[-1]-3.0**p1)*dt;
    }
    //first column
    p0=p;
    p1=p+ncols;
    p2=p1+ncols;
    pp=newp+ncols;
    for(i=1;i<(nrows-1);i++){
	*pp=*p1+(*p0+*p2+p1[1]-3.0**p1)*dt;
	pp+=ncols;p0+=ncols;p1+=ncols;p2+=ncols;
    }
    //last column
    p0=p+ncols-1;
    p1=p0+ncols;
    p2=p1+ncols;
    pp=newp+2*ncols-1;
    for(i=1;i<(nrows-1);i++){
	*pp=*p1+(*p0+*p2+p1[-1]-3.0**p1)*dt;
	pp+=ncols;p0+=ncols;p1+=ncols;p2+=ncols;
    }
    //corners
    *newp=*p+(p[1]+p[ncols]-2.0**p)*dt;
    i=ncols-1;
    newp[i]=p[i]+(p[i-1]+p[i+ncols]-2.0*p[i])*dt;
    i=ncols*(nrows-1);
    newp[i]=p[i]+(p[i+1]+p[i-ncols]-2.0*p[i])*dt;
    i=ncols*nrows-1;
    newp[i]=p[i]+(p[i-1]+p[i-ncols]-2.0*p[i])*dt;
}