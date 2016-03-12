//
//  EndAssessViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/9.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "EndAssessViewController.h"
#import "AssDetailsViewController.h"

@interface EndAssessViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView  *_tableView;
    
    NSMutableArray          *_dataSource;
}
@end

@implementation EndAssessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.tag = 10;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(didEditItemAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];

    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    
    [self loadDataItems];
}
- (void)didEditItemAction:(UIButton *)btn
{
    if ([btn.titleLabel.text isEqualToString:@"编辑"]) {
        [btn setTitle:@"完成" forState:0];
        [_tableView setEditing:YES animated:YES];
    }else {
         [btn setTitle:@"编辑" forState:0];
        [_tableView setEditing:NO animated:YES];
    }
   
    
}
- (void)loadDataItems
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_NursingList withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"]} completed:^(id content, NSError *err) {
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
                [_dataSource setArray:data];
                [_tableView reloadData];
            }else{
                [self.view showHUDTitleView:@"此病人暂无评估信息" image:nil];
            }
        }
        
    }];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark TableVeiwDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_dataSource[section][@"timeList"] count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *patientsCell = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:patientsCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:patientsCell];
    }
    
    NSString *strCode = [NSString stringWithFormat:@"%@     总分:%@",_dataSource[indexPath.section][@"timeList"][indexPath.row][@"RECORD_TIME"],_dataSource[indexPath.section][@"timeList"][indexPath.row][@"SCORES"]];
    
    cell.textLabel.text = strCode;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AssDetailsViewController *assDetailsVC = [[AssDetailsViewController alloc] initWithNibName:@"AssDetailsViewController" bundle:nil];
    assDetailsVC.dict = self.dict;
    assDetailsVC.assessID = _dataSource[indexPath.section][@"id"];
    assDetailsVC.time = _dataSource[indexPath.section][@"timeList"][indexPath.row][@"RECORD_TIME"];
    
    [self.navigationController pushViewController:assDetailsVC animated:YES];
    
    
}
- (CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    headView.backgroundColor = RGB(255, 154, 56);
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 40)];
    labText.backgroundColor = [UIColor clearColor];
    labText.font = [UIFont systemFontOfSize:15];
    labText.text = _dataSource[section][@"name"];
    [headView addSubview:labText];
    
//    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnDel.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 40, 40);
//    [btnDel setImage:[UIImage imageNamed:@"Club_vi_delete"] forState:UIControlStateNormal];
//    btnDel.tag = section;
//    
//    [btnDel addTarget:self action:@selector(didSelectDelItem:) forControlEvents:UIControlEventTouchUpInside];
//    [headView addSubview:btnDel];
    
    return headView;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self didSelectDelItem:indexPath.section row:indexPath.row];
    }
}
- (void)didSelectDelItem:(NSInteger)section row:(NSInteger)row
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_NursingDel withParameter:@{@"id":_dataSource[section][@"id"],@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"dtime":_dataSource[section][@"timeList"][row][@"RECORD_TIME"],@"uid":USERID} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content[@"status"] integerValue] == 1){
            [self.view showSuccess:@"删除成功"];
            
            [self loadDataItems];
            
            
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
