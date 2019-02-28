//
//  ViewController.m
//  tttest
//
//  Created by cheng on 16/1/11.
//  Copyright © 2016年 cheng. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import "DTFileShareManager.h"
#import "TableViewController.h"
#import "FFJSONHelper.h"

@interface ViewController () <
UIDocumentPickerDelegate
,UIDocumentBrowserViewControllerDelegate
,TableViewControllerDelegate
>

{
    
    __weak IBOutlet UITextView *textView;
    
    __weak IBOutlet UIImageView *imageView;
    
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UIButton *btn2;
    __weak IBOutlet UIButton *btn3;
    __weak IBOutlet UIButton *btn4;
    
    __weak IBOutlet UISwitch *showShareSwitch;
    NSInteger _btnTag;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    textView.text = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShareContent:) name:@"APP_EnterForeground" object:nil];
    
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

- (IBAction)showShareContent:(id)sender {
    if (showShareSwitch.on) {
        NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID2];
        NSDictionary *shareItem = [sharedDefaults objectForKey:@"share_item_data"];
        if (shareItem) {
            NSString *string = [NSString stringWithFormat:@"%@", shareItem];
        
            textView.text = [self replaceUnicode:string];
        }
        
        NSString *type = [shareItem objectForKey:@"data_type"];
        
        if ([type rangeOfString:@"image"].length || [type rangeOfString:@"png"].length) {
            NSString *path = [shareItem objectForKey:@"data_url"];
            NSString *fileName = path.lastPathComponent;
            
            NSURL *url = [self shareFileDir];
            
            url = [url URLByAppendingPathComponent:fileName];
            
            path = url.path;
            imageView.image = [UIImage imageWithContentsOfFile:path];
        }
    }
}

- (IBAction)btnAction:(UIButton *)sender {

    _btnTag = sender.tag;
    switch (_btnTag) {
        case 1:
        case 2:
        {
            //查看沙盒文件
            UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.image",@"public.pdf",@"public.txt",@"public.data"] inMode:UIDocumentPickerModeImport];
            vc.delegate = self;
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_11_0
            vc.allowsMultipleSelection = YES;
#endif
            [self presentViewController:vc animated:YES completion:^{
                
            }];
            
            /*//ios 11
             UIDocumentBrowserViewController *vc = [[UIDocumentBrowserViewController alloc] initForOpeningFilesWithContentTypes:@[@"public.image"]];
             vc.delegate = self;
             vc.allowsDocumentCreation = YES;
             vc.allowsPickingMultipleItems = YES;
             [self presentViewController:vc animated:YES completion:^{
             
             }];
             */
        }
            break;
            break;
        case 3:
        {
            NSString *path = DOCPATH(@"share_file");
            NSArray<NSString *> *array = [DTFileManager contentsWithPath:path];
            
            TableViewController *vc = [[TableViewController alloc] init];
            vc.dataSource = array;
            vc.path = path;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 4:
        {
            NSURL *url = [self shareFileDir];
            
            NSArray<NSString *> *array = [DTFileManager contentsWithPath:url.path];
            
            TableViewController *vc = [[TableViewController alloc] init];
            vc.dataSource = array;
            vc.path = url.path;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
    
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID2];
//    id shareItemData = [sharedDefaults objectForKey:@"share_item_data"];
//    id shareItemString = [sharedDefaults objectForKey:@"share_item_string"];
//    id shareItem = shareItemData;
//    if (shareItem) {
//        NSLog(@"share_item:%@", shareItem);
//
//        label1.text = [NSString stringWithFormat:@"%@", shareItem];
//
//        if ([shareItem isKindOfClass:[NSDictionary class]]) {
//            NSURL *url = [shareItem objectForKey:@"share_url"];
//            NSString *urlStr = [shareItem objectForKey:@"share_url_string"];
//            if (url) {
//                [DTFileShareManager handleOpenURL:url];
//            } else {
//                url = [NSURL URLWithString:urlStr];
//
//                [DTFileShareManager handleOpenURL:url];
//            }
//        } else if ([shareItem isKindOfClass:[NSString class]]) {
//            NSDictionary *dict = [shareItem JSONObject];
//            if (dict) {
//                NSURL *url = [dict objectForKey:@"share_url"];
//                [DTFileShareManager handleOpenURL:url];
//            }
//        }
//
//
//    } else {
//        label1.text = @"null";
//    }
//    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    textView.text = [NSString stringWithFormat:@"%@",urls];
    [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (_btnTag == 1) {
            [DTFileShareManager handleOpenURL:obj];
        } else if (_btnTag == 2) {
            [DTFileShareManager shareFileWithURL:obj];
        }
    }];
}

#pragma mark - UIDocumentBrowserViewControllerDelegate

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentURLs:(NSArray<NSURL *> *)documentURLs
{
    NSLog(@"urls = %@", documentURLs);
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didRequestDocumentCreationWithHandler:(void (^)(NSURL * _Nullable, UIDocumentBrowserImportMode))importHandler
{
    NSLog(@"imprt hanlder");
//    NSString *name = [NSNumber numberWithDouble:CFAbsoluteTimeGetCurrent()].stringValue;
//    NSURL *url = [NSURL fileURLWithPath:DOCPATH(name)];
//    importHandler(url, UIDocumentBrowserImportModeCopy);
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didImportDocumentAtURL:(NSURL *)sourceURL toDestinationURL:(NSURL *)destinationURL
{
    //todo 需要主动消失
    NSLog(@"import = %@, %@", sourceURL, destinationURL);
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableViewControllerDelegate

- (void)TableViewController:(TableViewController *)vc path:(NSString *)path
{
    textView.text = [NSString stringWithFormat:@"%@",path];
    
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    if (_btnTag == 3) {
        [DTFileShareManager shareFileWithPath:path];
    } else if (_btnTag == 4) {
        NSString *toPath = [DTFileShareManager pathWithName:path.lastPathComponent];
        [DTFileManager copyItemWithPath:path toPath:toPath];
    }
}

@end
