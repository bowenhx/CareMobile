//
//  Assess2ViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/3.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "Assess2ViewController.h"
#import "ConstantConfig.h"

@interface Assess2ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView  *_tableView;
    
    __weak IBOutlet UIView *_headView;
    __weak IBOutlet UILabel *_labTitle;
    
    IBOutlet UIView *_footView;
    
    
    NSMutableArray      *_dataSource;
}
@end

@implementation Assess2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"评估项";
    
    _dataSource = [NSMutableArray array];
    
    [self initViews];
    
    [self loadViewData];
}
- (void)initViews
{
    UINib *cellNib = [UINib nibWithNibName:@"AssessViewCell" bundle:nil];
    [_tableView registerNib:cellNib forCellReuseIdentifier:@"assessViewCell"];
    
    _tableView.tableFooterView = _footView;
    
    _headView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bglist"]];

}
- (void)loadViewData
{
    if (_dict.count >0) {
        
        _labTitle.text = _headTitle;
        
        [[CARequest shareInstance] startWithRequestCompletion:_reqURL withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"itemid":_itemid} completed:^(id content, NSError *err) {
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
                    
                }else {
                    
                }
            }
            
        }];
        
    }
    
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
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"assessViewCell" forIndexPath:indexPath];
    [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *selectBtn = (UIButton *)[cell.contentView viewWithTag:100];
    selectBtn.selected = [_dataSource[indexPath.row][@"selected"] boolValue];
    selectBtn.layer.cornerRadius = 3;
    selectBtn.layer.borderWidth = 1;
    selectBtn.layer.borderColor = [UIColor colorAppBg].CGColor;
    
    
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:200];
    title.text = _dataSource[indexPath.row][@"itemname"];
    
    selectBtn.tag = indexPath.row;
    [selectBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (void)selectAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    
}
- (IBAction)selectSaveAction:(id)sender {
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view removeHUDActivity];
        [self.view showHUDTitleView:@"请求出错" image:nil];
    });

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
