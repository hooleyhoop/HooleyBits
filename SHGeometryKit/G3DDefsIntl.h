/*-----------------------------------------------------------------------------
// Project            	SHGeometryKit
// Class              	G3DDefsIntl
// Creator            	Philippe C.D. Robert
// Maintainer         	Philippe C.D. Robert
// Creation Date      	Sat Oct 19 12:30:39 CEST 2002
//
// Copyright (c) Philippe C.D. Robert
//
// The SHGeometryKit is free software; you can redistribute it and/or modify it 
// under the terms of the GNU LGPL Version 2 as published by the Free 
// Software Foundation
//
// $Id: G3DDefsIntl.h,v 1.1 2002/10/19 10:40:19 probert Exp $
//
//---------------------------------------------------------------------------*/

#ifndef __G3DDefsIntl_h_INCLUDE
#define __G3DDefsIntl_h_INCLUDE

/******************************************************************************
 *
 * Enums
 *
 *****************************************************************************/

typedef enum {
  G3D_SCALE       = 0,
  G3D_ROTATION    = 1,
  G3D_TRANSLATION = 2,
  G3D_ID          = 3,
  G3D_GENERIC     = 255
} G3DMatrixType;

#endif
