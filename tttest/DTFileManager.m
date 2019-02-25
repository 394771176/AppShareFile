//
//  DTFileManager.m
//  Snake
//
//  Created by cheng on 17/8/19.
//  Copyright © 2017年 cheng. All rights reserved.
//

#import "DTFileManager.h"

@interface DTFileManager () {
    
}

@property (nonatomic, readonly) NSFileManager *fileManager;

@end

@implementation DTFileManager

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSFileManager *)fileManager
{
    return [NSFileManager defaultManager];
}

+ (NSFileManager *)fileManager
{
    return [[self sharedInstance] fileManager];
}

+ (BOOL)isFileExist:(NSString *)path
{
    return [[self fileManager] fileExistsAtPath:path];
}

+ (BOOL)isFileDirectory:(NSString *)path
{
    BOOL isDir = NO;
    BOOL isExist = NO;
    isExist = [[self fileManager] fileExistsAtPath:path isDirectory:&isDir];
    return isExist & isDir;
}

+ (NSArray *)contentsWithPath:(NSString *)path
{
    return [[self fileManager] contentsOfDirectoryAtPath:path error:NULL];
}

+ (NSArray *)subpathsWithPath:(NSString *)path
{
    return [[self fileManager] subpathsOfDirectoryAtPath:path error:NULL];
}

+ (NSArray *)subpathsAtPath:(NSString *)path
{
    return [[self fileManager] subpathsAtPath:path];
}

+ (NSDictionary *)attWithFilePath:(NSString *)path
{
    return [[self fileManager] attributesOfItemAtPath:path error:NULL];
}

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath
{
    return [self copyItemWithPath:path toPath:toPath cover:YES];
}

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover
{
    if ([self.fileManager fileExistsAtPath:path]) {
        if (cover || ![self.fileManager fileExistsAtPath:toPath]) {
            NSError *error = nil;
            [self.fileManager copyItemAtPath:path toPath:toPath error:&error];
            return error ? NO : YES;
        }
    }
    return NO;
}

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath
{
    return [self moveItemWithPath:path toPath:toPath cover:YES];
}

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover
{
    if ([self.fileManager fileExistsAtPath:path]) {
        if (cover || ![self.fileManager fileExistsAtPath:toPath]) {
            NSError *error = nil;
            [self.fileManager moveItemAtPath:path toPath:toPath error:&error];
            return error ? NO : YES;
        }
    }
    return NO;
}

+ (BOOL)deleteItemWithPath:(NSString *)path
{
    if (path) {
        NSError *error = nil;
        [[self fileManager] removeItemAtPath:path error:&error];
        return error ? NO : YES;
    }
    return NO;
}

+ (BOOL)deleteItemWithPath:(NSString *)path fileName:(NSString *)fileName
{
    if (path && fileName) {
     return [self deleteItemWithPath:[path stringByAppendingPathComponent:fileName]];
    }
    return NO;
}

@end
