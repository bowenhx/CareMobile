//
//  ScanViewController.h
//  CareMobile
//
//  Created by Guibin on 15/11/14.
//  Copyright © 2015年 MobileCare. All rights reserved.
//
/*
 *  扫码功能页面
 */
#import "BaseViewController.h"

typedef enum {
    ScanTypeSearchAction = 0,
    ScanTypeLoginAction  = 1,
    ScanTypeAdviceActon  = 2,       //医嘱执行单
} ScanType;



@interface ScanViewController : BaseViewController

@property (nonatomic , strong) UIColor  *color;
@property ( nonatomic )        ScanType scanType;
//@property (nonatomic , assign)NSInteger isSearch;
/*
@property (nonatomic , copy) NSString *navTitle;

@property (nonatomic , copy) NSDictionary *dict;

@property (nonatomic , copy) NSString *strAge;

@property (nonatomic , copy) NSString *JYID;*/

@property (nonatomic , copy) void (^didUpdataDicBlock)(NSDictionary *dictInfo);
@end
