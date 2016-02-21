//
//  SubItemViewController.m
//  CareMobile
//
//  Created by Guibin on 15/11/4.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "SubItemViewController.h"
#import "DetailsHeadView.h"

@interface SubItemViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
     DetailsHeadView *_detailsView;
    
    IBOutlet UIView *_pickerViewBg;
    
    __weak IBOutlet UIDatePicker *_pickerDateView;
    __weak IBOutlet UIPickerView *_pickerView;
    
    IBOutlet UIView *_datePicViewBg;
    
    __weak IBOutlet UIDatePicker *_datePicView;
    
    
    UIView      *_typeItemView;
    
    UITableView         *_tableView;
    
    NSMutableArray      *_dataSource;
    NSMutableArray      *_eidtData;
    NSMutableArray      *_pickerData;
    NSMutableArray      *_tempPickData;
    
    UITextField         *_tempTextField;
    NSInteger           _pickerRow;
    NSInteger           _indexRow;
    NSString            *_tempType;
    
    BOOL                _deleteText;  //临时变量观察值
    
    NSInteger            _tempSelectPicker;
}

@end

@implementation SubItemViewController

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
  
    [_pickerDateView setDatePickerMode:UIDatePickerModeDateAndTime];
    [_pickerDateView setDate:[NSDate date]];
    
    /**
     *  设置_datePckerVIew 的frame适应屏幕尺寸
     */
    _datePicViewBg.backgroundColor = [UIColor colorViewBg];
    rect = _datePicViewBg.frame;
    rect.size.width = SCREEN_WIDTH;
    _datePicViewBg.frame = rect;
    
    UIView *pickerV = (UIView *)[_datePicViewBg viewWithTag:20];
    for (UIView *label in pickerV.subviews) {
        label.backgroundColor = [UIColor colorAppBg];
    }
    
    [_datePicView setDatePickerMode:UIDatePickerModeDateAndTime];
    

}
- (NSMutableDictionary *)dictTime{
    if (!_dictTime) {
        _dictTime = [NSMutableDictionary dictionary];
    }
    return _dictTime;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = _navTitle;
    
    [self initViews];
    
    [self loadHeadViewDatas];
    
   
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }
}
- (NSString *)todayTime
{
    //设置其他选项的时间为默认当前时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:[NSDate date]];
    return strDate;
}
- (void)initViews
{
    _indexRow = 0;
    _tempType = @"A";
    _tempSelectPicker = 0;
    _dataSource = [NSMutableArray array];
    _eidtData = [NSMutableArray array];
    _pickerData = [NSMutableArray array];
    _tempPickData = [NSMutableArray array];
    self.dictTime[@"A"] = _strTime;
  
    _dictTime[@"D"] = [self todayTime];
    
    
    
    NSArray *arrViews = [[NSBundle mainBundle] loadNibNamed:@"DetailsHeadView" owner:nil options:nil];
    _detailsView = arrViews[0];
    _detailsView.frame = CGRectMake(0, 64, SCREEN_WIDTH, HEIGHT(_detailsView));
    [self.view addSubview:_detailsView];
    
    NSArray *typeViews = [[NSBundle mainBundle] loadNibNamed:@"SearchViewItem" owner:nil options:nil];
    _typeItemView = typeViews[4];
    _typeItemView.frame = CGRectMake(0, HEIGHTADDY(_detailsView), SCREEN_WIDTH, 44);
    [self.view addSubview:_typeItemView];
    
    UIView *titleV = typeViews[2];
    titleV.frame = CGRectMake(0, HEIGHTADDY(_typeItemView), SCREEN_WIDTH, 44);
    titleV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"yizhubiaozhu3"]];
    [self.view addSubview:titleV];
    
    int i = 0;
    for (UIButton *typeBtn in [_typeItemView subviews]) {
        UIButton *btn = (UIButton *)typeBtn;
        btn.tag = i;
        btn.selected = i== 0;
        [btn addTarget:self action:@selector(didSelectTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        i ++;
        
    }
    
    i= 0;
    for (UILabel *titleLabel in [titleV subviews]) {
        titleLabel.textColor = [UIColor blackColor];
        if (i==0) {
            titleLabel.text = @"项目";
        }else if (i == 1)
        {
            if ([_navRight isEqualToString:@"添加"]) {
                titleLabel.text = @"";
            }else{
                titleLabel.text = @"时间";
            }
        }else{
            titleLabel.text = @"值";
        }
        
        i++;
    }
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, HEIGHTADDY(titleV), SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHTADDY(titleV) - 460) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.layer.borderWidth = 1;
//    _tableView.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:_tableView];
    
   
    
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 70, 30);
    [navRightBtn setBackgroundImage:[UIImage imageNamed:@"log_bt"] forState:UIControlStateNormal];
    [navRightBtn setTitle:_navRight forState:UIControlStateNormal];
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    navRightBtn.layer.cornerRadius = 15;
    navRightBtn.layer.borderWidth = 1;
    navRightBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    navRightBtn.layer.masksToBounds = YES;
    [navRightBtn addTarget:self action:@selector(didSelectTijiao:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];

    if ([navRightBtn.titleLabel.text isEqualToString:@"添加"])
    {
         [_tableView registerNib:[UINib nibWithNibName:@"SubItemHuLiAddCell" bundle:nil] forCellReuseIdentifier:@"subItemHuLiAddCell"];
        

        [self neatemData];
        
        [self setDatePickerData];
       
        [self requestAddItemData:@"A"];
        
    }else{
        [_tableView registerNib:[UINib nibWithNibName:@"SubItemViewCell" bundle:nil] forCellReuseIdentifier:@"subItemViewCell"];
        
        [self requestTypeItem:@"A"];
    }
   
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)neatemData
{
    _pickerRow = 0;
}

