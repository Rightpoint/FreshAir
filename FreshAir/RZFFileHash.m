/*
 *  FileHash.m
 *  FileMD5Hash
 *
 *  Copyright © 2010-2014 Joel Lopes Da Silva. All rights reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#import "RZFFileHash.h"

#include <CommonCrypto/CommonDigest.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdint.h>
#include <stdio.h>

static const size_t RZFFileHashChunkSize = 4096;

@implementation RZFFileHash

+ (NSString *)sha1HashOfFileAtPath:(NSString *)filePath
{
    NSString *result = nil;
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
    CFReadStreamRef readStream = fileURL ? CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL) : NULL;
    BOOL didSucceed = readStream ? (BOOL)CFReadStreamOpen(readStream) : NO;
    CC_SHA1_CTX hashContext;
    if (didSucceed) {
        // Initialize the hash object
        CC_SHA1_Init(&hashContext);

        // Feed the data to the hash object.
        BOOL hasMoreData = YES;
        while (hasMoreData) {
            uint8_t buffer[RZFFileHashChunkSize];
            CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
            if (readBytesCount == -1) {
                break;
            } else if (readBytesCount == 0) {
                hasMoreData = NO;
            } else {
                CC_SHA1_Update(&hashContext, (const void *)buffer, (CC_LONG)readBytesCount);
            }
        }

        // Compute the hash digest
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1_Final(digest, &hashContext);

        // Close the read stream.
        CFReadStreamClose(readStream);

        // Proceed if the read operation succeeded.
        didSucceed = !hasMoreData;
        if (didSucceed) {
            char hash[2 * sizeof(digest) + 1];
            for (size_t i = 0; i < sizeof(digest); ++i) {
                snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
            }
            result = [NSString stringWithUTF8String:hash];
        }

    }
    if (readStream) CFRelease(readStream);
    if (fileURL)    CFRelease(fileURL);
    return result;
}

@end
