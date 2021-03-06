/*
 *  HooClass.c
 *  MachoLoader
 *
 *  Created by Steven Hooley on 09/11/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

#import "HooClass.h"

// pre defined functions
float uselessFunction( float a, float b ) { return 0.0f; }

// Pre defined arg maps
struct ArgMap noArgs					= { 0, 0, {0, 0, 0}, {0, 0, 0} };

struct ArgMap oneInput					= { 1, 0, {1, 0, 0}, {0, 0, 0} };
struct ArgMap twoInputs					= { 2, 0, {1, 2, 0}, {0, 0, 0} };

struct ArgMap oneInputOneOutput			= { 1, 1, {1, 0, 0}, {2, 0, 0} };
struct ArgMap oneInputOneOutput2		= { 1, 1, {1, 0, 0}, {1, 0, 0} };
struct ArgMap twoInputOneOutput			= { 2, 1, {2, 1, 0}, {2, 0, 0} };
struct ArgMap twoInputOneOutput2		= { 2, 1, {2, 1, 0}, {3, 0, 0} };

struct ArgMap twoInputTwoOutput			= { 2, 2, {2, 1, 0}, {2, 1, 0} };



// 0 args
struct HooClass			___________		= { "david", 0, &noArgs,				uselessFunction };

// 1 arg
struct HooClass			_________i1		= { "david", 1, &oneInput,				uselessFunction };
struct HooClass			______i1_o1		= { "david", 1, &oneInputOneOutput2,	uselessFunction };

// 2 args
struct HooClass			______i1_o2		= { "david", 2, &oneInputOneOutput,		uselessFunction };
struct HooClass			______i1_i2		= { "david", 2, &twoInputs,				uselessFunction };
struct HooClass			___i2_i1_o2		= { "david", 2, &twoInputOneOutput,		uselessFunction };
struct HooClass			i2_i1_o2_o1		= { "david", 2, &twoInputTwoOutput,		uselessFunction };

// 3 args
struct HooClass			___i2_i1_o3		= { "david", 3, &twoInputOneOutput2,	uselessFunction };

