//
//  UIColor+app.m
//  BKMobile
//
//  Created by Guibin on 15/1/23.
//  Copyright (c) 2015年 com.mobile-kingdom.bkapps All rights reserved.
//

#import "UIColor+app.h"

@implementation UIColor (AppUIColor)

/**
 *  app 全局主色调，包括导航背景
 *
 *  @return
 */
+ (UIColor *)colorAppBg
{
    return RGB(84, 162, 228);
}
/**
 *  设置view 背景及tabView 的背景颜色
 *
 *  @return UIColor
 */
+ (UIColor *)colorViewBg
{
    return RGB(240, 239, 245);
}
/**
 *  设置cell的颜色
 *
 *  @return UIColor
 */
+ (UIColor *)colorCellBg
{
    return RGB(135, 220, 210);
}

/**
 *  设置cell 线条灰色
 *
 *  @return UIColor
 */
+ (UIColor *)colorMemberFBg{
    return RGB(210, 220, 200);
}
@end

@implementation UIImage (BImage_Color)

/**
 *  根据颜色和尺寸返回一个image
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context,color.CGColor);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    }
}


@end

