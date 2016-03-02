//
//  RecordEditViewController.m
//  CareMobile
//
//  Created by Guibin on 16/1/7.
//  Copyright © 2016年 MobileCare. All rights reserved.
//

#import "RecordEditViewController.h"
#import "LGActionSheet.h"
#import "LGActionSheetCell.h"

@interface RecordEditViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UITextViewDelegate,LGActionSheetDelegate>
{
    __weak IBOutlet UITableView  *_tableView;
    
    IBOutlet UIView *_pickerViewBg;
    
    __weak IBOutlet UIPickerView *_pickerView;
    
    IBOutlet UIView *_datePickViewBg;
    __weak IBOutlet UIDatePicker *_datePickerView;

    
    UITextField     *_tempTextField;
    UITextView      *_tempTextView;
    
    NSMutableArray  *_dataSource;
    NSMutableArray  *_pickerData;
    
    NSMutableArray  *_eidtData;
    
    NSString        *_tempString;
    
    NSInteger       _indexRow;
    NSInteger       _pickerRow;
    
    BOOL             _deleteText;  //临时变量观察值
}
@property (nonatomic , copy)NSString *userName;
@end

@implementation RecordEditViewController


- (void)addNavTitleView
{
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH-140, 44)];
    
    UILabel *labTitile = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, WIDTH(navView), 23)];
    labTitile.text = _navString;
    labTitile.textColor = [UIColor whiteColor];
    labTitile.textAlignment = NSTextAlignmentCenter;
    labTitile.font = SYSTEMFONT(17);
    [navView addSubview:labTitile];
    
    UILabel *labSubTitile = [[UILabel alloc] initWithFrame:CGRectMake(0, HEIGHTADDY(labTitile), WIDTH(navView), 17)];
    labSubTitile.text = [NSString stringWithFormat:@"%@ 床 %@",_dict[@"CHUANG"],_dict[@"BRNAME"]];
    labSubTitile.textColor = [UIColor whiteColor];
    labSubTitile.textAlignment = NSTextAlignmentCenter;
    labSubTitile.font = SYSTEMFONT(13);
    [navView addSubview:labSubTitile];
    
    
    self.navigationItem.titleView = navView;
}
- (void)setDatePickerData
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

    
    /**
     *  设置_datePckerVIew 的frame适应屏幕尺寸
     */
    _datePickViewBg.backgroundColor = [UIColor colorViewBg];
    rect = _datePickViewBg.frame;
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
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self addNavTitleView];
    
    _indexRow = 0xffff;
    
    UINib *nibCell = [UINib nibWithNibName:@"RecordEditViewCell" bundle:nil];
    [_tableView registerNib:nibCell forCellReuseIdentifier:@"recordEditViewCell"];
    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    _pickerData = [[NSMutableArray alloc] initWithCapacity:0];
    _eidtData = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    NSDictionary *dicdata = [SavaData parseDicFromFile:User_File];
    self.userName  = dicdata[@"utname"];
   
    [self setDatePickerData];
    
    
    
    NSString *str = @"";
    if ([_navString isEqualToString:@"新增"]) {
        str = @"添加";
        NSDictionary *dict = @{@"id":@(_recID),
                               @"bid":_dict[@"BRID"],
                               @"vid":_dict[@"ZYID"]
                               };
        [self initDataRequestDict:dict url:CAPI_RecordAdd];
    }else {
        str = @"保存";
        NSDictionary *dict = @{@"id":@(_recID),
                               @"bid":_dict[@"BRID"],
                               @"vid":_dict[@"ZYID"],
                               @"dt":_itemData[@"RECORD_DATE"]
                               };
        [self initDataRequestDict:dict url:CAPI_RecordChange];
    }
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 60, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:str forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.tag = 10;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(didAddItemAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];

    
    
}
- (void)initDataRequestDict:(NSDictionary *)dict url:(NSString *)url
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:url withParameter:dict completed:^(id content, NSError *err) {
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
            
            [self loadChangeEditData:data];
            
            if (data.count == 0) {
                [self.view showHUDTitleView:@"此病人暂无信息" image:nil];
            }
        }
        
    }];
}
- (void)loadChangeEditData:(NSArray *)arr
{
    if ([_navString isEqualToString:@"修改"]) {
        [_dataSource setArray: arr];
        [_tableView reloadData];
        
        
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_eidtData addObject:@{@"code":obj[@"code"],@"value":obj[@"value"]}];

        }];