- (void)didSelectTijiao:(UIButton *)btn
{
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }
    if (_eidtData.count == 0) {
        [self.view showHUDTitleView:@"请编辑后再提交" image:nil];
        return;
    }
    
    if ([btn.titleLabel.text isEqualToString:@"添加"]) {
        
        if ([@"" isStringBlank:_dictTime[_tempType]]) {
            [self.view showHUDTitleView:@"请选择时间" image:nil];
            return;
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:_eidtData options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSDictionary *dicdata = [SavaData parseDicFromFile:User_File];
        NSDictionary *userInfo = @{@"uid":USERID,
                                   @"uname" :dicdata[@"utname"],
                                   @"bid"   :_dict[@"BRID"],
                                   @"vid"   :_dict[@"ZYID"],
                                   @"time"  : _dictTime[_tempType],
                                   @"saveok":json};
        
        
        [self.view showHUDActivityView:@"正在加载" shade:NO];
        
        [[CARequest shareInstance] startWithPostCompletion:CAPI_HLSave withParmeter:userInfo completed:^(id content, NSError *err) {
        
            NSLog(@"content = %@",content);
            [self.view removeHUDActivity];
        
            if ([content isKindOfClass:[NSDictionary class]]) {

                if ([content[@"status"] integerValue] == 1 )
                {
                    [self.view showHUDTitleView:@"保存成功" image:nil];
                   
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updataListData" object:nil];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }else{
                    [self.view showHUDTitleView:@"保存失败" image:nil];
                }
            }else if ([content isKindOfClass:[NSArray class]]){
                
            }
        

         
        }];
    }else{
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:_eidtData options:NSJSONWritingPrettyPrinted error:nil];
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        NSString *name = [[SavaData shareInstance] printDataStr:USERNAMEKEY];
        NSDictionary *userInfo = @{@"uid"   :USERID,
                                   @"bid"   :_dict[@"BRID"],
                                   @"vid"   :_dict[@"ZYID"],
                                   @"saveok":json};
        
        
        [self.view showHUDActivityView:@"正在加载" shade:NO];
        
        [[CARequest shareInstance] startWithPostCompletion:CAPI_update withParmeter:userInfo completed:^(id content, NSError *err) {
            
            NSLog(@"content = %@",content);
            [self.view removeHUDActivity];
            
            if ([content isKindOfClass:[NSDictionary class]]) {
                
                if ([content[@"status"] integerValue] == 1 )
                {
                    [self.view showHUDTitleView:@"保存成功" image:nil];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updataListData" object:nil];
                        
                       [self.navigationController popViewControllerAnimated:YES];
                    });
                    
                }else{
                    [self.view showHUDTitleView:@"保存失败" image:nil];
                }
            }else if ([content isKindOfClass:[NSArray class]]){
                
            }
            
            
            
        }];

    }
    

}
- (void)didSelectTypeAction:(UIButton *)btn
{
    NSLog(@"btn.tag = %d",btn.tag);
    for (UIButton *typeBtn in [_typeItemView subviews]) {
        UIButton *itemBtn = (UIButton *)typeBtn;
        if (itemBtn.tag == btn.tag) {
            itemBtn.selected = true;
        }else{
            itemBtn.selected = false;
        }
    }
    
    NSString *typeStr = @"";
    switch (btn.tag) {
        case 0: typeStr = @"A"; break;
        case 1: typeStr = @"B"; break;
        case 2: typeStr = @"C"; break;
        case 3: typeStr = @"D"; break;
        default:
            break;
    }

    _tempType = typeStr;
    if ([_navRight isEqualToString:@"添加"])
    {
        [self requestAddItemData:typeStr];
    }else{
        
        [self requestTypeItem:typeStr];
    }
    
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }
    [self animateForViewSize];
}
- (void)requestAddItemData:(NSString *)type
{
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_HLOrder withParameter:@{@"cls":type,@"uid":USERID} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content isKindOfClass:[NSDictionary class]]) {
            NSArray *arrData = content[@"SUBTIME"];
            if (arrData.count) {
                [_pickerData setArray:arrData];
                [_tempPickData setArray:arrData];
                [_pickerView reloadAllComponents];
                
                NSInteger todayValue = [[self todayTime] integerValue];
                
                __block NSInteger index = 0;
                //在新增给生命体征时间时，给一个默认的选项值
               [_pickerData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   NSInteger value = [obj integerValue];
                   if (todayValue >= value) {
                       index += 1;
                   }
               }];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                
                if (index == 0) {
                    NSString *strDate = [NSString stringWithFormat:@"%@ %@",[formatter stringFromDate:_pickerDateView.date],_pickerData[_pickerData.count-1]];
                    _dictTime[_tempType] = strDate;
                }else{
                    if (![_tempType isEqualToString:@"D"]) {
                        NSString *strDate = [NSString stringWithFormat:@"%@ %@",[formatter stringFromDate:_pickerDateView.date],_pickerData[index-1]];
                        _dictTime[_tempType] = strDate;
                    }
                    
                }
                
            }
            
            NSArray *arrItem = content[@"ORDERITEM"];
            [_dataSource setArray:arrItem];
            [_tableView reloadData];
        
        }else if ([content isKindOfClass:[NSArray class]]){
            NSArray *data = (NSArray *)content;
            
            [_dataSource setArray:data];
            [_tableView reloadData];
        }
        
    }];
}
- (void)requestTypeItem:(NSString *)type
{
   [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_HLOrderOk withParameter:@{@"uid":USERID,@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"hldate":_huliTime,@"cls":type} completed:^(id content, NSError *err) {
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
    if ([_navRight isEqualToString:@"添加"]) {
        if (_dataSource.count) {
            return _dataSource.count +1;
        }
        return 0;
    }
    return _dataSource.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_navRight isEqualToString:@"添加"]) {
        static NSString *patientsCell = @"subItemHuLiAddCell";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:patientsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadAddDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    }else{
        static NSString *patientsCell = @"subItemViewCell";
        UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:patientsCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadDataForTableViewCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    }
    
    
}
- (void)loadAddDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *labItem = (UILabel *)[cell.contentView viewWithTag:10];
    UITextField *textF = (UITextField *)[cell.contentView viewWithTag:11];
    textF.delegate = self;
    
    if (indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        textF.borderStyle = UITextBorderStyleNone;
        textF.enabled = NO;
        labItem.text = @"时间";

        textF.text   = _dictTime[_tempType];
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        textF.enabled = YES;
        textF.borderStyle = UITextBorderStyleRoundedRect;
        NSInteger row = indexPath.row - 1;
        NSString *unit = _dataSource[row][@"HL_UNIT"];
        if ([@"" isStringBlank:unit]) {
            labItem.text = [NSString stringWithFormat:@"%@",_dataSource[row][@"HL_ITEM"]];
        }else{
            labItem.text = [NSString stringWithFormat:@"%@（%@）",_dataSource[row][@"HL_ITEM"],unit];
        }
       
        //控制键盘类型
//        BOOL keyboday = [_dataSource[row][@"CTRL"] boolValue];
//        if (keyboday) {
        textF.keyboardType = UIKeyboardTypeDecimalPad;
//        }else{
//            textF.keyboardType = UIKeyboardTypeURL;
//        }
        
        
        if ([_dataSource[row][@"HL_ITEM"] isEqualToString:@"血压"]) {
            //添加监听textField 字数变化事件
            [textF addTarget:self action:@selector(textFieldNotification:) forControlEvents:UIControlEventEditingChanged];
        }else if ([_dataSource[row][@"HL_ITEM"] isEqualToString:@"体重"]){
            textF.keyboardType = UIKeyboardTypeDefault;
        }
        
        textF.text = _dataSource[row][@"HL_VALUE"];
        
        //是否是选择填写
        NSString *strValue = _dataSource[row][@"DICT"];
        if (![@"" isStringBlank:strValue]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
       
    }
    
   
}
- (void)loadDataForTableViewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *labItem = (UILabel *)[cell.contentView viewWithTag:10];
    labItem.text = _dataSource[indexPath.row][@"HL_ITEM"];
    
    UILabel *labTime = (UILabel *)[cell.contentView viewWithTag:11];
    labTime.text = _dataSource[indexPath.row][@"HL_TIME"];

    
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:12];
    textField.text = [self stringForNull:_dataSource[indexPath.row][@"HL_VALUE"]];
    textField.delegate = self;
