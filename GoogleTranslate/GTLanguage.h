//
//  GTLanguage.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

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
