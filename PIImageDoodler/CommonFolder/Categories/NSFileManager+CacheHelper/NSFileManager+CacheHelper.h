//
//  NSFileManager+CacheHelper.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (CacheHelper)

- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(NSDictionary *)attributes
                iCloudExclude:(BOOL)isExcludeNeeded
                        error:(NSError *__autoreleasing *)error;

- (BOOL)createDirectoryAtURL:(NSURL *)url
 withIntermediateDirectories:(BOOL)createIntermediates
                  attributes:(NSDictionary *)attributes
               iCloudExclude:(BOOL)isExcludeNeeded error:(NSError *__autoreleasing *)error;

- (BOOL)createFileAtPath:(NSString *)path
                contents:(NSData *)data
              attributes:(NSDictionary *)attr
           iCloudExclude:(BOOL)isExcludeNeeded;

- (void)iCloudExcludeFileAtPath:(NSString *)path;

- (BOOL)copyItemAtPath:(NSString *)srcPath
                toPath:(NSString *)dstPath
         iCloudExclude:(BOOL)isExcludeNeeded
                 error:(NSError *__autoreleasing *)error;

- (BOOL)copyItemAtURL:(NSURL *)srcURL
                toURL:(NSURL *)dstURL
        iCloudExclude:(BOOL)isExcludeNeeded
                error:(NSError *__autoreleasing *)error;

- (BOOL)moveItemAtPath:(NSString *)srcPath
                toPath:(NSString *)dstPath
         iCloudExclude:(BOOL)isExcludeNeeded
                 error:(NSError * __autoreleasing *)error;

- (BOOL)moveItemAtURL:(NSURL *)srcURL
                toURL:(NSURL *)dstURL
        iCloudExclude:(BOOL)isExcludeNeeded
                error:(NSError * __autoreleasing *)error;

@end
