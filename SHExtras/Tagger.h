//
//  Tagger.h
//  BBExtras
//
//  Created by Jonathan del Strother on 01/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* BBTagStart;
extern NSString* BBTagEnd;
extern NSString* BBTagAttributes;
extern NSString* BBTagName;
extern NSString* BBTagAttributes;

@interface Tagger : NSObject {
	NSString* string;
	
	NSMutableString* parsedString;
	NSMutableArray* tags;
	
	NSMutableArray* tagsInProgress;
}


-(id)initWithString:(NSString*)str;
-(void)setString:(NSString*)str;
-(void)parseString;
-(NSString*)parsedString;
-(NSArray*)tags;
@end
