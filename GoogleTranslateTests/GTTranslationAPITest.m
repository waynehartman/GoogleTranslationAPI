//
//  GTTranslationAPITest.m
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

#import <XCTest/XCTest.h>
#import "GTAsyncTesting.h"
#import "GTLocalDataProtocol.h"
#import "GTTranslationAPI.h"

@interface GTTranslationAPITest : XCTestCase

@property (nonatomic, strong) GTTranslationAPI *api;

@end

@implementation GTTranslationAPITest

- (void)setUp {
    [super setUp];
    self.api = [[GTTranslationAPI alloc] initWithApiKey:@"dummy key"];
}

- (void)tearDown {
    [super tearDown];
    self.api = nil;
}

#pragma mark - Translation Tests

/*!
 *  Has all required parameters
 */
- (void)testTranslate_HappyPath {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();

    [self.api translateText:@"test text"
        usingSourceLanguage:[[GTLanguage alloc] initWithLanguageCode:@"en"]
        destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"es"]
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();

          XCTAssertNil(error);
          XCTAssertNotNil(translations);
          GTTranslationResult *result = [translations lastObject];

          XCTAssertNotNil(result);
          XCTAssertTrue([result isKindOfClass:[GTTranslationResult class]]);
          XCTAssertNotNil(result.text);
      }];

    WaitUntilAsyncTestCompletes();

    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Missing the source language and will depend on source detection
 */
- (void)testTranslate_SourceDetection {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api translateText:@"test text"
        usingSourceLanguage:nil
        destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"es"]
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();
          
          XCTAssertNil(error);
          XCTAssertNotNil(translations);
          GTTranslationResult *result = [translations lastObject];
          
          XCTAssertNotNil(result);
          XCTAssertTrue([result isKindOfClass:[GTTranslationResult class]]);
          XCTAssertNotNil(result.text);
      }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Missing the required destination language
 */
- (void)testTranslate_MissingLanguage {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api translateText:@"test text"
        usingSourceLanguage:nil
        destinationLanguage:nil
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();

          XCTAssertNil(translations);
          XCTAssertNotNil(error);
      }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Missing text to translate
 */
- (void)testTranslate_MissingText {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api translateText:nil
        usingSourceLanguage:nil
        destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"en"]
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();

          XCTAssertNil(translations);
          XCTAssertNotNil(error);
      }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Missing all required parameters
 */
- (void)testTranslate_MissingAllRequiredParms {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api translateText:nil
        usingSourceLanguage:nil
        destinationLanguage:nil
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();
          
          XCTAssertNil(translations);
          XCTAssertNotNil(error);
      }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Situation where the server returns a 400 error
 */
- (void)testTranslate_ServerError {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:YES];
    StartAsyncTest();
    
    [self.api translateText:@"test text"
        usingSourceLanguage:nil
        destinationLanguage:[[GTLanguage alloc] initWithLanguageCode:@"es"]
      withCompletionHandler:^(NSArray *translations, NSError *error) {
          EndAsyncTest();
          
          XCTAssertNotNil(error);
          XCTAssertNil(translations);
      }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

#pragma mark - Fetch Languages Tests


/*!
 *  Fetch languages with happy path
 */
- (void)testFetchLanguages_HappyPath {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();

    [self.api fetchAvailableTranslationLanguagesUsingLocalCache:NO
                                          forTargetLanguageCode:@"en"
                                          withCompletionHandler:^(NSArray *languages, NSError *error) {
                                              EndAsyncTest();
                                              
                                              XCTAssertNil(error);
                                              XCTAssertNotNil(languages);
                                              
                                              XCTAssertTrue(languages.count > 0);
                                              
                                              for (GTLanguage *language in languages) {
                                                  XCTAssertTrue([language isKindOfClass:[GTLanguage class]]);
                                                  XCTAssertNotNil(language.languageCode);
                                              }
                                          }];

    WaitUntilAsyncTestCompletes();

    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Missing the target language and a default should be set
 */
- (void)testFetchLanguages_MissingTargetLanguage {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api fetchAvailableTranslationLanguagesUsingLocalCache:NO
                                          forTargetLanguageCode:nil
                                          withCompletionHandler:^(NSArray *languages, NSError *error) {
                                              EndAsyncTest();

                                              XCTAssertNil(error);
                                              XCTAssertNotNil(languages);

                                              XCTAssertTrue(languages.count > 0);

                                              for (GTLanguage *language in languages) {
                                                  XCTAssertTrue([language isKindOfClass:[GTLanguage class]]);
                                                  XCTAssertNotNil(language.languageCode);
                                              }
                                          }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Situation where the server returns a 400 error
 */
- (void)testFetchLanguages_ServerError {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:YES];
    StartAsyncTest();

    [self.api fetchAvailableTranslationLanguagesUsingLocalCache:NO
                                          forTargetLanguageCode:nil
                                          withCompletionHandler:^(NSArray *languages, NSError *error) {
                                              EndAsyncTest();

                                              XCTAssertNil(languages);
                                              XCTAssertNotNil(error);
                                          }];

    WaitUntilAsyncTestCompletes();

    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

#pragma mark - Language Detection Tests

/*!
 * Happy path language detection
 */
- (void)testLanguageDetection_HappyPath {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();

    [self.api detectLanguageFromText:@"text"
                   completionHandler:^(NSArray *detectionResults, NSError *error) {
                       EndAsyncTest();

                       XCTAssertNotNil(detectionResults);
                       XCTAssertNil(error);
                       XCTAssertTrue(detectionResults.count > 0);
                   }];

    WaitUntilAsyncTestCompletes();

    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Test missing text to detect
 */
- (void)testLanguageDetection_MissingTextParameter {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:NO];
    StartAsyncTest();
    
    [self.api detectLanguageFromText:nil
                   completionHandler:^(NSArray *detectionResults, NSError *error) {
                       EndAsyncTest();

                       XCTAssertNil(detectionResults);
                       XCTAssertNotNil(error);
                   }];
    
    WaitUntilAsyncTestCompletes();
    
    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

/*!
 *  Situation where the server runs a 400 error
 */
- (void)testLanguageDetection_ServerError {
    [GTLocalDataProtocol registerLocalDataProtocolWithErrors:YES];
    StartAsyncTest();

    [self.api detectLanguageFromText:@"text"
                   completionHandler:^(NSArray *detectionResults, NSError *error) {
                       EndAsyncTest();
                       
                       XCTAssertNil(detectionResults);
                       XCTAssertNotNil(error);
                   }];

    WaitUntilAsyncTestCompletes();

    [GTLocalDataProtocol unregisterLocalDataProtocol];
}

@end
