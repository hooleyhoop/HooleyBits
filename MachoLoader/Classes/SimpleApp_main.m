//
//  main.m
//  MachoLoader
//
//  Created by steve hooley on 23/02/2009.
//  Copyright BestBefore Ltd 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	printf("Hello World");
	NSLog(@"HaHaHa");
	[[NSOpenPanel openPanel] setResolvesAliases:YES];
	return 0xABCD;
}

// otool -t -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp 
(__TEXT,__text) section
start:
00001e3c	pushl	$0x00
00001e3e	movl	%esp,%ebp
00001e40	andl	$0xf0,%esp
00001e43	subl	$0x10,%esp
00001e46	movl	0x04(%ebp),%ebx
00001e49	movl	%ebx,0x00(%esp)
00001e4d	leal	0x08(%ebp),%ecx
00001e50	movl	%ecx,0x04(%esp)
00001e54	addl	$0x01,%ebx
00001e57	shll	$0x02,%ebx
00001e5a	addl	%ecx,%ebx
00001e5c	movl	%ebx,0x08(%esp)
00001e60	movl	(%ebx),%eax
00001e62	addl	$0x04,%ebx
00001e65	testl	%eax,%eax
00001e67	jne	0x100001e60
00001e69	movl	%ebx,0x0c(%esp)
00001e6d	calll	_main
00001e72	movl	%eax,0x00(%esp)
00001e76	calll	0x00001f38	; symbol stub for: _exit
00001e7b	hlt
dyld_stub_binding_helper:
00001e7c	calll	0x00001e81
00001e81	popl	%eax
00001e82	pushl	0x000001d3(%eax)
00001e88	movl	0x0000017f(%eax),%eax
00001e8e	jmp	*%eax
__dyld_func_lookup:
00001e90	calll	0x00001e95
00001e95	popl	%eax
00001e96	movl	0x0000016f(%eax),%eax
00001e9c	jmp	*%eax
_main:
00001e9e	pushl	%ebp
00001e9f	movl	%esp,%ebp
00001ea1	subl	$0x18,%esp
00001ea4	movl	$0x00001ef3,(%esp)
00001eab	calll	0x00001f44	; symbol stub for: _printf
00001eb0	movl	$0x00002034,(%esp)
00001eb7	calll	0x00001f32	; symbol stub for: _NSLog
00001ebc	movl	0x00003004,%eax
00001ec1	movl	%eax,0x04(%esp)
00001ec5	movl	0x00003008,%eax
00001eca	movl	%eax,(%esp)
00001ecd	calll	0x00001f3e	; symbol stub for: _objc_msgSend
00001ed2	movl	$0x00000001,0x08(%esp)
00001eda	movl	0x00003000,%edx
00001ee0	movl	%edx,0x04(%esp)
00001ee4	movl	%eax,(%esp)
00001ee7	calll	0x00001f3e	; symbol stub for: _objc_msgSend
00001eec	movl	$0x0000abcd,%eax
00001ef1	leave
00001ef2	ret

// otool -s __TEXT __cstring -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Contents of (__TEXT,__cstring) section
00001ef3  Hello World
00001eff  HaHaHa
00001f06  setResolvesAliases:
00001f1a  openPanel
00001f24  
00001f25  NSOpenPanel

// otool -s __TEXT __symbol_stub -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Contents of (__TEXT,__symbol_stub) section
00001f32	jmp	*0x00002024
00001f38	jmp	*0x00002028
00001f3e	jmp	*0x0000202c
00001f44	jmp	*0x00002030

// otool -s __DATA __nl_symbol_ptr -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleAp
Contents of (__DATA,__nl_symbol_ptr) section
Unknown section type (0x6)
0000201c	00 00 00 00 00 00 00 00 

// otool -s __DATA __la_symbol_ptr -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp 
Contents of (__DATA,__la_symbol_ptr) section
Unknown section type (0x7)
00002024	6e 1f 00 00 7e 1f 00 00 8e 1f 00 00 9e 1f 00 00 

// otool -s __DATA __cfstring -v _V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Contents of (__DATA,__cfstring) section
00002034	00 00 00 00 c8 07 00 00 ff 1e 00 00 06 00 00 00 

// otool -s __OBJC __message_refs -v /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Contents of (__OBJC,__message_refs) section
00003000  __TEXT:__cstring:setResolvesAliases:
00003004  __TEXT:__cstring:openPanel

// otool -s __OBJC __cls_refs -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Contents of (__OBJC,__cls_refs) section
00003008  __TEXT:__cstring:NSOpenPanel

// otool -I -v -V /Users/shooley/Desktop/Programming/Cocoa/HooleyBits/MachoLoader/build/Release/SimpleApp.app/Contents/MacOS/SimpleApp
Indirect symbols for (__TEXT,__symbol_stub) 4 entries
address    index name
0x00001f32    20 _NSLog
0x00001f38    22 _exit
0x00001f3e    23 _objc_msgSend
0x00001f44    24 _printf
Indirect symbols for (__DATA,__nl_symbol_ptr) 2 entries
address    index name
0x0000201c ABSOLUTE
0x00002020 ABSOLUTE
Indirect symbols for (__DATA,__la_symbol_ptr) 4 entries
address    index name
0x00002024    20 _NSLog
0x00002028    22 _exit
0x0000202c    23 _objc_msgSend
0x00002030    24 _printf

