//
//  DemangleTests.m
//  MachoLoader
//
//  Created by Steven Hooley on 26/08/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//


@interface DemangleTests : SenTestCase {
	
}

@end

@implementation DemangleTests

extern char *__cxa_demangle(const char* __mangled_name, char* __output_buffer, size_t* __length, int* __status);

- (void)testDemangleSomeShit {
	
//	__ZNSs9push_backEc
//	__ZNSt12out_of_rangeC1ERKSs
//	__ZNSs6insertEN9__gnu_cxx17__normal_iteratorIPcSsEEc
//	__ZNSs13_S_copy_charsEPcN9__gnu_cxx17__normal_iteratorIS_SsEES2_
//	__ZNSs7replaceEN9__gnu_cxx17__normal_iteratorIPcSsEES2_PKcS4_
	
	int demangledStat;
	char output[256];
	size_t length;
	
	char *demangledName = __cxa_demangle( "_ZNSt12out_of_rangeC1ERKSs", output, &length, &demangledStat);
	switch (demangledStat) {
		case 0:
			NSLog(@"Yaya");
			break;
		case -1:
			NSLog(@"Memory error");
			break;
		case -2:
			NSLog(@"not a mangled name");
			break;
		case -3:
			NSLog(@"invalid argument");
			break;
			
		default:
			break;
	}
	if(demangledName!=nil) {
		NSLog(@"yay %s",demangledName );
//		free(demangledName);
	}
}

@end
