/*
 *  AEDescUtils.cp
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 */
#include "AEDescUtils.h"

#define LidoHeaderSize 16

OSErr UAECoerceDesc(const AEDesc *  theAEDesc,DescType toType,AEDesc *result){
	if(theAEDesc->descriptorType!=typeUnicodeText || toType==typeChar)
		return AECoerceDesc(theAEDesc,toType,result);
	AEDesc dum;
	OSErr err=AECoerceDesc(theAEDesc,typeChar,&dum);
	if(err)
	    return err;
	err=AECoerceDesc(&dum,toType,result);
	AEDisposeDesc(&dum);
	return err;
}

OSErr DescDataAs(const AEDesc& d,void* p,long size,DescType t){
	OSErr err=noErr;
	if(d.descriptorType!=t){
	    AEDesc newdesc;
	    err=UAECoerceDesc(&d,t,&newdesc); //err=AECoerceDesc(&d,t,&newdesc);
	    if(err)
		return err;
	    err=DescDataAs(newdesc,p, size, t);
	    AEDisposeDesc(&newdesc);
	    return err;
	}
	err=AEGetDescData(&d,p,size);
	return err;
}

#pragma mark -
#pragma mark AEDescTo C declarations
#pragma mark -

OSErr AEDescToDouble(const AEDesc d, double* c){
		return DescDataAs(d, c, sizeof(*c),typeLongFloat);
}

OSErr AEDescToFloat(const AEDesc d, float* c){
		return DescDataAs(d, c, sizeof(*c),typeShortFloat);
}

OSErr AEDescToShort(const AEDesc d, short* c){
	return DescDataAs(d, c, sizeof(*c),typeShortInteger);
}

OSErr AEDescToLong(const AEDesc d, long* c){
	return DescDataAs(d, c, sizeof(*c),typeLongInteger);
}

OSErr AEDescToInt(const AEDesc d, int* c){
	return DescDataAs(d, c, sizeof(*c),typeLongInteger);
}

OSErr AEDescToUInt(const AEDesc d, unsigned int* c){
	return DescDataAs(d, c, sizeof(*c),typeMagnitude);
}

OSErr AEDescToBool(const AEDesc d, Boolean* c){
	switch(d.descriptorType){
	    case typeTrue:*c=true;return noErr;
	    case typeFalse:*c=false;return noErr;
	    default:return DescDataAs(d, c, sizeof(*c),typeBoolean);
	}
}

OSErr AEDescToChar(const AEDesc d, char* c){
	return DescDataAs(d, c, sizeof(*c),typeChar);
}

OSErr AEDescToStr255(const AEDesc d, Str255 c){
	OSErr err=noErr;
	Size l;
	if(d.descriptorType!=typeChar){
		AEDesc newdesc;
		err=AECoerceDesc(&d,typeChar,&newdesc);
		if(err)
		    return err;
		l=AEGetDescDataSize(&newdesc);
		if(l>255)l=255;
		if(l)
		    err=AEGetDescData(&newdesc,&c[1],l);
		c[0]=l;
		AEDisposeDesc(&newdesc); 
	}else{
	    l=AEGetDescDataSize(&d);
	    if(l>255)
		    l=255;
	    if(l)
		    err=AEGetDescData(&d,&c[1],l);
	    c[0]=l;
	}
	return err;
}

#pragma mark -
#pragma mark AEDescFrom C declarations
#pragma mark -

OSErr AEDescFromDouble(AEDesc* d, const double c){
	return AECreateDesc(typeLongFloat, &c,sizeof(c),d);
}

OSErr AEDescFromFloat(AEDesc* d, const float c){
	return AECreateDesc(typeShortFloat, &c,sizeof(c),d);
}

OSErr AEDescFromShort(AEDesc* d, const short c){
	return AECreateDesc(typeShortInteger, &c,sizeof(c),d);
}

OSErr AEDescFromLong(AEDesc* d, const long c){
	return AECreateDesc(typeLongInteger, &c,sizeof(c),d);
}

OSErr AEDescFromInt(AEDesc* d, const int c){
	return AECreateDesc(typeLongInteger, &c,sizeof(c),d);
}

OSErr AEDescFromUInt(AEDesc* d, const unsigned int c){
	return AECreateDesc(typeMagnitude, &c,sizeof(c),d);
}

OSErr AEDescFromBool(AEDesc* d, const Boolean c){
	return AECreateDesc(typeBoolean, &c,sizeof(c),d);
}

OSErr AEDescFromChar(AEDesc* d, const char c){
	return AECreateDesc(typeChar, &c,sizeof(c),d);
}

OSErr AEDescFromStr255(AEDesc* d,const Str255 c){
	return AECreateDesc(typeChar,&c[1],c[0],d);
}

