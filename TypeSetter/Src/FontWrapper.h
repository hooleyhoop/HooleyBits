//
//  FontWrapper.h
//  TypeSetter
//
//  Created by Steven Hooley on 31/05/2010.
//  Copyright 2010 Tinsal Parks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FontWrapper : NSObject {
	
	CTFontRef _iFont;
	uint16 _numberOfGlyphs;
	int16_t _indexToLocFormat;
}

CTFontRef CreateFont( CTFontDescriptorRef iFontDescriptor, CGFloat iSize );
CTFontDescriptorRef CreateFontDescriptorFromName( CFStringRef iPostScriptName, CGFloat iSize );

+ (NSString *)randomFontName;
+ (void)getRandomFont:(CTFontRef *)iFont size:(CGFloat)floatSize;

- (void)inspectFont:(NSString *)fontName glyph:(NSString *)glyph size:(CGFloat)size;


#pragma mark -
- (id)initWithName:(NSString *)arg1 size:(CGFloat)arg2;

@end
