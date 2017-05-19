//
//  PIDataManager.m
//  PIImageDoodler
//
//  Created by Pavan on 19/05/17.
//  Copyright © 2017 Pavan Itagi. All rights reserved.
//

#import "PIDataManager.h"

static id sharedDataManager = nil;

@interface PIDataManager ()
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, strong, readonly) NSManagedObjectContext *backgroundMasterContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation PIDataManager

@synthesize mainContext = _mainContext;
@synthesize backgroundMasterContext = _backgroundMasterContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (PIDataManager *)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedDataManager = [[[self class] alloc] init];
    });
    return sharedDataManager;
}

#pragma mark - Singleton Override Methods
+ (id)allocWithZone:(NSZone *)zone
{
    if (sharedDataManager == nil) {
        sharedDataManager = [super allocWithZone:zone];
        return sharedDataManager;
    }
    return nil;
}

+ (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)dealloc
{
    // will never be called
}

- (id)init
{
    if (self = [super init]) {
        DLog(@"INIT : SBDataManager");
    }
    return self;
}

#pragma mark - Core Data stack
- (NSManagedObjectContext*)backgroundMasterContext
{
    if(!_backgroundMasterContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if(coordinator) {
            _backgroundMasterContext =  [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [_backgroundMasterContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _backgroundMasterContext;
}

- (NSManagedObjectContext*)mainContext
{
    if (!_mainContext) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_mainContext setParentContext:self.backgroundMasterContext];
        }
    }
    return _mainContext;
}

- (NSManagedObjectContext*)createWriteContext
{
    NSManagedObjectContext *newContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [newContext setParentContext:self.mainContext];
    return newContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PIImageDoodler" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[PIHelper localDatabaseStoragePath] URLByAppendingPathComponent:@"PIImageDoodler.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES}; // add migration options
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        DLog(@"Unresolved error forcing creation of file %@, %@", error, [error userInfo]);
        
        NSURL *storeURL = [[PIHelper localDatabaseStoragePath] URLByAppendingPathComponent:@"PIImageDoodler.sqlite"];
        if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
            DLog(@"Error removeAllCacheData %@ %@", error, [error userInfo]);
            abort();
        }
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            DLog(@"Error removeAllCacheData %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

- (void)removeAllCachedData
{
    NSError *error=nil;
    [_persistentStoreCoordinator removePersistentStore:[_persistentStoreCoordinator.persistentStores objectAtIndex:0] error:&error];
    if(error) {
        DLog(@"Error removeAllCacheData %@ %@", error, [error userInfo]);
        abort();
    }
    NSURL *storeURL = [[PIHelper localDatabaseStoragePath] URLByAppendingPathComponent:@"PIImageDoodler.sqlite"];
    if(![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
        DLog(@"Error removeAllCacheData %@ %@", error, [error userInfo]);
        abort();
    }
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        DLog(@"Error removeAllCacheData %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)saveAllWithContext:(NSManagedObjectContext *)writeContext withCoreDataCallBack:(CoreDataCallBack)coreDataCallBack
{
    NSError *error;
    if (![writeContext save:&error]) {
        DLog(@"saveAllWithContext: some error in saving category is %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            coreDataCallBack(FALSE);
        });
    } else {
        if (writeContext != self.mainContext && writeContext != self.backgroundMasterContext) {
            [self.mainContext performBlock:^{
                NSError * error = nil;
                [self.mainContext save:&error];
                if (error) {
                    DLog(@"saveAllWithContext: desc %@",error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        coreDataCallBack(FALSE);
                    });
                } else {
                    [self.backgroundMasterContext performBlock:^{
                        NSError * error = nil;
                        [self.backgroundMasterContext save:&error];
                        if (error) {
                            DLog(@"saveAllWithContext: desc %@",error);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                coreDataCallBack(FALSE);
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                coreDataCallBack(TRUE);
                            });
                        }
                    }];
                }
            }];
        } else if (writeContext == self.mainContext) { // writeContext == self.backgroundMasterContext need to check when we will get this situation?
            if (error) {
                DLog(@"saveAllWithContext: desc %@",error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    coreDataCallBack(FALSE);
                });
            } else {
                [self.backgroundMasterContext performBlock:^{
                    NSError * error = nil;
                    [self.backgroundMasterContext save:&error];
                    if (error) {
                        DLog(@"saveAllWithContext: desc %@",error);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            coreDataCallBack(FALSE);
                        });
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            coreDataCallBack(TRUE);
                        });
                    }
                }];
            }
        }
    }
}

