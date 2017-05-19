//
//  NSFileManager+CacheHelper.m
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import "NSFileManager+CacheHelper.h"

@implementation NSFileManager (CacheHelper)

- (BOOL)createFileAtPath:(NSString *)path
                contents:(NSData *)data
              attributes:(NSDictionary *)attr
           iCloudExclude:(BOOL)isExcludeNeeded
{
    BOOL isSuccess = [self createFileAtPath:path
                                   contents:data
                                 attributes:attr];
    if (isExcludeNeeded) {
        NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        [self excludeFileAtURL:fileURL];
    }
    
    [self encryptItemAtPth:path];
    return isSuccess;
}

- (BOOL)createDirectoryAtURL:(NSURL *)url
 withIntermediateDirectories:(BOOL)createIntermediates
                  attributes:(NSDictionary *)attributes
               iCloudExclude:(BOOL)isExcludeNeeded
                       error:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = [self createDirectoryAtURL:url
                    withIntermediateDirectories:createIntermediates
                                     attributes:attributes
                                          error:error];
    if (isExcludeNeeded) {
        [self excludeFileAtURL:url];
    }
    
    [self encryptItemAtPth:url.path];
    return isSuccess;
}

- (BOOL)createDirectoryAtPath:(NSString *)path
  withIntermediateDirectories:(BOOL)createIntermediates
                   attributes:(NSDictionary *)attributes
                iCloudExclude:(BOOL)isExcludeNeeded
                        error:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = [self createDirectoryAtPath:path
                     withIntermediateDirectories:createIntermediates
                                      attributes:attributes
                                           error:error];
    if (isExcludeNeeded) {
        NSURL *directoryURL = [NSURL fileURLWithPath:path isDirectory:YES];
        [self excludeFileAtURL:directoryURL];
    }
    
    [self encryptItemAtPth:path];
    return isSuccess;
}

- (BOOL)copyItemAtPath:(NSString *)srcPath
                toPath:(NSString *)dstPath
         iCloudExclude:(BOOL)isExcludeNeeded
                 error:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = [self copyItemAtPath:srcPath
                                   toPath:dstPath
                                    error:error];
    if (isExcludeNeeded) {
        NSURL *directoryURL = [NSURL fileURLWithPath:dstPath isDirectory:YES];
        [self excludeFileAtURL:directoryURL];
    }
    
    [self encryptItemAtPth:dstPath];
    return isSuccess;
}

- (BOOL)copyItemAtURL:(NSURL *)srcURL
                toURL:(NSURL *)dstURL
        iCloudExclude:(BOOL)isExcludeNeeded
                error:(NSError *__autoreleasing *)error
{
    BOOL isSuccess = [self copyItemAtURL:srcURL
                                   toURL:dstURL
                                   error:error];
    if (isExcludeNeeded) {
        [self excludeFileAtURL:dstURL];
    }
    
    [self encryptItemAtPth:dstURL.path];
    return isSuccess;
}

- (BOOL)moveItemAtPath:(NSString *)srcPath
                toPath:(NSString *)dstPath
         iCloudExclude:(BOOL)isExcludeNeeded
                 error:(NSError * __autoreleasing *)error
{
    BOOL isSuccess = [self moveItemAtPath:srcPath
                                   toPath:dstPath
                                    error:error];
    
    if (isExcludeNeeded) {
        NSURL *directoryURL = [NSURL fileURLWithPath:dstPath isDirectory:YES];
        [self excludeFileAtURL:directoryURL];
    }
    
    [self encryptItemAtPth:dstPath];
    return isSuccess;
}

- (BOOL)moveItemAtURL:(NSURL *)srcURL
                toURL:(NSURL *)dstURL
        iCloudExclude:(BOOL)isExcludeNeeded
                error:(NSError * __autoreleasing *)error
{
    BOOL isSuccess = [self moveItemAtURL:srcURL
                                   toURL:dstURL
                                   error:error];
    
    if (isExcludeNeeded) {
        [self excludeFileAtURL:dstURL];
    }
    
    [self encryptItemAtPth:dstURL.path];
    return isSuccess;
}

- (void)iCloudExcludeFileAtPath:(NSString *)path
{
    NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
    [self excludeFileAtURL:fileURL];
}

- (void)excludeFileAtURL:(NSURL *)url
{
    NSError *excludeError;
    BOOL val = [url setResourceValue:@YES
                              forKey:NSURLIsExcludedFromBackupKey
                               error:&excludeError];
    if (!val) {
        DLog(@"Error while excluding : %@ and error: %@", url, excludeError);
    }
}

- (void)encryptItemAtPth:(NSString *)path
{
    NSError *error;
    NSDictionary *currentAttributes = [self attributesOfItemAtPath:path error:&error];
    if (error) {
        DLog(@"Error while getting attributes for item at path : %@ and error: %@", path, error);
    }
    
    NSDictionary *updatedAttributes = currentAttributes;
    if (currentAttributes) {
        NSString *protectionAttributeValue = currentAttributes[NSFileProtectionKey];
        if ((protectionAttributeValue == nil) ||
            ![protectionAttributeValue isEqualToString:NSFileProtectionComplete]) { // check if protection not set/ protection is not what we needed
            NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:currentAttributes];
            // NSFileProtectionComplete : the file is only accessible while the device is unlocked : this is sufficient as we are not supporting background mode
            newAttributes[NSFileProtectionKey] = NSFileProtectionComplete;
            updatedAttributes = newAttributes;
        }
    } else {
        // Note: Any file/folder will have some default attributes set.
        DLog(@"Not attributes found for item at path : %@", path);
        updatedAttributes = @{NSFileProtectionKey: NSFileProtectionComplete};
    }
    
    error = nil;
    if (![self setAttributes:updatedAttributes
                ofItemAtPath:path
                       error:&error]) {
        if (error) {
            DLog(@"Error while encrypting : %@ and error: %@", path, error);
        }
    }
}

@end
