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

#import <Cocoa/Cocoa.h>

/*! @category 	NSString (UFIStringAdditions)
    @abstract   Adds methods for creating and converting <code>NSString</code> instances between different encodings.
    @discussion Enables easy interoperability with AppleScript, UCS2 and UTF-32 encodings
*/
@interface NSString (UFIStringAdditions)

/*! @method toUCS2Digits
    @abstract Convert the string into the digits that a Unicode UCS-2 implementation of the string would need.
    @discussion	Each character is represented as 4 hexadecimal digits (ie, every character is 2 bytes long).
        This doesn't convert to UCS-2 encoding per-se, but the digits in the new NSString returned are the digits
        that would make up a UCS-2 encoded string. The result has been auto-released.
    @result a new NString consisting of the digits that represent this NSString if it were encoded in UCS-2 encoding.
 */
- (NSString *) toUCS2Digits;

/*! @method toAppleScriptData:
    @abstract Convert the string to an Apple Script <code>Data</code> class instance.
    @discussion The contents of the object is a UCS-2 encoded string that AppleScript can understand as Unicode data.
                (AppleScript doesn't understand the UTF-16 style encoding NSString will typically use, not does it get UTF-8).
    @result a new autoreleased NSString whose contents can be inserted into an Apple Script as a string literal. AppleScript will
    understand this string as <code>Unicode Text</code>.
 */
- (NSString *) toAppleScriptData;

/*! @method 	stringWithUTF32Characters:length:
    @abstract   Create a string from 32bit Unicode data.
    @discussion Constructs a new <code>NSString</code> instance from the given buffer of 32 bit character data.
                The characters in the buffer will be converted to 16-bit (UTF16) format for storage in the string.
                Characters above 65535 decimal will be converted to surrogate pairs.
    @param      a_chars buffer of characters to use for the string
    @param 	a_length the number of characters in the buffer
    @result	a new <code>NSString</code> object with the data provided
 */
+ (id) stringWithUTF32Characters: (const UTF32Char *) a_chars length: (unsigned) a_length;

/*! @method 	UTF32String
    @abstract   Extract 32 bit Unicode data from an <code>NSString</code> instance.
    @discussion Gets a UTF32 cgaracter buffer from an <code>NSString</code>. Since <code>NSString</code> instances are UTF16
                internally, any surrogate pairs in the string are converted to full 32 bit chars.
    @result	a UTF32 representation of the <code>NSString</code>
 */
- (const UTF32Char *) UTF32String;

/*! @method 	UTF32CharAtIndex
    @abstract   Get a <code>UTF32Char</code> from the given index.
    @discussion Get a <code>UTF32Char</code> from the given index. Raises an <code>NSRangeException</code> if
    <code>a_index</code> lies beyond the end of the receiver
    @param a_index the indes to get the character from
    @result	the character at <code>a_index</code>
 */
- (UTF32Char) UTF32CharAtIndex: (unsigned int) a_index;

 /*! @method 	UTF32CharAtIndex:length
    @abstract   Get a <code>UTF32Char</code> from the given index.
    @discussion Get a <code>UTF32Char</code> from the given index. Raises an <code>NSRangeException</code> if
        <code>a_index</code> lies beyond the end of the receiver
    @param a_index the indes to get the character from
    @param a_outLength the number of characters consumed from the receiver at the requested index. Will be 1 or 2 depending
         on whether the character at the index is a simple UTF-16 char, or a surrogate pair
    @result	the character at <code>a_index</code>
 */
- (UTF32Char) UTF32CharAtIndex: (unsigned int) a_index length: (unsigned int*) a_outLength;

@end
