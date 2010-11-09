/*
 *  HooClass.h
 *  MachoLoader
 *
 *  Created by Steven Hooley on 09/11/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

struct ArgMap {
	int inputCount;
	int outputCount;
	int inputs[3];
	int outputs[3];
};

struct HooClass {
	char name[10];
	int numberOfArgs;
	struct ArgMap *argMap;
	float (*funcPtr1)(float, float);
};

// Predefined function declarations
float uselessFunction( float a, float b );


// Predefined arg map declarations
// * None yet *

// Predefined Class declarations
struct HooClass			___________;
struct HooClass			_________i1;
struct HooClass			______i1_o2;
struct HooClass			______i1_i2;
struct HooClass			___i2_i1_o2;