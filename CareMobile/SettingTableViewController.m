//
//  SettingTableViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/14.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ManageViewController.h"
#import "SettingViewController.h"
#import "CopyrightViewController.h"

@interface SettingTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_arrTitle;
}
@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _arrTitle = @[
                  @[@"bigdocter",@"账号管理"],
                  @[@"setting_set",@"系统设置"],
                  @[@"setting_banbenxx",@"版本信息"],
                  @[@"setting_banquanxx",@"版权信息"]
                  ];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _arrTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:_arrTitle[indexPath.section][0]];
    cell.textLabel.text = _arrTitle[indexPath.section][1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            ManageViewController *manageVC = [[ManageViewController alloc] initWithNibName:@"ManageViewController" bundle:nil];
            manageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:manageVC animated:YES];
        }
            break;
        case 1:
        {
            SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
            settingVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case 2:
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.view showHUDTitleView:@"已是最新版本" image:nil];
                
            });
            
        }
            break;
        case 3:
        {
            CopyrightViewController *copyrightVC = [[CopyrightViewController alloc] initWithNibName:@"CopyrightViewController" bundle:nil];
            copyrightVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:copyrightVC animated:YES];
        }
            break;
            
        default:
            break;
    }
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