//    BOOL keyboday = [_dataSource[indexPath.row][@"CTRL"] boolValue];
//    if (keyboday) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
//    }else{
//        textField.keyboardType = UIKeyboardTypeURL;
//    }
    
    if ([labItem.text isEqualToString:@"血压"]) {
        //添加监听textField 字数变化事件
        [textField addTarget:self action:@selector(textFieldNotification:) forControlEvents:UIControlEventEditingChanged];
    }else if ([labItem.text isEqualToString:@"体重"]){
        textField.keyboardType = UIKeyboardTypeDefault;
    }
    
    UILabel *labValue = (UILabel *)[cell.contentView viewWithTag:13];
    labValue.text = [self stringForNull:_dataSource[indexPath.row][@"UNITS"]];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_navRight isEqualToString:@"添加"] && indexPath.row == 0) {
        _indexRow = 500;
        if (_pickerData.count) {
            if ([_tempType isEqualToString:@"D"]) {
                //显示时间选择器
                [self showDatePickerView];
            }else{
                [self changePcickerViewOfPickdateFrame:YES];
                
                //显示时间类型选择数据（已有）

                [_pickerData setArray:_tempPickData];
                [self showPickerView];
                [_pickerView selectedRowInComponent:0];
                [_pickerView reloadAllComponents];
            }
            
        }else{
            //没有数据去请求拿数据
            [self.view showHUDTitleView:@"数据加载错误，请稍后再试" image:nil];
            [self requestAddItemData:@"A"];
            
        }
        
    }else{
        _indexRow = indexPath.row ;
        if ([_navRight isEqualToString:@"添加"]) {
            _indexRow -= 1;
        }
        
        [self changePcickerViewOfPickdateFrame:NO];
        
        NSString *strValue = _dataSource[_indexRow][@"DICT"];
        if (![@"" isStringBlank:strValue]) {
            NSArray *arrData = [strValue componentsSeparatedByString:@"$"];
            [_pickerData setArray:arrData];
            [self showPickerView];
            [_pickerView selectedRowInComponent:0];
            [_pickerView reloadAllComponents];
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_navRight isEqualToString:@"添加"]) {
         return NO;
    }
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self didSelectDelItemRow:indexPath.row];
    }
}
- (void)didSelectDelItemRow:(NSInteger)row
{
    NSString *time = [NSString stringWithFormat:@"%@ %@",_huliTime,_dataSource[row][@"HL_TIME"]];
    [self.view showHUDActivityView:@"正在加载" shade:NO];
    [[CARequest shareInstance] startWithRequestCompletion:CAPI_HLDelDo withParameter:@{@"bid":_dict[@"BRID"],@"vid":_dict[@"ZYID"],@"t":time} completed:^(id content, NSError *err) {
        NSLog(@"content = %@",content);
        [self.view removeHUDActivity];
        if ([content[@"status"] integerValue] == 1){
            [self.view showSuccess:@"删除成功"];
            
            [self requestTypeItem:_tempType];
            
            
        }else{
            [self.view showError:@"删除失败"];
        }
        
    }];
    
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hiddenPickerView];
    [self didHiddenDatePickerView];
    _tempTextField = textField;
    CGPoint point = [textField convertPoint:CGPointZero toView:_tableView];
    if (point.y > 240) {
        point.y = 230;
    }
    
    point.y += 10;
   
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = -point.y;
        self.view.frame = rect;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_dataSource.count ==0) {
        return;
    }
