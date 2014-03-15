//
//  GTTranslationResult.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTTranslationResult.h"

@implementation GTTranslationResult

#pragma mark - Initialization

- (instancetype)initWithText:(NSString *)text detectedLanguageCode:(NSString *)detectedLanguageCode {
    if ((self = [super init])) {
        _text = text;
        _detectedLanguageCode = detectedLanguageCode;
    }

    return self;
}

#pragma mark - Debug

- (NSString *)debugDescription {
    NSString *superDescription = [super debugDescription];
    
    return [NSString stringWithFormat:@"%@ Detected Language: %@ Translation: (%@)", superDescription, self.detectedLanguageCode, self.text];
}

- (NSString *)description {
    NSString *superDescription = [super description];
    
    return [NSString stringWithFormat:@"%@ Detected Language: %@ Translation: (%@)", superDescription, self.detectedLanguageCode, self.text];
}

@end
