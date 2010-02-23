//
//  Atsui.h
//
//  Created by Jonathan del Strother on 11/09/2005.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef UInt32 BBTextAlignment;
enum {
	kTextAlignLeft,
	kTextAlignCenter,
	kTextAlignRight,
	kTextAlignJustified
};

@class TextStyle;

@interface Atsui : NSObject {
	NSData* textureData;
	NSSize textureSize;
	int imageHeight;

	float leading;
	float lineBreakWidth;
	float displayPercentage;	//Usually 1.00, unless we're doing a l-to-r reveal of text, when it will increment over time from 0 to 1.
	
	BBTextAlignment textAlignment;
	
	BOOL textureNeedsRefresh;
	BOOL maryDaleHack;
	
	NSString* text;
	UniChar					*uniText;
	UniCharCount			textLength;
	
	NSArray* styleTags;
	TextStyle* style;
	ATSUTextLayout layout;
	ATSUStyle baseStyle;
	
	unsigned int maxTextureSize;
	int lineCount;	// Used to output to QC the number of lines used
	
	BOOL technicolor, htmlEnabled;
	
	unsigned char* buffer;
	size_t bufferSize;
}
-(id)initWithString:(NSString*)string;

-(void)setDisplayPercentage:(float)_displayPercent;
-(void)setLineBreakWidth:(float)_lineBreakWidth;
-(void)setImageHeight:(float)_height;
-(void)setFontName:(NSString*)fontName;
-(void)setColor:(NSColor*)color;
-(void)setColorEnabled:(BOOL)val;
-(void)setHTMLEnabled:(BOOL)val;
-(BOOL)htmlEnabled;
-(void)setGlowColor:(NSColor*)targetColor;
-(void)setGlowSize:(float)size;
-(void)setPointSize:(float)size;
-(void)setLeading:(float)newValue;
-(void)setKerning:(float)newValue;
-(void)setString:(NSString*)text;
-(void)setTextAlignment:(BBTextAlignment)_alignment;
-(void)setMaxTextureSize:(unsigned int)maxTextureSize;
-(NSSize)textBounds;
-(NSSize)textBoundsForString:(NSString*)str;
-(UInt32)offsetForPosition:(NSPoint)pos;

-(NSData*)dataBuffer;
-(BOOL)textureNeedsRefresh;
-(NSSize)textureSize;
-(BOOL)colorEnabled;
-(int)lineCount;
@end
