//
//  PatientsViewController.m
//  CareMobile
//
//  Created by Guibin on 15/10/30.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "PatientsViewController.h"
#import "ConstantConfig.h"
#import "MBProgressHUD.h"
#import "CARequest.h"
#import "DetailsViewController.h"
#import "ScanViewController.h"
#import "ManageViewController.h"
#import "CareButton.h"
#import "PresentsViewController.h"
#import "MJRefresh.h"

@interface PatientsViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    
    __weak IBOutlet UIButton *_navLeftBtn;
    
    __weak IBOutlet UIButton *_navBtnName;
    
    
    __weak IBOutlet  UISegmentedControl *_segmentedContBtn;
    
    __weak IBOutlet UIButton *_navRightBtn;
    
    __weak IBOutlet UISearchBar *_mySearchBar;
    
    __weak IBOutlet UITableView  *_tableView;
    

    
    NSMutableArray          *_dataSource;
}
@property (nonatomic , strong) UIImageView *imgView;
@end

@implementation PatientsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    
//    _tableView.layer.borderWidth = 1;
//    _tableView.layer.borderColor = [UIColor redColor].CGColor;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _segmentedContBtn.selectedSegmentIndex= 0;
    
    [self initViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDatas) name:UpdataNotification object:nil];
   
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_dataSource.count == 0) {
         [_tableView.header beginRefreshing];
    }
}
- (void)initViews
{
    _navRightBtn.layer.cornerRadius = 15;
    _navRightBtn.layer.borderWidth = 1;
    _navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _navRightBtn.layer.masksToBounds = YES;
    
    
    NSDictionary *dicdata = [SavaData parseDicFromFile:User_File];
    [_navBtnName setTitle:dicdata[@"utname"] forState:UIControlStateNormal];
    
    _segmentedContBtn.tintColor = [UIColor whiteColor];
    [_segmentedContBtn setWidth:60 forSegmentAtIndex:0];
    _segmentedContBtn.selectedSegmentIndex = 0;
    
    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadDatas)];
    
}
- (void)reloadDatas
{
    _mySearchBar.text = @"";
    
    NSLog(@"userID = %@",USERID);
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BingRenList withParameter:@{@"uid":USERID,@"curpage":@"1"} completed:^(id content, NSError *err) {
         [self.view removeHUDActivity];
        NSLog(@"content = %@",content);
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            
            if (_segmentedContBtn.selectedSegmentIndex == 0) {
                //所有病人
                [_dataSource setArray:content];
                [_tableView reloadData];
            }else{
                [_dataSource removeAllObjects];
                
                //已关注病人
                [content enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if ([obj[@"ATTENT"] integerValue] == 1) {
                        [_dataSource addObject:obj];
                    }
                }];
                
                [_tableView reloadData];
            }
        }
        
        /**
         *  隐藏上拉刷新或者上拉加载更多状态
         */
        if (_tableView.header.isRefreshing) {
            [_tableView.header endRefreshing];
        }
    }];
    
//    [[CARequest shareInstance] startWithRequestCompletion:CAPI_Huili withParameter:@{@"api":@"1qaz2wsx",@"bid":@"00133083",@"vid":@"1",@"hldate":@"2015/5/8",@"cls":@"B"} completed:^(id content, NSError *err) {
//       
//        NSLog(@"content = %@",content);
//        if ([content isKindOfClass:[NSDictionary class]]) {
//            NSString *message = content[@"message"];
//            if (message.length > 2 )
//            {
//                [self.view showHUDTitleView:message image:nil];
//            }
//        }
//    }];
    
    
//    [[CARequest shareInstance] startWithRequestCompletion:CAPI_Order withParameter:@{@"api":@"1qaz2wsx",@"cls":@"B"} completed:^(id content, NSError *err) {
//        
//        NSLog(@"content = %@",content);
//    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.view showHUDActivityView:@"正在加载" shade:NO];
   
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_mySearchBar resignFirstResponder];
    
}

