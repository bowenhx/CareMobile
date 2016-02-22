//
//  DetailsViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/1.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "DetailsViewController.h"
#import "ConstantConfig.h"
#import "DetailsHeadView.h"
#import "ItemViewController.h"
#import "AssessViewController.h"
#import "ScanViewController.h"

@interface DetailsViewController ()
{
    __weak IBOutlet UIScrollView *_headScrollView;
    
    __weak IBOutlet UIView *_ItemViews;
    
    UIButton *_navNameBtn;
    
    DetailsHeadView *_detailsView;
}
@property (nonatomic , copy) NSString *state;
@end

@implementation DetailsViewController

- (void)didSelectBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSArray *)rightItemBtns
{
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(0, 0, 70, 30);
    [btn1 setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [btn1 setTitle:@"下一床" forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:14];
    btn1.tag = 500;
    btn1.layer.cornerRadius = 15;
    btn1.layer.borderWidth = 1;
    btn1.layer.borderColor = [UIColor whiteColor].CGColor;
    btn1.layer.masksToBounds = YES;
    
    
    UIButton *btn2=[UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0, 0, 70, 30);
    [btn2 setTitle:@"上一床" forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:14];
    btn2.tag = 600;
    [btn2 setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    btn2.layer.cornerRadius = 15;
    btn2.layer.borderWidth = 1;
    btn2.layer.borderColor = [UIColor whiteColor].CGColor;
    btn2.layer.masksToBounds = YES;
    
    UIBarButtonItem *barBtn1 = [[UIBarButtonItem alloc]initWithCustomView:btn1];
    UIBarButtonItem *barBtn2 = [[UIBarButtonItem alloc]initWithCustomView:btn2];
    
    [btn1 addTarget:self action:@selector(selectViewItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(selectViewItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return @[barBtn1 , barBtn2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self initViews];
    
   
    _state = @"";
    
    [self loadDatas];
   
    
//    for (int i=0; i<3; i++) {
//        
//        DetailsHeadView *detailsView = [[DetailsHeadView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, HEIGHT(_headScrollView))];
//        detailsView.backgroundColor = [SavaData randomColor];
//        [_headScrollView addSubview:detailsView];
//    }
    

    
}
- (void)initViews
{
    
    
    self.navigationItem.rightBarButtonItems = [self rightItemBtns];

    //_headScrollView.contentSize = CGSizeMake(WIDTH(_headScrollView), HEIGHT(_headScrollView));
    
    
    NSArray *arrViews = [[NSBundle mainBundle] loadNibNamed:@"DetailsHeadView" owner:nil options:nil];
    _detailsView = arrViews[0];
    _detailsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT(_detailsView));
    //DetailsHeadView *headView = [[DetailsHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];

    
    [_headScrollView addSubview:_detailsView];
}

- (void)loadDatas
{
    if (_dict.count) {
        [self.view showHUDActivityView:@"正在加载" shade:NO];
        [[CARequest shareInstance] startWithRequestCompletion:CAPI_BingRen withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"t":_state,@"out":_outKey} completed:^(id content, NSError *err) {
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
                    _dict = content[0];
                    [self loadHeadViewDatas];
                }else if ([_state isEqualToString:@"up"]){
                    [self.view showHUDTitleView:@"已是第一位病人" image:nil];
                }else if ([_state isEqualToString:@"next"]){
                    [self.view showHUDTitleView:@"已是最后一位病人" image:nil];
                }
                
            }
            
        }];
    }
    


    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)loadHeadViewDatas
{
    if (_dict.count) {
        self.backText = _dict[@"BRNAME"];
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
- (IBAction)selectItemAction:(UIButton *)btn
{
    NSLog(@"btn.tag = %d",btn.tag);
    NSString *text = btn.titleLabel.text;
    if ( [text isEqualToString:@"教育"] || [text isEqualToString:@"交接班"]) {
        [self.view showHUDTitleView:@"该功能暂未开放，敬请期待" image:nil];
        return;
    }
    switch (btn.tag) {
        case 50:
        {
            AssessViewController *assessVC = [[AssessViewController alloc] initWithNibName:@"AssessViewController" bundle:nil];
            assessVC.navTitle = @"护理记录单";
            assessVC.dict = _dict;
            [self.navigationController pushViewController:assessVC animated:YES];
        }
            break;
        case 55:
        {
            AssessViewController *assessVC = [[AssessViewController alloc] initWithNibName:@"AssessViewController" bundle:nil];
            assessVC.navTitle = @"教育";
            assessVC.dict = _dict;
            [self.navigationController pushViewController:assessVC animated:YES];
        }
            break;
        case 61:
        {
            AssessViewController *assessVC = [[AssessViewController alloc] initWithNibName:@"AssessViewController" bundle:nil];
            assessVC.navTitle = @"病程录";
            assessVC.dict = _dict;
            [self.navigationController pushViewController:assessVC animated:YES];

        }
            break;

        default:
        {
            ItemViewController *itemVC = [[ItemViewController alloc] initWithNibName:@"ItemViewController" bundle:nil];
            itemVC.dict = _dict;
            itemVC.navTitle = btn.titleLabel.text;
            itemVC.JYID = @"";
            [self.navigationController pushViewController:itemVC animated:YES];
        }
            break;
    }
    
   
}
- (void)selectViewItemAction:(UIButton *)btn
{
    if (btn.tag == 500) {
       //下一床
        _state = @"next";
    }else{
        
        //上一床
        _state = @"up";
    }
    [self loadDatas];
}

- (IBAction)swipeGestureRightAction:(id)sender {
    //上一床
    _state = @"up";
    [self loadDatas];
}
- (IBAction)swipeGestureLefttAction:(id)sender {
     //下一床
    _state = @"next";
    [self loadDatas];
}


- (void)tapBackBtn
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdataNotification object:nil];
}
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
