//
//  GTTranslationPreferences.m
//  GoogleTranslate
//

/*
 *  Copyright (c) 2014, Wayne Hartman
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *  * Redistributions of source code must retain the above copyright notice, this
 *  list of conditions and the following disclaimer.
 *
 *  * Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 *
 *  * Neither the name of Wayne Hartman nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 *  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 *  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 *  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 *  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "GTTranslationPreferences.h"

@interface GTTranslationPreferences ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

#define KEY_SOURCE  @"KEY_SOURCE"
#define KEY_DEST    @"KEY_DEST"

@implementation GTTranslationPreferences

static GTTranslationPreferences *singleton;

#pragma mark - Singleton

+ (instancetype)preferences {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[GTTranslationPreferences alloc] init];
    });

    return singleton;
}

#pragma mark - Getters/Setters

- (void)setDestinationLanguage:(GTLanguage *)destinationLanguage {
    if (destinationLanguage == nil) {
        [self.cache removeObjectForKey:KEY_DEST];
    } else {
        self.cache[KEY_DEST] = destinationLanguage;
    }

    [self synchronize];
}

- (void)setSourceLanguage:(GTLanguage *)sourceLanguage {
    if (sourceLanguage == nil) {
        [self.cache removeObjectForKey:KEY_SOURCE];
    } else {
        self.cache[KEY_SOURCE] = sourceLanguage;
    }

    [self synchronize];
}

- (GTLanguage *)sourceLanguage {
    return self.cache[KEY_SOURCE];
}

- (GTLanguage *)destinationLanguage {
    return self.cache[KEY_DEST];
}

#pragma mark - Utility Methods

- (void)synchronize {
    [NSKeyedArchiver archiveRootObject:self.cache toFile:[self path]];
}

- (NSMutableDictionary *)cache {
    if (!_cache) {
        NSFileManager *fm = [[NSFileManager alloc] init];
        NSString *path = [self path];
        BOOL exists = [fm fileExistsAtPath:path];
        if (exists) {
            NSDictionary *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            _cache = [cache mutableCopy];
        } else {
            _cache = [NSMutableDictionary dictionary];
        }
    }

    return _cache;
}

- (NSString *)path {
    static NSString *path = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [NSString stringWithFormat:@"%@/prefernces.plist", [self preferencesDirectory]];
    });

    return path;
}

- (NSString *)preferencesDirectory {
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directory = [NSString stringWithFormat:@"%@/GoogleTranslateAPIPreferences", libraryDirectory];

    NSFileManager *fm = [[NSFileManager alloc] init];
    if (![fm fileExistsAtPath:directory]) {
        [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return directory;
}

@end
