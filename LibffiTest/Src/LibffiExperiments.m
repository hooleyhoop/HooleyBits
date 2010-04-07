//
//  LibffiExperiments.m
//  LibffiTest
//
//  Created by steve hooley on 31/03/2010.
//  Copyright 2010 BestBefore Ltd. All rights reserved.
//

#import "LibffiExperiments.h"
#import <dlfcn.h>
#import <ffi/ffi.h>

@implementation LibffiExperiments

char get_typeChar_from_typeString(const char *typeString)
{
    int i = 0;
    char typeChar = typeString[i];
    while ((typeChar == 'r') || (typeChar == 'R') ||
		   (typeChar == 'n') || (typeChar == 'N') ||
		   (typeChar == 'o') || (typeChar == 'O') ||
		   (typeChar == 'V')
		   ) {
        // uncomment the following two lines to complain about unused quantifiers in ObjC type encodings
        // if (typeChar != 'r')                      // don't worry about const
        //     NSLog(@"ignoring qualifier %c in %s", typeChar, typeString);
        typeChar = typeString[++i];
    }
    return typeChar;
}

void *value_buffer_for_objc_type(const char *typeString)
{
    char typeChar = get_typeChar_from_typeString(typeString);
    switch (typeChar) {
        case 'f': return malloc(sizeof(float));
        case 'd': return malloc(sizeof(double));
        case 'v': return malloc(sizeof(void *));
        case 'B': return malloc(sizeof(unsigned int));
        case 'C': return malloc(sizeof(unsigned int));
        case 'c': return malloc(sizeof(int));
        case 'S': return malloc(sizeof(unsigned int));
        case 's': return malloc(sizeof(int));
        case 'I': return malloc(sizeof(unsigned int));
        case 'i': return malloc(sizeof(int));
        case 'L': return malloc(sizeof(unsigned long));
        case 'l': return malloc(sizeof(long));
        case 'Q': return malloc(sizeof(unsigned long long));
        case 'q': return malloc(sizeof(long long));
        case '@': return malloc(sizeof(void *));
        case '#': return malloc(sizeof(void *));
        case '*': return malloc(sizeof(void *));
        case ':': return malloc(sizeof(void *));
        case '^': return malloc(sizeof(void *));
//        case '{':
//        {
//            if (!strcmp(typeString, NSRECT_SIGNATURE0) ||
//                !strcmp(typeString, NSRECT_SIGNATURE1) ||
//                !strcmp(typeString, NSRECT_SIGNATURE2) ||
//                !strcmp(typeString, CGRECT_SIGNATURE0) ||
//                !strcmp(typeString, CGRECT_SIGNATURE1) ||
//                !strcmp(typeString, CGRECT_SIGNATURE2)
//				) {
//                return malloc(sizeof(NSRect));
//            }
//            else if (
//					 !strcmp(typeString, NSRANGE_SIGNATURE) ||
//					 !strcmp(typeString, NSRANGE_SIGNATURE1)
//					 ) {
//                return malloc(sizeof(NSRange));
//            }
//            else if (
//					 !strcmp(typeString, NSPOINT_SIGNATURE0) ||
//					 !strcmp(typeString, NSPOINT_SIGNATURE1) ||
//					 !strcmp(typeString, NSPOINT_SIGNATURE2) ||
//					 !strcmp(typeString, CGPOINT_SIGNATURE)
//					 ) {
//                return malloc(sizeof(NSPoint));
//            }
//            else if (
//					 !strcmp(typeString, NSSIZE_SIGNATURE0) ||
//					 !strcmp(typeString, NSSIZE_SIGNATURE1) ||
//					 !strcmp(typeString, NSSIZE_SIGNATURE2) ||
//					 !strcmp(typeString, CGSIZE_SIGNATURE)
//					 ) {
//                return malloc(sizeof(NSSize));
//            }
//            else {
//                NSLog(@"unknown type identifier %s", typeString);
//                return malloc(sizeof (void *));
//            }
//        }
        default:
        {
            NSLog(@"unknown type identifier %s", typeString);
            return malloc(sizeof (void *));
        }
    }
}

