//
//  GTTranslationAPI.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTTranslationAPI.h"
#import "GTLanguage.h"
#import "GTLanguageDetectionResult.h"
#import "GTLanguageCache.h"
#import "AFNetworking.h"

@interface GTTranslationAPI ()

@property (nonatomic, strong) NSString *apiKey;

@end

#define ERROR_DOMAIN_GOOGLE_TRANSLATE @"GTTranslationErrorDomain"
#define DEFAULT_LANGUAGE_CODE @"en"

#define API_URL_GET_LANGUAGES       @"https://www.googleapis.com/language/translate/v2/languages"
#define API_URL_DETECT_LANGUAGE     @"https://www.googleapis.com/language/translate/v2/detect"
#define API_URL_TRANSLATE_TEXT      @"https://www.googleapis.com/language/translate/v2"

#define PARM_KEY_APIKEY                 @"key"
#define PARM_KEY_LANGUAGE_TARGET        @"target"
#define PARM_KEY_DETECTION_TEXT         @"q"
#define PARM_KEY_SOURCE_LANGUAGE        @"source"
#define PARM_KEY_DESTINATION_LANGUAGE   @"target"

@implementation GTTranslationAPI

#pragma mark - Initialization

- (instancetype)initWithApiKey:(NSString *)key {
    if ((self = [super init])) {
        _apiKey = key;
    }

    return self;
}

#pragma mark - Public API

- (void)translateText:(NSString *)text usingSourceLanguage:(GTLanguage *)sourceLanguage destinationLanguage:(GTLanguage *)destinationLanguage withCompletionHandler:(GTTranslateCompletionHandler)completionHandler {
    NSError *preValidationError = nil;
    
    if (![self passesPrevalidationTranslationForText:text error:&preValidationError]) {
        if (completionHandler) {
            completionHandler(nil, preValidationError);
        }
        return;
    } else if (destinationLanguage == nil || destinationLanguage.languageCode == nil) {
        if (completionHandler) {
            completionHandler(nil, [self errorWithErrorCode:GTTranslationErrorValidationMissingDestinationLanguage]);
        }
    } else {    // Passes validation
        NSDictionary *parameters = @{
                                     PARM_KEY_APIKEY : self.apiKey,
                                     PARM_KEY_DETECTION_TEXT : text,
                                     PARM_KEY_DESTINATION_LANGUAGE : destinationLanguage.languageCode
                                     };
        
        if (sourceLanguage.languageCode) {
            NSMutableDictionary *mutableParms = [parameters mutableCopy];
            mutableParms[PARM_KEY_SOURCE_LANGUAGE] = sourceLanguage.languageCode;

            parameters = mutableParms;
        }

        void(^failureHandler)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        };
        
        void(^successHandler)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = [self errorFromDictionary:responseObject];
            
            if (error) {
                failureHandler(operation, error);
            } else {
                if (completionHandler) {
                    NSArray *results = [self translationResultsFromDictionary:responseObject];
                    completionHandler(results, nil);
                }
            }
        };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:API_URL_TRANSLATE_TEXT parameters:parameters success:successHandler failure:failureHandler];
    }
}

- (void)detectLanguageFromText:(NSString *)text completionHandler:(GTDetectLanguageCompletionHandler)completionHandler {
    NSError *preValidationError = nil;

    if (![self passesPrevalidationTranslationForText:text error:&preValidationError]) {
        if (completionHandler) {
            completionHandler(nil, preValidationError);
        }

        return;
    } else {    // Passes validation
        NSDictionary *parameters = @{
                                     PARM_KEY_APIKEY : self.apiKey,
                                     PARM_KEY_DETECTION_TEXT : text
                                     };

        void(^failureHandler)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completionHandler) {
                completionHandler(nil, error);
            }
        };

        void(^successHandler)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSError *error = [self errorFromDictionary:responseObject];
            
            if (error) {
                failureHandler(operation, error);
            } else {
                if (completionHandler) {
                    NSArray *detectionResults = [self detectionResultsFromDictionary:responseObject];
                    completionHandler(detectionResults, nil);
                }
            }
        };
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:API_URL_DETECT_LANGUAGE parameters:parameters success:successHandler failure:failureHandler];
    }
}

