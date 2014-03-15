//
//  GTLanguage.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

#import "GTLanguage.h"

@implementation GTLanguage

#pragma mark - Initialization

- (instancetype)initWithLanguageCode:(NSString *)languageCode {
    if ((self = [super init])) {
        _languageCode = languageCode;
    }

    return self;
}

- (instancetype)initWithLanguageCode:(NSString *)languageCode name:(NSString *)name {
    if ((self = [super init])) {
        _languageCode = languageCode;
        _name = name;
    }

    return self;
}

#pragma mark - Comparison

- (BOOL)isEqualToLanguage:(GTLanguage *)language {
    if (self.languageCode == nil && language.languageCode == nil) {
        return YES;
    }

    return [self.languageCode isEqualToString:language.languageCode];
}

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.languageCode forKey:@"languageCode"];
    [encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.languageCode = [decoder decodeObjectForKey:@"languageCode"];
        self.name = [decoder decodeObjectForKey:@"name"];
    }

    return self;
}

#pragma mark - Debug

- (NSString *)debugDescription {
    NSString *superDescription = [super debugDescription];

    return [NSString stringWithFormat:@"%@ %@: %@", superDescription, self.languageCode, self.name];
}

- (NSString *)description {
    NSString *superDescription = [super description];
    
    return [NSString stringWithFormat:@"%@ %@: %@", superDescription, self.languageCode, self.name];
}

@end