ffi_type *ffi_type_for_objc_type( const char *typeString )
{
    char typeChar = get_typeChar_from_typeString(typeString);
    switch (typeChar) {
        case 'f': return &ffi_type_float;
        case 'd': return &ffi_type_double;
        case 'v': return &ffi_type_void;
        case 'B': return &ffi_type_uchar;
        case 'C': return &ffi_type_uchar;
        case 'c': return &ffi_type_schar;
        case 'S': return &ffi_type_ushort;
        case 's': return &ffi_type_sshort;
        case 'I': return &ffi_type_uint;
        case 'i': return &ffi_type_sint;
#ifdef __x86_64__
        case 'L': return &ffi_type_ulong;
        case 'l': return &ffi_type_slong;
#else
        case 'L': return &ffi_type_uint;
        case 'l': return &ffi_type_sint;
#endif
        case 'Q': return &ffi_type_uint64;
        case 'q': return &ffi_type_sint64;
        case '@': return &ffi_type_pointer;
        case '#': return &ffi_type_pointer;
        case '*': return &ffi_type_pointer;
        case ':': return &ffi_type_pointer;
        case '^': return &ffi_type_pointer;
        case '{':
//        {
//            if (!strcmp(typeString, NSRECT_SIGNATURE0) ||
//                !strcmp(typeString, NSRECT_SIGNATURE1) ||
//                !strcmp(typeString, NSRECT_SIGNATURE2) ||
//                !strcmp(typeString, CGRECT_SIGNATURE0) ||
//                !strcmp(typeString, CGRECT_SIGNATURE1) ||
//                !strcmp(typeString, CGRECT_SIGNATURE2)
//				) {
//                if (!initialized_ffi_types) initialize_ffi_types();
//                return &ffi_type_nsrect;
//            }
//            else if (
//					 !strcmp(typeString, NSRANGE_SIGNATURE) ||
//					 !strcmp(typeString, NSRANGE_SIGNATURE1)
//					 ) {
//                if (!initialized_ffi_types) initialize_ffi_types();
//                return &ffi_type_nsrange;
//            }
//            else if (
//					 !strcmp(typeString, NSPOINT_SIGNATURE0) ||
//					 !strcmp(typeString, NSPOINT_SIGNATURE1) ||
//					 !strcmp(typeString, NSPOINT_SIGNATURE2) ||
//					 !strcmp(typeString, CGPOINT_SIGNATURE)
//					 ) {
//                if (!initialized_ffi_types) initialize_ffi_types();
//                return &ffi_type_nspoint;
//            }
//            else if (
//					 !strcmp(typeString, NSSIZE_SIGNATURE0) ||
//					 !strcmp(typeString, NSSIZE_SIGNATURE1) ||
//					 !strcmp(typeString, NSSIZE_SIGNATURE2) ||
//					 !strcmp(typeString, CGSIZE_SIGNATURE)
//					 ) {
//                if (!initialized_ffi_types) initialize_ffi_types();
//                return &ffi_type_nssize;
//            }
//            else {
//                NSLog(@"unknown type identifier %s", typeString);
//                return &ffi_type_void;
//            }
//        }
        default:
        {
            NSLog(@"unknown type identifier %s", typeString);
            return &ffi_type_void;                // urfkd
        }
    }
}

void sayHello() {
	printf("Hell Yess\n");
}

- (void)experiment {
	
	printf("Entering\n");
	
    ffi_cif *cif = (ffi_cif *)malloc(sizeof(ffi_cif));
	ffi_type** args = NULL;
	void** values = NULL;
	int	effectiveArgumentCount = 0;
	
	void *callAddress = dlsym( RTLD_DEFAULT, "sayHello" );
	
	if( callAddress ) {
		//		if(effectiveArgumentCount > 0)
		//		{
		//			args = malloc(sizeof(ffi_type*)*effectiveArgumentCount);
		//			values = malloc(sizeof(void*)*effectiveArgumentCount);
		//		}
		// Get return value holder
		//		id returnValue = [argumentEncodings objectAtIndex:0];
		
		// Allocate return value storage if it's a pointer
		//		if ([returnValue typeEncoding] == '^')
		//			[returnValue allocateStorage];
		
		// Setup ffi
		ffi_type returnType = ffi_type_void;
		ffi_status prep_status = ffi_prep_cif( cif, FFI_DEFAULT_ABI, effectiveArgumentCount, &returnType, args );
		
		//
		// Call !
		//
		if( prep_status==FFI_OK )
		{
			void* returnStorage = NULL;
			//			void* storage = [returnValue storage];
			//			if ([returnValue ffi_type] == &ffi_type_void)	
			//				storage = NULL;
			ffi_call( cif, callAddress, returnStorage, values );
		}
		
		//		if (effectiveArgumentCount > 0)	
		//		{
		//			free(args);
		//			free(values);
		//		}
		//		if (prep_status != FFI_OK)
		//			return	throwException(ctx, exception, @"ffi_prep_cif failed"), NULL;
		
		// Return now if our function returns void
		// Return null as a JSValueRef to avoid crashing
		//		if ([returnValue ffi_type] == &ffi_type_void)	
		//			return	JSValueMakeNull(ctx);
		
		
	}
	free(cif);
}

