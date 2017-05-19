//
//  PIDataManager.h
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CoreDataCallBack)(BOOL isSuccess);

@interface PIDataManager : NSObject

+ (NSArray<Doodle *> *)getStoredDoodles;

+ (void)createDoodleWithName:(NSString *)name
                 description:(NSString *)description
                    uniqueId:(NSString *)uniqueId
                  completion:(void(^)(Doodle *docObject))callback;

+ (void)deleteDoodles:(NSArray<Doodle *> *)doodles
            completion:(void(^)(BOOL isSuccess))callback;

+ (void)deleteAllDoodlesWithCompletion:(void(^)(BOOL isSuccess))callback;

+ (Doodle *)getDoodleForId:(NSString *)uniqueId;
@end
