//
//  CourseDetailViewController.h
//  CareMobile
//
//  Created by Stray on 15/11/30.
//  Copyright © 2015年 MobileCare. All rights reserved.
//
/*
 *  病程录页面
 */
#import "BaseViewController.h"

@interface CourseDetailViewController : BaseViewController

@property (nonatomic , copy)NSString *typeTitle;
@property (nonatomic , copy)NSString *typeBCID;
@property (nonatomic , copy) NSDictionary *dict;
@end
