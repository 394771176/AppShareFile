//
//  ShareViewController.m
//  share
//
//  Created by cheng on 16/8/12.
//  Copyright © 2016年 cheng. All rights reserved.
//

#import "ShareViewController.h"
#import "TTDefine.h"
#import "FFJSONHelper.h"

@interface ShareViewController () {
    NSURL *_fileUrl;
    NSData *_fileData;
    NSString *_dataType;
}

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getFileData];
}

static NSInteger const maxCharactersAllowed =  140;//手动设置字符数上限
- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    NSInteger length = self.contentText.length;
    self.charactersRemaining = @(maxCharactersAllowed - length);
    if ([self.charactersRemaining integerValue] < 0) {
        return NO;
    }
    return YES;
}

- (NSString *)replaceUnicode:(NSString*)unicodeStr{
    NSString *tempStr1=[unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2=[tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3=[[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData=[tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr =[NSPropertyListSerialization propertyListFromData:tempData
                                                          mutabilityOption:NSPropertyListImmutable
                                                                    format:NULL
                                                          errorDescription:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

- (void)getFileData
{
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *dataType = itemProvider.registeredTypeIdentifiers.firstObject;//实际上一个NSItemProvider里也只有一种数据类型
            _dataType = dataType;
            
            [itemProvider loadItemForTypeIdentifier:dataType options:nil completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                if([(NSObject*)item isKindOfClass:[NSURL class]]) {
                    _fileUrl = (id)item;
                }
            }];
        }];
    }];
}

- (void)didSelectPost
{
    NSString *groupId = APP_GROUPS_SECURITY_ID2;
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:groupId];
    
    NSMutableDictionary *shareObj = [NSMutableDictionary dictionary];
    [shareObj setObject:_dataType?:@"" forKey:@"data_type"];
    NSString *fileUrl = [self replaceUnicode:_fileUrl.path];
    [shareObj setObject:fileUrl?:@"" forKey:@"data_url"];
    [shareObj setObject:self.contentText?:@"" forKey:@"share_text"];
    [sharedDefaults setObject:shareObj forKey:@"share_item_data"];
    [sharedDefaults synchronize];
    
    if (_fileUrl) {
        _fileData = [NSData dataWithContentsOfURL:_fileUrl];
    }
    if (_fileData) {
        NSURL *url = [self shareFileDir];
        NSString *fileName = [self replaceUnicode:_fileUrl.lastPathComponent];
        url = [url URLByAppendingPathComponent:fileName];
//        url = [url URLByAppendingPathComponent:_fileUrl.lastPathComponent];
        
        BOOL success = [_fileData writeToURL:url atomically:YES];
        
        if (!success) {
            NSLog(@"file error");
        } else {
            NSLog(@"file success");
        }
    } else {
        NSLog(@"url:%@, data:%@", _fileUrl, _fileData);
    }
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSURL *)shareFileDir
{
    NSError *error;
    NSURL *url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUPS_SECURITY_ID2];
    url = [url URLByAppendingPathComponent:@"share_file"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:url.path]) {
        if (![fileManager createDirectoryAtPath:url.path withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Unable to create folder at %@: %@", url.path, error.localizedDescription);
            return nil;
        }
    }
    return url;
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

- (NSString *)placeholder
{
    return @"分享内容";
}
@end
