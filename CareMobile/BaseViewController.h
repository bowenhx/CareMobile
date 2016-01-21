//
//  BaseViewController.h
//  BKMobile
//
//  Created by Guibin on 14/12/22.
//  Copyright (c) 2014年 com.mobile-kingdom.bkapps All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstantConfig.h"

@interface NavigationItemView : UIView
@property (nonatomic , strong) UIImageView *imageView;

@property (nonatomic , strong) UIButton *leftBtn;

@property (nonatomic , strong) UIButton *rightBtn;

@end;

@interface BaseViewController : UIViewController

@property (strong , nonatomic)  UINavigationBar *baseNavigationBar;

@property (nonatomic , strong) UILabel *navTitleLab;

@property (nonatomic , strong) NavigationItemView *navItemView;

@property (nonatomic , strong) NavigationItemView *rightItemView;

@property (nonatomic , strong) UIButton *backBtn;

@property (nonatomic , strong) UIButton *rightBtn;

@property (nonatomic , copy) NSString *backText;

- (void)tapBackBtn;

- (void)tapRightBtn;

- (void)navBarLeftAction;

- (void)navBarRightAction;

@end
