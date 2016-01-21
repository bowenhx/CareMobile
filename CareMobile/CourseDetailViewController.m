//
//  CourseDetailViewController.m
//  CareMobile
//
//  Created by Stray on 15/11/30.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "CourseDetailViewController.h"
#import "ConstantConfig.h"


@interface CourseDetailViewController ()
{
    __weak IBOutlet UILabel    *_labTitle;
    
    __weak IBOutlet UILabel    *_labName;
    
    __weak IBOutlet UILabel    *_labTime;
    
    __weak IBOutlet UILabel    *_labDoctorName;
    
    __weak IBOutlet UITextView *_textView;
    
}
@end

@implementation CourseDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
    
}
- (void)initData
{
    self.title  = _typeTitle;
    
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_CourseOrDet withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"bcid":_typeBCID} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            
            if (data.count) {
                [self showData:data[0]];
            }else{
                [self.view showHUDTitleView:[NSString stringWithFormat:@"此病人暂无%@信息",self.title] image:nil];
            }
        }
        
    }];

}
- (void)showData:(NSDictionary *)info
{
    
    _labName.text        = [info[@"BRNAME"] objString];
    _labTime.text        = [info[@"NOTETIME"] objString];
    _labDoctorName.text  = [info[@"DOCNAME"] objString];
    _textView.text       = [info[@"NOTES"] objString];
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