#pragma mark 搜索页面，扫描二维码
- (IBAction)didSelectScanVC:(id)sender
{
    ScanViewController *scanVC = [[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil];
//    scanVC.isSearch = 1;
    scanVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:scanVC animated:YES];
    scanVC.didUpdataDicBlock = ^(NSDictionary * dict){
         [self pushDetailsViewController:dict];
    };
}
#pragma mark 体温预警列表
- (IBAction)didSelectTemperatureVC:(id)sender
{
    PresentsViewController *presentsVC = [[PresentsViewController alloc] initWithNibName:@"PresentsViewController" bundle:nil];
    presentsVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:presentsVC animated:YES];
}
- (IBAction)selectTitleTypeAction:(UISegmentedControl *)sender {
    [_tableView.header beginRefreshing];
}


#pragma mark 设置
- (IBAction)selectSettingVC:(id)sender{
    ManageViewController *manageVC = [[ManageViewController alloc] initWithNibName:@"ManageViewController" bundle:nil];
    manageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:manageVC animated:YES];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *strKey = [searchBar.text stringByAppendingString:text];
    [self searchBeginAction:strKey];
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
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_BRSearch withParameter:@{@"uid":USERID,@"curpage":@"1",@"key":key} completed:^(id content, NSError *err) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    labMake.text = [_dataSource[indexPath.row][@"BRID"] objString];
    
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
    
    NSInteger tempflag = [_dataSource[indexPath.row][@"TEMPFLAG"] integerValue];
    
    switch (tempflag) {
        case 0:
        {
            //新
            imgNew.hidden = NO;
            imgTemp.hidden = YES;
        }
            break;
        case 1:
        {
            //无
            imgNew.hidden = YES;
            imgTemp.hidden = YES;
        }
            break;
        case 2:
        {
            //正常
            imgNew.hidden = YES;
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"blank"];
        }
            break;
        case 3:
        {
            //新
            imgNew.hidden = YES;
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"half"];
        }
            break;
        case 4:
        {
            //新
            imgNew.hidden = YES;
            imgTemp.hidden = NO;
            imgTemp.image = [UIImage imageNamed:@"full"];
        }
            break;
            
        default:
            break;
    }
    
   
    
    
    [btnAttention addTarget:self action:@selector(didSelectAttention:) forControlEvents:UIControlEventTouchUpInside];
    
}

//- (NSString *)ageNumber:(NSString *)str
//{
//    NSInteger num = [[str substringToIndex:4] integerValue];
//    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"yyyy-MM-dd"];
//    NSInteger year = [[formater stringFromDate:[NSDate date]] integerValue];
//    
//    return [NSString stringWithFormat:@"%ld",year - num];
    /*
     
     NSDate *brithDate = [formater dateFromString:str];
     // 出生日期转换 年月日
     NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:brithDate];
     NSInteger brithDateYear  = [components1 year];
     NSInteger brithDateDay   = [components1 day];
     NSInteger brithDateMonth = [components1 month];
     
     // 获取系统当前 年月日
     NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
     NSInteger currentDateYear  = [components2 year];
     NSInteger currentDateDay   = [components2 day];
     NSInteger currentDateMonth = [components2 month];
     
     // 计算年龄
     NSInteger iAge = currentDateYear - brithDateYear;
     if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
     iAge++;
     }
     */
    
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushDetailsViewController:_dataSource[indexPath.row]];

}
- (void)pushDetailsViewController:(NSDictionary *)dic
{
    DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithNibName:@"DetailsViewController" bundle:nil];
    detailsVC.dict = dic;
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
            
            
            NSMutableDictionary *mutabDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[btn.btnTag]];
            mutabDic[@"ATTENT"] = @(!btn.selected);
            
            [_dataSource replaceObjectAtIndex:btn.btnTag withObject:mutabDic];
            
            [_tableView reloadData];
        }else{
            [self.view showError:@"关注病人失败"];
        }
        
       
    }];

}
@end
