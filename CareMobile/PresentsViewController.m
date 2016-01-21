//
//  PresentsViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/8.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "PresentsViewController.h"
#import "SubItemViewController.h"

@interface PresentsViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    
    __weak IBOutlet UIButton *_timeBtn;
    
    __weak IBOutlet UITableView *_tableView;
    
    
    IBOutlet UIView *_pickerViewBg;
    
    __weak IBOutlet UIPickerView *_pickerView;
    
    
    NSMutableArray  *_dataSource;
    NSMutableArray  *_pickerData;
    NSInteger   _pickerRow;
}
@end

@implementation PresentsViewController

- (void)setPickerViewBg
{
    /**
     *  设置_pickerView 的frame适应屏幕尺寸
     */
    _pickerViewBg.backgroundColor = [UIColor colorViewBg];
    CGRect rect = _pickerViewBg.frame;
    rect.size.width = SCREEN_WIDTH;
    _pickerViewBg.frame = rect;
    
    UIView *datePickView = (UIView *)[_pickerViewBg viewWithTag:10];
    for (UIView *label in datePickView.subviews) {
        label.backgroundColor = [UIColor colorAppBg];
    }
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"体温监控";
    
    _pickerRow = 0;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _pickerData = [[NSMutableArray alloc] initWithCapacity:0];
    [self setPickerViewBg];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestLoadData:) name:@"updataListData" object:nil];
    
    [self requestLoadData:@""];
}
- (void)requestLoadData:(NSString *)time
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BRTemperature withParameter:@{@"uid":USERID,@"curpage":@"1",@"t":time} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            [_timeBtn setTitle:content[@"RECPOINT"] forState:0];
            [_pickerData setArray:content[@"SUBTIME"]];
            
            [_dataSource setArray:content[@"PATS"]];
            [_tableView reloadData];
            if ( [content[@"PATS"] count] ==0 ){
                [self.view showHUDTitleView:@"暂无体温监控信息" image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            if (!data.count) {
                [self.view showHUDTitleView:@"暂无体温监控信息" image:nil];
            }
            
        }
    }];

}
- (IBAction)selectTimeItem:(id)sender
{
    [self showPickerView];
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
    NSString *strCode = [NSString stringWithFormat:@"%@床     %@",_dataSource[indexPath.row][@"BEDNO"],_dataSource[indexPath.row][@"BRNAME"]];
    
    cell.textLabel.text = strCode;
    
    return cell;
}

- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:10];
    title.text = _dataSource[indexPath.row][@"value"];
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = _dataSource[indexPath.row];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BingRen withParameter:@{@"bid":dic[@"BRID"],@"vid":dic[@"ZYID"],@"t":@""} completed:^(id content, NSError *err) {
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
                
                SubItemViewController *subItem = [[SubItemViewController alloc] initWithNibName:@"SubItemViewController" bundle:nil];
                subItem.navTitle = @"生命体征";
                subItem.dict = data[0];
                subItem.strTime = _timeBtn.titleLabel.text;
                subItem.navRight = @"添加";
                [self.navigationController pushViewController:subItem animated:YES];
            }
        }
        
    }];
    
    
   

}

#pragma  mark PickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@",_pickerData[row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _pickerRow = row;
    
}
#pragma mark 选择完成操作PickerDate
- (IBAction)didSelectCancelAction:(UIButton *)sender {
    [self didHiddenPickerView];
}
#pragma mark 选择完成并保存
- (IBAction)didSelectFinishAction:(UIButton *)sender {
    [_timeBtn setTitle:_pickerData[_pickerRow] forState:0];
    [self didHiddenPickerView];
    [self requestLoadData:_pickerData[_pickerRow]];
}
- (void)showPickerView
{
    [_pickerView reloadAllComponents];
    CGRect rect = _pickerViewBg.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _pickerViewBg.frame = rect;
    if (!_pickerViewBg.superview) {
        [self.view addSubview:_pickerViewBg];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _pickerViewBg.frame;
        frame.origin.y = SCREEN_HEIGHT - _pickerViewBg.frame.size.height;
        _pickerViewBg.frame = frame;
    }];
    
}
- (void)didHiddenPickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _pickerViewBg.frame;
        rect.origin.y = SCREEN_HEIGHT;
        _pickerViewBg.frame = rect;
        
    } completion:^(BOOL finished) {
        [_pickerViewBg removeFromSuperview];
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
