/*
 *  ArgStack.c
 *  MachoLoader
 *
 *  Created by Steven Hooley on 30/09/2010.
 *  Copyright 2010 Tinsal Parks. All rights reserved.
 *
 */
#include <stdio.h>
#include <stdlib.h>

#include "ArgStack.h"

void argStack_Init( struct ArgStack *S ) {

    S->size = 0;
}

int64_t argStack_Top( struct ArgStack *S ) {

    if (S->size == 0) {
        fprintf(stderr, "Error: arg stack empty\n");
        return -1;
    }
    return S->data[S->size-1];
}

void argStack_Push( struct ArgStack *S, int64_t d ){

    if (S->size < STACK_MAX)
        S->data[S->size++] = d;
    else
        fprintf(stderr, "Error: arg stack full\n");
}

void argStack_Pop( struct ArgStack *S ){

    if (S->size == 0)
        fprintf(stderr, "Error: arg stack empty\n");
    else
        S->size--;
}
