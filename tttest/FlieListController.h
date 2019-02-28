//
//  TableViewController.h
//  tttest
//
//  Created by cheng on 2019/2/24.
//  Copyright © 2019年 cheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlieListController;

@protocol FlieListControllerDelegate<NSObject>

@optional

- (void)FlieListController:(FlieListController *)vc path:(NSString *)path;

@end

@interface FlieListController : UITableViewController

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSString *path;//if nil, has default path

@property (nonatomic, weak) id<FlieListControllerDelegate> delegate;

@end
