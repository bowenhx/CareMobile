//
//  AppDelegate.m
//  CareMobile
//
//  Created by Guibin on 15/10/29.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "AppDelegate.h"
#import "ConstantConfig.h"
#import "LoginViewController.h"
static AppDelegate *_appDelegate;
@interface AppDelegate ()

@end

@implementation AppDelegate
+ (AppDelegate *)getAppDelegate
{
    return _appDelegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _appDelegate = self;
    
    NSLog(@"userID = %@",USERID);
    if (USERID == nil || [@"" isStringBlank:USERID]) {
        //启动后首先进入登陆界面
        [self beginShowLoginView];
        self.window.backgroundColor = [UIColor whiteColor];
    }else{
        //使用Storyboard初始化根界面
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyBoard instantiateInitialViewController];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}
- (void)showLoginVC{
    
    if (self.window.rootViewController.view != nil) {
        [self.window.rootViewController.view removeFromSuperview];
    }
    
    [self beginShowLoginView];
}
- (void)beginShowLoginView
{
    //启动后首先进入登陆界面
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

//    if (self.window.rootViewController.view != nil) {
//        [self.window.rootViewController.view removeFromSuperview];
//    }
//
//     [[SavaData shareInstance] savadataStr:@"" KeyString:USER_ID_KEY];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
//    [self showLoginVC];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
