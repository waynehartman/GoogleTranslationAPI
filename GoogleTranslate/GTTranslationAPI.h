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

@interface GTTranslationAPI : NSObject

- (instancetype)initWithApiKey:(NSString *)key;

- (void)translateText:(NSString *)text usingSourceLanguage:(GTLanguage *)sourceLanguage destinationLanguage:(GTLanguage *)destinationLanguage withCompletionHandler:(GTTranslateCompletionHandler)completionHandler;
- (void)detectLanguageFromText:(NSString *)text completionHandler:(GTDetectLanguageCompletionHandler)completionHandler;
- (void)fetchAvailableTranslationLanguagesUsingLocalCache:(BOOL)fetchFromLocalCache forTargetLanguageCode:(NSString *)languageCode withCompletionHandler:(GTLanguageAvailabilityCompletionHandler)completionHandler;

@end
