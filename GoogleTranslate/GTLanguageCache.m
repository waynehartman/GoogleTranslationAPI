//
//  GTLanguageCache.m
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

#import "GTLanguageCache.h"

@implementation GTLanguageCache

#pragma mark - Public API

- (NSArray *)cachedLanguageListForLanguageCode:(NSString *)languageCode {
    NSString *path = [self cachePathForLanguageCode:languageCode];

    NSFileManager *fm = [[NSFileManager alloc] init];
    BOOL exists = [fm fileExistsAtPath:path];

    if (exists) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } else {
        return nil;
    }
}

- (void)cacheLanguageList:(NSArray *)languageList forLanguageCode:(NSString *)languageCode {
    NSString *path = [self cachePathForLanguageCode:languageCode];
    BOOL success = [NSKeyedArchiver archiveRootObject:languageList toFile:path];

    if (!success) {
        NSLog(@"error archiving language cache");
    }
}

- (void)clearCache {
    NSString *cacheDirectory = [self cacheDirectory];

    NSFileManager *fm = [[NSFileManager alloc] init];

    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheDirectory error:nil];
    for (NSString *file in directoryContents) {
        NSError *error = nil;
        BOOL success = [fm removeItemAtPath:file error:&error];

        if (!success) {
            NSLog(@"Unable to delete file: %@ error:\n%@", file, error);
        }
    }
}

#pragma mark - Utility Methods

- (NSString *)cachePathForLanguageCode:(NSString *)languageCode {
    NSString *cacheDirectory = [self cacheDirectory];
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist", cacheDirectory, languageCode];

    return path;
}

- (NSString *)cacheDirectory {
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directory = [NSString stringWithFormat:@"%@/GoogleTranslateAPI", cacheDirectory];

    NSFileManager *fm = [[NSFileManager alloc] init];

    if (![fm fileExistsAtPath:directory]) {
        [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return directory;
}

@end
