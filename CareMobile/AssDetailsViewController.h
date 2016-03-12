//
//  AssDetailsViewController.h
//  CareMobile
//
//  Created by Guibin on 16/3/12.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "BaseViewController.h"
//评估单详细
@interface AssDetailsViewController : BaseViewController
@property (nonatomic , copy) NSDictionary *dict;
@property (nonatomic , copy) NSString *assessID;
@property (nonatomic , copy) NSString *time;
@end
