//
//  GTLanguageCache.m
//  GoogleTranslate
//
//  Created by Wayne Hartman on 3/15/14.
//  Copyright (c) 2014 Wayne Hartman. All rights reserved.
//

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
