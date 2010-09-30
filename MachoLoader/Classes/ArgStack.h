/*
 *  ArgStack.h
 *  MachoLoader
 *
 *  Created by Steven Hooley on 30/09/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */

#define STACK_MAX 10

struct ArgStack {
    int64_t     data[STACK_MAX];
    int32_t		size;
};

void argStack_Init( struct ArgStack *S );

int64_t argStack_Top( struct ArgStack *S );

void argStack_Push( struct ArgStack *S, int64_t d );
void argStack_Pop( struct ArgStack *S );
