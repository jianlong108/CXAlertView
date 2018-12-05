//
//  CXCusKeyWindowRootViewController.m
//  CXAlertViewDemo
//
//  Created by Wangjianlong on 2018/12/5.
//  Copyright © 2018 ChrisXu. All rights reserved.
//

#import "CusKeyWindowRootViewController.h"

@interface CusKeyWindowRootViewController ()

@property(nonatomic, strong) CXCustomKeyWindow *keyWindow;

@end

@implementation CusKeyWindowRootViewController

- (instancetype)initWithCustomKeyWindow:(CXCustomKeyWindow *)customKeyWindow
{
    if (self = [super init]) {
        _keyWindow = customKeyWindow;
    }
    return self;
}

- (void)loadView
{
    self.view = self.keyWindow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.keyWindow setup];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
