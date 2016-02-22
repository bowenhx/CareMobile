//
//  LoginViewController.m
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "LoginViewController.h"
#import "ConstantConfig.h"
#import "SettingViewController.h"
#import "ScanViewController.h"


@interface LoginViewController ()<UITextFieldDelegate>
{
    __weak IBOutlet UITextField *_accountNameTextField;
    
    __weak IBOutlet UITextField *_passwordTextField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    UIButton *btnName = (UIButton *)[self.view viewWithTag:100];
    NSString *name = [[SavaData shareInstance] printDataStr:USERNAMEKEY];
    if (![@"" isStringBlank:name]) {
        _accountNameTextField.text = name;
        
        btnName.selected = YES;
    }else{
        btnName.selected = NO;
    }
    
    NSString *password = [[SavaData shareInstance] printDataStr:USERPASSWORDKEY];
     UIButton *btnPasw = (UIButton *)[self.view viewWithTag:200];
    if (![@"" isStringBlank:password]) {
        _passwordTextField.text = password;
       
        btnPasw.selected = YES;
        
    }else{
        btnPasw.selected = NO;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveUserNameAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected && _accountNameTextField.text.length > 1) {
        [[SavaData shareInstance] savadataStr:_accountNameTextField.text KeyString:USERNAMEKEY];
    }else{
         [[SavaData shareInstance] savadataStr:@"" KeyString:USERNAMEKEY];
    }
    
}

- (IBAction)savePasswordAction:(UIButton *)sender {
    
    if (_passwordTextField.text.length > 1) {
        sender.selected = !sender.selected;
        [[SavaData shareInstance] savadataStr:_passwordTextField.text KeyString:USERPASSWORDKEY];
    }else{
        sender.selected = NO;
        [[SavaData shareInstance] savadataStr:@"" KeyString:USERPASSWORDKEY];
    }
}

- (IBAction)pushSetPageAction:(id)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    settingVC.color = self.view.backgroundColor;
    [self.navigationController pushViewController:settingVC animated:YES];

}

- (IBAction)pushLoginHomePageAction:(id)sender {

    if ([@"" isStringBlank:_accountNameTextField.text]) {
        [self.view showHUDTitleView:@"用户名不能为空" image:nil];
        return;
    }
//    else if ([@"" isStringBlank:_passwordTextField.text]){
//        [self.view showHUDTitleView:@"密码不能为空" image:nil];
//        return;
//    }
    
    
    [self.view showHUDActivityView:@"正在登陆" shade:NO];
    
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_Login withParameter:@{@"uname":_accountNameTextField.text,@"upwd":_passwordTextField.text} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        
        NSLog(@"content %@",content);
       
        NSDictionary *data = (NSDictionary *)content;
        if (data.count > 0 ) {
            
            if ([data[@"message"] isEqualToString:@"请设置服务器参数再登录"]) {
                [self.view showHUDTitleView:data[@"message"]  image:nil];
                return ;
            }else if ([data[@"status"] integerValue] == 0) {
                [self.view showHUDTitleView:@"用户名或密码错误"  image:nil];
                return ;
            }else if ([data[@"message"] isEqualToString:@"请求出错，请稍后重试"]) {
                [self.view showHUDTitleView:@"用户名或密码错误"  image:nil];
                return ;
            }
            
            /**
             *  保存用户userid
             */
            NSString *userid = [data[@"uid"] stringByReplacingOccurrencesOfString:@" " withString:@""];
            [[SavaData shareInstance] savadataStr:userid KeyString:USER_ID_KEY];
            
            UIButton *btnName = (UIButton *)[self.view viewWithTag:100];
            UIButton *btnpassword = (UIButton *)[self.view viewWithTag:200];
            
            if (btnName.selected) {
                [[SavaData shareInstance] savadataStr:_accountNameTextField.text KeyString:USERNAMEKEY];
            }else{
                [[SavaData shareInstance] savadataStr:@"" KeyString:USERNAMEKEY];
            }
            
            if (btnpassword.selected) {
                [[SavaData shareInstance] savadataStr:_passwordTextField.text KeyString:USERPASSWORDKEY];
            }else{
                [[SavaData shareInstance] savadataStr:@"" KeyString:USERPASSWORDKEY];
            }
            
            [SavaData writeDicToFile:data FileName:User_File];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [self presentViewController:[mainStoryboard instantiateInitialViewController] animated:YES completion:^{
                
            }];
        }
        
    }];


    
}
#pragma mark 扫码登陆
- (IBAction)scanLoginAction:(id)sender{
    ScanViewController *scanVC = [[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil];
    scanVC.color = self.view.backgroundColor;
    scanVC.scanType = ScanTypeLoginAction;
    [self.navigationController pushViewController:scanVC animated:YES];
    scanVC.didUpdataDicBlock = ^(NSDictionary * dict){
        NSString *scanKey = [NSString stringWithFormat:@"%@",dict[@"uname"]];
        
        UIButton *btnName = (UIButton *)[self.view viewWithTag:100];
        if (btnName.selected) {
            [[SavaData shareInstance] savadataStr:scanKey KeyString:USERNAMEKEY];
        }else{
            _accountNameTextField.text = scanKey;
        }
        
        [self performSelector:@selector(pushLoginHomePageAction:) withObject:nil afterDelay:.5];
    };
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
     if ( Y(self.view) == 0 ) {
        [UIView animateWithDuration:.3f animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 70;
            self.view.frame = rect;
        }];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _accountNameTextField) {
        [_passwordTextField becomeFirstResponder];
    }else{
        [textField resignFirstResponder];
        [self changeViewSize];
    }
    return YES;
}
- (void)changeViewSize{
    if (Y(self.view) != 0) {
        [UIView animateWithDuration:.3f animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y += 70;
            self.view.frame = rect;
        }];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([_accountNameTextField isFirstResponder]) {
        [_accountNameTextField resignFirstResponder];
    }else if ([_passwordTextField isFirstResponder])
    {
        [_passwordTextField resignFirstResponder];
    }
    
    [self changeViewSize];
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
