//
//  AssessDetailViewController.m
//  CareMobile
//
//  Created by bowen on 16/1/5.
//  Copyright © 2016年 MobileCare. All rights reserved.
//
#import "ConstantConfig.h"
#import "AssessDetailViewController.h"

@interface AssessDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView  *_tableView;
    
    __weak IBOutlet UILabel *_labTextNum;
    
    __weak IBOutlet UIButton *_timeBtn;
    
    IBOutlet UIView *_datePickViewBg;
    __weak IBOutlet UIDatePicker *_datePickerView;
    
    
    NSMutableArray          *_dataSource;
    
    NSMutableArray          *_editData;
}
@end

@implementation AssessDetailViewController

- (void)pickerDateView
{
    /**
     *  设置_datePckerVIew 的frame适应屏幕尺寸
     */
    _datePickViewBg.backgroundColor = [UIColor colorViewBg];
    CGRect rect = _datePickViewBg.frame;
    rect.size.width = SCREEN_WIDTH;
    _datePickViewBg.frame = rect;
    
    UIView *pickerV = (UIView *)[_datePickViewBg viewWithTag:20];
    for (UIView *label in pickerV.subviews) {
        label.backgroundColor = [UIColor colorAppBg];
    }
    
    [_datePickerView setDatePickerMode:UIDatePickerModeDateAndTime];
//    [_datePickerView setMaximumDate:[NSDate date]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _editData = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:@"保存" forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(selectSaveItem) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];

    
    
    
    _timeBtn.layer.borderWidth = 1;
    _timeBtn.layer.borderColor =  [UIColor colorViewBg].CGColor;
    _timeBtn.layer.cornerRadius = 5;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]];
    [_timeBtn setTitle:strDate forState:0];
    
    
    [_tableView registerNib:[UINib nibWithNibName:@"AssessSelectViewCell" bundle:nil] forCellReuseIdentifier:@"assessSelectViewCell"];
    
    
    [self pickerDateView];
    [self loadDataItem];
    
}
- (void)selectSaveItem
{
    if (_editData.count == 0) {
        [self.view showHUDTitleView:@"请选择评估项再保存" image:nil];
        return;
    }
    [_editData removeAllObjects];
    [self itemScoreCount:_dataSource];
    
    [_editData addObject:@{@"id":@"RECORD_TIME",@"value":_timeBtn.titleLabel.text}];
    NSData *data = [NSJSONSerialization dataWithJSONObject:_editData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *dicInfo = @{
                           @"id":_assessID,
                           @"uid":USERID,
                           @"bid":_dict[@"BRID"],
                           @"vid":_dict[@"ZYID"],
                           @"items":json
                           };
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithPostCompletion:CAPI_NursingSave withParmeter:dicInfo completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            if ([content[@"status"] integerValue] == 1) {
                [self.view showSuccess:@"保存成功"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.view showError:@"保存失败"];
            }
            
            
        }else if ([content isKindOfClass:[NSArray class]]){
        }else{
            [self.view showHUDTitleView:@"没有搜索到匹配内容" image:nil];
        }
    }];

}
- (void)itemScoreCount:(NSArray *)itmes
{
    __block NSInteger countNum = 0;
    [itmes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSArray *arrData = obj[@"option"];
        [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"status"] integerValue] == 1) {
                countNum += [obj[@"score"] integerValue];
                [_editData addObject:@{@"id":obj[@"id"],@"value":obj[@"name"]}];
            }
        }];
        
    }];
    
    [_editData addObject:@{@"id":@"SCORES",@"value":@(countNum)}];
    _labTextNum.text = [NSString stringWithFormat:@"总分 ：%ld",(long)countNum];
}
- (void)loadDataItem
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_NursingDict withParameter:@{@"id":_assessID} completed:^(id content, NSError *err) {
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
                [self.view showHUDTitleView:@"此病人暂无评估信息" image:nil];
            }
        }
        
    }];
}
- (IBAction)selectTimeAction:(id)sender
{
    [self showDatePickerView];
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
    return [_dataSource[section][@"option"] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"assessSelectViewCell" forIndexPath:indexPath];
   
    [self loadForTableViewCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}
- (void)loadForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:10];
    title.text = _dataSource[indexPath.section][@"option"][indexPath.row][@"name"];
    
    NSInteger status = [_dataSource[indexPath.section][@"option"][indexPath.row][@"status"] integerValue];
    if (status == 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    if (cell.textLabel.text.length > 16) {
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = _dataSource[indexPath.section][@"option"][indexPath.row][@"name"];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-8-35, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSTEMFONT(16)} context:nil];
    NSLog(@"height = %f",rect.size.height);
    return rect.size.height < 20 ? 44 : rect.size.height+30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
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
    labText.text = _dataSource[section][@"group"];
    [headView addSubview:labText];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *mutabDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[indexPath.section]];
    NSMutableArray *items = [NSMutableArray arrayWithArray:mutabDic[@"option"]];
    if ([mutabDic[@"group"] isEqualToString:@"护理措施"]) {
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:obj];
            if (indexPath.row ==  idx) {
                BOOL status = [mutableDic[@"status"] boolValue];
                //选中
                mutableDic[@"status"] = @(!status);
            }
         
            [items replaceObjectAtIndex:idx withObject:mutableDic];
            
        }];

    }else{
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithDictionary:obj];
            BOOL status = [mutableDic[@"status"] boolValue];
            if (indexPath.row == idx) {
                //选中
                mutableDic[@"status"] = @(!status);
                
            }else{
                mutableDic[@"status"] = @(0);
            }
            
            [items replaceObjectAtIndex:idx withObject:mutableDic];
            
        }];
    }
    
    
    mutabDic[@"option"] = items;
    [_dataSource replaceObjectAtIndex:indexPath.section withObject:mutabDic];
    
    [_tableView reloadData];
    
    [self itemScoreCount:_dataSource];
    
}
#pragma mark 选择完成操作PickerDate
- (IBAction)didSelectCancelDateAction:(UIButton *)sender {
    [self didHiddenDatePickerView];
}
#pragma mark 选择完成并保存
- (IBAction)didSelectFinishDateAction:(UIButton *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:_datePickerView.date];
    
    [_timeBtn setTitle:strDate forState:0];
    [self didHiddenDatePickerView];

}


- (void)showDatePickerView
{
    CGRect rect = _datePickViewBg.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _datePickViewBg.frame = rect;
    if (!_datePickViewBg.superview) {
        [self.view addSubview:_datePickViewBg];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _datePickViewBg.frame;
        frame.origin.y = SCREEN_HEIGHT - _datePickViewBg.frame.size.height;
        _datePickViewBg.frame = frame;
    }];
    
}
- (void)didHiddenDatePickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _datePickViewBg.frame;
        rect.origin.y = SCREEN_HEIGHT;
        _datePickViewBg.frame = rect;
        
    } completion:^(BOOL finished) {
        [_datePickViewBg removeFromSuperview];
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
