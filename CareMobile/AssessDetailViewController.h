//
//  AssessDetailViewController.h
//  CareMobile
//
//  Created by bowen on 16/1/5.
//  Copyright © 2016年 MobileCare. All rights reserved.
//
//护理评估页面
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface AssessDetailViewController : BaseViewController

@property (nonatomic , copy)NSDictionary *dict;
@property (nonatomic , copy)NSString *assessID;
@end