//    NSLog(@"textF = %@",textField.text);
    CGPoint point = [textField convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
   
    if ([@"" isStringBlank:textField.text]) {
        textField.text = @"";
    }
    
    if ([_navRight isEqualToString:@"添加"]) {
        if (indexPath.row > 0){
            [self editAddItemsDataText:textField.text forIndex:indexPath.row-1];
        }
        
        
    }else{
            //修改值
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[indexPath.row]];
            mutDic[@"HL_VALUE"] = textField.text;
            [_dataSource replaceObjectAtIndex:indexPath.row withObject:mutDic];
            
            if (_eidtData.count) {
                __block BOOL edit = NO;
                [_eidtData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   
                    if ([obj[@"HL_ITEM"] isEqualToString:mutDic[@"HL_ITEM"]]) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
                        dict[@"HL_VALUE"] = textField.text;
                        [_eidtData replaceObjectAtIndex:idx withObject:dict];
                        edit = YES;
                    }
                }];
                
                if (!edit) {
                    //添加一个字典时判定value是否有值，没有不添加
                    if (![@"" isStringBlank:textField.text]) {
                        NSString *endTime = [NSString stringWithFormat:@"%@ %@",_huliTime,mutDic[@"HL_TIME"]];
                        [_eidtData addObject:@{@"HL_TIME":endTime,
                                               @"HL_ITEM":mutDic[@"HL_ITEM"],
                                               @"HL_VALUE":mutDic[@"HL_VALUE"]}
                         ];
                    }
                    

                }
                
            }else{
                //添加一个字典时判定value是否有值，没有不添加
                if (![@"" isStringBlank:textField.text]) {
                    NSString *endTime = [NSString stringWithFormat:@"%@ %@",_huliTime,mutDic[@"HL_TIME"]];
                    [_eidtData addObject:@{@"HL_TIME":endTime,
                                           @"HL_ITEM":mutDic[@"HL_ITEM"],
                                           @"HL_VALUE":mutDic[@"HL_VALUE"]}
                     ];
                }
        }
        
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
    //取血压vulue
    NSInteger value = [sender.text integerValue];
    if (value < 20 ) {
        //不追加/
    }else{
        //追加/
        sender.text = [NSString stringWithFormat:@"%d/",value];
    }

    
}

