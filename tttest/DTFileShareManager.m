//
//  DTFileShareManager.m
//  tttest
//
//  Created by cheng on 2019/2/22.
//  Copyright © 2019 cheng. All rights reserved.
//

#import "DTFileShareManager.h"

@interface DTFileShareManager () <UIDocumentInteractionControllerDelegate>
{
    
}

@end

BOOL FFCreateFolderIfNeeded(NSString *dirPath) {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:dirPath]) {
        if (![fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Unable to create folder at %@: %@", dirPath, error.localizedDescription);
            return NO;
        }
    }
    return YES;
}

@implementation DTFileShareManager

SHARED_INSTANCE_M

+ (NSString *)sharePath
{
    NSString *filePath = DOCPATH(@"share_file");
    FFCreateFolderIfNeeded(filePath);
    return filePath;
}

+ (NSString *)pathWithName:(NSString *)name
{
    return [[self sharePath] stringByAppendingPathComponent:name];
}

+ (BOOL)handleOpenURL:(NSURL *)url
{
    if ([url.scheme isEqualToString:@"file"]) {
        UIDocumentInteractionController *_docVc = [UIDocumentInteractionController interactionControllerWithURL:url];
        _docVc.delegate = [self sharedInstance];
        [_docVc presentPreviewAnimated:YES];
        
        [self saveFileWithUrl:url];
        
        return YES;
    }
    
    return NO;
}

+ (BOOL)saveFileWithUrl:(NSURL *)url
{
    if (url != nil) {
        NSString *string = [[url absoluteString] stringByRemovingPercentEncoding];
        NSMutableString *path = [[NSMutableString alloc] initWithString:string];
        if ([path hasPrefix:@"file:///private"]) {
            //todo 1
            [path replaceOccurrencesOfString:@"file:///private" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, path.length)];
        }

        NSString *fileName = url.lastPathComponent;
        NSString *filePath = DOCPATH(@"share_file");
        FFCreateFolderIfNeeded(filePath);
        filePath = [filePath stringByAppendingPathComponent:fileName];
        
        if ([DTFileManager isFileExist:filePath]) {
            NSLog(@"文件已存在");
            return YES;
        }
        BOOL success = [DTFileManager copyItemWithPath:path toPath:filePath];
        if (success) {
            NSLog(@"save success");
        } else {
            NSLog(@"save fail");
        }
        return success;
    }
    return NO;
}

+ (void)shareFileWithPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    [self shareFileWithURL:url];
}

+ (void)shareFileWithURL:(NSURL *)url
{
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIDocumentInteractionController *vc = [UIDocumentInteractionController interactionControllerWithURL:url];
    vc.delegate = [self sharedInstance];
    vc.UTI = [self getUTIFromPath:url.absoluteString];
    
    NSLog(@"path: %@, UTI: %@", url.absoluteString, vc.UTI);
    
    //todo 2
    [DTFileShareManager sharedInstance].doc = vc;
    
    [vc presentOpenInMenuFromRect:CGRectZero
                           inView:root.view
                         animated:YES];
}

+ (NSString *)getUTIFromPath:(NSString *)path
{
    NSString *fileName = path.lastPathComponent;
    NSString *fileType = [[fileName componentsSeparatedByString:@"."].lastObject lowercaseString];
    if ([fileType isEqualToString:@"pdf"]) {
        return @"com.adobe.pdf";
    } else if ([fileType isEqualToString:@"jpg"] || [fileType isEqualToString:@"jpeg"] || [fileType isEqualToString:@"png"]) {
        return @"public.image";
    } else if ([fileType isEqualToString:@"txt"] || [fileType isEqualToString:@"html"] || [fileType isEqualToString:@"h"] || [fileType isEqualToString:@"m"]) {
        return @"public.txt";
    }
    return @"public.data";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application
{
    NSLog(@"will begin");
}
- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(nullable NSString *)application
{
    NSLog(@"did end");
}

@end
