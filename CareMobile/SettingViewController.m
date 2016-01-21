//
//  SettingViewController.m
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "SettingViewController.h"
#import "ConstantConfig.h"
@interface SettingViewController ()<UITextFieldDelegate>
{
    UITextField *_textF;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"系统设置";
    


    UITextField *textIP = (UITextField *)[self.view viewWithTag:10];
    textIP.text = [[CARequest shareInstance] printDataString:CBASE_URL_KEY];
    
    UITextField *textPort = (UITextField *)[self.view viewWithTag:11];
    textPort.text = [[CARequest shareInstance] printDataString:CPORT_KEY];
    
    
    UITextField *textCode = (UITextField *)[self.view viewWithTag:12];
    textCode.text = [[CARequest shareInstance] printDataString:CGORGE_KEY];



}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_color) {
        self.navigationController.navigationBar.barTintColor = _color;
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectSaveDataAction:(id)sender{
    UITextField *textIP = (UITextField *)[self.view viewWithTag:10];
    
    UITextField *textPort = (UITextField *)[self.view viewWithTag:11];
    
    UITextField *textCode = (UITextField *)[self.view viewWithTag:12];
    
    //判断是否有填写
    if ([@"" isStringBlank:textIP.text] || [@"" isStringBlank:textPort.text] || [@"" isStringBlank:textCode.text]) {
        [self.view showHUDTitleView:@"请填写完整信息" image:nil];
        return;
    }
    
    [[CARequest shareInstance] saveDataString:textIP.text key:CBASE_URL_KEY];
    [[CARequest shareInstance] saveDataString:textPort.text key:CPORT_KEY];
    [[CARequest shareInstance] saveDataString:textCode.text key:CGORGE_KEY];
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_Link withParameter:nil completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            if ([content[@"status"]boolValue] == YES )
            {
                [self.view showHUDTitleView:@"设置成功" image:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:UpdataNotification object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                });

            }else{
                [self.view showHUDTitleView:@"连接服务器失败，请检查设置" image:nil];
            }
        }else {
            [self.view showHUDTitleView:@"连接服务器失败，请检查设置" image:nil];
        }
    }];

    
    /*
    
    //判断设置是否和服务器接口连接地址一样
    NSArray *strArr = [CBASE_URL componentsSeparatedByString:@":"];
    NSString *strIP = [strArr[1] substringFromIndex:2];
    NSString *strPort = strArr[2];
    NSString *strCode = [CAPI_Link substringFromIndex:13];
    NSString *strPort2 = [CBASE_URL2 componentsSeparatedByString:@":"][2];
    
    if (![strIP isEqualToString:textIP.text]) {
        [self.view showHUDTitleView:@"连接服务器失败，请检查设置" image:nil];
        return;
    }else if (!([strPort isEqualToString:textPort.text] || [strPort2 isEqualToString:textPort.text]))
    {
        [self.view showHUDTitleView:@"连接服务器失败，请检查设置" image:nil];
        return;
    }else if (![strCode isEqualToString:textCode.text])
    {
        [self.view showHUDTitleView:@"连接服务器失败，请检查设置" image:nil];
        return;
    }
    
    
    //设置后与服务器地址匹配成功，把数据保存本地
    NSDictionary *dict = @{@"textIp":textIP.text,@"textPort":textPort.text,@"textCode":textCode.text};
    [SavaData writeDicToFile:dict FileName:Set_File];
    
    [self.view showHUDTitleView:@"设置成功" image:nil];
  
     
    */
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _textF = textField;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger tag = textField.tag;
    if (tag < 12) {
        tag ++;
        textField = [self.view viewWithTag:tag];
        [textField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([_textF isFirstResponder]) {
        [_textF resignFirstResponder];
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
