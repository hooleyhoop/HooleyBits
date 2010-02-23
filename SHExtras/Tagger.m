//
//  Tagger.m
//  BBExtras
//
//  Created by Jonathan del Strother on 01/03/2006.
//  Copyright 2006 Best Before. All rights reserved.
//

#import "Tagger.h"

NSString* BBTagStart = @"BBTagStart";
NSString* BBTagEnd = @"BBTagEnd";
NSString* BBTagAttributes = @"BBTagAttributes";
NSString* BBTagName = @"BBTagName";

@implementation Tagger

-(id)initWithString:(NSString*)str
{
	if (![super init])
		return nil;
		
	[self setString:str];
		
	return self;
}

-(void)dealloc
{
	[string release];
	[tags release];
	[parsedString release];
	[super dealloc];
}


-(void)setString:(NSString*)str
{
	[string release];
	string = [[NSString stringWithFormat:@"<?xml version=\"1.0\"?><content>%@</content>", str] retain];

	[parsedString release];
	parsedString = nil;
	
	[tags release];
	tags = nil;	
}


-(void)parseString
{
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
	if (!parser)
	{
	//	NSLog(@"Couldn't create XML parser");
		return;
	}

	[parser setDelegate:self];
	
	[parser parse];
	
	[parser release];
}


-(NSString*)parsedString
{
	return [[parsedString copy] autorelease];
}

-(NSArray*)tags
{
NSLog([tags description]);
	return [[tags copy] autorelease];
}


- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	[tagsInProgress release];
	tagsInProgress = [[NSMutableArray alloc] init];
	
	[tags release];
	tags = [[NSMutableArray alloc] init];
	
	[parsedString release];
	parsedString = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[tagsInProgress release];
	tagsInProgress = nil;
	
	NSSortDescriptor* sorterStart = [[NSSortDescriptor alloc] initWithKey:BBTagStart ascending:YES];
	NSSortDescriptor* sorterEnd = [[NSSortDescriptor alloc] initWithKey:BBTagEnd ascending:NO];
	[tags sortUsingDescriptors:[NSArray arrayWithObjects:sorterStart, sorterEnd, nil]];
	[sorterStart release];
	[sorterEnd release];
}




// DTD handling methods for various declarations.
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	NSLog(@"notation declaration %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
	NSLog(@"unparsed entity declaration %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue
{
	NSLog(@"attribute declaration %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{
	NSLog(@"found element declaration %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value
{
	NSLog(@"Found internal entity %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID
{
	NSLog(@"found external entity %@", parser);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSMutableDictionary* newElement = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:[parsedString length]],BBTagStart,
		[elementName lowercaseString], BBTagName,
		attributeDict, BBTagAttributes, nil];
	[tagsInProgress addObject:newElement];	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//We've finished an element.  Pop it off the stack, and insert an immutable copy into the tags array.
	NSMutableDictionary* finishedElement = [tagsInProgress lastObject];
	[finishedElement setObject:[NSNumber numberWithInt:[parsedString length]] forKey:BBTagEnd];
	[tags addObject:finishedElement];
	[tagsInProgress removeLastObject];
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	NSLog(@"did start mapping %@", parser);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
	NSLog(@"did end mapping %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)chars
{
	[parsedString appendString:chars];
}
//
//- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
//{
//	NSLog(@"White space %@", parser);
//}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{
	NSLog(@"Unhandled - processing instruction : %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
	NSLog(@"%@", comment);
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
	NSLog(@"Unhandled - found CData :  %@", [[[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding] autorelease]);
}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
	NSLog(@"Unhandled - resolve external entity name :  %@", parser);
	return nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[parser abortParsing];
	NSLog(@"Parse error occurred at line %d:%d (%@)", [parser lineNumber], [parser columnNumber], [parseError localizedDescription]);
	[tagsInProgress release];
	tagsInProgress = nil;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	NSLog(@"validation error occurred: %@", validationError);
}


@end
