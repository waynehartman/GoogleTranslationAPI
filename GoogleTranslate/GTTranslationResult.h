//
//  GTTranslationResult.h
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
 *  Object representing a translation result returned by the translate service
 */
@interface GTTranslationResult : NSObject

/*!
 *  The text returned by the translation service
 */
@property (nonatomic, strong) NSString *text;

/*!
 *  The detected language from the supplied text.
 *  @discussion This property may only be set when the translate API is not given the source language.  The code returned may be used to create GTLanguage objects.  Note that the API will not return to the display name of the language.
 */
@property (nonatomic, strong) NSString *detectedLanguageCode;

/*!
 *  Initializer for creating GTTranslationResult instances
 *  @param text The text of the translation
 *  @param detectedLanguageCode the language code that was detected during the translation process
 */
- (instancetype)initWithText:(NSString *)text detectedLanguageCode:(NSString *)detectedLanguageCode;

@end
