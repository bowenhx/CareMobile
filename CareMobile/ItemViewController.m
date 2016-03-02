//
//  ItemViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "ItemViewController.h"
#import "ConstantConfig.h"
#import "DetailsHeadView.h"
#import "AssessViewController.h"
#import "SubItemViewController.h"
#import "NSString+UIColor.h"
#import "ScanViewController.h"
#import "AssessDetailViewController.h"
#import "EndAssessViewController.h"
#import "ItemTypeViewCell3.h"
#import "SimpleCollectionViewCell.h"

#define ViewTag  999999

@interface ItemViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
{
    DetailsHeadView *_detailsView;
    
    UICollectionView        *_collectionView;
    
    UITableView             *_tableView;
    
    UIView                  *_detailView;
    
    UIView                  *_typeTitleView;
    
    NSMutableArray      *_dataSource;
    NSDictionary        *_dataDic;
    NSMutableArray      *_heightsArr;
    
    NSInteger           _showIndex;
    NSInteger           _showOldIndex;
    float               _viewHeight;
    UIButton           *_typeBtn;
    
    NSString            *_type1;
    NSString            *_type2;
    
    NSString           *_scanCode;//医嘱执行单中扫描过来的二维码
}
@end

@implementation ItemViewController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updataListData" object:nil];
}
- (void)loadViewHuLi
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2.4, 50);
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 20, 5, 20);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
//    flowLayout.minimumInteritemSpacing = 4;
//    flowLayout.minimumLineSpacing = 10;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, HEIGHTADDY(_detailsView), SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHTADDY(_detailsView)-128) collectionViewLayout:flowLayout];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor clearColor];
   
    UINib *nibCell = [UINib nibWithNibName:@"SimpleCollectionViewCell" bundle:nil];
    [_collectionView registerNib:nibCell forCellWithReuseIdentifier:@"collectionViewCell"];
    [self.view addSubview:_collectionView];
//    _collectionView.layer.borderWidth = 1;
//    _collectionView.layer.borderColor = [UIColor redColor].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataHuLi) name:@"updataListData" object:nil];
    
}
- (void)loadDataHuLi
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_HLList withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"]} completed:^(id content, NSError *err) {
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
                [_collectionView reloadData];
            }else{
                [self.view showHUDTitleView:[NSString stringWithFormat:@"此病人暂无%@信息",_navTitle] image:nil];
            }
        }
        
    }];

}
//护理评估单
- (void)loadEssesView
{
    
     [self initTableView:CGRectMake(0, HEIGHTADDY(_detailsView), SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHTADDY(_detailsView)-130)];
}

