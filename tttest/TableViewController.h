//
//  TableViewController.h
//  tttest
//
//  Created by cheng on 2019/2/24.
//  Copyright © 2019年 cheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TableViewController;

@protocol TableViewControllerDelegate<NSObject>

@optional

- (void)TableViewController:(TableViewController *)vc path:(NSString *)path;

@end

@interface TableViewController : UITableViewController

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) NSString *path;//if nil, has default path

@property (nonatomic, weak) id<TableViewControllerDelegate> delegate;

@end
