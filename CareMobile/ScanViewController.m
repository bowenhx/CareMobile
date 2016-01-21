//
//  ScanViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/14.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "ScanViewController.h"
#import "ZBarSDK.h"
#import "SearchViewController.h"
#import "ItemViewController.h"
#import "WardListViewController.h"
#import "WardHistoryViewController.h"
#import "RetrievalViewController.h"

@interface ScanViewController ()<ZBarReaderViewDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UIView *_searchTypeView;
    
    
    NSInteger       _wardRounds;
    
}
@end

@implementation ScanViewController
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_color) {
        self.navigationController.navigationBar.barTintColor = _color;
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"扫描二维码";

    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:@"历史查询" forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(selectHistorySee) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];
    
    
    ZBarReaderView *readview = [ZBarReaderView new]; // 初始化
    readview.frame = CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(self.view)); // 改变frame
    readview.readerDelegate = self; // 设置delegate
    readview.allowsPinchZoom = NO; // 不使用Pinch手势变焦
    readview.torchMode = 0;
    
    [self.view addSubview:readview];
    
    [readview start]; // 开始扫描 [readview stop]; // 停止扫描
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:readview.frame];
    imageV.image = [UIImage imageNamed:@"icon_scan_codeBg"];
    imageV.alpha = .2f;
    [self.view addSubview:imageV];
    
    ZBarImageScanner *scanner = readview.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    
    if (_scanType == ScanTypeSearchAction) {
        _searchTypeView.hidden = NO;
        _wardRounds = 10;
        
        _searchTypeView.backgroundColor = [UIColor colorAppBg];
        
        [self.view sendSubviewToBack:readview];
        
        for (UIButton *btn in _searchTypeView.subviews) {
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        
    }
    
    /*
    UIButton *btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.frame = CGRectMake(50, SCREEN_HEIGHT-60, SCREEN_WIDTH - 100, 40);
    [btnSearch setTitle:@"直接搜索" forState:UIControlStateNormal];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(didSelectSearchAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSearch];
    if (!_isSearch) {
         [btnSearch setTitle:@"扫码查看" forState:UIControlStateNormal];
    }
    btnSearch.hidden = YES;*/
}
//历史巡防记录
- (void)selectHistorySee
{
    RetrievalViewController *tetrievalVC = [[RetrievalViewController alloc] initWithNibName:@"RetrievalViewController" bundle:nil];
    [self.navigationController pushViewController:tetrievalVC animated:YES];
    
//    WardHistoryViewController *wardHistoryVC = [[WardHistoryViewController alloc] initWithNibName:@"WardHistoryViewController" bundle:nil];
//    [self.navigationController pushViewController:wardHistoryVC animated:YES];
}
- (IBAction)selectSearchBingRTypeAction:(UIButton *)sender {
    
    if (sender.tag == 10) {
        UIButton *btn = (UIButton *)[_searchTypeView viewWithTag:11];
        if (sender.selected) {
            btn.selected = YES;
            _wardRounds = 11;
        }else{
            btn.selected = NO;
            _wardRounds = 10;
        }
        sender.selected = !sender.selected;
    }else{
        UIButton *btn = (UIButton *)[_searchTypeView viewWithTag:10];
        if (sender.selected) {
            btn.selected = YES;
            _wardRounds = 10;
        }else{
            btn.selected = NO;
            _wardRounds = 11;
        }
        sender.selected = !sender.selected;
       
    }
    
//    NSLog(@"_wardRounds = %d",_wardRounds);
   
}



- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{ // 得到扫描的条码内容
    const zbar_symbol_t *symbol = zbar_symbol_set_first_symbol(symbols.zbarSymbolSet);
    NSString *symbolStr = [NSString stringWithUTF8String:zbar_symbol_get_data(symbol)];
    if (zbar_symbol_get_type(symbol) == ZBAR_QRCODE)
    {
        // 是否QR二维码
        NSLog(@"symbolStr = %@",symbolStr);
        //扫码登陆类型处理
        if (_scanType == ScanTypeLoginAction) {
            
            [self.navigationController popViewControllerAnimated:YES];
            if (_didUpdataDicBlock) {
                _didUpdataDicBlock (@{@"uname":symbolStr});
            }
            return;
        }else if (_scanType == ScanTypeAdviceActon){
            //医嘱执行单扫码
            if (_didUpdataDicBlock) {
                _didUpdataDicBlock (@{@"code":symbolStr});
            }
            [self.navigationController popViewControllerAnimated:YES];
            return;
            
        }
        
        //扫码搜索用户类型处理
        if (_wardRounds == 10) {
            [self.view showHUDActivityView:@"正在加载" shade:NO];
            [[CARequest shareInstance] startWithRequestCompletion:CAPI_BRSearch withParameter:@{@"uid":USERID,@"curpage":@"1",@"key":symbolStr} completed:^(id content, NSError *err) {
                [self.view removeHUDActivity];
                NSLog(@"content = %@",content);
                if ([content isKindOfClass:[NSDictionary class]]) {
                    NSString *message = content[@"message"];
                    if (message.length > 2 )
                    {
                        [self.view showHUDTitleView:@"没有搜索到匹配内容" image:nil];
                    }
                }else if ([content isKindOfClass:[NSArray class]]){
                    NSArray *data = (NSArray *)content;
                    if (data.count) {
                        NSDictionary *dict = data[0];
                        if ([dict isKindOfClass:[NSDictionary class]]) {
                            [self.navigationController popViewControllerAnimated:YES];
                            if (_didUpdataDicBlock) {
                                _didUpdataDicBlock (dict);
                            }
                        }
                    }else{
                        [self.view showHUDTitleView:@"没有搜索到匹配内容" image:nil];
                    }
                }
            }];

        }else{
            //病房巡视搜索
            [self.view showHUDActivityView:@"正在加载" shade:NO];
            [[CARequest shareInstance] startWithRequestCompletion:CAPI_WardBedList withParameter:@{@"uid":USERID,@"code":symbolStr} completed:^(id content, NSError *err) {
                [self.view removeHUDActivity];
                NSLog(@"content = %@",content);
                if ([content isKindOfClass:[NSDictionary class]]) {
                    WardListViewController *wardListVC = [[WardListViewController alloc] initWithNibName:@"WardListViewController" bundle:nil];
                    wardListVC.dictInfo = content;
                    [self.navigationController pushViewController:wardListVC animated:YES];
                    
                }else if ([content isKindOfClass:[NSArray class]]){
                }else{
                        [self.view showHUDTitleView:@"没有搜索到匹配内容" image:nil];
                }

            }];

            
            
        }
        
        
        

        
//        [[[UIAlertView alloc] initWithTitle:nil message:symbolStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil] show];
    }else{
        [self.view showHUDTitleView:@"请扫描二维码再尝试" image:nil];
    }
    
}
/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self didSelectSearchAction];
}
- (void)didSelectSearchAction
{
    if (_isSearch) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchViewController *searchVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:searchVC animated:YES];
    }else{
        ItemViewController *itemVC = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
        itemVC.dict = _dict;
        itemVC.strAge = _strAge;
        itemVC.navTitle = _navTitle;
        itemVC.JYID = @"";
        [self.navigationController pushViewController:itemVC animated:YES];
    }
   
}*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
