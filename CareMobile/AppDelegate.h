//
//  AppDelegate.h
//  CareMobile
//
//  Created by Guibin on 15/10/29.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate *)getAppDelegate;
- (void)showLoginVC;
@end