#pragma mark -
#pragma mark declarations relative to arrays
#pragma mark -
#ifndef MALLOC
#define MALLOC malloc
#endif
#ifndef FREE
#define FREE ::free
#endif
#pragma mark DoubleArray
static	const char* LiDoHeaderStrd="Not a recorddoub";
static	const char* LiDoHeaderStrf="Not a recordsing";

float* double2float(int n,double*pp){
	if(!n)return 0;
	float*p=(float*)MALLOC(n*sizeof(float));
    for(int i=0;i<n;i++)
		p[i]=pp[i];
	return p;
}

double* float2double(int n,float*pp){
	if(!n)return 0;
	double*p=(double*)MALLOC(n*sizeof(double));
    for(int i=0;i<n;i++)
		p[i]=pp[i];
	return p;
}

OSErr TypeOfArrayOfReal(const AEDesc* d,DescType* t){
	if(d->descriptorType!='Lido')
		return paramErr;
	OSErr err=AEGetDescDataRange(d, t,LidoHeaderSize-4 ,4);
	if(err)
		return err;
	if(*t=='doub')
		return 0;
	*t='sing';
	return 0;
}

OSErr TypeOfArrayOfRealFromAppleEvent(const AppleEvent* message,DescType key,DescType* t){
    DescType typeCode='null';
    Size actualSize;
	DescType tt[4];
    OSErr err=AEGetParamPtr(message,key,typeWildCard,&typeCode,tt,LidoHeaderSize,&actualSize);
	if(err)
		return err;
    if(typeCode!='Lido')return paramErr;
	if(tt[3]=='doub')
		*t=tt[3];
	*t='sing';
	return 0;
}

static OSErr DoDoubleArrayFromDesc(const AEDesc* d, long*n,double**p);
static OSErr DoFloatArrayFromDesc(const AEDesc* d, long*n,float**p){
    long l=AEGetDescDataSize(d)-LidoHeaderSize;
	if(l<0)
		return paramErr;
	DescType t ;
	OSErr err=AEGetDescDataRange(d, &t,LidoHeaderSize-4 ,4);
	if(err)
		return err;
	if(t=='doub'){
		double* pp=0;
		err=DoDoubleArrayFromDesc(d, n,&pp);
		if(err)
			return err;
		*p=double2float( *n,pp);
		FREE(pp);
		return 0;
	}
	if(l<0 || l%4)
		return paramErr;
	if(!l){
	    *p=0;*n=0;
	    return noErr;
	}
	*p=(float*)MALLOC(l);
	err=AEGetDescDataRange(d, *p,LidoHeaderSize ,l);
	if(err){
		FREE(*p);*p=0;
		return err;
	}
	*n=l/4;
    return 0;
}
static OSErr DoDoubleArrayFromDesc(const AEDesc* d, long*n,double**p){
    long l=AEGetDescDataSize(d)-LidoHeaderSize;
	if(l<0)
		return paramErr;
	DescType t ;
	OSErr err=AEGetDescDataRange(d, &t,LidoHeaderSize-4 ,4);
	if(err)
			return err;
	if(t!='doub'){
		float* pp=0;
		err=DoFloatArrayFromDesc(d, n,&pp);
		if(err)
			return err;
		*p=float2double( *n,pp);
		FREE(pp);
		return 0;
	}
	if(l<0 || l%8)
		return paramErr;
	if(!l){
	    *p=0;*n=0;
	    return noErr;
	}
	*p=(double*)MALLOC(l);
	err=AEGetDescDataRange(d, *p,LidoHeaderSize ,l);
	if(err){
		FREE(*p);*p=0;
		return err;
	}
	*n=l/8;
    return 0;
}

OSErr DoubleArrayFromDesc(const AEDesc* d, long*n,double**p){
    if(d->descriptorType!=typeListOfLongFloat){
		AEDesc temp;
		OSErr err=AECoerceDesc(d,typeListOfLongFloat,&temp);
		if(err){
			double x;
			err=*d>>x;
			if (err)
				return err;
			*p=(double*)MALLOC(sizeof(x));
			**p=x;
			*n=1;
			return 0;
		}
		err=DoDoubleArrayFromDesc(&temp,n,p);
		AEDisposeDesc(&temp);
		return err;
    }
    return DoDoubleArrayFromDesc(d,n,p);
}

OSErr DoubleArrayToAEStream(AEStreamRef  ref, long n,double* p){
	OSErr err=AEStreamOpenDesc( ref,typeListOfLongFloat);
	if(!err)
		err=AEStreamWriteData( ref,LiDoHeaderStrd,LidoHeaderSize);
	if(!err && n)
		err=AEStreamWriteData( ref,p,n*sizeof(double));
	if(!err)
		err=AEStreamCloseDesc( ref) ;
	return err;
}

