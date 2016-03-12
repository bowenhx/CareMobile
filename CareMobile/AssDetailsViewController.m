//
//  AssDetailsViewController.m
//  CareMobile
//
//  Created by Guibin on 16/3/12.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "AssDetailsViewController.h"

@interface AssDetailsViewController ()
{
    __weak IBOutlet UITextView *_textView;
}
@end

@implementation AssDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadDataItems];
}
- (void)loadDataItems
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_NursingDetail withParameter:@{@"id":_assessID,@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"dt":_time} completed:^(id content, NSError *err) {
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
            if (data.count) {
                __block NSString *string = nil;
                __block NSMutableArray *arrItems = [NSMutableArray array];
               [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                   if ([obj[@"value"] isKindOfClass:[NSArray class]]) {
                       NSString *valueItem = [obj[@"value"] componentsJoinedByString:@"\n"];
                       string = [NSString stringWithFormat:@"%@\n%@",obj[@"item"],valueItem];

                   }else{
                       string = [NSString stringWithFormat:@"%@%@",obj[@"item"],obj[@"value"]];
                       
                   }
                   
                  [arrItems addObject:string];
                   
               }];
                
                NSString *itemString = [arrItems componentsJoinedByString:@"\n\n"];
                
                _textView.text = itemString;
                
                
            }else{
                [self.view showHUDTitleView:@"此病人暂无评单明细" image:nil];
            }
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
