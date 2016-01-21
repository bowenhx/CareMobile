//
//  CopyrightViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/15.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "CopyrightViewController.h"
#import "ConstantConfig.h"
@interface CopyrightViewController ()
{
    __weak IBOutlet UITextView *_textView;
    
}
@end

@implementation CopyrightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"版权信息";

    NSLog(@"_textView = %@",_textView);
//    _textView.layer.borderWidth = 1;
//    _textView.layer.borderColor = [UIColor redColor].CGColor;
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_Verinfo withParameter:nil completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *verinfo = content[@"verinfo"];
            _textView.text  = verinfo;
        }else if ([content isKindOfClass:[NSArray class]]){
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
