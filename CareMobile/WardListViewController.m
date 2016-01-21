//
//  WardListViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/9.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "WardListViewController.h"

@interface WardListViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
{
     __weak IBOutlet UITableView  *_tableView;
    
    
    IBOutlet UIView *_footView;
    
    NSMutableArray  *_dataSource;
    
    NSMutableArray  *_editData;
    
    NSInteger       _indexRow;
}
@end

@implementation WardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    
    
    [self initLoadData];
    
    _dataSource = [[NSMutableArray alloc] initWithArray:_dictInfo[@"rooms"]];
    _editData = [NSMutableArray array];
}
- (void)initLoadData
{
    [_tableView registerNib:[UINib nibWithNibName:@"ItemTypeViewCell" bundle:nil] forCellReuseIdentifier:@"ItemTypeViewCell"];


    
    [_tableView setTableFooterView:_footView];
}

- (IBAction)selectSaveItemAction:(id)sender{
    if (_editData.count == 0) {
        
        [self.view showHUDTitleView:@"请选择状态再做保存" image:nil];
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:_editData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSDictionary *dict = @{
                           @"uid":USERID,
                           @"rec":json
                           };
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithPostCompletion:CAPI_WardBedSave withParmeter:dict completed:^(id content, NSError *err) {
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
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"ItemTypeViewCell" forIndexPath:indexPath];
    
    UILabel *labNum = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *labName  = (UILabel *)[cell.contentView viewWithTag:11];
    UIButton *statusBtn  = (UIButton *)[cell.contentView viewWithTag:13];
    statusBtn.hidden = NO;
    statusBtn.userInteractionEnabled = NO;
    labNum.text =  [NSString stringWithFormat:@"%@",_dataSource[indexPath.row][@"bed_no"]];
    
    labName.text = _dataSource[indexPath.row][@"name"];
    
    NSString *statusTitle = _dataSource[indexPath.row][@"status"];
    if (![@"" isStringBlank:statusTitle]) {
        [statusBtn setTitle:statusTitle forState:0];
    }else{
        [statusBtn setTitle:@"" forState:0];
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    headView.backgroundColor = RGB(255, 154, 56);
    headView.alpha = 0.6;
    UILabel *labText = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 40)];
    labText.textAlignment = NSTextAlignmentCenter;
    labText.backgroundColor = [UIColor clearColor];
    labText.font = [UIFont systemFontOfSize:15];
    labText.text = [NSString stringWithFormat:@"%@    %@病房",_dictInfo[@"ward_name"],_dictInfo[@"room_no"]];
    [headView addSubview:labText];
    
    NSArray *typeViews = [[NSBundle mainBundle] loadNibNamed:@"SearchViewItem" owner:nil options:nil];
    
    UIView *typeView = typeViews[2];
    typeView.backgroundColor = [UIColor lightGrayColor];
    typeView.frame = CGRectMake(0, HEIGHTADDY(labText), SCREEN_WIDTH, 40);
    [headView addSubview:typeView];
    NSArray *titles = @[@"床号",@"病人",@"状态"];
    int i=0;
    for (UILabel *titleLabel in [typeView subviews]) {
        titleLabel.text = titles[i];
        titleLabel.textColor = [UIColor darkTextColor];
        i ++;
    }
    
    
    return headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _indexRow = indexPath.row;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    

    NSArray *arrData = [_dictInfo[@"status_dict"] componentsSeparatedByString:@"$"];
    [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [actionSheet addButtonWithTitle:obj];
    }];

    [actionSheet showInView:self.view];
}
#pragma  mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSArray *arrData = [_dictInfo[@"status_dict"] componentsSeparatedByString:@"$"];
        NSMutableDictionary *mutabDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[_indexRow]];
        mutabDic[@"status"] = arrData[buttonIndex-1];
        [_dataSource replaceObjectAtIndex:_indexRow withObject:mutabDic];
        [_editData addObject:@{@"bed_no":mutabDic[@"bed_no"],@"status":mutabDic[@"status"]}];
        [_tableView reloadData];
    }


   

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
