/*******************************************************************/
/*                                                                 */
/*                      ADOBE CONFIDENTIAL                         */
/*                   _ _ _ _ _ _ _ _ _ _ _ _ _                     */
/*                                                                 */
/* Copyright 2007 Adobe Systems Incorporated                       */
/* All Rights Reserved.                                            */
/*                                                                 */
/* NOTICE:  All information contained herein is, and remains the   */
/* property of Adobe Systems Incorporated and its suppliers, if    */
/* any.  The intellectual and technical concepts contained         */
/* herein are proprietary to Adobe Systems Incorporated and its    */
/* suppliers and may be covered by U.S. and Foreign Patents,       */
/* patents in process, and are protected by trade secret or        */
/* copyright law.  Dissemination of this information or            */
/* reproduction of this material is strictly forbidden unless      */
/* prior written permission is obtained from Adobe Systems         */
/* Incorporated.                                                   */
/*                                                                 */
/*******************************************************************/

/*
	AudioFFTRender.h
*/

//#pragma once

//#ifndef SKELETON_H
//#define SKELETON_H
//
typedef unsigned char		u_char;
typedef unsigned short		u_short;
typedef unsigned short		u_int16;
typedef unsigned long		u_long;
typedef short int			int16;
#define PF_TABLE_BITS	12
#define PF_TABLE_SZ_16	4096

#define PF_DEEP_COLOR_AWARE 1	// make sure we get 16bpc pixels; 
								// AE_Effect.h checks for this.

#import "AEConfig.h"

//#ifdef AE_OS_WIN
//	typedef unsigned short PixelType;
//	#import <Windows.h>
//#endif

#import "entry.h"
#import "AE_Effect.h"


#define	MAJOR_VERSION	1
#define	MINOR_VERSION	0
#define	BUG_VERSION		0
#define	STAGE_VERSION	PF_Stage_DEVELOP
#define	BUILD_VERSION	1


/* Parameter defaults */
#define	SKELETON_AMOUNT_MIN		0
#define	SKELETON_AMOUNT_MAX		100
#define	SKELETON_AMOUNT_DFLT	50

#define 	SND_RATE_44100			0xac440000

enum {
	SKELETON_INPUT = 0,
	SKELETON_AMOUNT,
	SKELETON_COLOR,
	SKELETON_DOWNSAMPLE,
	SKELETON_USE_3D,
	SKELETON_NUM_PARAMS
};

enum {
	AMOUNT_DISK_ID = 1,
	COLOR_DISK_ID,
	DOWNSAMPLE_DISK_ID,
	THREED_DISK_ID
};

//#ifdef __cplusplus
//	extern "C" {
//#endif
//	
DllExport PF_Err EntryPointFunc( PF_Cmd cmd, PF_InData *in_data, PF_OutData *out_data, PF_ParamDef *params[], PF_LayerDef *output, void *extra );

//#ifdef __cplusplus
//}
//#endif
//
//#endif // SKELETON_H