- (void)loadMeiRequest
{
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_NursingNames withParameter:@{@"uid":USERID} completed:^(id content, NSError *err) {
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


- (NSString *)itemTypeViewCellClass
{
    if ([_navTitle isEqualToString:@"手术"] || [_navTitle isEqualToString:@"标本管理"]) {
        return @"ItemTypeViewCell4";
    }else{
        return @"ItemTypeViewCell3";
    }

}
- (void)initTableView:(CGRect)rect
{
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
//    _tableView.layer.borderWidth = 1;
//    _tableView.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:_tableView];
    
  
    [_tableView registerNib:[UINib nibWithNibName:[self itemTypeViewCellClass] bundle:nil] forCellReuseIdentifier:[self itemTypeViewCellClass]];
    
   
}
- (void)loadTypeViewIndex:(NSInteger)row pageType:(NSInteger)index
{
    NSArray *typeViews = [[NSBundle mainBundle] loadNibNamed:@"SearchViewItem" owner:nil options:nil];
    
    _typeTitleView = typeViews[row];
    _typeTitleView.frame = CGRectMake(0, HEIGHTADDY(_detailsView), SCREEN_WIDTH, 44);
    [self.view addSubview:_typeTitleView];
    
    [self initTableView:CGRectMake(0, HEIGHTADDY(_typeTitleView), SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHTADDY(_typeTitleView)-372)];
    
    
    NSArray *viewTitles = nil;
    switch (index) {
        case 1:{
            viewTitles = @[@"标本",@"项目",@"检验日期"];
        }
            break;
        case 2:{
            _typeTitleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yizhubiaozhu3"]];
            
            viewTitles = @[@"项目名称",@"结果", @"标准值"];
        }
            break;
        case 3:{
            //创建一个view 用来点击展示详情的
            _detailView = typeViews[5];
            _detailView.tag = ViewTag;
            
            viewTitles = @[@"检查类别",@"检查子类",@"检查日期"];
        }
            break;
        case 4:{
            viewTitles = @[@"手术名称",@"手术部位",@"手术时间",@"手术医生"];
        }
            break;
        case 5:{
            viewTitles = @[@"标本",@"检查号",@"采集人",@"采集时间"];
        
        }
            break;
        case 6:{
            //医嘱
            viewTitles = @[@"医嘱内容",@"剂量",@"执行时间"];
        }
            break;
        case 7:{
            //医嘱执行单
            viewTitles = @[@"医嘱内容",@"剂量",@"执行时间"];
        }
            break;
        case 8:{
            
        }
            break;
            
        default:
            break;
    }
    
    if (index == 6 || index == 7) {
        //创建一个view 用来点击展示详情的
        _detailView = typeViews[5];
        _detailView.tag = ViewTag;
        

        int i= 0;
        for (UIButton *selectBtn in [_typeTitleView subviews]) {
            if ([selectBtn isKindOfClass:[UIButton class]]) {
                [selectBtn addTarget:self action:@selector(selectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
               
                if (index == 7) {
                    //医嘱执行单选中状态
                    selectBtn.selected = i== 2;
                    i++;
                }
            }
        }
        
        CGRect rect = _tableView.frame;
        rect.origin.y += 44;
        rect.size.height -= 44;
        _tableView.frame = rect;

        
        
        UIView *towTitleView = typeViews[2];
        towTitleView.frame = CGRectMake(0, HEIGHTADDY(_typeTitleView), SCREEN_WIDTH, 44);
        towTitleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yizhubiaozhu3"]];
        [self.view addSubview:towTitleView];
        
        i = 0;
        for (UILabel *titleLabel in [towTitleView subviews]) {
            titleLabel.text = viewTitles[i];
            titleLabel.textColor = [UIColor darkTextColor];
            i++;
        }
        
    }else{
       
        int i= 0;
        for (UILabel *titleLabel in [_typeTitleView subviews]) {
            titleLabel.text = viewTitles[i];
            titleLabel.textColor = [UIColor darkTextColor];
            i++;
        }
        
    }
    
    
    
    
    
    
    

}
- (void)loadDataTypeRequest:(NSString *)reqUrl
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:reqUrl withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"jyid":_JYID} completed:^(id content, NSError *err) {
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
                 [self.view showHUDTitleView:[NSString stringWithFormat:@"此病人暂无%@信息",_navTitle] image:nil];
            }
        }
        
    }];
}
- (void)loadYiZhuTypeRequest:(NSString *)reqUrl
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:reqUrl withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"ot":_type1,@"cl":_type2} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content isKindOfClass:[NSDictionary class]]) {
            _dataDic = content;
            NSArray *data = content[@"orderList"];
            
            if ([_navTitle isEqualToString:@"医嘱"]) {
                [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    NSString *string = obj[@"YZ_ITEM"];
                    CGRect rect = [string boundingRectWithSize:CGSizeMake(90, 500) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSTEMFONT(15)} context:nil];
                    
                    [_heightsArr addObject:@(rect.size.height)];
                }];
                
            }
            
            [_dataSource setArray:data];
            [_tableView reloadData];
            
            if (data.count ==0) {
                [self.view showHUDTitleView:[NSString stringWithFormat:@"此病人暂无%@信息",_navTitle] image:nil];
            }
            
            NSString *message = content[@"message"];
            if (message.length > 2 )
            {
                [self.view showHUDTitleView:message image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            
            
        }
        
    }];

}
- (void)selectTypeAction:(UIButton *)btn
{
    if (btn.tag <20) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"全部" otherButtonTitles:nil];
        _typeBtn = btn;
        
        if (btn.tag == 10) {
            NSArray *arrData = _dataDic[@"orderType"];
            [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [actionSheet addButtonWithTitle:obj[@"name"]];
            }];
        }else{
            NSArray *arrData = _dataDic[@"orderCL"];
            [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [actionSheet addButtonWithTitle:obj[@"name"]];
            }];
            
        }
        
        [actionSheet showInView:self.view];
    }else{
        
        //医嘱执行单选项操作
        for (UIButton *typeBtn in [_typeTitleView subviews]) {
            UIButton *itemBtn = (UIButton *)typeBtn;
            if (itemBtn.tag == btn.tag) {
                itemBtn.selected = true;
            }else{
                itemBtn.selected = false;
            }
        }
        NSString *typeStr = @"";
        switch (btn.tag) {
            case 20: typeStr = @"A"; break;
            case 21: typeStr = @"B"; break;
            case 22: typeStr = @"C"; break;
            case 23: typeStr = @"D"; break;
            case 24: typeStr = @"F"; break;
            default:
                break;
        }
        //请求网络布局数据
        _type1 = typeStr;
        [self loadYiZhuTypeRequest:CAPI_YZZXD];
    }
    
   
}

