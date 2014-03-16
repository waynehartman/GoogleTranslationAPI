//
//  GTTranslationAPI.m
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

        [self sendRequestWithUrlPath:API_URL_TRANSLATE_TEXT parms:parameters successHandler:successHandler failureHandler:failureHandler];
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

        [self sendRequestWithUrlPath:API_URL_DETECT_LANGUAGE parms:parameters successHandler:successHandler failureHandler:failureHandler];
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

    void(^failureHandler)(AFHTTPRequestOperation*, NSError*) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    };

    void(^successHandler)(AFHTTPRequestOperation*, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionHandler) {
            NSArray *languages = [self languagesFromDictionary:responseObject];
            GTLanguageCache *cache = [[GTLanguageCache alloc] init];
            [cache cacheLanguageList:languages forLanguageCode:languageCode];
            
            completionHandler(languages, nil);
        }
    };

    [self sendRequestWithUrlPath:API_URL_GET_LANGUAGES parms:parameters successHandler:successHandler failureHandler:failureHandler];
}

#pragma mark - Utility Methods

- (void)sendRequestWithUrlPath:(NSString *)path parms:(NSDictionary *)parms successHandler:(void (^)(AFHTTPRequestOperation *operation, id responseObject))successHandler failureHandler:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureHandler
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableURLRequest *request = [self translateRequestWithPath:path parms:parms];

    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                         success:successHandler
                                                                         failure:failureHandler];

    [manager.operationQueue addOperation:operation];
}

- (NSMutableURLRequest *)translateRequestWithPath:(NSString *)path parms:(NSDictionary *)parms {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET"
                                                                      URLString:path
                                                                     parameters:parms
                                                                          error:nil];
    [request addValue:[[NSBundle mainBundle] bundleIdentifier] forHTTPHeaderField:@"Referer"];
    
    return request;
}

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
