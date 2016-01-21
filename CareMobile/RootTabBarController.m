//
//  RootTabBarController.m
//  CareMobile
//
//  Created by Guibin on 15/10/29.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "RootTabBarController.h"
#import "AppDelegate.h"
#import "ConstantConfig.h"
//#import "LoginViewController.h"

@interface RootTabBarController ()<UITabBarDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UITabBar *_tabBar;
}

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置默认选择
    self.selectedIndex = 1;
    
    //设置文字大小
    for (int i=0; i<_tabBar.items.count; i++) {
        UITabBarItem *item = self.tabBar.items[i];
        [item setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
    }
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTabBar) name:SelectTabBarNotification object:nil];
}
//- (void)setSelectedIndex:(NSUInteger)selectedIndex
//{
//    if (selectedIndex == 3) {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"确定退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
//        return;
//    }
//}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [[AppDelegate getAppDelegate] showLoginVC];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didSelectTabBar
{
    self.selectedIndex = 1;
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
