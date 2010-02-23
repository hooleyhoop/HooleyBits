#include "BBPython.h"
#include <Python/Python.h>
#include <math.h>
#import "pyobjc-api.h"

#define DEGREES_TO_RADIANS  (3.1415926535897932384626433832795029L/180.0)
#define WINDOW_SIZE 400

double currentX;
double currentY;
double currentDirection;
int penDown = 1;

static PyObject * crypt_crypt(PyObject *self, PyObject *args)
{
  char *word, *salt;
  // parse the incoming arguments
  if (!PyArg_Parse(args, "(ss)", &word, &salt))
    {
      return NULL;
    }
  // return the hashed string
  return PyString_FromString(crypt(word, salt));
}

static PyObject *BBPython_reset(PyObject *self, PyObject* args)
{
    PyObject* patch;
    if (!PyArg_ParseTuple(args, "O", &patch)) // "O" = PyObject*
        return NULL;

    [patch resetLocalVariables];
	
    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *BBPython_pendown(PyObject *self, PyObject* args)
{
    penDown = 1;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *BBPython_penup(PyObject *self, PyObject* args)
{
    penDown = 0;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *BBPython_turn(PyObject *self, PyObject* args)
{
    int degrees;

    if (!PyArg_ParseTuple(args, "i", &degrees))
        return NULL;
    
    currentDirection += (double)degrees;

    Py_INCREF(Py_None);
    return Py_None;
}

static PyObject *BBPython_move(PyObject *self, PyObject* args)
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

static PyMethodDef BBPython_methods[] = {
		{"crypt", crypt_crypt},
        {"reset", BBPython_reset, METH_VARARGS, "Pen down at original head toward right."},
        {"pendown", BBPython_pendown, METH_VARARGS, "Pen down."},
        {"penup", BBPython_penup, METH_VARARGS, "Pen up."},
        {"turn", BBPython_turn,  METH_VARARGS, "Turn head by degrees."},
        {"move", BBPython_move, METH_VARARGS, "Move."},
        {NULL, NULL, 0, NULL}
};

void initBBPython(void)
{
	PyImport_AddModule("BBPython");
	Py_InitModule("BBPython", BBPython_methods);
}

void BBPython_initialize()
{
    static int initialized = 0;

    if (!initialized) {
        initialized = 1;
        BBPython_reset(NULL, NULL);
        
        Py_Initialize();
        
        initBBPython();
    }
}


