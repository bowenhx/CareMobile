//
//  ViewController.m
//  CareMobile
//
//  Created by Guibin on 15/10/29.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ConstantConfig.h"
@interface ViewController ()<UIAlertViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[UIAlertView alloc] initWithTitle:nil message:@"确定退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        /**
         *  清除用户userid
         */
        [[SavaData shareInstance] savadataStr:@"" KeyString:USER_ID_KEY];

        [[AppDelegate getAppDelegate] showLoginVC];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:SelectTabBarNotification object:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
