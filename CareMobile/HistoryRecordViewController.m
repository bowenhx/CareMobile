//
//  HistoryRecordViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/7.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "HistoryRecordViewController.h"
#import "ConstantConfig.h"
#import "RecordEditViewController.h"

@interface HistoryRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UISegmentedControl *_segmentedBtn;
    
    __weak IBOutlet UITableView *_tableView;

    
    NSMutableArray  *_dataSource;
    
}
@end

@implementation HistoryRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentedBtn.selectedSegmentIndex = 0;
    _segmentedBtn.tintColor = [UIColor colorAppBg];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewData) name:@"updataHisToryData" object:nil];
    
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:@"新增" forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.tag = 10;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(didAddItemAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];

    
    
    _dataSource = [[NSMutableArray alloc] init];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
            
        }
       
    }
    
    [self loadViewData];
    
}

- (IBAction)selectTimeAction:(UISegmentedControl *)sender {
    
    [self loadViewData];
}

- (IBAction)selectTypeAction:(UIButton *)sender {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            if (sender == btn) {
                sender.selected = YES;
                if (sender.tag == 10) {
                    [self loadAllTotalNumItem:0];
                }else{
                    [self loadAllTotalNumItem:1];
                }
            }else{
                btn.selected = NO;
            }
        }
        
    }

}
- (void)loadAllTotalNumItem:(NSInteger)temp
{
    NSDictionary *userInfo = @{@"uid" :USERID,
                               @"id"   :@(_recID),
                               @"bid"   :_dict[@"BRID"],
                               @"vid"  : _dict[@"ZYID"],
                               @"items":@(temp)};
    
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    
    [[CARequest shareInstance] startWithPostCompletion:CAPI_RecordSave withParmeter:userInfo completed:^(id content, NSError *err) {
        
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        
        if ([content isKindOfClass:[NSDictionary class]]) {
            [self loadViewData];
            
            [self.view showHUDTitleView:content[@"msg"] image:nil];
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            
            if (data.count) {
                [_dataSource setArray:data];
            }else{
                [self.view showHUDTitleView:@"此病人暂无历史记录信息" image:nil];
            }
            
            [_tableView reloadData];
        }
        
        
        
    }];

}

- (void)loadViewData
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_RecordHis withParameter:@{@"id":@(_recID),@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"week":@(_segmentedBtn.selectedSegmentIndex)} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        [_dataSource removeAllObjects];
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            
            if (data.count) {
                [_dataSource setArray:data];
            }else{
    
                [self.view showHUDTitleView:@"此病人暂无历史记录信息" image:nil];
            }
            
            [_tableView reloadData];
        }
        
    }];
    

}
- (void)didAddItemAction:(UIButton *)btn
{
    RecordEditViewController *recordEditVC = [[RecordEditViewController alloc] initWithNibName:@"RecordEditViewController" bundle:nil];
    recordEditVC.navString = @"新增";
    recordEditVC.recID = _recID;
    recordEditVC.dict = _dict;
    [self.navigationController pushViewController:recordEditVC animated:YES];
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
    static NSString *patientsCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:patientsCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:patientsCell];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSString *strCode = _dataSource[indexPath.row][0][@"value"];
   
    cell.textLabel.text = strCode;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecordEditViewController *recordEditVC = [[RecordEditViewController alloc] initWithNibName:@"RecordEditViewController" bundle:nil];
    recordEditVC.navString = @"修改";
    recordEditVC.recID = _recID;
    recordEditVC.data = _dataSource[indexPath.row];
    recordEditVC.dict = _dict;
    [self.navigationController pushViewController:recordEditVC animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self didSelectDelItemRow:indexPath.row];
    }
}
- (void)didSelectDelItemRow:(NSInteger)row
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_RecordDel withParameter:@{@"id":@(_recID),@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"dtime":_dataSource[row][0][@"value"]} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content[@"status"] integerValue] == 1){
            [self.view showSuccess:@"删除成功"];
            
            [self loadViewData];
            
            
        }else{
            [self.view showError:@"删除失败"];
        }
        
    }];
    
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
