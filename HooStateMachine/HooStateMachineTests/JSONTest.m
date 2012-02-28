//
//  JSONTest.m
//  HooStateMachine
//
//  Created by Steven Hooley on 22/05/2011.
//  Copyright 2011 AudioBoo. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <SBJson/SBJson.h>


@interface JSONTest : SenTestCase {
@private
    
}

@end

@implementation JSONTest

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    
    [super tearDown];
}

- (void)testJSON {
    
    NSString *json_string = @"{"
    "\"glossary\": {"
    "   \"title\": \"example glossary\","
    "   \"GlossDiv\": {"
    "       \"title\": \"S\","
    "       \"GlossList\": {"
    "           \"GlossEntry\": {"
    "               \"ID\": \"SGML\","
    "               \"SortAs\": \"SGML\","
    "               \"GlossTerm\": \"Standard Generalized Markup Language\","
    "               \"Acronym\": \"SGML\","
    "               \"Abbrev\": \"ISO 8879:1986\","
    "               \"GlossDef\": {"
    "                   \"para\": \"A meta-markup language, used to create markup languages such as DocBook.\","
    "                   \"GlossSeeAlso\": [\"GML\", \"XML\"]"
    "               },"
    "               \"GlossSee\": \"markup\""
    "              }"
    "           }"
    "         }"
    "     }"
    "}";
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSError *error = nil;    
    NSDictionary *object = [parser objectWithString:json_string error:&error];
    STAssertTrue([[object allKeys] count]>0, nil);
    NSLog(@"%@", [object allKeys]);
}

@end
