//
//  BNZHex.h
//  BNZHex
//
// Created by Trevor Johns
/*
 Copyright (c) 2006, Big Nerd Ranch, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Big Nerd Ranch, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#import <Foundation/Foundation.h>

/*!
 @category    BNZHex
 @abstract    Adds support to NSData for reading and writing hexadecimal 
 strings.
 @discussion  This category allows the conversion of NSData objects to and
 from NSStrings containing hexadecimal characters.
 
 When converting from an NSString, it is assumed that the 
 string does not begin with '0x', and does not contain any
 special formatting, such as spaces or dashes. Invalid 
 characters are considered equivilent to 0x0. In the event the 
 string does not contain an even number of characters, an extra 
 0x0 will be prepended to the string so that the binary 
 equivilent representation fits within byte boundaries.
 
 Likewise, when when converting to an NSString, no special 
 formatting will be applied. If this is desired, you may want 
 to instead use the [NSData description] method.
 */

@interface NSData (BNZHex)
/*!
 @method      dataWithHexString:
 @abstract    Request an autoreleased NSData object from a hexadecimal string.
 @discussion  This function returns an autoreleased NSData containing
 the binary representation of hexString.
 @param       hexString The hexadecimal string from which the data object 
 will be created.
 @result      A data object containing the binary representation of hexString.
 */
+ (NSData *) dataWithHexString: (NSString *)hexString;

/*!
 @method      initWithHexString:
 @abstract    Initialize a new NSData object with a hexadecimal string.
 @discussion  This function initializes a new NSData object, filling it's 
 buffer with the binary representation of hexString.
 @param       hexString The hexadecimal string from which the data object 
 will be initialized.
 @result      A data object containing the binary representation of hexString.
 */
- (NSData *) initWithHexString: (NSString *)hexString;

/*!
 @method      hexString:
 @abstract    Get the hexadecimal representation of an NSData object.
 @discussion  This function will convert the contents of a data object into 
 hexadecimal, without applying any special formatting.
 @result      An autoreleased NSString containg the hexadecimal 
 representation of the data object.
 */
- (NSString *) hexString;
@end