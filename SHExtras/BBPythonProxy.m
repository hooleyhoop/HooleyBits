//
//  BBPythonProxy.m
//  SHExtras
//
//  Created by Steven Hooley on 06/07/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBPythonProxy.h"


@implementation BBPythonProxy

// PyFloat_Check
// PyInt_AsLong
// PyTuple_New
// PyTuple_SetItem

+ (id)proxyFor:(PyObject *)obj {
  return [self proxyFor:obj steal:NO];
}
+ (id)proxyFor:(PyObject *)obj steal:(BOOL)steal {
  return [[[self alloc] initWithPythonObject:obj steal:steal] autorelease];
}

- (id)initWithPythonObject:(PyObject *)obj steal:(BOOL)steal {
   if (!obj) {
    [self dealloc];
    return nil;
  }
  if (!steal) 
	Py_INCREF(obj);
  pyObj = obj;
  return self;
}

- (void)dealloc {
  Py_XDECREF(pyObj);
  pyObj = NULL;
  [super dealloc];
}

- (NSString *)description {
  PyObject *repr;
  char *cstr;

  if (!pyObj) {
    return @"<Invalid Python Proxy>";
  }

  repr = PyObject_Repr(pyObj);
  if (!repr) {
    // fixme: do something with the exception
    return @"<Exception while getting representation>";
  }

  cstr = PyString_AsString(repr);
  if (!cstr) {
    return @"<Exception while getting representation>";
  }

  {
    NSString *result = [NSString stringWithCString:cstr];
    Py_DECREF(repr);
    return result;
  }
}

- (PyObject *)original
{
	return pyObj;
}

@end