//
//      
//        
//        [_data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
//            
//            NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:obj];
//              
//            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                   if ([mutDic[@"CODE"] isEqualToString:obj[@"code"]]) {
//                    mutDic[@"CTRL"] = obj[@"CTRL"];
//                    mutDic[@"ITEM"] = obj[@"ITEM"];
//                }
//                   
//            }];
//              
//             [_dataSource addObject:mutDic];
//         }];
//        
//        [_tableView reloadData];
    }else{
        [_dataSource setArray:arr];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *strDate = [formatter stringFromDate:[NSDate date]];
        [self editAddItemsDataText:strDate forIndex:0];
        
        __block NSInteger index = 12;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = [NSString stringWithFormat:@"COL%d",index];
            if ([obj[@"code"] isEqualToString:str]) {
                [_eidtData addObject:@{@"code":obj[@"code"],@"value":obj[@"preval"]}];
                index ++;
                if (index == 15) {
                    index = 9999999;
                }
            }else if (![@"" isStringBlank:obj[@"preval"]])
            {
                [_eidtData addObject:@{@"code":obj[@"code"],@"value":obj[@"preval"]}];
            }
            
        }];
        
        
        [_tableView reloadData];
    }
    
   
}
- (void)didAddItemAction:(UIButton *)btn
{
    [self resiginFirstResponder];
    
    if (_eidtData.count == 0) {
        [self.view showHUDTitleView:@"请编辑后再提交" image:nil];
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:_eidtData options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *userInfo = @{@"uid" :USERID,
                               @"id"   :@(_recID),
                               @"bid"   :_dict[@"BRID"],
                               @"vid"  : _dict[@"ZYID"],
                               @"NURSE_SYS_NAME" : self.userName,
                               @"items":json};
    
    
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    
    [[CARequest shareInstance] startWithPostCompletion:CAPI_RecordSave withParmeter:userInfo completed:^(id content, NSError *err) {
        
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        
        if ([content isKindOfClass:[NSDictionary class]]) {
            
            if ([content[@"status"] integerValue] == 1 )
            {
                [self.view showHUDTitleView:@"保存成功" image:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updataHisToryData" object:nil];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [self.view showHUDTitleView:@"保存失败" image:nil];
            }
        }else if ([content isKindOfClass:[NSArray class]]){
            
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
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"recordEditViewCell" forIndexPath:indexPath];
    
    [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UILabel *title = (UILabel *)[cell.contentView viewWithTag:10];
    title.text = _dataSource[indexPath.row][@"item"];
    
    NSString *item = _dataSource[indexPath.row][@"dict"];
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else if (![@"" isStringBlank:item]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITextField *textF = (UITextField *)[cell.contentView viewWithTag:20];
    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:30];
    textF.delegate = self;
    textView.delegate = self;
    
    //添加血压touch 事件
     if ([title.text isEqualToString:@"血压"]) {
         //添加监听textField 字数变化事件
        [textF addTarget:self action:@selector(textFieldNotification:) forControlEvents:UIControlEventEditingChanged];
        textF.keyboardType = UIKeyboardTypeDecimalPad;
     }else{
        textF.keyboardType = UIKeyboardTypeDefault;
     }
    
    
    
    if ([title.text hasPrefix:@"病情观察"]) {
        textF.hidden = YES;
        textView.hidden = NO;
        textView.text = _dataSource[indexPath.row][@"value"];
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [UIColor colorMemberFBg].CGColor;
        textView.layer.cornerRadius = 5;
    }else if ([_dataSource[indexPath.row][@"ctrl"] isEqualToString:@"READONLY"])
    {
        if ([_navString isEqualToString:@"新增"]) {
            textF.enabled = NO;
        }else{
            textF.enabled = YES;
        }
        textF.text = self.userName;
        
    }else{
        if ([_navString isEqualToString:@"新增"]) {
            textF.text = _dataSource[indexPath.row][@"preval"];
            
        }else{
            NSString *value =  _dataSource[indexPath.row][@"value"];
            textF.text = value;
        }
        
        textF.hidden = NO;
        textView.hidden = YES;
        textF.enabled = YES;
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_dataSource[indexPath.row][@"item"] hasPrefix:@"病情观察"]) {
        return 100;
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *item = _dataSource[indexPath.row][@"dict"];
    if (indexPath.row == 0) {
        _indexRow = indexPath.row;
        [self showDatePickerView];
    }else if (![@"" isStringBlank:item]) {
        [self resiginFirstResponder];
        
        NSArray *items = [item componentsSeparatedByString:@"$"];
        [_pickerData setArray:items];
         _indexRow = indexPath.row;
        
        if ( [_dataSource[indexPath.row][@"item"] isEqualToString:@"病情观察及护理"] ) {
            LGActionSheet *actionSheet = [[LGActionSheet alloc] initWithTitle:nil
                                                                 buttonTitles:items
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                                actionHandler:nil
                                                                cancelHandler:nil
                                                           destructiveHandler:nil];
            actionSheet.buttonsNumberOfLines = 0;
            actionSheet.delegate = self;
            [actionSheet showAnimated:YES completionHandler:nil];
            return;
        }
        
        [self showPickerView];
        [_pickerView reloadAllComponents];
    }

}
#pragma mark 
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hiddenPickerView];
    _tempTextField = textField;
    CGPoint point = [textField convertPoint:CGPointZero toView:_tableView];
    point.y -= 50;
    [_tableView setContentOffset:CGPointMake(0, point.y) animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"textF = %@",textField.text);
    CGPoint point = [textField convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
  
    if ([@"" isStringBlank:textField.text]) {
        textField.text = @"";
    }

    [self editAddItemsDataText:textField.text forIndex:indexPath.row];
    
    
}
- (void)editAddItemsDataText:(NSString *)text forIndex:(NSInteger)index
{
    if (_indexRow != 0xffff) {
         NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[index]];
        if ([_dataSource[index][@"ctrl"] isEqualToString:@"MULTI"])
        {
            NSString *value = mutDic[@"value"];
            if (!([@"" isStringBlank:value] || [@"" isStringBlank:text])) {
//                NSRange range = [value rangeOfString:text];
//                if (range.location) {
//                    
//                }else{
            
                    text = [NSString stringWithFormat:@"%@,%@",value, text];
//                }
                
            }
           
        }
    }
    
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[index]];
    mutDic[@"value"] = text;
    if ([_navString isEqualToString:@"新增"]) {
        mutDic[@"preval"] = text;
    }
    [_dataSource replaceObjectAtIndex:index withObject:mutDic];
    
    if (_eidtData.count) {
        __block BOOL isSame = NO;
        [_eidtData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = obj[@"code"];
            if ([str isEqualToString:mutDic[@"code"]]) {
                [_eidtData replaceObjectAtIndex:idx withObject:@{@"code":str,@"value":text}];
                 isSame = YES;
            }
            
        }];
        
        if (!isSame) {
            [_eidtData addObject:@{@"code":mutDic[@"code"],@"value":text}];
        }
        
    }else{
        [_eidtData addObject:@{@"code":mutDic[@"code"],@"value":text}];
    }
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) {
        _deleteText = YES;
    }else{
        _deleteText = NO;
    }
    return YES;
}
#pragma mark textFied 监听字数改变
- (void)textFieldNotification:(UITextField *)sender
{
    NSRange range = [sender.text rangeOfString:@"/"];
    if (range.location != NSNotFound) {
        return;
    }else if (_deleteText){
        return;
    }

    NSInteger value = [sender.text integerValue];
    
    if (value < 20 ) {
        //不追加/
    }else{
        //追加/
        sender.text = [NSString stringWithFormat:@"%d/",value];
    }
    
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            CGRect rect = self.view.frame;
//            rect.origin.y = 0;
//            self.view.frame = rect;
//        }];
    }
    return YES;
}
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
     _tempTextView = textView;
    [self hiddenPickerView];
    CGPoint point = [textView convertPoint:CGPointZero toView:_tableView];
    point.y -= 50;
    [_tableView setContentOffset:CGPointMake(0, point.y) animated:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
   
    if ([@"" isStringBlank:textView.text]) {
       textView.text = @"";
    }
    
    textView.text = [textView.text stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        if ([obj[@"item"] hasPrefix:@"病情观察"]) {
            _indexRow = idx;
        }
    }];
    
    [self editAddItemsDataText:textView.text forIndex:_indexRow];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([@"\n" isEqualToString:text] == YES) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
