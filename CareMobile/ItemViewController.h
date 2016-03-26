//
//  ItemViewController.h
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//
/*
 *  详情分类页面
 */
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ItemViewController : BaseViewController

@property (nonatomic , copy) NSString *navTitle;

@property (nonatomic , copy) NSDictionary *dict;

@property (nonatomic , copy) NSString *JYID;

@end
