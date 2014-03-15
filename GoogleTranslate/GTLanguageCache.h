//
//  GTLanguageCache.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLanguageCache : NSObject

- (NSArray *)cachedLanguageListForLanguageCode:(NSString *)languageCode;
- (void)cacheLanguageList:(NSArray *)languageList forLanguageCode:(NSString *)languageCode;
- (void)clearCache;

@end