NSUInteger hooFakeAutoreleasePoolCount( id fuck ) {
	NSLog(@"arg is %@", fuck);
	return 255;
}

- (void)releasePoolExperiment {
	
	char *resultObjcType = "i";
    ffi_type *result_type = ffi_type_for_objc_type(resultObjcType);
	void *result_value = value_buffer_for_objc_type(resultObjcType);
	unsigned int effectiveArgumentCount = 1;

    ffi_cif *cif = (ffi_cif *)malloc(sizeof(ffi_cif));

	ffi_type **argument_types = (ffi_type **) malloc (effectiveArgumentCount * sizeof(ffi_type *));
	void **argument_values = (void **) malloc (effectiveArgumentCount * sizeof(void *));
	
//	http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
	char *arg1Type = "@";
//	method_getArgumentType(m, i, &arg_type_buffer[0], BUFSIZE);

	argument_types[0] = ffi_type_for_objc_type(arg1Type);
	argument_values[0] = value_buffer_for_objc_type(arg1Type);
	*((id *) argument_values[0]) = self;
	
	void *callAddress = dlsym( RTLD_DEFAULT, "hooFakeAutoreleasePoolCount" );
	if( callAddress ) {
		ffi_status prep_status = ffi_prep_cif( cif, FFI_DEFAULT_ABI, effectiveArgumentCount, result_type, argument_types );
		if( prep_status==FFI_OK ) {
			ffi_call( cif, callAddress, result_value, argument_values );
			NSUInteger result = *((NSUInteger *)result_value);
			NSLog(@"Mutha fucker %i", result);
		}
	}
	free(cif);
	free(argument_types);
	free(argument_values[0]);
	free(argument_values);
	free(result_value);
}

- (void)releasePoolExperiment2 {
	
	[self retain];
	[self autorelease];
	
	char *resultObjcType = "i";
    ffi_type *result_type = ffi_type_for_objc_type(resultObjcType);
	void *result_value = value_buffer_for_objc_type(resultObjcType);
	unsigned int effectiveArgumentCount = 1;
	
    ffi_cif *cif = (ffi_cif *)malloc(sizeof(ffi_cif));
	
	ffi_type **argument_types = (ffi_type **) malloc (effectiveArgumentCount * sizeof(ffi_type *));
	void **argument_values = (void **) malloc (effectiveArgumentCount * sizeof(void *));
	
	//	http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
	char *arg1Type = "@";
	//	method_getArgumentType(m, i, &arg_type_buffer[0], BUFSIZE);
	
	argument_types[0] = ffi_type_for_objc_type(arg1Type);
	argument_values[0] = value_buffer_for_objc_type(arg1Type);
	*((id *) argument_values[0]) = self;
	
	void *callAddress = dlsym( RTLD_DEFAULT, "NSAutoreleasePoolCountForObject" );
	if( callAddress ) {
		ffi_status prep_status = ffi_prep_cif( cif, FFI_DEFAULT_ABI, effectiveArgumentCount, result_type, argument_types );
		if( prep_status==FFI_OK ) {
			ffi_call( cif, callAddress, result_value, argument_values );
			NSUInteger result = *((NSUInteger *)result_value);
			NSLog(@"Mutha fucker %i", result);
		}
	}
	free(cif);
	free(argument_types);
	free(argument_values[0]);
	free(argument_values);
	free(result_value);
}

- (void)awakeFromNib {
	[self experiment];
	[self releasePoolExperiment];
	[self releasePoolExperiment2];

}

@end
