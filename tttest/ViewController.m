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

@interface ViewController () <UIDocumentPickerDelegate, UIDocumentBrowserViewControllerDelegate> {
    UIImageView *_imageV;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID];
    NSDictionary *dict = [sharedDefaults objectForKey:@"img"];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageV];
    
    imageV.image = [UIImage imageWithData:[dict objectForKey:@"imgData"]];
    imageV.alpha = 0.5;
    
    _imageV = imageV;
}

- (IBAction)btnAction:(id)sender {
//    _imageV.hidden = !_imageV.hidden;
//    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUPS_SECURITY_ID];
//    NSDictionary *dict = [sharedDefaults objectForKey:@"img"];
//    NSLog(@"shareType = %@", [dict objectForKey:@"type"]);
//    NSLog(@"shareText = %@", [dict objectForKey:@"text"]);
//    NSLog(@"shareClass = %@", [dict objectForKey:@"class"]);
//    NSLog(@"dataType  = %@", [sharedDefaults objectForKey:@"dataType"]);
    
    UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.image",@"public.pdf",@"public.txt",@"public.data"]
                                                                                                inMode:UIDocumentPickerModeImport];
    vc.delegate = self;
    vc.allowsMultipleSelection = YES;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
    
}
- (IBAction)browserAction:(id)sender {
    //ios 11
    UIDocumentBrowserViewController *vc = [[UIDocumentBrowserViewController alloc] initForOpeningFilesWithContentTypes:@[@"public.image"]];
    vc.delegate = self;
    vc.allowsDocumentCreation = YES;
    vc.allowsPickingMultipleItems = YES;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}
- (IBAction)shareAction:(id)sender {
    
    NSArray<NSString *> *array = [DTFileManager contentsWithPath:[DTFileShareManager sharePath]];
    
    TableViewController *vc = [[TableViewController alloc] init];
    vc.dataSource = array;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    NSLog(@"url = %@", url);
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    NSLog(@"urls = %@", urls);
    [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [DTFileShareManager shareFileWithURL:obj];
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
    NSLog(@"import = %@, %@", sourceURL, destinationURL);
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end