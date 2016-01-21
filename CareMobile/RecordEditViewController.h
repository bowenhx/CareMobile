//
//  RecordEditViewController.h
//  CareMobile
//
//  Created by Guibin on 16/1/7.
//  Copyright © 2016年 MobileCare. All rights reserved.
//
//编辑记录单保存提交
#import "BaseViewController.h"

@interface RecordEditViewController : BaseViewController

@property (nonatomic , copy) NSString *navString;
@property (nonatomic , copy) NSDictionary *dict;
@property (nonatomic , assign) NSInteger recID;


@property (nonatomic , copy) NSArray *data;

@end
