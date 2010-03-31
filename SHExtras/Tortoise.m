#include "Tortoise.h"

#include <Python/Python.h>
#include <math.h>

#define DEGREES_TO_RADIANS  (3.1415926535897932384626433832795029L/180.0)
#define WINDOW_SIZE 400

double currentX;
double currentY;
double currentDirection;
int penDown = 1;

static PyObject *tortoise_reset(PyObject *self, PyObject* args)
{
    currentX = currentY = WINDOW_SIZE/2;
    currentDirection = 0;
    penDown = 1;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *tortoise_pendown(PyObject *self, PyObject* args)
{
    penDown = 1;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *tortoise_penup(PyObject *self, PyObject* args)
{
    penDown = 0;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *tortoise_turn(PyObject *self, PyObject* args)
{
    int degrees;

    if (!PyArg_ParseTuple(args, "i", &degrees))
        return NULL;
    
    currentDirection += (double)degrees;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *tortoise_move(PyObject *self, PyObject* args)
{
    double newX, newY;
    int steps;
    
    if (!PyArg_ParseTuple(args, "i", &steps))
        return NULL;

    /* first work out the new endpoint */
    newX = currentX + sin(currentDirection*DEGREES_TO_RADIANS)*(double)steps;
    newY = currentY - cos(currentDirection*DEGREES_TO_RADIANS)*(double)steps;

    /* if the pen is down, draw a line */
    if (penDown) {
	NSPoint p1, p2;
        p1 = NSMakePoint(currentX, currentY);
        p2 = NSMakePoint(newX, newY);
            
	[NSBezierPath strokeLineFromPoint:p1 toPoint:p2];  
    }

    currentX = newX;
    currentY = newY;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyMethodDef tortoise_methods[] = {
        {"reset", tortoise_reset, METH_VARARGS, "Pen down at original head toward right."},
        {"pendown", tortoise_pendown, METH_VARARGS, "Pen down."},
        {"penup", tortoise_penup, METH_VARARGS, "Pen up."},
        {"turn", tortoise_turn,  METH_VARARGS, "Turn head by degrees."},
        {"move", tortoise_move, METH_VARARGS, "Move."},
        {NULL, NULL, 0, NULL}
};

void inittortoise(void)
{
        PyImport_AddModule("tortoise");
        Py_InitModule("tortoise", tortoise_methods);
}

void tortoise_initialize()
{
    static int initialized = 0;

    if (!initialized) {
        initialized = 1;
        tortoise_reset(NULL, NULL);
        
        Py_Initialize();
        
        inittortoise();
    }
}