OSErr DoubleArrayToDesc(AEDesc* d, long n,double* p){
 	if(n<0)
		return paramErr;
	AEStreamRef  ref=AEStreamOpen();
	OSErr err=DoubleArrayToAEStream(ref,  n, p);
	if(!err)
		err=AEStreamClose(  ref,d) ;
	else
		AEStreamClose(  ref,0) ;
    return err;
}

OSErr DoubleArrayToAppleEvent(AppleEvent* reply,DescType key, long n,double* p){
 	if(n<0)
		return paramErr;
	AEStreamRef ref=AEStreamOpenEvent(reply);
	OSErr err=AEStreamWriteKey ( ref,key);
	err=DoubleArrayToAEStream(  ref,  n, p);
	return AEStreamClose( ref,reply);
}

#pragma mark FloatArray
OSErr FloatArrayFromDesc(const AEDesc* d, long*n,float**p){
    if(d->descriptorType!=typeListOfLongFloat){
		AEDesc temp;
		OSErr err=AECoerceDesc(d,typeListOfLongFloat,&temp);
		if(err){
			float x;
			err=*d>>x;
			if (err)
				return err;
			*p=(float*)MALLOC(sizeof(x));
			**p=x;
			*n=1;
			return 0;
		}
		err=DoFloatArrayFromDesc(&temp,n,p);
		AEDisposeDesc(&temp);
		return err;
    }
    return DoFloatArrayFromDesc(d,n,p);
}

OSErr FloatArrayToDesc(AEDesc* d, long n,float* p){
 	if(n<0)
		return paramErr;
	AEStreamRef  ref=AEStreamOpen();
	OSErr err=FloatArrayToAEStream(ref,  n, p);
	if(!err)
		err=AEStreamClose(  ref,d) ;
	else
		AEStreamClose(  ref,0) ;
    return err;
}

OSErr FloatArrayToAppleEvent(AppleEvent* reply,DescType key, long n,float* p){
 	if(n<0)
		return paramErr;
	AEStreamRef ref=AEStreamOpenEvent(reply);
	OSErr err=AEStreamWriteKey ( ref,key);
	err=FloatArrayToAEStream(  ref,  n, p);
	return AEStreamClose( ref,reply);
}

OSErr FloatArrayToAEStream(AEStreamRef  ref, long n,float* p){
	if(n<0)
		return paramErr;
	OSErr err=AEStreamOpenDesc( ref,typeListOfLongFloat);
	if(!err)
		err=AEStreamWriteData( ref,LiDoHeaderStrf,LidoHeaderSize);
	if(!err && n)
		err=AEStreamWriteData( ref,p,n*sizeof(float));
	if(!err)
		err=AEStreamCloseDesc( ref) ;
	return err;
}

#pragma mark LongArray
static long* double2long(int n,double*pp){
    if(!n)return 0;
    long*p=(long*)MALLOC(n*sizeof(long));
    for(int i=0;i<n;i++)
		p[i]=(long)pp[i];
	return p;
}

static double* long2double(int n,long*pp){
    if(!n)return 0;
    double*p=(double*)MALLOC(n*sizeof(double));
    for(int i=0;i<n;i++)
		p[i]=pp[i];
	return p;
}

OSErr LongArrayFromDesc(const AEDesc* d, long*n,long**p){
    double * pp;
    OSErr err=DoubleArrayFromDesc(d,n,&pp);
    if(err)
		return err;
    *p=double2long(*n,pp);
	FREE(pp);
	return 0; 
}

OSErr LongArrayToDesc(AEDesc* d, long n,long* p){
	if(n<0)
		return paramErr;
    double* pp=0;
	if(n) pp=long2double(n,p);
    OSErr err=DoubleArrayToDesc(d,n,pp);
    FREE(pp);
    return err;
}

OSErr LongArrayToAppleEvent(AppleEvent* reply,DescType key, long n,long* p){
	if(n<0)
		return paramErr;
    double* pp=0;
	if(n) pp=long2double(n,p);
    OSErr err=DoubleArrayToAppleEvent(reply, key,n,pp);
    FREE(pp);
    return err;
}

OSErr LongArrayToAEStream(AEStreamRef  ref, long n,long* p){
	if(n<0)
		return paramErr;
    double* pp=0;
	if(n) pp=long2double(n,p);
    OSErr err=DoubleArrayToAEStream(ref,n,pp);
    FREE(pp);
    return err;
}

#pragma mark Matrix

