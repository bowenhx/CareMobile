//
//  WardHistoryViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/9.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "WardHistoryViewController.h"

@interface WardHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
{
     __weak IBOutlet UITableView  *_tableView;
    
}
@end

@implementation WardHistoryViewController
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"巡视列表";
    
    [_tableView registerNib:[UINib nibWithNibName:@"ItemTypeViewCell" bundle:nil] forCellReuseIdentifier:@"ItemTypeViewCell"];
    
    
    //[self loadDatas];
}
- (void)loadDatas
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_WardHistory withParameter:@{@"uid":USERID} completed:^(id content, NSError *err) {
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
            
            [_dataSource setArray:data];
            [_tableView reloadData];
            
            if (data.count == 0) {
                [self.view showHUDTitleView:@"暂无巡视记录" image:nil];
            }
        }
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableVeiwDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_dataSource[section][@"beds"] count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ItemTypeViewCell" forIndexPath:indexPath];
    
    UILabel *labNum = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *labName  = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *labStatus  = (UILabel *)[cell.contentView viewWithTag:12];


    labNum.text =  [NSString stringWithFormat:@"%@床",_dataSource[indexPath.section][@"beds"][indexPath.row][@"bed_no"]];
    
    labName.text = _dataSource[indexPath.section][@"beds"][indexPath.row][@"patient_name"];
    
    labStatus.text = _dataSource[indexPath.section][@"beds"][indexPath.row][@"status"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    headView.backgroundColor = RGB(255, 154, 56);
    headView.alpha = 0.6;
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 40)];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.backgroundColor = [UIColor clearColor];
    labText.font = [UIFont systemFontOfSize:15];
    labText.text = [NSString stringWithFormat:@"%@病房    %@",_dataSource[section][@"room_no"],_dataSource[section][@"time"]];
    [headView addSubview:labText];
    return headView;
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
