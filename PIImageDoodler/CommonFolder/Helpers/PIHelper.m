//
//  PIHelper.m
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import "PIHelper.h"

@implementation PIHelper

#pragma mark - Path Helper methods
+ (NSURL *)localDatabaseStoragePathWithFolderName:(NSString *)folderName
{
    /*
     * Creating new New Url as <Document Directory>/Database/
     * which will be easy for us exclude this folder while handling Cache cleanup
     * even it is helpful in migration process where we have to move all DB related files along with sqlite file
     */
    NSURL *storageURL = [PIHelper databaseDirectoryURL];
    NSURL *newURL = [storageURL URLByAppendingPathComponent:folderName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:newURL.path]) {
        NSError *createError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:newURL
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                    iCloudExclude:YES
                                                            error:&createError]) {
            if (createError) {
                // Ideally should not happen but extreme case we will set it directory path
                // Need better mechanism to track this when these kind of things happen
                DLog(@"localDatabaseStoragePath: error creating directory");
            }
        }
    }
    return newURL;
}


+ (NSURL *)localDatabaseStoragePath
{
    return [PIHelper localDatabaseStoragePathWithFolderName:DATABASE_FOLDER];
}

+ (NSString *)localCachePathWithFolderName:(NSString *)cacheName
{
    /*
     * Creating new New Url as <DocumentDirectory>/LocalCache/
     * which will be easy for us include only this folder while handling Cache cleanup
     */
    
    NSString *localCachePath = [[PIHelper documentDirectoryPath] stringByAppendingPathComponent:cacheName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localCachePath]) {
        NSError *createError;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:localCachePath
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                     iCloudExclude:YES
                                                             error:&createError]) {
            if (createError) {
                // Ideally should not happen but extreme case we will set it directory path
                // Need better mechanism to track this when these kind of things happen
                DLog(@"localCachePath: Failed to create directory at path:%@ with error: %@", localCachePath, createError);
            }
        }
    }
    return localCachePath;
}

+ (NSString *)localCachePath
{
    return [PIHelper localCachePathWithFolderName:LOCAL_CACHE_FOLDER];
}

+ (NSURL *)databaseDirectoryURL
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)documentDirectoryCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)documentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+ (NSString *)iOSOpenINCachedInboxDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Inbox"];
}

+ (NSNumber *)getDoodleUniqueID
{
    NSTimeInterval val = [[NSDate date] timeIntervalSince1970] * 1000000; // Get the time interval string
    long long uniqueId = [[NSNumber numberWithDouble:val] longLongValue]; // to make sure unique id is unique
    return @(uniqueId); // return NSNumber of 'long long' instead of 'NSTimeInterval' which is 'double' value
}

+ (NSString *)imagePathForDoodleWithUniqueId:(NSString *)uniqueId
{
    return [[PIHelper localCachePath] stringByAppendingPathComponent:uniqueId];
}

@end
