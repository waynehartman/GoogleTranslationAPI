//
//  GTLanguage.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLanguage : NSObject <NSCoding>

@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic, strong) NSString *name;

- (BOOL)isEqualToLanguage:(GTLanguage *)language;

@end