#pragma UIPIckerViewDelegate
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
    _tempString = _pickerData[_pickerRow];
    [self editAddItemsDataText:_tempString forIndex:_indexRow];
    [self didHiddenPickerView];
    [_tableView reloadData];
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
    [self editAddItemsDataText:strDate forIndex:_indexRow];
    
    [self didHiddenDatePickerView];
    [_tableView reloadData];
}



- (void)showPickerView
{
    [self resiginFirstResponder];

    
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
- (void)hiddenPickerView
{
    if (_pickerViewBg.superview) {
        [_pickerViewBg removeFromSuperview];
    }
}
- (void)showDatePickerView
{
    [self resiginFirstResponder];
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if ([_tempTextField isFirstResponder]) {
//        [_tempTextField resignFirstResponder];
//    }else if ([_tempTextView isFirstResponder]){
//        [_tempTextView resignFirstResponder];
//    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
- (void)resiginFirstResponder
{
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }else if ([_tempTextView isFirstResponder]){
        [_tempTextView resignFirstResponder];
    }
}
- (void)actionSheet:(LGActionSheet *)actionSheet buttonPressedWithTitle:(NSString *)title index:(NSUInteger)index
{
    [self editAddItemsDataText:_pickerData[index] forIndex:_indexRow];
    [_tableView reloadData];
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
