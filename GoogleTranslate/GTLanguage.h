//
//  GTLanguage.h
//  GoogleTranslate
//

/*
 *  Copyright (c) 2014, Wayne Hartman
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 *
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 *
 *  * Neither the name of Wayne Hartman nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

/*!
 *  Object representing a language to be used in translation
 *  @discussion This class is key/value coding compliant and may be serialized.
 */
@interface GTLanguage : NSObject <NSCoding>

/*!
 *  Language code needed by the API to determine source and destination translation
 */
@property (nonatomic, strong) NSString *languageCode;

/*!
 *  Display name used for user interfaces
 */
@property (nonatomic, strong) NSString *name;

/*!
 *  Used for comparing GTLanguage objects.
 *  @param language the language object to compare to the receiver
 *  @return Boolean whether the objects are equal or not
 *  @discussion Internally, only the language code will be compared for equality
 */
- (BOOL)isEqualToLanguage:(GTLanguage *)language;

/*!
 *  Initializer for GTLanguage instance
 *  @param languageCode The language code to be used to initialize the instance
 *  @return fully initialized instance with the given parameters
 */
- (instancetype)initWithLanguageCode:(NSString *)languageCode;

/*!
 *  Initializer for GTLanguage instance
 *  @param languageCode The language code to be used to initialize the instance
 *  @param name The user-friendly display name for the language
 *  @return fully initialized instance with the given parameters
 */
- (instancetype)initWithLanguageCode:(NSString *)languageCode name:(NSString *)name;

@end
