/*Copyright (c) 2003 Andrew Thompson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of
the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "UFIStringAdditions.h"

static unichar  UFI_LEFT_DOUBLE_ANGLE_QUOTATION_MARK = 0x00AB;	// Ç
static unichar  UFI_RIGHT_DOUBLE_ANGLE_QUOTATION_MARK = 0x00BB;// È
static NSString *UFI_APPLESCRIPT_DATA_HEADER = @"data utxt";

@implementation NSString (UFIStringAdditions)

- (NSString *) toUCS2Digits {
    NSMutableString *result = [[[NSMutableString alloc] initWithCapacity: [self length]] autorelease];
    int i=0;

    for (i=0; i < [self length]; i++) {
        unichar curr= [self characterAtIndex: i];
        [result appendString: [NSString stringWithFormat: @"%04X", curr]];
    }
    return result;
}

- (NSString *) toAppleScriptData {
    return [NSString stringWithFormat: @"%@%@%@%@",
        [NSString stringWithCharacters: &UFI_LEFT_DOUBLE_ANGLE_QUOTATION_MARK length: 1],
        UFI_APPLESCRIPT_DATA_HEADER,
        [self toUCS2Digits],
        [NSString stringWithCharacters: &UFI_RIGHT_DOUBLE_ANGLE_QUOTATION_MARK length: 1]];
}

+ (id) stringWithUTF32Characters: (const UTF32Char *) a_chars length: (unsigned) a_length {
    NSParameterAssert(a_chars != nil);
    NSParameterAssert(a_length >= 0);    
    NSMutableData *buf = [NSMutableData dataWithCapacity: a_length];
    int i=0;
    UTF32Char curr;
    UniChar chars[2];
    
    for (i=0; i < a_length; i++) {
        curr = a_chars[i];
        //need to convert to surrogate pair, if outside BMP
        if ( curr <= 0x10000 ) {
            curr = curr << 16;
            [buf appendBytes: &curr length: 2];
        } else {
            //See Unicode Standard Section 3.7 Surrogates           
            chars[0] = (curr - 0x10000) / 0x400 + 0xD800;
            chars[1] = (curr - 0x10000) % 0x400 + 0xDC00;
            [buf appendBytes: chars length: 4];            
        }
    }
    return [[[NSString alloc] initWithData: buf encoding: NSUnicodeStringEncoding] autorelease];
}

- (const UTF32Char *) UTF32String {
    int sourceIndex=0, destIndex=0;
    UTF32Char *result = NSZoneCalloc(NSDefaultMallocZone(), [self length] + 1, sizeof(UTF32Char));    
    if (!result) {
        [NSException raise: NSMallocException format: @"Insufficient memory for UTF32 character buffer"];
    }

    NS_DURING    
        //See Unicode Standard Section 3.7 Surrogates
        unsigned int used;
        for(destIndex=0; sourceIndex < [self length]; destIndex++) {
            result[destIndex] = [self UTF32CharAtIndex: sourceIndex length: &used];
            sourceIndex += used;
        }
        result[destIndex] = (UTF32Char) '\0';
        NS_VALUERETURN(result, const UTF32Char *);
    NS_HANDLER
        if ([[localException name] isEqualToString:NSRangeException]) {
            NSZoneFree(NSDefaultMallocZone(), result);            
        }
        [localException raise]; /* Re-raise the exception. */        
    NS_ENDHANDLER
    NSAssert(NO, @"Not Reached");
    return nil;
}

- (UTF32Char) UTF32CharAtIndex: (unsigned int) a_index {
    unsigned int ignore;
    return [self UTF32CharAtIndex: a_index length: &ignore];
}

- (UTF32Char) UTF32CharAtIndex: (unsigned int) a_index length: (unsigned int *) a_outLength {
    NSParameterAssert(a_outLength);
    //See Unicode Standard Section 3.7 Surrogates
    UniChar high = [self characterAtIndex: a_index];
    UTF32Char result;

    if (high >= 0xD800 && high <= 0xDBFF) {
        UniChar low = [self characterAtIndex: a_index + 1];
        if (low < 0xDC00 || low > 0xDFFF) {
            [NSException raise: NSRangeException format: @"Low char out of range (not a surrogate pair): %d", low];
        }
        result = (high - 0xD800) * 0x400 + (low - 0xDC00) + 0x10000;
        *a_outLength = 2;
    } else {
        result = (UTF32Char) high;
        *a_outLength = 1;
    }
    return result;
}
@end
