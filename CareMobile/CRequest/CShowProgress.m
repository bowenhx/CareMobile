//
//  CShowProgress.m
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "CShowProgress.h"
#import "ConstantConfig.h"
@implementation CShowProgress

+ (id)shareInstance
{
    static CShowProgress *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[CShowProgress alloc] initWithFrame:CGRectMake((SCREEN_WIDTH -120 )/2, SCREEN_HEIGHT / 2 - 100, 120, 100)];
    });
    return _shareInstance;
    
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];
        self.alpha = .7;
        self.layer.cornerRadius = 6;
        
        NSMutableArray *gifArray = [NSMutableArray array];
        for (int i=1; i <= 16; i++) {
            NSString *strName = [NSString stringWithFormat:@"progress_%d.png",i];
            UIImage *image = [UIImage imageNamed:strName];
            [gifArray addObject:image];
        }
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 50)/2, 10, 50, 50 )];
        imgView.animationImages = gifArray; //动画图片数组
        imgView.animationDuration = 2.0; //执行一次完整动画所需的时长
        imgView.animationRepeatCount = 99999999;  //动画重复次数
        [imgView startAnimating];
        
        [self addSubview:imgView];
        
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 20)];
        _textLab.text = @"正在加载";
        _textLab.font = [UIFont boldSystemFontOfSize:16];
        _textLab.textColor = [UIColor whiteColor];
        _textLab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLab];
    }
    return self;
}

@end
