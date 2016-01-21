//
//  LGActionSheetCell.h
//  TestSheetView
//
//  Created by bowen on 15/11/30.
//  Copyright © 2015年 xxxxxxx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGActionSheetCell : UITableViewCell

@property (strong, nonatomic) NSString  *title;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIColor *titleColorHighlighted;

@property (strong, nonatomic) UIColor *backgroundColorHighlighted;

@property (assign, nonatomic, getter=isSeparatorVisible) BOOL separatorVisible;
@property (strong, nonatomic) UIColor *separatorColor_;

@property (strong, nonatomic) NSArray         *fonts;
@property (strong, nonatomic) UIFont          *font;
@property (assign, nonatomic) NSUInteger      numberOfLines;
@property (assign, nonatomic) NSLineBreakMode lineBreakMode;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (assign, nonatomic) BOOL            adjustsFontSizeToFitWidth;
@property (assign, nonatomic) CGFloat         minimumScaleFactor;

@end