- (void)editAddItemsDataText:(NSString *)text forIndex:(NSInteger)index
{
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:_dataSource[index]];
    mutDic[@"HL_VALUE"] = text;
    [_dataSource replaceObjectAtIndex:index withObject:mutDic];
    
    if (_eidtData.count) {
         __block BOOL edit = NO;
        [_eidtData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"HL_ITEM"] isEqualToString:mutDic[@"HL_ITEM"]]) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
                dict[@"HL_VALUE"] = text;
                [_eidtData replaceObjectAtIndex:idx withObject:dict];
                 edit = YES;
            }
        }];
        if (!edit) {
            if (![@"" isStringBlank:text]) {
                [_eidtData addObject:mutDic];
            }
            
        }
        
    }else{
        if (![@"" isStringBlank:text]) {
            [_eidtData addObject:mutDic];
        }

    }
   

    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            self.view.frame = rect;
        }];
    }
    return YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
        [self animateForViewSize];
    }
   
}
- (void)animateForViewSize
{
    if (Y(self.view) != 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.view.frame;
            rect.origin.y = 0;
            self.view.frame = rect;
        }];
        
    }

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
    return [NSString stringWithFormat:@"%@",_pickerData.count > row ? _pickerData[row] : _pickerData[_pickerData.count-1]];
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
    if (_indexRow == 500) {
        //选择日期
        if (_pickerDateView.hidden) {
            _dictTime[_tempType] = _pickerData[_pickerRow];
        }else{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *strDate = [NSString stringWithFormat:@"%@ %@",[formatter stringFromDate:_pickerDateView.date],_pickerData[_pickerRow]];
            _dictTime[_tempType] = strDate;
        }
        
    }else{
        [self editAddItemsDataText:_pickerData[_pickerRow] forIndex:_indexRow];
    }
   
    [self didHiddenPickerView];
    [_tableView reloadData];
}
- (void)changePcickerViewOfPickdateFrame:(BOOL)isAll
{
    if (isAll) {
        _tempSelectPicker = 1;
        _pickerDateView.hidden = NO;
        CGRect rectPickerViewFrame = _pickerView.frame;
        rectPickerViewFrame.origin.x = 190;
        rectPickerViewFrame.size.width = 130;
        _pickerView.frame = rectPickerViewFrame;
        _pickerView.backgroundColor = [UIColor whiteColor];
    }else{
        _pickerDateView.hidden = YES;
        CGRect rectPickerViewFrame = _pickerView.frame;
        rectPickerViewFrame.origin.x = _tempSelectPicker == 0 ? 0 : (SCREEN_WIDTH - 130)/2;
        rectPickerViewFrame.size.width = SCREEN_WIDTH;
        _pickerView.frame = rectPickerViewFrame;
        _pickerView.backgroundColor = [UIColor clearColor];
//        _tempSelectPicker = 0;
    }
    

}
- (void)showPickerView
{
    [self animateForViewSize];
    
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }
    
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
#pragma mark 选择完成操作PickerDate
- (IBAction)didSelectCancelDateAction:(UIButton *)sender {
    [self didHiddenDatePickerView];
}
#pragma mark 选择完成并保存
- (IBAction)didSelectFinishDateAction:(UIButton *)sender {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:_datePicView.date];
    _dictTime[_tempType] = strDate;
    
    [self didHiddenDatePickerView];
    [_tableView reloadData];
}
- (void)showDatePickerView
{
    if ([_tempTextField isFirstResponder]) {
        [_tempTextField resignFirstResponder];
    }
   
    [_datePicView setDate:[NSDate date] animated:YES];
    
    CGRect rect = _datePicViewBg.frame;
    rect.origin.x = 0;
    rect.origin.y = SCREEN_HEIGHT;
    _datePicViewBg.frame = rect;
    if (!_datePicViewBg.superview) {
        [self.view addSubview:_datePicViewBg];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _datePicViewBg.frame;
        frame.origin.y = SCREEN_HEIGHT - _datePicViewBg.frame.size.height;
        _datePicViewBg.frame = frame;
    }];
    
}
- (void)didHiddenDatePickerView
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = _datePicViewBg.frame;
        rect.origin.y = SCREEN_HEIGHT;
        _datePicViewBg.frame = rect;
        
    } completion:^(BOOL finished) {
        [_datePicViewBg removeFromSuperview];
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
