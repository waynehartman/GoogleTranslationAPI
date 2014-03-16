//
//  GTTranslationResult.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

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
