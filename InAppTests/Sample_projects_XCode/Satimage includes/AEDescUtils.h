/*
 *  AEDescUtils.h
 *
 *  Copyright (c) 2003 Satimage. All rights reserved.
 *
 * Provides convenient routines to translate C variables into AEDesc's (and v-v).
 */
#ifndef __AEDESCUTILS__
#define __AEDESCUTILS__
#include <Carbon/Carbon.h>
#define typeListOfLongFloat 'Lido'
#define typeListOfShortFloat 'Lido'
#define typeMatrix 'Matr'
#define typePolynomial 'Poly'
#define LidoHeaderSize 16

#ifdef __cplusplus
extern "C" {
#endif

OSErr AEDescToDouble(const AEDesc d, double* c);
OSErr AEDescToFloat(const AEDesc d, float* c);
OSErr AEDescToShort(const AEDesc d, short* c);
OSErr AEDescToLong(const AEDesc d, long* c);
OSErr AEDescToInt(const AEDesc d, int* c);
OSErr AEDescToUInt(const AEDesc d, unsigned int* c);
OSErr AEDescToBool(const AEDesc d, Boolean* c);
OSErr AEDescToChar(const AEDesc d, char* c);
OSErr AEDescToStr255(const AEDesc d, Str255 c);

OSErr AEDescFromDouble(AEDesc* d, const double c);
OSErr AEDescFromFloat(AEDesc* d, const float c);
OSErr AEDescFromShort(AEDesc* d, const short c);
OSErr AEDescFromLong(AEDesc* d, const long c);
OSErr AEDescFromInt(AEDesc* d, const int c);
OSErr AEDescFromUInt(AEDesc* d, const unsigned int c);
OSErr AEDescFromBool(AEDesc* d, const Boolean c);
OSErr AEDescFromChar(AEDesc* d, const char c);
OSErr AEDescFromStr255(AEDesc* d,const Str255 c);

OSErr DoubleArrayFromDesc(const AEDesc* d, long*n,double**p);
OSErr DoubleArrayToDesc(AEDesc* d, long n,double* p);
OSErr DoubleArrayToAppleEvent(AppleEvent* reply,DescType key, long n,double* p);
OSErr DoubleArrayToAEStream(AEStreamRef  ref, long n,double* p);

OSErr FloatArrayFromDesc(const AEDesc* d, long*n,float**p);
OSErr FloatArrayToDesc(AEDesc* d, long n,float* p);
OSErr FloatArrayToAppleEvent(AppleEvent* reply,DescType key, long n,float* p);
OSErr FloatArrayToAEStream(AEStreamRef  ref, long n,float* p);

OSErr LongArrayFromDesc(const AEDesc* d, long*n,long**p);
OSErr LongArrayToDesc(AEDesc* d, long n,long* p);
OSErr LongArrayToAppleEvent(AppleEvent* reply,DescType key, long n,long* p);
OSErr LongArrayToAEStream(AEStreamRef  ref, long n,long* p);

OSErr MatrixFromDesc(const AEDesc* d, long*ncols,long* nrows,double**p);
OSErr MatrixToDesc(AEDesc* d, long ncols,long nrows,double* p);
OSErr MatrixToAppleEvent(AppleEvent* reply, DescType key, long ncols,long nrows,double* p);
OSErr MatrixToAEStream(AEStreamRef   ref, long ncols,long nrows,double* p);

OSErr FloatMatrixFromDesc(const AEDesc* d, long *ncols,long *nrows,float**p);
OSErr FloatMatrixToDesc(AEDesc* d, long ncols,long nrows,float* p);
OSErr FloatMatrixToAppleEvent(AppleEvent* reply,DescType key, long ncols,long nrows, float* p);
OSErr FloatMatrixToAEStream(AEStreamRef  ref, long ncols,long nrows, float* p);

OSErr TypeOfArrayOfReal(const AEDesc* d,DescType* t);
OSErr TypeOfArrayOfRealFromAppleEvent(const AppleEvent* message,DescType key,DescType* t);
#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
OSErr DescDataAs(const AEDesc& d,void* p,long size,DescType t);

inline OSErr operator>>(const AEDesc& source,double& c){return AEDescToDouble(source, &c);}
inline OSErr operator>>(const AEDesc& source,float& c){return AEDescToFloat(source, &c);}
inline OSErr operator>>(const AEDesc& source,short& c){return AEDescToShort(source, &c);}
inline OSErr operator>>(const AEDesc& source,long& c){return AEDescToLong(source, &c);}
inline OSErr operator>>(const AEDesc& source,int& c){return AEDescToInt(source, &c);}
inline OSErr operator>>(const AEDesc& source,unsigned int& c){return AEDescToUInt(source, &c);}
inline OSErr operator>>(const AEDesc& source,Boolean& c){return AEDescToBool(source, &c);}
inline OSErr operator>>(const AEDesc& source,char& c){return AEDescToChar(source, &c);}
inline OSErr operator>>(const AEDesc& source,Str255 c){return AEDescToStr255(source, c);}
inline OSErr operator>>(const AEDesc& data, FSRef& ref){return DescDataAs(data,&ref,sizeof(ref),typeFSRef);}
inline OSErr operator>>(const AEDesc& data, FSSpec& ref){return DescDataAs(data,&ref,sizeof(ref),typeFSS);}

inline OSErr operator<<(AEDesc& d, const double c){return AEDescFromDouble(&d, c);}
inline OSErr operator<<(AEDesc& d, const float c){return AEDescFromFloat(&d, c);}
inline OSErr operator<<(AEDesc& d, const short c){return AEDescFromShort(&d, c);}
inline OSErr operator<<(AEDesc& d, const long c){return AEDescFromLong(&d, c);}
inline OSErr operator<<(AEDesc& d, const int c){return AEDescFromInt(&d, c);}
inline OSErr operator<<(AEDesc& d, const unsigned int c){return AEDescFromUInt(&d, c);}
inline OSErr operator<<(AEDesc& d, const Boolean c){return AEDescFromBool(&d, c);}
inline OSErr operator<<(AEDesc& d, const char c){return AEDescFromChar(&d, c);}
inline OSErr operator<<(AEDesc& d, const Str255 c){return AEDescFromStr255(&d, c);}
inline OSErr operator<< (AEDesc& data,FSRef& ref){ return AECreateDesc( typeFSRef,&ref,sizeof(ref),&data);}
inline OSErr operator<< (AEDesc& data,FSSpec& ref){return AECreateDesc( typeFSS,&ref,sizeof(ref),&data);}
#endif

#endif