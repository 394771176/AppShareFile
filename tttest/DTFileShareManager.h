//
//  DTFileShareManager.h
//  tttest
//
//  Created by cheng on 2019/2/22.
//  Copyright © 2019 cheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DTFileManager.h"

#define SHARED_INSTANCE_H  + (instancetype)sharedInstance;
#define SHARED_INSTANCE_M  \
+ (instancetype)sharedInstance \
{ \
static id instance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
instance = [self.class new]; \
}); \
return instance; \
}

NS_ASSUME_NONNULL_BEGIN

@interface DTFileShareManager : NSObject

@property (nonatomic, strong) UIDocumentInteractionController *doc;

SHARED_INSTANCE_H

+ (NSString *)sharePath;
+ (NSString *)pathWithName:(NSString *)name;

+ (BOOL)handleOpenURL:(NSURL *)url;

+ (BOOL)saveFileWithUrl:(NSURL *)url;

+ (void)shareFileWithPath:(NSString *)path;

+ (void)shareFileWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
