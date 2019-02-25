//
//  ShareViewController.m
//  share
//
//  Created by cheng on 16/8/12.
//  Copyright © 2016年 cheng. All rights reserved.
//

#import "ShareViewController.h"
#import "TTDefine.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

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

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext.inputItems enumerateObjectsUsingBlock:^(NSExtensionItem * _Nonnull extItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [extItem.attachments enumerateObjectsUsingBlock:^(NSItemProvider * _Nonnull itemProvider, NSUInteger idx, BOOL * _Nonnull stop) {
            NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID];
            NSString *dataType = itemProvider.registeredTypeIdentifiers.firstObject;//实际上一个NSItemProvider里也只有一种数据类型
            [sharedDefaults setObject:dataType?:@"" forKey:@"dataType"];
            if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"])
            {
                [itemProvider loadItemForTypeIdentifier:@"public.url"
                                                options:nil
                                      completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                                          
                                          if ([(NSObject *)item isKindOfClass:[NSURL class]])
                                          {
                                              NSLog(@"分享的URL = %@", item);
                                              [sharedDefaults setValue: ((NSURL *)item).absoluteString forKey:@"share-url"];
                                              //用于标记是新的分享
                                              [sharedDefaults setBool:YES forKey:@"has-new-share"];
                                          }
                                          
                                      }];
            } else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.png"]||[itemProvider hasItemConformingToTypeIdentifier:@"public.image"]||[itemProvider hasItemConformingToTypeIdentifier:@"public.jpeg"]) {
                [itemProvider loadItemForTypeIdentifier:dataType options:nil completionHandler: ^(id<NSSecureCoding> item, NSError *error) {
                    NSData *imgData;
                    if([(NSObject*)item isKindOfClass:[NSURL class]]) {
                        imgData = [NSData dataWithContentsOfURL:(NSURL*)item];
                    }
                    if([(NSObject*)item isKindOfClass:[UIImage class]]) {
                        imgData = UIImagePNGRepresentation((UIImage*)item);
                    }
                    
                    NSObject *obj = (id)item;
                    NSString *claStr = NSStringFromClass([obj class]);
                    NSDictionary *dict = @{
                                           @"imgData" : imgData?:@"",
                                           @"type" : dataType?:@"",
                                           @"class" : claStr?:@"",
                                           @"text" : self.contentText?:@""
                                           };
                    [sharedDefaults setObject:dict forKey:@"img"];
                    [sharedDefaults synchronize];
                }];
            }
        }];
    }];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSArray *inputItems = self.extensionContext.inputItems;
//        NSExtensionItem *item = inputItems.firstObject;//无论多少数据，实际上只有一个 NSExtensionItem 对象
//        NSInteger i = 0;
//        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID];
//        for (NSItemProvider *provider in item.attachments) {
//            //completionHandler 是异步运行的
//            NSString *dataType = provider.registeredTypeIdentifiers.firstObject;//实际上一个NSItemProvider里也只有一种数据类型
//            [sharedDefaults setObject:dataType forKey:@"sharetype"];
//            [sharedDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:provider] forKey:[NSString stringWithFormat:@"shareObj-%zd", i]];
//            i++;
//            if ([dataType isEqualToString:@"public.image"]) {
//                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(UIImage *image, NSError *error){
//                    //collect image...
//                }];
//            }else if ([dataType isEqualToString:@"public.text"]){
//                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSString *contentText, NSError *error){
//                    //collect image...
//                    [sharedDefaults setObject:contentText forKey:@"share"];
//                }];
//            }else if ([dataType isEqualToString:@"public.url"]){
//                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSURL *url, NSError *error){
//                    //collect url...
//                }];
//            }else
//                NSLog(@"don't support data type: %@", dataType);
//        }
//        [sharedDefaults setInteger:i forKey:@"shareItemCount"];
//    });
    
    //    NSArray *array = [item.attachments registeredTypeIdentifiers];
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
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