//
//  SearchViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "SearchViewController.h"
#import "ConstantConfig.h"


@interface SearchViewController ()<UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    
    UIView *_pickViewBg;
    
    UIPickerView *_pickerView;
    
    UIView *_viewBg;
    
    NSMutableArray      *_dataSource;
    
    NSMutableArray      *_pickerData;
    
    UIButton            *_tempBtn;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    _scrollView.layer.borderWidth = 1;
//    _scrollView.layer.borderColor = [UIColor redColor].CGColor;
    
    [self loadDataView];
    
    [self loadDatas];
    
}
- (void)loadDataView
{
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _pickerData = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"SearchViewItem" owner:nil options:nil];
    _viewBg = views[0];
    _pickViewBg = views[1];
    _pickerView = [_pickViewBg viewWithTag:5];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    _scrollView.contentSize = CGSizeMake(WIDTH(_scrollView),HEIGHT(_viewBg));
    
    [_scrollView addSubview:_viewBg];

    UIButton *selectBtn = (UIButton *)[_viewBg viewWithTag:100];
    selectBtn.layer.cornerRadius = 3;
    selectBtn.layer.borderWidth = 1;
    selectBtn.layer.borderColor = [UIColor colorAppBg].CGColor;
    
    
    for (UIView *subView in [_viewBg subviews]) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subView;
            if (btn.tag == 100) {
                [selectBtn addTarget:self action:@selector(selectRYMZZ:) forControlEvents:UIControlEventTouchUpInside];
            }else{
                 [btn addTarget:self action:@selector(didSelectAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else if ([subView isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subView;
            textField.delegate = self;
        }
    }
    
    
}
- (void)loadDatas
{
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_SearchItem withParameter:@{} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            [_dataSource setArray:content];
        }
    }];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}
- (void)didSelectAction:(UIButton *)btn
{
    NSLog(@"btn.tag = %d",btn.tag);
    _tempBtn = btn;
    //更新pickView 数据
    switch (btn.tag) {
        case 10:
        {
           [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               if ([obj[@"oname"] isEqualToString:@"护理等级"]) {
                   [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
               }
               
           }];
        }
            break;
        case 11:
        {
            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"oname"] isEqualToString:@"饮食"]) {
                    [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
                }
                
            }];
        }
            break;
        case 12:
        {
            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"oname"] isEqualToString:@"医嘱"]) {
                    [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
                }
                
            }];
        }
            break;
        case 13:
        {
            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"oname"] isEqualToString:@"病情"]) {
                    [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
                }
                
            }];
        }
            break;
        case 14:
        {
            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"oname"] isEqualToString:@"护理常规"]) {
                    [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
                }
                
            }];
        }
            break;
        case 15:
        {
            [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj[@"oname"] isEqualToString:@"三日内大便"]) {
                    [_pickerData setArray:obj[@"ovalues"][@"ovalue"]];
                }
                
            }];
        }
            break;
        default:
            break;
    }

    [self showPickView];
}
- (void)selectRYMZZ:(UIButton *)btn
{
    btn.selected = !btn.selected;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectSearchAction:(UIButton *)sender {
    NSLog(@"开始搜索");
    [self.view showHUDActivityView:@"正在搜索" shade:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view removeHUDActivity];
        [self.view showHUDTitleView:@"服务器出错，请重新搜索" image:nil];
        
    });
    
}
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self changeViewSize:textField.tag show:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag == 20 || tag == 21) {
        tag ++;
        textField = [_viewBg viewWithTag:tag];
        [textField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        [self changeViewSize:tag show:NO];
    }
    return YES;
}
- (void)changeViewSize:(NSInteger)tag show:(BOOL)isShow{
    if (isShow) {
        float height = 80;
        if (tag > 20) {
            height = 150;
            if (tag == 22) {
                height = 200;
            }
        }
        [UIView animateWithDuration:.3f animations:^{
            CGRect rect = _viewBg.frame;
            rect.origin.y = -height;
            _viewBg.frame = rect;
        }];

    }else{
        if (Y(_viewBg) != 0) {
            [UIView animateWithDuration:.3f animations:^{
                CGRect rect = _viewBg.frame;
                rect.origin.y = 0;
                _viewBg.frame = rect;
            }];
        }
        
        for (UITextField *textF in [_viewBg subviews]) {
            if ([textF isKindOfClass:[UITextField class]]) {
                if ([textF isFirstResponder]) {
                    [textF resignFirstResponder];
                }
            }
        }
    }
    
}

#pragma  mark PickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerData[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *name = _pickerData[row];
    [_tempBtn setTitle:name forState:UIControlStateNormal];
}

- (void)showPickView
{
    CGRect rect = _pickViewBg.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _pickViewBg.frame = rect;
    if (!_pickViewBg.superview) {
        [self.view addSubview:_pickViewBg];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _pickViewBg.frame;
        frame.origin.x = 0;
        frame.origin.y = HEIGHT(self.view) - _pickViewBg.frame.size.height;
        _pickViewBg.frame = frame;
    }];
    
    [_pickerView reloadAllComponents];
}
- (void)didHiddenPickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _pickViewBg.frame;
        rect.origin.x = 0;
        rect.origin.y = SCREEN_HEIGHT;
        _pickViewBg.frame = rect;
        
        
    } completion:^(BOOL finished) {
        [_pickViewBg removeFromSuperview];
    }];
    
}
- (IBAction)tapGestureHiddenPickerViewAction:(UITapGestureRecognizer *)sender {
    [self didHiddenPickerView];
    [self changeViewSize:0 show:NO];
}




@end