- (void)fetchAvailableTranslationLanguagesUsingLocalCache:(BOOL)fetchFromLocalCache forTargetLanguageCode:(NSString *)languageCode withCompletionHandler:(GTLanguageAvailabilityCompletionHandler)completionHandler {
    if (languageCode == nil) {
        languageCode = DEFAULT_LANGUAGE_CODE;
    }

    if (fetchFromLocalCache) {
        GTLanguageCache *cache = [[GTLanguageCache alloc] init];
        NSArray *cachedLanguages = [cache cachedLanguageListForLanguageCode:languageCode];

        if (cachedLanguages) {
            if (completionHandler) {
                completionHandler(cachedLanguages, nil);
            }

            return;
        }
    }

    //  Didn't want to use cached data, or there wasn't anything cached...
    NSDictionary *parameters = @{
                                    PARM_KEY_APIKEY : self.apiKey,
                                    PARM_KEY_LANGUAGE_TARGET : languageCode
                                 };

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:API_URL_GET_LANGUAGES parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionHandler) {
            NSArray *languages = [self languagesFromDictionary:responseObject];
            GTLanguageCache *cache = [[GTLanguageCache alloc] init];
            [cache cacheLanguageList:languages forLanguageCode:languageCode];

            completionHandler(languages, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

#pragma mark - Caching



#pragma mark - Utility Methods

- (BOOL)passesPrevalidationTranslationForText:(NSString *)text error:(NSError **)error {
    if (!self.apiKey) {
        *error = [self errorWithErrorCode:GTTranslationErrorValidationMissingKey];
        return NO;
    } else if (text.length == 0) {
        *error = [self errorWithErrorCode:GTTranslationErrorValidationInvalidText];
        return NO;
    }

    return YES;
}

- (NSError *)errorWithErrorCode:(GTTranslationError)errorCode {
    return [NSError errorWithDomain:ERROR_DOMAIN_GOOGLE_TRANSLATE code:errorCode userInfo:nil];
}

- (NSArray *)translationResultsFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *data = dictionary[@"data"];

    if (data) {
        NSArray *rawTranslations = data[@"translations"];
        NSMutableArray *translations = [[NSMutableArray alloc] initWithCapacity:rawTranslations.count];

        for (NSDictionary *rawTranslation in rawTranslations) {
            GTTranslationResult *result = [[GTTranslationResult alloc] initWithText:rawTranslation[@"translatedText"]
                                                               detectedLanguageCode:rawTranslation[@"detectedSourceLanguage"]];
            [translations addObject:result];
        }

        return translations;
    } else {
        return nil;
    }
}

- (NSArray *)languagesFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *data = dictionary[@"data"];

    if (data) {
        NSArray *rawLanguages = data[@"languages"];
        NSMutableArray *languages = [[NSMutableArray alloc] initWithCapacity:rawLanguages.count];

        for (NSDictionary *rawLanguage in rawLanguages) {
            GTLanguage *language = [[GTLanguage alloc] initWithLanguageCode:rawLanguage[@"language"]
                                                                       name:rawLanguage[@"name"]];
            [languages addObject:language];
        }

        return languages;
    } else {
        return nil;
    }
}

- (NSArray *)detectionResultsFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *data = dictionary[@"data"];
    
    if (data) {
        NSArray *rawDetections = data[@"detections"];
        NSMutableArray *detections = [[NSMutableArray alloc] initWithCapacity:rawDetections.count];

        for (NSDictionary *rawDetection in [rawDetections firstObject]) {
            GTLanguageDetectionResult *detectionResult = [[GTLanguageDetectionResult alloc] init];
            detectionResult.reliable = [rawDetection[@"isReliable"] boolValue];
            detectionResult.languageCode = rawDetection[@"language"];
            detectionResult.confidence = [rawDetection[@"confidence"] floatValue];

            [detections addObject:detectionResult];
        }

        return detections;
    } else {
        return nil;
    }
}

- (NSError *)errorFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *errorDict = dictionary[@"error"];
    
    if (errorDict) {
        NSInteger errorCode = GTTranslationAPIErrorGeneric - [errorDict[@"code"] integerValue];

        NSMutableString *errorMessage = [[NSMutableString alloc] init];

        for (NSDictionary *errorDetail in errorDict[@"errors"]) {
            for (NSString *key in [errorDetail allKeys]) {
                NSString *errorPair = [NSString stringWithFormat:@"%@ : %@; ", key, errorDetail[key]];
                [errorMessage appendString:errorPair];
            }
        }

        NSError *error = [[NSError alloc] initWithDomain:ERROR_DOMAIN_GOOGLE_TRANSLATE code:errorCode userInfo:@{(NSString *)kCFErrorLocalizedFailureReasonKey : errorMessage}];

        return error;
    } else {
        return nil;
    }
}

@end
