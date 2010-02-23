//
//  RSSReader+XMLParser.m
//  QuartzXML
//
//  Created by Jonathan del Strother on 02/02/2006.
//  Copyright 2006 Best Before Media Ltd. All rights reserved.
//

#import "RSSReader+XMLParser.h"

static NSString* StringContents = @"__JDS__String_Contents";

@implementation RSSReader (XMLParser)

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	[xmlElements release];
	xmlElements = [[NSMutableArray alloc] init];
	[xmlElements addObject:[NSMutableDictionary dictionary]];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	if ([xmlElements count]!=1)
	{
		[self setErrorMessage:[NSString stringWithFormat:@"Finished reading %@, file isn't finished (%@)", url, xmlElements]];
		return;
	}
	
	[xmlDictionary release];
	xmlDictionary = [[xmlElements objectAtIndex:0] copy];
	
	[xmlElements release];
	xmlElements = nil;
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
	NSMutableDictionary* newElement = [NSMutableDictionary dictionary];
	[xmlElements addObject:newElement];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//We've finished an element.  Pop it off the stack...
	NSMutableDictionary* finishedElement = [xmlElements lastObject];
	[xmlElements removeLastObject];
	//And insert an immutable copy into the parent dictionary.
	id finishedContents;
	
	if (([finishedElement objectForKey:StringContents]!= nil)&&([finishedElement count]==1))
	{	
		//If the latest element only contains StringContents, then it's a leaf node - use the string contents.
		finishedContents = [[finishedElement objectForKey:StringContents] copy];
	}
	else if ([finishedElement count] == 0)		//Empty node : just use an empty string:
	{
		finishedContents = [@"" copy];
	}
	else
	{
		//Otherwise, strip out the StringContents and use the rest of the dictionary contents
		[finishedElement removeObjectForKey:StringContents];
		finishedContents = [finishedElement copy];
	}
	
	
	//Insert the new element into its parent:
	NSMutableDictionary* parentElement = [xmlElements lastObject];	
	if ([parentElement objectForKey:elementName] == nil)
	{
		//We don't have anything with the same element name yet.  Just insert the new element : 
		[parentElement setObject:finishedContents forKey:elementName];
	}
	else
	{
		//We're about to overwrite the existing element.  Oops.
		//So, grab the existing one and convert it to an array which is going to contain all of the matching elements (if we haven't already converted, that is.)
		id existingElement = [parentElement objectForKey:elementName];
		if (![existingElement isKindOfClass:[NSMutableArray class]])
		{
			[parentElement setObject:[NSMutableArray arrayWithObject:existingElement] forKey:elementName];
		}
		NSMutableArray* arrayOfExistingElements = [parentElement objectForKey:elementName];
		[arrayOfExistingElements addObject:finishedContents];
	}

	
	[finishedContents release];
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{
	NSLog(@"did start mapping %@", parser);
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{
	NSLog(@"did end mapping %@", parser);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	NSMutableDictionary* currentElement = [xmlElements lastObject];
	NSMutableString* stringContents = [currentElement objectForKey:StringContents];
	if (!stringContents)
	{
		[currentElement setObject:[NSMutableString string] forKey:StringContents];
		stringContents = [currentElement objectForKey:StringContents];
	}
	
	[stringContents appendString:string];
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
	[self setErrorMessage:[NSString stringWithFormat:@"Parse error occurred at line %d:%d (%@)", [parser lineNumber], [parser columnNumber], [parseError localizedDescription]]];
	[xmlElements release];
	xmlElements = nil;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
	NSLog(@"validation error occurred: %@", validationError);
}


@end
