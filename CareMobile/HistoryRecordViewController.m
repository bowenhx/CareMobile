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
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)addNavTitleView
{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH-140, 44)];
    
    UILabel *labTitile = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, WIDTH(navView), 23)];
    labTitile.text = self.title;
    labTitile.textColor = [UIColor whiteColor];
    labTitile.textAlignment = NSTextAlignmentCenter;
    labTitile.font = SYSTEMFONT(17);
    [navView addSubview:labTitile];
    
    UILabel *labSubTitile = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHTADDY(labTitile), WIDTH(navView), 17)];
    labSubTitile.text = [NSString stringWithFormat:@"%@ 床 %@",_dict[@"CHUANG"],_dict[@"BRNAME"]];
    labSubTitile.textColor = [UIColor whiteColor];
    labSubTitile.textAlignment = NSTextAlignmentCenter;
    labSubTitile.font = SYSTEMFONT(13);
    [navView addSubview:labSubTitile];
    
    
    self.navigationItem.titleView = navView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentedBtn.selectedSegmentIndex = 0;
    _segmentedBtn.tintColor = [UIColor colorAppBg];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadViewData) name:@"updataHisToryData" object:nil];
    
    [self addNavTitleView];
    
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

    
    
    [_tableView registerNib:[UINib nibWithNibName:@"RecordHistoryViewCell" bundle:nil] forCellReuseIdentifier:@"recordHistoryViewCell"];
    
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
                               @"bid"  :_dict[@"BRID"],
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
        }else if (content == nil){
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            
            [self.view showHUDTitleView:@"该时间段暂无记录信息" image:nil];
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
    static NSString *patientsCell = @"recordHistoryViewCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:patientsCell forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self loadDataTableViewCell:cell cellForRowIndexPath:indexPath];
    
    
    return cell;
}
- (void)loadDataTableViewCell:(UITableViewCell *)cell cellForRowIndexPath:(NSIndexPath *)indexPath
{
    UILabel *timeLab = (UILabel *)[cell.contentView viewWithTag:10];
    timeLab.text = _dataSource[indexPath.row][@"RECORD_DATE"];
    

    NSString *tiwen = _dataSource[indexPath.row][@"TIWEN"];
    UILabel *heatLab = (UILabel *)[cell.contentView viewWithTag:11];
    
    if ([tiwen isEqual:@"24h"]) {
        cell.backgroundColor = [UIColor colorAppBg];
         heatLab.text = @"体温：";
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        heatLab.text = [NSString stringWithFormat:@"体温：%@",tiwen];
    }
  
    
    UILabel *throbLab = (UILabel *)[cell.contentView viewWithTag:12];
    throbLab.text = [NSString stringWithFormat:@"脉搏：%@",_dataSource[indexPath.row][@"MAIBO"]];
    
    UILabel *breatheLab = (UILabel *)[cell.contentView viewWithTag:13];
    breatheLab.text = [NSString stringWithFormat:@"呼吸：%@",_dataSource[indexPath.row][@"HUXI"]];
    
    UILabel *nurseLab = (UILabel *)[cell.contentView viewWithTag:14];
    nurseLab.text = [NSString stringWithFormat:@"病情护理及措施：%@",_dataSource[indexPath.row][@"BINGQING"]];
 
    
    

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RecordEditViewController *recordEditVC = [[RecordEditViewController alloc] initWithNibName:@"RecordEditViewController" bundle:nil];
    recordEditVC.navString = @"修改";
    recordEditVC.recID = _recID;
    recordEditVC.itemData = _dataSource[indexPath.row];
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
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_RecordDel withParameter:@{@"id":@(_recID),@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"dtime":_dataSource[row][@"RECORD_DATE"]} completed:^(id content, NSError *err) {
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = [NSString stringWithFormat:@"病情护理及措施：%@",_dataSource[indexPath.row][@"BINGQING"]];
    
    CGRect rect = [message boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-16, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSTEMFONT(15)} context:nil];
    return rect.size.height < 20 ? 80 : rect.size.height + 64;
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
