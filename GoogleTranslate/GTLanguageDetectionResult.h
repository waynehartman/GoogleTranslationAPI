//
//  GTLanguageDetectionResult.h
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTLanguageDetectionResult : NSObject

@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic, assign, getter = isReliable) BOOL reliable;
@property (nonatomic, assign) float confidence;

@end