- (void)loadHeadViewDatas
{
    if (_dict.count) {
        
        _detailsView.lab1.text = _dict[@"BINGQU"];
        _detailsView.lab2.text = [NSString stringWithFormat:@"%@ 床",_dict[@"CHUANG"]];
        _detailsView.lab3.text = [NSString stringWithFormat:@"病人ID %@",_dict[@"BRID"]];
        _detailsView.lab4.text = [NSString stringWithFormat:@"住院次数 %@",_dict[@"ZYID"]];
        
        _detailsView.labContent1.text = _dict[@"BRNAME"];
        _detailsView.labContent2.text = _dict[@"SEX"];
        _detailsView.labContent3.text = [_dict[@"BIRTH"] ageNumberString];
        _detailsView.labContent4.text = _dict[@"HULIDJ"];
        _detailsView.labContent5.text = _dict[@"ZHUYI"];
        _detailsView.labContent6.text = [_dict[@"ZYDATE"] objString];
        _detailsView.labContent7.text = [self stringForNull:_dict[@"ZHENDUAN"]];
        _detailsView.labContent8.text = _dict[@"FEIBIE"];
        _detailsView.labContent9.text = [self stringForFloatValue:[_dict[@"FEIYUE"] floatValue]];
    }
    
}

- (NSString *)stringForNull:(NSString *)str
{
    if ([str isEqual:[NSNull null]]) {
        return @"-";
    }
    return str;
}
- (NSString *)stringForFloatValue:(float)value
{
    NSString *strValue = [NSString stringWithFormat:@"%.03f",value];
    return strValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initViews];
    
    [self loadHeadViewDatas];
}
- (void)initViews
{
    
    self.title  = _navTitle;
    
    _showIndex  = 0xffff;
    _showOldIndex = 0xfffff;
    
    NSArray *arrViews = [[NSBundle mainBundle] loadNibNamed:@"DetailsHeadView" owner:nil options:nil];
    _detailsView = arrViews[0];
    _detailsView.frame = CGRectMake(0, 64, SCREEN_WIDTH, HEIGHT(_detailsView));
    [self.view addSubview:_detailsView];

    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:@"添加" forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.tag = 10;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(didSelectAdd:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];
    
    
    
    _dataSource = [NSMutableArray array];
    _dataDic = [NSDictionary dictionary];
    
    if ([_navTitle isEqualToString:@"医嘱"]) {
        self.navigationItem.rightBarButtonItem = nil;
        _type1 = @"All";
        _type2 = @"All";
        
        _heightsArr = [NSMutableArray array];
        [self loadTypeViewIndex:6 pageType:6];
        
        [self loadYiZhuTypeRequest:CAPI_Yizhu];
    }else if ([_navTitle isEqualToString:@"医嘱执行单"]) {
        [navRightBtn setTitle:@"扫一扫" forState:UIControlStateNormal];
        navRightBtn.tag = 15;
        _type1 = @"C";
        _type2 = @"All";
        
        [self loadTypeViewIndex:7 pageType:7];
        [self loadYiZhuTypeRequest:CAPI_YZZXD];
        
    }else if ([_navTitle isEqualToString:@"护理评估"]) {
        [navRightBtn setTitle:@"已评估" forState:UIControlStateNormal];
        navRightBtn.tag = 20;
        
        [self loadEssesView];
        [self loadMeiRequest];
        
    }else if ([_navTitle isEqualToString:@"生命体征"]) {
        
        [self loadViewHuLi];
        
        [self loadDataHuLi];
        
    }else if ([_navTitle isEqualToString:@"检验"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self loadTypeViewIndex:2 pageType:1];
        
        [self loadDataTypeRequest:CAPI_JianYan];
    }else if ([_navTitle isEqualToString:@"检验结果"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self loadTypeViewIndex:2 pageType:2];
        
        [self loadDataTypeRequest:CAPI_JianYanJieGuo];
    }else if ([_navTitle isEqualToString:@"检查"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self loadTypeViewIndex:2 pageType:3];
        
        [self loadDataTypeRequest:CAPI_JianCha];
    }else if ([_navTitle isEqualToString:@"手术"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self loadTypeViewIndex:3 pageType:4];
        
        [self loadDataTypeRequest:CAPI_ShouShu];
    }else if ([_navTitle isEqualToString:@"标本管理"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self loadTypeViewIndex:3 pageType:5];
        
        [self loadDataTypeRequest:CAPI_YangBenList];
    }else if ([_navTitle isEqualToString:@"交接班"])
    {
        self.navigationItem.rightBarButtonItem = nil;
        
        [self loadDataTypeRequest:CAPI_JiaoJie];
    }
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)didSelectAdd:(UIButton *)btn
{
    if (btn.tag == 10) {
        SubItemViewController *subItem = [[SubItemViewController alloc] initWithNibName:@"SubItemViewController" bundle:nil];
        subItem.navTitle = _navTitle;
        subItem.dict = _dict;
        subItem.navRight = @"添加";
        [self.navigationController pushViewController:subItem animated:YES];
    }else if (btn.tag == 15){
        //扫码
        ScanViewController *scanVC = [[ScanViewController alloc] initWithNibName:@"ScanViewController" bundle:nil];
        scanVC.scanType = ScanTypeAdviceActon;
        [self.navigationController pushViewController:scanVC animated:YES];
        
        scanVC.didUpdataDicBlock = ^(NSDictionary *dictInfor){
            
            if (dictInfor.count) {
                _scanCode = dictInfor[@"code"];
                [self scanCodeRequestFlag:0];
                
//                self.dict = dictInfor;
//                [self loadHeadViewDatas];
            }
            
        };
    }else if (btn.tag == 20)
    {
        //护理评估单中选择已评估
        EndAssessViewController *endAssessVC = [[EndAssessViewController alloc] initWithNibName:@"EndAssessViewController" bundle:nil];
        endAssessVC.dict = _dict;
        [self.navigationController pushViewController:endAssessVC animated:YES];
    }
    
    
}
- (void)scanCodeRequestFlag:(NSInteger)index
{
    //扫码校对
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_YZZXDDOOK withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"uid":USERID,@"zt":@"C",@"code":_scanCode,@"flag":@(index)} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        //执行失败
        if ([content[@"status"] integerValue] == 1) {
            //确定去执行医嘱执行单
            [[[UIAlertView alloc] initWithTitle:nil message:content[@"msg"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
        }else {
            NSString *message = content[@"msg"];
            if (message.length > 2 ){
                [self.view showHUDTitleView:message image:nil];
            }
            if ([content[@"status"] integerValue] == 2) {
                //执行单执行成功后去刷新列表
                [self loadYiZhuTypeRequest:CAPI_YZZXD];
            }
        }
        
    }];
}
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self scanCodeRequestFlag:1];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataSource.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SimpleCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
  
    [self collectionViewCell:cell cellForItemIndexPath:indexPath];
    
    return cell;
}
- (void)collectionViewCell:(SimpleCollectionViewCell *)cell cellForItemIndexPath:(NSIndexPath *)indexPath
{
   
    [cell.itemBtn setTitle:_dataSource[indexPath.row][@"RECORDING_DATE"] forState:UIControlStateNormal];
    cell.itemBtn.tag = indexPath.row;
    
    [cell.itemBtn addTarget:self action:@selector(selectItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark -  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}
- (void)selectItemAction:(UIButton *)btn
{
    NSLog(@"btn.tag = %d",btn.tag);
    SubItemViewController *subItem = [[SubItemViewController alloc] initWithNibName:@"SubItemViewController" bundle:nil];
    subItem.navTitle = _navTitle;
    subItem.dict = _dict;
    subItem.navRight = @"保存";
    subItem.huliTime = btn.titleLabel.text;
    [self.navigationController pushViewController:subItem animated:YES];

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
    if ([_navTitle isEqualToString:@"手术"] || [_navTitle isEqualToString:@"标本管理"]) {
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:[self itemTypeViewCellClass] forIndexPath:indexPath];
        [self loadTypeViewCell4:cell cellForRowAtIndexPath:indexPath];
         return cell;
    }else{
        ItemTypeViewCell3 *cell = [_tableView dequeueReusableCellWithIdentifier:[self itemTypeViewCellClass] forIndexPath:indexPath];
        [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    }
   
   
}
- (void)loadTypeViewCell4:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *labName = (UILabel *)[cell.contentView viewWithTag:10];
    UILabel *labSex  = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *labAge  = (UILabel *)[cell.contentView viewWithTag:12];
    UILabel *labTime        = (UILabel *)[cell.contentView viewWithTag:13];
    if ( [_navTitle isEqualToString:@"标本管理"] )
    {
        cell.selectionStyle      = UITableViewCellSelectionStyleNone;
        UIImageView *imgColor    = (UIImageView *)[cell.contentView viewWithTag:5];
       
        imgColor.backgroundColor = [_dataSource[indexPath.row][@"COLOR"] color];
        labName.text             = _dataSource[indexPath.row][@"YBNAME"];
        labSex.text              = _dataSource[indexPath.row][@"TEST_NO_SRC"];
        labAge.text              = [self stringForNull:_dataSource[indexPath.row][@"CJNAME"]];
        labTime.text             = [self stringForNull:_dataSource[indexPath.row][@"CJTIME"]];
    }else if ( [_navTitle isEqualToString:@"手术"] ){
        cell.selectionStyle      = UITableViewCellSelectionStyleNone;
        labName.text             = _dataSource[indexPath.row][@"SHOUSHU_NAME"];
        labSex.text              = _dataSource[indexPath.row][@"SHOWSHU_BUWEI"];
        labAge.text              = _dataSource[indexPath.row][@"SHOUSHU_DATE"];
        labTime.text             = _dataSource[indexPath.row][@"SHOUSHU_YISHI"];
        
    }
}
- (void)loadDataForTableViewCell:(ItemTypeViewCell3 *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_navTitle isEqualToString:@"医嘱"] || [_navTitle isEqualToString:@"医嘱执行单"]){
    
        cell.labTitle1.text        = _dataSource[indexPath.row][@"YZ_ITEM"];
        cell.labTitle2.text         = [NSString stringWithFormat:@"%@%@",_dataSource[indexPath.row][@"YZ_JINUM"],_dataSource[indexPath.row][@"YZ_DANWEI"]];
        cell.labTitle3.text         = _dataSource[indexPath.row][@"ZX_TIME"];
        
        NSString *colorStr  = _dataSource[indexPath.row][@"YZ_COLOR"];
        cell.labTitle1.textColor   = [colorStr color];
        cell.labTitle2.textColor    = [colorStr color];
        cell.labTitle3.textColor    = [colorStr color];
        
        if ([_navTitle isEqualToString:@"医嘱执行单"]) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([colorStr isEqualToString:@"#009900"]) {
                cell.backgroundColor = RGB(140, 210, 200);
            }else{
                cell.backgroundColor = RGB(100, 220, 210);//RGB(104, 215, 200);
            }
        }else{
            float flot = [_heightsArr[indexPath.row] floatValue];
//            flot = flot < 20 ? 50 : flot;
            cell.titleHeight.constant = flot < 40 ? 50 : flot;
//            cell.titleHeight2.constant = flot;
//            cell.titleHeight3.constant = flot;
        }
        
        
        [self addViewForCell:cell cellForRowAtIndexPath:indexPath];
        
    }else if ([_navTitle isEqualToString:@"检验"]){
        cell.labTitle1.text        = _dataSource[indexPath.row][@"JY_BIAOBEN"];
        cell.labTitle2.text         = _dataSource[indexPath.row][@"JY_ZHENDUAN"];
        cell.labTitle3.text         = _dataSource[indexPath.row][@"JY_DATE"];

    }else if ([_navTitle isEqualToString:@"检验结果"]){
        cell.labTitle1.text        = _dataSource[indexPath.row][@"REITEM"];
        cell.labTitle2.text         = _dataSource[indexPath.row][@"RESULTOK"];
        cell.labTitle3.text         = _dataSource[indexPath.row][@"ZHENGCHANG"];
        
        NSString *state = _dataSource[indexPath.row][@"STATE"];
        if ([state isEqualToString:@"L"]) {
            cell.labTitle1.textColor = [UIColor greenColor];
            cell.labTitle2.textColor  = [UIColor greenColor];
            cell.labTitle3.textColor  = [UIColor greenColor];
        }else if ([state isEqualToString:@"H"])
        {
             cell.labTitle1.textColor = [UIColor redColor];
            cell.labTitle2.textColor  = [UIColor redColor];
            cell.labTitle3.textColor  = [UIColor redColor];
        }
        
    }else if ([_navTitle isEqualToString:@"检查"]){
        
        cell.labTitle1.text        = _dataSource[indexPath.row][@"JC_BIGC"];
        cell.labTitle2.text         = _dataSource[indexPath.row][@"JC_SMC"];
        cell.labTitle3.text         = _dataSource[indexPath.row][@"JC_DATE"];

        [self addViewForCell:cell cellForRowAtIndexPath:indexPath];
        
    }else if ( [_navTitle isEqualToString:@"护理评估"] ){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.labTitle1.hidden = YES;
        cell.labTitle2.hidden  = YES;
        cell.labTitle3.hidden  = YES;
        cell.textLabel.text = _dataSource[indexPath.row][@"NAME"];
    }
    
}
- (void)addViewForCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showIndex == indexPath.row) {
        //判断当前cell 内容是否正在展示内容详细，如果有，去掉内容详细view，否则重新加上
        BOOL isShow = NO;
        for (UIView *detailView in [cell.contentView subviews]) {
            if (detailView.tag == ViewTag) {
                isShow = YES;
                [detailView removeFromSuperview];
            }
        }
        
        if (isShow) {
            return;
        }
        float flot = [_heightsArr[indexPath.row] floatValue];
        
        _detailView.frame = CGRectMake(0, flot < 40 ? 50 : flot, cell.frame.size.width, _viewHeight);
        [cell.contentView addSubview:_detailView];
        
        UILabel *labDetail = (UILabel *)[_detailView viewWithTag:10];
        NSString *nameKey = @"";
        if ([_navTitle isEqualToString:@"医嘱"]) {
            nameKey = @"ORDER_CLASS_NAME";
        }else{
            nameKey = @"JC_MEMO";
        }
        labDetail.text = _dataSource[indexPath.row][nameKey];
        
        UIImageView *imageV = (UIImageView *)[_detailView viewWithTag:20];
        imageV.image = [[UIImage imageNamed:@"yizhubiaozhu"] stretchableImageWithLeftCapWidth:5 topCapHeight:25];
        
    }else{
        for (UIView *detailView in [cell.contentView subviews]) {
            if (detailView.tag == ViewTag) {
                [detailView removeFromSuperview];
            }
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_navTitle isEqualToString:@"检验"]){
       ItemViewController *itemVC = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
       itemVC.dict = _dict;
       itemVC.navTitle = @"检验结果";
       itemVC.JYID = _dataSource[indexPath.row][@"JY_ID"];
       [self.navigationController pushViewController:itemVC animated:YES];
    }else if ([_navTitle isEqualToString:@"检查"]){
        //判断是否点击同一个cell ，如果是隐藏内容详细view
        if (_showIndex == _showOldIndex) {
            _showIndex = 0xffff;
             [_tableView reloadData];
        }else{
            _showIndex = indexPath.row;
            [_tableView reloadData];
            _showOldIndex = indexPath.row;
        }
       
    }else if ([_navTitle isEqualToString:@"医嘱"]){
        if (_showIndex == _showOldIndex) {
            _showIndex = 0xffff;
            [_tableView reloadData];
        }else{
            _showIndex = indexPath.row;
            [_tableView reloadData];
            _showOldIndex = indexPath.row;
        }
       
    }else if ( [_navTitle isEqualToString:@"护理评估"])
    {
        AssessDetailViewController *assessDetailVC = [[AssessDetailViewController alloc] initWithNibName:@"AssessDetailViewController" bundle:nil];
        assessDetailVC.assessID = _dataSource[indexPath.row][@"ID"];
        assessDetailVC.title = _dataSource[indexPath.row][@"NAME"];
        assessDetailVC.dict = _dict;
        [self.navigationController pushViewController:assessDetailVC animated:YES];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_showIndex != 0xffff) {
        if (_showIndex == indexPath.row) {
            NSString *string = _dataSource[indexPath.row][@"JC_MEMO"];
            if ([string isEqualToString:@"-"]) {
                _viewHeight = 40;
            }else{
                CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_HEIGHT - 20, 800) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYSTEMFONT(15)} context:nil];
                _viewHeight = rect.size.height + 78;
            }
            float flot = [_heightsArr[indexPath.row] floatValue];
            return  _viewHeight + (flot < 40 ? 50 : flot);
           
        }else{
            float flot = [_heightsArr[indexPath.row] floatValue];
            return flot < 40 ? 50 : flot;
        }
    }
    else if ([_navTitle isEqualToString:@"医嘱"])
    {
        float flot = [_heightsArr[indexPath.row] floatValue];
        return flot < 40 ? 50 : flot;
    }
    
    return 50;
}

