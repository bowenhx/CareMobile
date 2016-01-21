//
//  ManageViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/14.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "ManageViewController.h"
#import "ConstantConfig.h"
#import "SavaData.h"
@interface ManageViewController ()<UITextFieldDelegate>

@end

@implementation ManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"护士账户管理";
    
    NSDictionary *dicdata = [SavaData parseDicFromFile:User_File];
    
    UILabel *labName = (UILabel *)[self.view viewWithTag:10];
    labName.text = dicdata[@"utname"];
    
    UILabel *labOffice = (UILabel *)[self.view viewWithTag:11];
    labOffice.text = dicdata[@"keshi"];
    
    NSString *uname = dicdata[@"utname"];
    UILabel *labUname = (UILabel *)[self.view viewWithTag:12];
    labUname.text = uname;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ( Y(self.view) == 0 ) {
        [UIView animateWithDuration:.3f animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y -= 50;
            self.view.frame = rect;
        }];
    }

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self changeViewFrame];
    
    return YES;
}
- (IBAction)didConfirmAction:(UIButton *)sender
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view removeHUDActivity];
        [self.view showHUDTitleView:@"修改密码成功" image:nil];
        
    });
}
- (void)changeViewFrame
{
    if ( Y(self.view) != 0 ) {
        [UIView animateWithDuration:.3f animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            self.view.frame = rect;
        }];
    }

}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITextField *textF = (UITextField *)[self.view viewWithTag:13];
    if ([textF isFirstResponder]) {
        [textF resignFirstResponder];
        [self changeViewFrame];
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