#pragma mark - Private Interface methods
- (void)createDoodleWithName:(NSString *)name
                 description:(NSString *)description
                    uniqueId:(NSString *)uniqueId
                  completion:(void(^)(Doodle *docObject))callback
{
    NSManagedObjectContext *context = [self createWriteContext];
    [context performBlock:^{
        Doodle *subject = [NSEntityDescription insertNewObjectForEntityForName:@"Doodle" inManagedObjectContext:context];
        subject.name = name;
        subject.smallDescription = description;
        subject.uniqueId =  uniqueId;
        
        [self saveAllWithContext:context withCoreDataCallBack:^(BOOL isSuccess) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isSuccess) {
                    callback(subject);
                    return;
                }
                callback(nil);
            });
        }];
    }];
}

- (NSArray<Doodle *> *)getStoredDoodles
{
    NSManagedObjectContext *context = [self mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Doodle" inManagedObjectContext:context];
    [fetchRequest setEntity:categoryEntity];
    NSError * error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (Doodle *)getDoodleForId:(NSString *)uniqueId inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Doodle" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueId == %@", uniqueId];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setEntity:categoryEntity];
    NSError * error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count] > 0) {
        return fetchedObjects[0];
    }
    
    DLog(@"PIDatamanager: getDoodleForId: %@ : Doodle not found", uniqueId);
    return nil;
}

- (Doodle *)getDoodleForId:(NSString *)uniqueId
{
    NSManagedObjectContext *context = [self mainContext];
    return [self getDoodleForId:uniqueId inContext:context];
}

- (void)deleteDoodles:(NSArray<Doodle *> *)doodles
           completion:(void(^)(BOOL isSuccess))callback
{
    if (doodles.count == 0) {
        callback(NO);
        return;
    }
    
    NSManagedObjectContext *context = [self mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Doodle" inManagedObjectContext:context];
    
    
    NSString *formatStr = @"";
    for (int i = 0; i< doodles.count; i++) {
        Doodle *doodle = doodles[i];
        formatStr = [formatStr stringByAppendingString:[NSString stringWithFormat:@"uniqueId == %@", doodle.uniqueId]];
        if (i != doodles.count - 1) {
            formatStr = [formatStr stringByAppendingString:@" OR "];
        }
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:formatStr];
    [fetchRequest setEntity:categoryEntity];
    [fetchRequest setPredicate:predicate];
    NSError * error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *obj in fetchedObjects) {
        [context deleteObject:obj];
    }
    
    [self saveAllWithContext:context withCoreDataCallBack:^(BOOL isSuccess) {
        if (!isSuccess) {
            DLog(@"remove : Something went wrong while removing files!!")
        }
        
        callback(isSuccess);
    }];
}

- (void)deleteAllDoodlesWithCompletion:(void(^)(BOOL isSuccess))callback
{
    NSManagedObjectContext *context = [self mainContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *categoryEntity = [NSEntityDescription entityForName:@"Doodle" inManagedObjectContext:context];
    [fetchRequest setEntity:categoryEntity];
    
    NSError * error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in fetchedObjects) {
        [context deleteObject:obj];
    }
    
    [self saveAllWithContext:context withCoreDataCallBack:^(BOOL isSuccess) {
        if (!isSuccess) {
            DLog(@" : Something went wrong while removing files!!")
        }
        
        callback(isSuccess);
    }];
}

#pragma mark - Public Interface methods

+ (void)createDoodleWithName:(NSString *)name
                 description:(NSString *)description
                    uniqueId:(NSString *)uniqueId
                  completion:(void(^)(Doodle *docObject))callback
{
    [[PIDataManager sharedInstance] createDoodleWithName:name
                                              description:description
                                                 uniqueId:uniqueId
                                               completion:callback];
}

+ (NSArray<Doodle *> *)getStoredDoodles
{
    return [[PIDataManager sharedInstance] getStoredDoodles];
}

+ (void)deleteDoodles:(NSArray<Doodle *> *)doodles
           completion:(void(^)(BOOL isSuccess))callback
{
    [[PIDataManager sharedInstance] deleteDoodles:doodles
                                       completion:callback];
}

+ (void)deleteAllDoodlesWithCompletion:(void(^)(BOOL isSuccess))callback
{
    [[PIDataManager sharedInstance] deleteAllDoodlesWithCompletion:callback];
}

+ (Doodle *)getDoodleForId:(NSString *)uniqueId
{
    return [[PIDataManager sharedInstance] getDoodleForId:uniqueId];
}
@end
