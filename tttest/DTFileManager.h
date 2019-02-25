//
//  DTFileManager.h
//  Snake
//
//  Created by cheng on 17/8/19.
//  Copyright © 2017年 cheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HOME_PATH           (NSHomeDirectory())
#define DOC_PATH            ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])
#define DOCPATH(name)       ([DOC_PATH stringByAppendingPathComponent:name])

@interface DTFileManager : NSObject

// 宏 path
//+ (NSString *)homePath;
//+ (NSString *)docPath;

+ (BOOL)isFileExist:(NSString *)path;
+ (BOOL)isFileDirectory:(NSString *)path;

// file name array
+ (NSArray *)contentsWithPath:(NSString *)path;
// sub path array
+ (NSArray *)subpathsWithPath:(NSString *)path;

+ (NSArray *)subpathsAtPath:(NSString *)path;

+ (NSDictionary *)attWithFilePath:(NSString *)path;

// 复制 删除

+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath;//默认覆盖
+ (BOOL)copyItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover;

+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath;//默认覆盖
+ (BOOL)moveItemWithPath:(NSString *)path toPath:(NSString *)toPath cover:(BOOL)cover;

+ (BOOL)deleteItemWithPath:(NSString *)path;
+ (BOOL)deleteItemWithPath:(NSString *)path fileName:(NSString *)fileName;

@end
