//
//  GTLocalDataProtocol.m
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

#import "GTLocalDataProtocol.h"

@implementation GTLocalDataProtocol

#pragma mark - Registration

static BOOL SHOULD_ERROR = NO;

+ (BOOL)registerLocalDataProtocolWithErrors:(BOOL)shouldError {
    SHOULD_ERROR = shouldError;
    return [self registerClass:[self class]];
}

+ (void)unregisterLocalDataProtocol {
    [self unregisterClass:[self class]];
}

#pragma mark - Super Overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *host = request.URL.host;

    return [host isEqualToString:@"www.googleapis.com"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSData *data = [self dataForRequest:self.request];

    if (data == nil) {
        NSError *error = [[NSError alloc] initWithDomain:(NSString *)kCFErrorDomainCFNetwork code:404 userInfo:nil];
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        NSInteger statusCode = [self statusCodeForData:data];

        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:statusCode
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{ @"Content-Type" : @"application/json" }];

        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading {
    //  DO NOTHING
}

- (NSData *)dataForRequest:(NSURLRequest *)request {
    NSString *lastPathComponent = request.URL.lastPathComponent;

    NSString *fileName = nil;

    if (SHOULD_ERROR) {
        fileName = @"badrequest.json";
    } else {
        if ([lastPathComponent isEqualToString:@"v2"]) {
            fileName = @"translate.json";
        } else if ([lastPathComponent isEqualToString:@"languages"]) {
            fileName = @"languages.json";
        } else if ([lastPathComponent isEqualToString:@"detect"]) {
            fileName = @"detect.json";
        }
    }

    if (fileName) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];

        return data;
    } else {
        return nil;
    }
}

- (NSInteger)statusCodeForData:(NSData *)data {
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    if (!dataDict) {
        return 500;
    } else {
        NSDictionary *error = dataDict[@"error"];
        if (!error) {
            return 200;
        } else {
            return [error[@"code"] integerValue];
        }
    }
}

@end
