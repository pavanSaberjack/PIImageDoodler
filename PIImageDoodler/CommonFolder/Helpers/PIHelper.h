//
//  PIHelper.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PIHelper : NSObject

+ (NSURL *)localDatabaseStoragePath;
+ (NSNumber *)getDoodleUniqueID;
+ (NSString *)documentDirectoryPath;
+ (NSString *)imagePathForDoodleWithUniqueId:(NSString *)uniqueId;

@end
