//
//  BaseViewController.m
//  BKMobile
//
//  Created by Guibin on 14/12/22.
//  Copyright (c) 2014年 com.mobile-kingdom.bkapps All rights reserved.
//

#import "BaseViewController.h"

@interface NavigationItemView ()

@end
@implementation NavigationItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self showView];
    }
    return self;
}
- (void)showView
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
//    _imageView.layer.borderWidth = 1;
//    _imageView.layer.borderColor = [UIColor redColor].CGColor;
    [self addSubview:_imageView];

    //左按钮
    _leftBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(4, 4, self.bounds.size.width/2-6, self.bounds.size.height-8);
    _leftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _leftBtn.titleLabel.font = GETBOLDFONT(13.0);
    _leftBtn.layer.borderWidth = 1;
    _leftBtn.layer.borderColor = [UIColor greenColor].CGColor;
    [self addSubview:_leftBtn];
    
   

    //右按钮
    _rightBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(self.bounds.size.width/2+2, 4, self.bounds.size.width/2-6, self.bounds.size.height-8);
    _rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _rightBtn.titleLabel.font = GETBOLDFONT(13.0);
    _rightBtn.layer.borderWidth = 1;
    _rightBtn.layer.borderColor = [UIColor grayColor].CGColor;
    [self addSubview:_rightBtn];
    

    
    
}
@end

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [[self view] setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self backBtn];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (UILabel *)navTitleLab
{
    if (nil == _navTitleLab) {
        _navTitleLab = [[UILabel alloc] initWithFrame: CGRectMake(80, 20, 160, 24)];
        _navTitleLab.backgroundColor = [UIColor clearColor];
        _navTitleLab.font = GETBOLDFONT(22.0);
        _navTitleLab.textColor = [UIColor blackColor];
        _navTitleLab.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = _navTitleLab;
    }
    return _navTitleLab;
    
}
- (NavigationItemView *)navItemView
{
    if (nil == _navItemView) {
        _navItemView = [[NavigationItemView alloc] initWithFrame: CGRectMake(100, 2, 120, 40)];
        _navItemView.backgroundColor = [UIColor whiteColor];
        _navItemView.layer.cornerRadius = 20;

        //添加滑动手势
        UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
        UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
        
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [_navItemView.leftBtn addGestureRecognizer:rightSwipeGestureRecognizer];
        [_navItemView.rightBtn addGestureRecognizer:leftSwipeGestureRecognizer];
        
        self.navigationItem.titleView = _navItemView;
        
        //设置左右buttn
        _navItemView.leftBtn.layer.cornerRadius = 15;
        _navItemView.leftBtn.backgroundColor = [UIColor grayColor];
       
        _navItemView.rightBtn.layer.cornerRadius = 15;
       
        [_navItemView.leftBtn addTarget:self action:@selector(navBarLeftAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_navItemView.rightBtn addTarget:self action:@selector(navBarRightAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navItemView;
}
- (NavigationItemView *)rightItemView
{
    if (nil == _rightItemView) {
        _rightItemView = [[NavigationItemView alloc] initWithFrame: CGRectMake(WIDTH(self.view)-80, 0, 80, 44)];
        _rightItemView.backgroundColor = [UIColor clearColor];
        _rightItemView.layer.borderWidth = 1;
        _rightItemView.layer.borderColor = [UIColor greenColor].CGColor;
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView: _rightItemView];
        right.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = right;

    }
    return _rightItemView;
}
- (UIButton *)backBtn
{
    if (nil == _backBtn) {
        //返回按钮
        UIImage *backImage = [UIImage imageNamed:@"def_btn_Return_unpressed"];
        _backBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
        _backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 10);
        _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_backBtn setImage: backImage forState: UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_backBtn addTarget: self action: @selector(tapBackBtn) forControlEvents: UIControlEventTouchUpInside];
        UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView: _backBtn];
        left.style = UIBarButtonItemStylePlain;
        self.navigationItem.leftBarButtonItem = left;
    }
    return _backBtn;
}
- (UIButton *)rightBtn
{
    if (nil == _rightBtn) {
        //右按钮
        _rightBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 60, 30);
        _rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _rightBtn.titleLabel.font = GETBOLDFONT(18.0);
        [_rightBtn addTarget: self action: @selector(tapRightBtn) forControlEvents: UIControlEventTouchUpInside];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView: _rightBtn];
        right.style = UIBarButtonItemStylePlain;
        self.navigationItem.rightBarButtonItem = right;
    }
    return _rightBtn;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
#else
    NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
    CGRect keyboardBounds;
    [keyboardBoundsValue getValue:&keyboardBounds];
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setBackText:(NSString *)backText
{
    [self.backBtn setTitle:backText forState:UIControlStateNormal];
    CGSize size = [backText boundingRectWithSize:CGSizeMake(200, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size;
    self.backBtn.frame = CGRectMake(0, 0, size.width + 40, 44);

}
- (void)tapBackBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)tapRightBtn
{
    
}
//滑动手势方法
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self navBarLeftAction];
    }else if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self navBarRightAction];
    }
}
- (void)navBarLeftAction
{
    _navItemView.leftBtn.backgroundColor = [UIColor grayColor];
    _navItemView.rightBtn.backgroundColor = [UIColor whiteColor];
}
- (void)navBarRightAction
{
    _navItemView.rightBtn.backgroundColor = [UIColor grayColor];
    _navItemView.leftBtn.backgroundColor = [UIColor whiteColor];
   
}



@end
