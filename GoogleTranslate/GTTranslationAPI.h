//
//  GTTranslationAPI.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

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
