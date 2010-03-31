//
//  TextStyle.h
//  BBExtras
//
//  Created by Jonathan del Strother on 02/03/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TextStyle : NSObject {
   UniCharArrayOffset styleStart;
   UniCharCount styleLength;
   
   NSString* tagName;
   
   ATSUStyle* previousStyle;
   
   BOOL applyFontName;
   NSString* fontName;
   
   BOOL applyKerning;
   float kerning;
   
   BOOL applyPointSize;
   float pointSize;
   
   BOOL applyColor;
   NSColor* color;
   
   float glowSize;
   NSColor* glowColor;
   
   BOOL bold, italic, underline;
}

+(id)styleWithTag:(NSDictionary*)tag;
-(id)initWithTag:(NSDictionary*)tag;
//-(id)initByCopyingStyle:(ATSUStyle)style;
-(void)setStyleStart:(UniCharArrayOffset)start length:(UniCharCount)length;
-(void)setColor:(NSColor*)color;
-(void)setGlowColor:(NSColor*)targetColor;
-(void)setGlowSize:(float)size;
-(void)setPointSize:(float)size;
-(void)setFontName:(NSString*)newFont;
-(void)setKerning:(float)newValue;
-(void)applyToLayout:(ATSUTextLayout)layout;
-(double)padding;
@end

