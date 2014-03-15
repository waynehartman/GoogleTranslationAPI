//
//  GTLanguageDetectionResult.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTLanguageDetectionResult.h"

@implementation GTLanguageDetectionResult

- (NSString *)debugDescription {
    NSString *superDescription = [super debugDescription];
    
    return [NSString stringWithFormat:@"%@ Language code:%@ Confidence:%f isReliable:%i", superDescription, self.languageCode, self.confidence, self.isReliable];
}

- (NSString *)description {
    NSString *superDescription = [super description];
    
    return [NSString stringWithFormat:@"%@ Language code:%@ Confidence:%f isReliable:%i", superDescription, self.languageCode, self.confidence, self.isReliable];
}

@end
