//
//  RetrievalViewController.m
//  CareMobile
//
//  Created by bowen on 16/1/19.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "RetrievalViewController.h"
#import "WardHistoryViewController.h"

@interface RetrievalViewController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UITextField *_textFieldName;
    
    __weak IBOutlet UITextField *_textFieldNumber;
    
    __weak IBOutlet UIButton *_beginTimeBtn;
    
    __weak IBOutlet UIButton *_endTimeBtn;
    
    
    IBOutlet UIView *_datePickViewBg;
    __weak IBOutlet UIDatePicker *_datePickerView;
    NSInteger _indexTime;
}
@end

@implementation RetrievalViewController

- (void)setDatePickerViewBg
{
    /**
     *  设置_datePckerVIew 的frame适应屏幕尺寸
     */
    _datePickViewBg.backgroundColor = [UIColor colorViewBg];
    CGRect rect = _datePickViewBg.frame;
    rect.size.width = SCREEN_WIDTH;
    _datePickViewBg.frame = rect;
    
    UIView *pickerV = (UIView *)[_datePickViewBg viewWithTag:20];
    for (UIView *label in pickerV.subviews) {
        label.backgroundColor = [UIColor colorAppBg];
    }
    
    [_datePickerView setDatePickerMode:UIDatePickerModeDate];
    //[_datePickerView setMaximumDate:[NSDate date]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"巡视条件搜索";
    
    [self setDatePickerViewBg];
    
    _beginTimeBtn.layer.borderWidth = 1;
    _beginTimeBtn.layer.borderColor =  [UIColor colorViewBg].CGColor;
    _beginTimeBtn.layer.cornerRadius = 5;

    _endTimeBtn.layer.borderWidth = 1;
    _endTimeBtn.layer.borderColor =  [UIColor colorViewBg].CGColor;
    _endTimeBtn.layer.cornerRadius = 5;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]];
    
    [_endTimeBtn setTitle:strDate forState:0];
    
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:-(7*24*60*60)];
    NSString *beginDate = [formatter stringFromDate:date];
    
    [_beginTimeBtn setTitle:beginDate forState:0];
    
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 5) {
        [_textFieldNumber becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
- (IBAction)selectTimeTypeAction:(UIButton *)sender{
    _indexTime = sender.tag;
    
    [self showDatePickerView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showDatePickerView
{
    
    CGRect rect = _datePickViewBg.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _datePickViewBg.frame = rect;
    if (!_datePickViewBg.superview) {
        [self.view addSubview:_datePickViewBg];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _datePickViewBg.frame;
        frame.origin.y = SCREEN_HEIGHT - _datePickViewBg.frame.size.height;
        _datePickViewBg.frame = frame;
    }];
    
}
- (void)didHiddenDatePickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _datePickViewBg.frame;
        rect.origin.y = SCREEN_HEIGHT;
        _datePickViewBg.frame = rect;
        
    } completion:^(BOOL finished) {
        [_datePickViewBg removeFromSuperview];
    }];
    
}
- (IBAction)selectSumAction:(id)sender
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_WardHistory withParameter:@{@"uid":USERID,@"name":_textFieldName.text,@"room":_textFieldNumber.text,@"bt":_beginTimeBtn.titleLabel.text,@"et":_endTimeBtn.titleLabel.text} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            
            WardHistoryViewController *wardHistoryVC = [[WardHistoryViewController alloc] initWithNibName:@"WardHistoryViewController" bundle:nil];
            [wardHistoryVC.dataSource setArray:data];
            [self.navigationController pushViewController:wardHistoryVC animated:YES];
            
            if (data.count == 0) {
                [self.view showHUDTitleView:@"暂无巡视记录" image:nil];
            }
        }
        
    }];
}

#pragma mark 选择完成操作PickerDate
- (IBAction)didSelectCancelDateAction:(UIButton *)sender {
    [self didHiddenDatePickerView];
}
#pragma mark 选择完成并保存
- (IBAction)didSelectFinishDateAction:(UIButton *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [formatter stringFromDate:_datePickerView.date];
    
    if (_indexTime == 10) {
        [_beginTimeBtn setTitle:strDate forState:0];
    }else{
        [_endTimeBtn setTitle:strDate forState:0];
    }
    
    [self didHiddenDatePickerView];

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_textFieldName.isFirstResponder) {
        [_textFieldName resignFirstResponder];
    }else if (_textFieldNumber.isFirstResponder){
        [_textFieldNumber resignFirstResponder];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
