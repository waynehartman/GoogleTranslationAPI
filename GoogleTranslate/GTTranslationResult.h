//
//  GTTranslationResult.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTTranslationResult : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *detectedLanguageCode;

@end
