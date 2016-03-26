//
//  DetailsViewController.h
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//
/*
 *  病人详情页面
 */
#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface DetailsViewController : BaseViewController

@property (nonatomic , copy) NSString *outKey;
@property (nonatomic , copy) NSDictionary *dict;

@end