static OSErr DoMatrixFromDesc(const AEDesc* d, long*ncols,long* nrows,double**p){
	DescType typeCode;
	Size si;
	*p=0;
	OSErr err=AEGetKeyPtr(d, 'ncol',typeLongInteger,&typeCode, ncols,4,&si);
	if(err)
	    return err;
	err=AEGetKeyPtr(d, 'nrow',typeLongInteger,&typeCode, nrows,4,&si);
	if(err)
	    return err;
	AEDesc temp;
	err=AEGetKeyDesc(d, typeListOfLongFloat,typeListOfLongFloat,&temp);
	if(err)
	    return err;
	Size n;
	err=DoDoubleArrayFromDesc(&temp, &n,p);
	AEDisposeDesc(&temp);
	if(err || n!=(*nrows**ncols)){
	    if(*p)
		FREE(*p);
	    *p=0;
	    return paramErr;
	}
	return 0;
}

OSErr MatrixFromDesc(const AEDesc* d, long*ncols,long* nrows,double**p){
    if (d->descriptorType!=typeAERecord && d->descriptorType!=typeMatrix){
		AEDesc temp;
		OSErr err=AECoerceDesc(d,typeAERecord,&temp);
		if(err)
			return err;
		err=DoMatrixFromDesc(&temp,ncols, nrows,p);
		AEDisposeDesc(&temp);
		return err;
    }
    return DoMatrixFromDesc(d,ncols, nrows,p);
}

OSErr MatrixToAEStream(AEStreamRef   ref, long ncols,long nrows,double* p){
	OSErr err=0;
    err=AEStreamOpenRecord(ref,typeMatrix);
	if(err)
		return err;
    AEStreamWriteKeyDesc(ref,'ncol',typeLongInteger,&ncols,sizeof(ncols));
    AEStreamWriteKeyDesc(ref,'nrow',typeLongInteger,&nrows,sizeof(nrows));
    if((ncols*nrows)>0 && p){
		long n=ncols*nrows;
		err=AEStreamOpenKeyDesc ( ref,typeListOfShortFloat ,typeListOfShortFloat);
		if(!err)
			err=AEStreamWriteData( ref,LiDoHeaderStrd,LidoHeaderSize);
		if(!err)
			err=AEStreamWriteData( ref,p,n*sizeof(double));
		AEStreamCloseDesc(ref);
    }
	AEStreamCloseRecord(ref);
	return err;
}

OSErr MatrixToDesc(AEDesc* d, long ncols,long nrows,double* p){
    AEStreamRef   ref=AEStreamOpen();
	OSErr err=MatrixToAEStream(   ref,  ncols, nrows, p);
	if(!err)
		err=AEStreamClose( ref,d);
	else
		AEStreamClose( ref,0);
    return err;
}

OSErr MatrixToAppleEvent(AppleEvent* reply,DescType key, long ncols,long nrows,double* p){
	AEStreamRef ref=AEStreamOpenEvent(reply);
	OSErr err=AEStreamWriteKey(ref, key);
	err=MatrixToAEStream(   ref,  ncols, nrows, p);
	return AEStreamClose( ref,reply);
}

#pragma mark FloatMatrix

OSErr FloatMatrixFromDesc(const AEDesc* d, long *ncols,long *nrows,float**p){
    double * pp;
    OSErr err=MatrixFromDesc(d,ncols,nrows,&pp);
    if(err)
		return err;
    *p=double2float(*ncols**nrows,pp);
	FREE(pp);
	return 0; 
}

OSErr FloatMatrixToDesc(AEDesc* d, long ncols,long nrows,float* p){
    AEStreamRef   ref=AEStreamOpen();
	OSErr err=FloatMatrixToAEStream(   ref,  ncols, nrows, p);
	if(!err)
		err=AEStreamClose( ref,d);
	else
		AEStreamClose( ref,0);
    return err;
}

OSErr FloatMatrixToAppleEvent(AppleEvent* reply,DescType key, long ncols,long nrows, float* p){
	AEStreamRef ref=AEStreamOpenEvent(reply);
	OSErr err=AEStreamWriteKey(ref, key);
	err=FloatMatrixToAEStream(   ref,  ncols, nrows, p);
	return AEStreamClose( ref,reply);
}

OSErr FloatMatrixToAEStream(AEStreamRef  ref, long ncols,long nrows, float* p){
	OSErr err=0;
    err=AEStreamOpenRecord(ref,typeMatrix);
	if(err)
		return err;
    AEStreamWriteKeyDesc(ref,'ncol',typeLongInteger,&ncols,sizeof(ncols));
    AEStreamWriteKeyDesc(ref,'nrow',typeLongInteger,&nrows,sizeof(nrows));
    if((ncols*nrows)>0 && p){
		long n=ncols*nrows;
		err=AEStreamOpenKeyDesc ( ref,typeListOfShortFloat ,typeListOfShortFloat);
		if(!err)
			err=AEStreamWriteData( ref,LiDoHeaderStrf,LidoHeaderSize);
		if(!err)
			err=AEStreamWriteData( ref,p,n*sizeof(float));
		AEStreamCloseDesc(ref);
    }
	AEStreamCloseRecord(ref);
	return err;
}