#pragma mark UIActionDelegate 医嘱类型请求操作
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index = %ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        //取消选项，这里不处理
        return;
    }
    
    if (buttonIndex == 0) {
         [_typeBtn setTitle:@"全部" forState:UIControlStateNormal];
        if (_typeBtn.tag == 10) {
            _type1 = @"All";
        }else{
            _type2 = @"All";
        }
        [self loadYiZhuTypeRequest:CAPI_Yizhu];
        return;
    }
    
    if (_typeBtn.tag == 10) {
        NSMutableArray *arrData = [NSMutableArray arrayWithArray:_dataDic[@"orderType"]];
        [arrData insertObject:@{@"name":@"全部"} atIndex:0];
        [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (buttonIndex == idx +1) {
                [_typeBtn setTitle:obj[@"name"] forState:UIControlStateNormal];
                _type1 = obj[@"code"];
            }
            
        }];
    }else{
        NSMutableArray *arrData = [NSMutableArray arrayWithArray:_dataDic[@"orderCL"]];
        [arrData insertObject:@{@"name":@"全部"} atIndex:0];
        [arrData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (buttonIndex == idx +1) {
                [_typeBtn setTitle:obj[@"name"] forState:UIControlStateNormal];
                _type2 = obj[@"code"];
            }
            
        }];
        
    }
   
    [self loadYiZhuTypeRequest:CAPI_Yizhu];
}

@end
