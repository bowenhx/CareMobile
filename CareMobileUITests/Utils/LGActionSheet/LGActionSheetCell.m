//
//  LGActionSheetCell.m
//  TestSheetView
//
//  Created by bowen on 15/11/30.
//  Copyright © 2015年 xxxxxxx. All rights reserved.
//

#import "LGActionSheetCell.h"

#define kLGActionSheetSeparatorHeight ([UIScreen mainScreen].scale == 1.f || [UIDevice currentDevice].systemVersion.floatValue < 7.0 ? 1.f : 0.5)

@interface LGActionSheetCell ()

@property (strong, nonatomic) UILabel   *titleLabel;
@property (strong, nonatomic) UIView    *separatorView;

@end

@implementation LGActionSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
        
        _separatorView = [UIView new];
        [self addSubview:_separatorView];
    }
    return self;
}
/*<__NSArrayI 0x791815b0>(
 <UICTFont: 0x7916dfe0> font-family: ".SFUIText-Regular"; font-weight: normal; font-style: normal; font-size: 13.00pt
 )
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.text = _title;
    _titleLabel.textAlignment = _textAlignment;
    _titleLabel.font = _font;
    _titleLabel.numberOfLines = _numberOfLines;
    _titleLabel.lineBreakMode = _lineBreakMode;
    _titleLabel.adjustsFontSizeToFitWidth = _adjustsFontSizeToFitWidth;
    _titleLabel.minimumScaleFactor = _minimumScaleFactor;
    
    CGRect titleLabelFrame = CGRectMake(10.f, 0.f, self.frame.size.width-20.f, self.frame.size.height);
    
    if ([UIScreen mainScreen].scale == 1.f)
        titleLabelFrame = CGRectIntegral(titleLabelFrame);
    
    _titleLabel.frame = titleLabelFrame;
    
    if (self.isSeparatorVisible)
    {
        _separatorView.hidden = NO;
        _separatorView.backgroundColor = _separatorColor_;
        _separatorView.frame = CGRectMake(0.f, self.frame.size.height-kLGActionSheetSeparatorHeight, self.frame.size.width, kLGActionSheetSeparatorHeight);
    }
    else _separatorView.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        _titleLabel.textColor = _titleColorHighlighted;
        self.backgroundColor = _backgroundColorHighlighted;
    }
    else
    {
        _titleLabel.textColor = _titleColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        _titleLabel.textColor = _titleColorHighlighted;
        self.backgroundColor = _backgroundColorHighlighted;
    }
    else
    {
        _titleLabel.textColor = _titleColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

@end


