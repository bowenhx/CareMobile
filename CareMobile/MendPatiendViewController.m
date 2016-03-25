//
//  MendPatiendViewController.m
//  CareMobile
//
//  Created by Guibin on 16/2/20.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "MendPatiendViewController.h"
#import "DetailsViewController.h"

#import "CARequest.h"
#import "CareButton.h"
@interface MendPatiendViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    __weak IBOutlet UISearchBar *_mySearchBar;
    
    __weak IBOutlet UITableView  *_tableView;
    
    __weak IBOutlet UIButton     *_dateBtn;
    
    
    __weak IBOutlet UIButton     *_searchBtn;
    
    UIView              *_datePickViewBg;
    UIDatePicker        *_datePickerView;
    
    NSMutableArray          *_dataSource;

}
@end

@implementation MendPatiendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self initView];
    [self requestDatas];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initView
{
    NSArray *typeViews = [[NSBundle mainBundle] loadNibNamed:@"SearchViewItem" owner:nil options:nil];
    
    _datePickViewBg = typeViews[8];
    _datePickViewBg.backgroundColor = [UIColor colorViewBg];
    CGRect rect = _datePickViewBg.frame;
    rect.size.width = SCREEN_WIDTH;
    _datePickViewBg.frame = rect;
    
    _datePickerView = [_datePickViewBg viewWithTag:15];
    [_datePickerView setMaximumDate:[NSDate date]];
    
    UIButton *cancelBtn = [_datePickViewBg viewWithTag:11];
    UIButton *confirmBtn = [_datePickViewBg viewWithTag:12];
    
    [cancelBtn addTarget:self action:@selector(didSelectCancelDateAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [confirmBtn addTarget:self action:@selector(didSelectFinishDateAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _searchBtn.layer.cornerRadius = 5;
//    _searchBtn.layer.borderWidth = 1;
//    _searchBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _searchBtn.layer.masksToBounds = YES;

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *strDate = [formatter stringFromDate:[NSDate date]];
    
    [_dateBtn setTitle:strDate forState:0];

}
- (void)requestDatas
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BingOutList withParameter:@{@"uid":USERID,@"curpage":@"1",@"dt":_dateBtn.titleLabel.text} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            //所有病人
            [_dataSource setArray:content];
            [_tableView reloadData];
            
            if (_dataSource.count ==0) {
               [self.view showHUDTitleView:@"没有补录病人数据" image:nil];
            }
        }
     
    }];

}

- (IBAction)selectDateType:(UIButton *)sender
{
    [_mySearchBar resignFirstResponder];
    [self showDatePickerView];
}

- (IBAction)beginSearchDataAction:(UIButton *)sender
{
    [self didHiddenDatePickerView];
    NSString *searchTerm = _mySearchBar.text;
    [self searchBeginAction:searchTerm];
    
    [_mySearchBar resignFirstResponder];
}



- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    NSString *strKey = [searchBar.text stringByAppendingString:text];
//    [self searchBeginAction:strKey];
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBar.text222 = %@",searchBar.text);
    
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchTerm = searchBar.text;
    [self searchBeginAction:searchTerm];
    
    [searchBar resignFirstResponder];
    
}
- (void)searchBeginAction:(NSString *)key
{
    key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BingOutList withParameter:@{@"uid":USERID,@"key":key,@"dt":_dateBtn.titleLabel.text} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
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
                [_dataSource setArray:data];
                [_tableView reloadData];
                //                NSDictionary *dict = data[0];
                //                if ([dict isKindOfClass:[NSDictionary class]]) {
                //                    [self pushDetailsViewController:dict];
                //                }
            }else{
                [_dataSource removeAllObjects];
                [_tableView reloadData];
                [self.view showHUDTitleView:@"没用搜索到该病人" image:nil];
            }
            
        }
    }];
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
    static NSString *patientsCell = @"patientsCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:patientsCell forIndexPath:indexPath];
    [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:20];
    labName.text = _dataSource[indexPath.row][@"BRNAME"];
    
    UILabel *labSex = (UILabel *)[cell.contentView viewWithTag:21];
    labSex.text = _dataSource[indexPath.row][@"SEX"];
    
    UILabel *labAge = (UILabel *)[cell.contentView viewWithTag:22];
    labAge.text = [_dataSource[indexPath.row][@"BIRTH"] ageNumberString];
    
    UILabel *labOffice = (UILabel *)[cell.contentView viewWithTag:23];
    labOffice.text = _dataSource[indexPath.row][@"BINGQU"];
    
    UILabel *labDegree = (UILabel *)[cell.contentView viewWithTag:24];
    labDegree.text = _dataSource[indexPath.row][@"HULIDJ"];
    
    UILabel *labMake = (UILabel *)[cell.contentView viewWithTag:25];
    labMake.text = [_dataSource[indexPath.row][@"INPNO"] objString];
    
    UILabel *labNumber = (UILabel *)[cell.contentView viewWithTag:26];
    labNumber.text = [_dataSource[indexPath.row][@"ZYID"] objString];
    
    UILabel *labTime = (UILabel *)[cell.contentView viewWithTag:27];
    labTime.text = [NSString stringWithFormat:@"入院时间：%@",_dataSource[indexPath.row][@"ZYDATE"]];
    
    CareButton *btnAttention = (CareButton *)[cell.contentView viewWithTag:28];
    BOOL isAtt = [_dataSource[indexPath.row][@"ATTENT"]boolValue];
    btnAttention.selected = isAtt;
    btnAttention.btnTag = indexPath.row;
    
    UIView *headView = (UIView *)[cell.contentView viewWithTag:30];
    headView.layer.cornerRadius = 15;
    UIImageView *imgV = (UIImageView *)[headView viewWithTag:50];
    if ([labSex.text isEqualToString:@"女"]) {
        imgV.image = [UIImage imageNamed:@"woman"];
    }else{
        imgV.image = [UIImage imageNamed:@"man"];
    }
    UILabel *headOffice = (UILabel *)[headView viewWithTag:51];
    headOffice.text = _dataSource[indexPath.row][@"BINGQU"];
    
    UILabel *headNum = (UILabel *)[headView viewWithTag:52];
    headNum.text = [_dataSource[indexPath.row][@"CHUANG"] objString];
    
    UIImageView *imgTemp = (UIImageView *)[headView viewWithTag:100];
    UIImageView *imgNew = (UIImageView *)[headView viewWithTag:101];
    imgNew.hidden = ![_dataSource[indexPath.row][@"NEWPAT"] boolValue];
    
    
    NSInteger tempflag = [_dataSource[indexPath.row][@"TEMPFLAG"] integerValue];
    
    switch (tempflag) {
        case 0:
        {
            //新
            imgTemp.hidden = YES;
        }
            break;
        case 1:
        {
            
            imgTemp.hidden = YES;
        }
            break;
        case 2:
        {
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"blank"];
        }
            break;
        case 3:
        {
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"half"];
        }
            break;
        case 4:
        {
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"full"];
        }
            break;
            
        default:
            break;
    }
    
    
    
    
    [btnAttention addTarget:self action:@selector(didSelectAttention:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushDetailsViewController:_dataSource[indexPath.row]];
    
}
- (void)pushDetailsViewController:(NSDictionary *)dic
{
    DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    detailsVC.dict = dic;
    detailsVC.outKey = @"yes";
    detailsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailsVC animated:YES];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_mySearchBar isFirstResponder]) {
        [_mySearchBar resignFirstResponder];
    }
    
}

- (void)didSelectAttention:(CareButton *)btn
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BRPatsAttent withParameter:@{@"uid":USERID,@"bid":_dataSource[btn.btnTag][@"BRID"],@"vid":_dataSource[btn.btnTag][@"ZYID"],@"flag":@(!btn.selected)} completed:^(id content, NSError *err) {
        [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content[@"status"] integerValue] == 1) {
            if (btn.selected) {
                [self.view showSuccess:@"取消关注病人成功"];
            }else{
                [self.view showSuccess:@"关注病人成功"];
            }
            
            
        }else{
            [self.view showError:@"关注病人失败"];
        }
        
        
    }];
    
}


#pragma mark 选择完成操作PickerDate
- (void)didSelectCancelDateAction:(UIButton *)sender {
    [self didHiddenDatePickerView];
}
#pragma mark 选择完成并保存
- (void)didSelectFinishDateAction:(UIButton *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [formatter stringFromDate:_datePickerView.date];
    
    [_dateBtn setTitle:strDate forState:0];
    
    [self requestDatas];
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
        frame.origin.y = SCREEN_HEIGHT - _datePickViewBg.frame.size.height - 44;
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
