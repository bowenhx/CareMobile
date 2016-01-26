//
//  ConstantConfig.h
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SavaData.h"
#import "UIImageView+WebCache.h"
#import "UIColor+app.h"
#import "MBProgressHUD+Add.h"
#import "CARequest.h"
#import "NSString+UIColor.h"


#ifndef ConstantConfig_h
#define ConstantConfig_h

/**
 *  保存用户基本信息文件
 *
 */
//用户ID key
#define USER_ID_KEY        @"OWNUSERIDKEY"

//获取用户UID
#define USERID           [[SavaData shareInstance] printDataStr:USER_ID_KEY]

//用户基本信息保存plist文件
#define User_File        [NSString stringWithFormat:@"user_%@.plist",USERID]

#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width

#define USERNAMEKEY  @"USERNAMEKEY"
#define USERPASSWORDKEY  @"USERPASSWORDKEY"

//设置信息数据
#define Set_File  @"setting.plist"

// 获得特定字号的字体
#define GETFONT(x) [UIFont fontWithName:DSFONT size:(x)]
#define SYSTEMFONT(FONTSIZE)    [UIFont systemFontOfSize:FONTSIZE]
#define GETBOLDFONT(x) [UIFont boldSystemFontOfSize:(x)]

// View 坐标(x,y)和宽高(width,height)
#define X(v)                    (v).frame.origin.x
#define Y(v)                    (v).frame.origin.y
#define WIDTH(v)                (v).frame.size.width
#define HEIGHT(v)               (v).frame.size.height
#define HEIGHTADDY(v)           (v).frame.size.height + (v).frame.origin.y
#define WIDTHADDX(v)            (v).frame.size.width + (v).frame.origin.x


#define SelectTabBarNotification  @"selectTabBarNotification"

#define UpdataNotification @"updataNotification"
#endif /* ConstantConfig */


//----------------------------------统一根地址url----------------------------------

#define CBASE_URL_KEY @"BASEURL"

#define CPORT_KEY @"CPORT"

#define CGORGE_KEY @"CGORGE"



#define CBASE_URL  @"http://123.57.43.174:8080"



//检测是否连接服务器
#define CAPI_Link  @"/link.do?api="

//用户登录接口
#define CAPI_Login @"/login.do?api="

//服务器apk版本检查
#define CAPI_Version @"/version.do?api="

//获取版权信息（接口）
#define CAPI_Verinfo @"/verinfo.do?api="





//高级搜索病人列表（支持扫码搜索）
#define CAPI_BRSearch   @"/bingrenlist.do?api="

//获取搜索选项
#define CAPI_SearchItem  @"/br_search.do?api="

//病房巡视搜索
#define CAPI_WardBedList  @"/ward_bed_list.do?api="

//病房巡视保存记录
#define CAPI_WardBedSave  @"/ward_inspection.do?api="

//巡视记录查询
#define CAPI_WardHistory @"/ward_inspect_history.do?api="






//病人列表
#define CAPI_BingRenList @"/bingrenlist.do?api="

//病人信息界面 ////【上】【下】病人按钮
#define CAPI_BingRen  @"/bingren.do?api="

//新增关注病人：病人列表
#define CAPI_BRAttent  @"/bingrenlist_attent.do?api="

//新增关注病人：关注、取消关注
#define CAPI_BRPatsAttent  @"/pats_attent.do?api="



//体温预警（列表）
#define CAPI_BRTemperature @"/temperature_list.do?api="





//护理记录单列表 (一 / 二 级目录)
#define CAPI_RYPglist  @"/nursing_record_names.do?api="

//历史记录列表
#define CAPI_RecordHis  @"/nursing_record_dates.do?api="  

//修改记录
#define CAPI_RecordChange @"/nursing_record_list.do?api="

//记录单添加选项
#define CAPI_RecordAdd  @"/nursing_record_dict.do?api="

//保存与更新
#define CAPI_RecordSave @"/nursing_record_dml.do?api="

//护理记录单删除
#define CAPI_RecordDel  @"/nursing_record_del.do?api="






//医嘱列表
#define CAPI_Yizhu  @"/yizhu.do?api="

//医嘱执行单
#define CAPI_YZZXD  @"/yz_zhixingdan.do?api="

//医嘱执行单（立即执行）【支持扫码执行】
#define CAPI_YZZXDDOOK  @"/yzzxd_dook.do?api="




//每日评估（时间列表）
#define CAPI_MRPG  @"/mrpg_list.do?api="

//每日评估（评估选项）
#define CAPI_MRPGList  @"/new_mrpglist.do?api="

//每日评估（保存）
#define CAPI_MRPGSave  @"/pgsave.do?api="



//评估单名称列表
#define CAPI_NursingNames  @"/nursing_eval_names.do?api="

//评估历史记录
#define CAPI_NursingList @"/nursing_eval_list.do?api="

//评估历史删除
#define CAPI_NursingDel  @"/nursing_eval_del.do?api="

//评估项列表
#define CAPI_NursingDict @"/nursing_eval_dict.do?api="

//评估保存
#define CAPI_NursingSave  @"/nursing_eval_save.do?api="





//护理（时间列表）
#define CAPI_HLList  @"/huli_list.do?api="

//护理（记录）
#define CAPI_HLOrderOk  @"/huli_orderok.do?api="

//护理（添加选项）
#define CAPI_HLOrder  @"/huli_order.do?api="

//护理（提交）
#define CAPI_HLSave  @"/huli_save.do?api="

//护理生命体征修改保存
#define CAPI_update @"/huli_update.do?api="

//护理删除
#define CAPI_HLDelDo  @"/huli_del.do?api="



//教育(教育列表)
#define CAPI_JiaoYuList  @"/new_edulist.do?api="

//教育（教育表单列表）
#define CAPI_JiaoYuEdu  @"/eduorder.do?api="

//提交（提交）
#define CAPI_JiaoYuSave  @"/eduorderok.do?api="





//检验（一级列表）
#define CAPI_JianYan @"/jianyan.do?api="

//检验结果（二级列表）
#define CAPI_JianYanJieGuo  @"/jianyan_result.do?api="




//检查
#define CAPI_JianCha  @"/jiancha.do?api="




//手术
#define CAPI_ShouShu  @"/shoushu.do?api="




//样本列表
#define CAPI_YangBenList  @"/biaoben.do?api="

//功能描述：搜索扫描到的版本号
#define CAPI_BiaoBen  @"/biaobenscan.do?api="

//样本采集触发方法
#define CAPI_   @"/biaobencaiji.do?api="





//交接班列表
#define CAPI_JiaoJie  @"/jiaojielist.do?api="

//交接班詳情
#define CAPI_JaoJieXQ  @"/jiaojieban.do?api="





//病程录 、//病程录详情
#define CAPI_CourseOrDet  @"/progress_note.do?api="



//功能描述：修改密码（护士账号信息 修改密码接口）
#define CAPI_PassWord  @"/modpwd.do?api="












