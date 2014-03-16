//
//  GTTranslationAPI.h
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
#import "GTLanguage.h"
#import "GTLanguageDetectionResult.h"
#import "GTTranslationResult.h"

typedef void(^GTTranslateCompletionHandler)(NSArray *translations, NSError *error);
typedef void(^GTDetectLanguageCompletionHandler)(NSArray *detectionResults, NSError *error);
typedef void(^GTLanguageAvailabilityCompletionHandler)(NSArray *languages, NSError *error);

typedef NS_ENUM(NSInteger, GTTranslationError) {
    GTTranslationErrorValidationMissingKey                  = -1000,
    GTTranslationErrorValidationInvalidText                 = -1001,
    GTTranslationErrorValidationMissingDestinationLanguage  = -1002,
    GTTranslationAPIErrorGeneric                            = -2000
};

/*!
 *  Main class for interacting the Google Translate API
 */
@interface GTTranslationAPI : NSObject

/*!
 *  Designated initializer for a GTTranslationAPI instance
 *  @param The Google Translate API key issued to you for making API calls
 */
- (instancetype)initWithApiKey:(NSString *)key;

/*!
 *  Translate text
 *  @param text the text to be translated
 *  @param sourceLanguage the source language to be used in the translation (optional)
 *  @param destinationLanguage the destination language to be translated into
 *  @param completionHandler block to be called when the API call is complete.
 *  @discussion If the sourceLanguage parameter is nil, the translation service will attempt to detect what the language is.
 */
- (void)translateText:(NSString *)text usingSourceLanguage:(GTLanguage *)sourceLanguage destinationLanguage:(GTLanguage *)destinationLanguage withCompletionHandler:(GTTranslateCompletionHandler)completionHandler;

/*!
 *  Detect language from the specified text
 *  @param text the text to be used to detect what language is being used
 *  @param completionHandler block to be called when the API call is complete
 */
- (void)detectLanguageFromText:(NSString *)text completionHandler:(GTDetectLanguageCompletionHandler)completionHandler;

/*!
 *  Retreive all the available languages to be used with the Google Translate API
 *  @param fetchFromLocalCache Flag for specifying if the values should be fetched from the local cache
 *  @param languageCode The language code to specify in which language should the list be in (optional)
 *  @param completionHandler block to be called when the API call is complete
 *  @discussion If no langauge code is specifed, then a default of "en" (English) is used.
 *
 */
- (void)fetchAvailableTranslationLanguagesUsingLocalCache:(BOOL)fetchFromLocalCache forTargetLanguageCode:(NSString *)languageCode withCompletionHandler:(GTLanguageAvailabilityCompletionHandler)completionHandler;

@end
