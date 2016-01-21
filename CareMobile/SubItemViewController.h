//
//  SubItemViewController.h
//  CareMobile
//
//  Created by Guibin on 15/11/4.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface SubItemViewController : BaseViewController


@property (nonatomic , copy) NSString *strTime;
@property (nonatomic , strong) NSMutableDictionary *dictTime;

@property (nonatomic , copy) NSDictionary *dict;

@property (nonatomic , copy) NSString *navTitle;

@property (nonatomic , copy) NSString *huliTime;

@property (nonatomic , copy) NSString *navRight;
@end
