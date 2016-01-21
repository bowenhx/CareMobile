//
//  AssessViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "AssessViewController.h"
#import "ConstantConfig.h"
#import "Assess2ViewController.h"
#import "CourseDetailViewController.h"
#import "HistoryRecordViewController.h"

@interface AssessViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView  *_tableView;
    
    
    NSMutableArray      *_dataSource;
    
    
}

@end

@implementation AssessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _navTitle;
    self.automaticallyAdjustsScrollViewInsets = NO;

    _dataSource = [NSMutableArray array];
    
    
    [self initViews];
    
    [self loadViewData];
}
- (void)initViews
{
    if ([_navTitle isEqualToString:@"病程录"]) {
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"assessViewCell"];
    }else{
        UINib *cellNib = [UINib nibWithNibName:@"AssessViewCell" bundle:nil];
        [_tableView registerNib:cellNib forCellReuseIdentifier:@"assessViewCell"];
    }
   
    
    
}
- (NSString *)typeUrl
{
    NSString *url = @"";
    if ([_navTitle isEqualToString:@"护理记录单"]) {
        url = CAPI_RYPglist;
    }else if ([_navTitle isEqualToString:@"护理评估"]){
        url = CAPI_MRPGList;
    }else if ([_navTitle isEqualToString:@"教育"])
    {
        url = CAPI_JiaoYuList;
    }else if ([_navTitle isEqualToString:@"病程录"])
    {
        url = CAPI_CourseOrDet;
    }
    return url;
}
- (NSDictionary *)typeDictionary
{
    if ([_navTitle isEqualToString:@"病程录"]){
        return @{
                 @"bid":_dict[@"BRID"],
                 @"vid":_dict[@"ZYID"],
                 @"itemid":@(0)
                 };
    }else if ([_navTitle isEqualToString:@"护理记录单"])
    {
        return @{
                 @"uid":USERID
                 };
    }else{
        return @{@"bid":_dict[@"BRID"],
                 @"vid":_dict[@"ZYID"],
                 @"bcid":@""
                 };
    }
}
- (void)loadViewData
{
    if (_dict.count) {
        [self.view showHUDActivityView:@"正在加载" shade:NO];
        [[CARequest shareInstance] startWithRequestCompletion:[self typeUrl] withParameter:[self typeDictionary] completed:^(id content, NSError *err) {
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
                  [self.view showHUDTitleView:[NSString stringWithFormat:@"此病人暂无%@信息",_navTitle] image:nil];
                }
            }
            
        }];

    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark TableVeiwDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _dataSource.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"assessViewCell" forIndexPath:indexPath];
   
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
    
    if ([_navTitle isEqualToString:@"病程录"]) {
        cell.textLabel.text = _dataSource[indexPath.row][@"BCNAME"];
    }else if ([_navTitle isEqualToString:@"护理记录单"]) {
        UIButton *selectBtn = (UIButton *)[cell.contentView viewWithTag:100];
        selectBtn.hidden = YES;
        UILabel *title = (UILabel *)[cell.contentView viewWithTag:200];
        title.hidden = YES;
         cell.textLabel.text = _dataSource[indexPath.row][@"NAME"];
    }else{
         [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *selectBtn = (UIButton *)[cell.contentView viewWithTag:100];
    selectBtn.selected = [_dataSource[indexPath.row][@"selected"] boolValue];
    selectBtn.layer.cornerRadius = 3;
    selectBtn.layer.borderWidth = 1;
    selectBtn.layer.borderColor = [UIColor colorAppBg].CGColor;
    
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:200];
    title.text = _dataSource[indexPath.row][@"itemname"];
    
    selectBtn.tag = indexPath.row;
    [selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_navTitle isEqualToString:@"病程录"]) {

        CourseDetailViewController *courseDetailVC = [[CourseDetailViewController alloc] initWithNibName:@"CourseDetailViewController" bundle:nil];
        courseDetailVC.dict = _dict;
        courseDetailVC.typeTitle = _dataSource[indexPath.row][@"BCNAME"];
        courseDetailVC.typeBCID  = _dataSource[indexPath.row][@"BCID"];
        [self.navigationController pushViewController:courseDetailVC animated:YES];
        
    }else if ([_navTitle isEqualToString:@"护理记录单"]) {
    
        HistoryRecordViewController *historyRecordVC = [[HistoryRecordViewController alloc] initWithNibName:@"HistoryRecordViewController" bundle:nil];
        historyRecordVC.title = _dataSource[indexPath.row][@"NAME"];
        historyRecordVC.dict = _dict;
        historyRecordVC.recID = [_dataSource[indexPath.row][@"ID"] integerValue];
        [self.navigationController pushViewController:historyRecordVC animated:YES];
    }else{
        Assess2ViewController *assess2VC = [[Assess2ViewController alloc] initWithNibName:@"Assess2ViewController" bundle:nil];
        assess2VC.reqURL = [self typeUrl];
        assess2VC.dict = _dict;
        assess2VC.itemid = _dataSource[indexPath.row][@"itemid"];
        assess2VC.headTitle =  _dataSource[indexPath.row][@"itemname"];
        [self.navigationController pushViewController:assess2VC animated:YES];
    }
}

- (void)selectAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
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
