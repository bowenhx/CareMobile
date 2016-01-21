//
//  CABackBarButtonltem.m
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "CABackBarButtonltem.h"

@implementation CABackBarButtonltem

- (id)initWithTitle:(NSString*)title target:(id)target action:(SEL)action
{
    title = (title == nil ? @"" : title);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"def_btn_Return_unpressed"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    CGSize size = [title boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]} context:nil].size;
    button.frame = CGRectMake(0, 0, size.width + 16, 30);
    return [[super init] initWithCustomView:button];
}


@end
