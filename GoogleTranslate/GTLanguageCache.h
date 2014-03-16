//
//  GTLanguageCache.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  Object used to locally cache language objects to disk
 */
@interface GTLanguageCache : NSObject

/*!
 *  Pull a language list for the given language code from the cache
 *  @param languageCode The language code for the list of languages
 *  @return An array of GTLanguage objects for the given language code
 *  @discussion If there is no cached languages for the given code, then this method will return nil.
 */
- (NSArray *)cachedLanguageListForLanguageCode:(NSString *)languageCode;

/*!
 *  Caches the given list for the specified language code
 *  @param languageList Array of GTLanguage objects to be cached
 *  @param languageCode The language code that specifies what language the language list is in.
 */
- (void)cacheLanguageList:(NSArray *)languageList forLanguageCode:(NSString *)languageCode;

/*!
 *  Clears the cache of all lists.
 */
- (void)clearCache;

@end
