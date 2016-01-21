//
//  CARequest.m
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import "CARequest.h"
#import "ConstantConfig.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPSessionManager.h"
#import "AFSecurityPolicy.h"


#define Message  @"请求出错，请稍后重试"

@implementation CARequest



+ (id)shareInstance
{
    static CARequest *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
    
}
//检查网络
- (void)checkNetwork:(AFHTTPSessionManager *)manager block:(void(^)(BOOL isNat))block{
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"-------AFNetworkReachabilityStatusReachableViaWWAN------");
                 block ( true );
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"-------AFNetworkReachabilityStatusReachableViaWiFi------");
                 block ( true );
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"-------AFNetworkReachabilityStatusNotReachable------");
                block ( false );
                break;
            default:
                break;
        }
        
    }];
    [manager.reachabilityManager startMonitoring];
    
}

- (void)startWithRequestCompletion:(NSString *)url  withParameter:(NSDictionary *)dict completed:(void (^)(id content,NSError *err))completed
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self checkNetwork:manager block:^(BOOL isNat) {
        //判断网络状态
        if (isNat) {
            NSString *baseUrl = [self printDataString:CBASE_URL_KEY];
            if ([@"" isStringBlank:baseUrl]) {
                completed ( @{@"message":@"请设置服务器参数再登录"} , nil );
                return ;
            }
            NSString *urlStr = [self buildRequestUrl:url andDic:dict];
            
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            
            
            [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if ( [responseObject isKindOfClass:[NSNull class]] ) {
                    NSLog(@"responseObject = %@",responseObject);
                    completed ( @{@"message":Message} , nil );
                }else{
                    if ([responseObject isKindOfClass:[NSData class]]) {
                        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                        completed ( jsonObj , nil );
                    }else{
                        completed ( @{@"message":Message} , nil );
                    }
                    
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                completed ( @{@"message":Message} , nil );
            }];

        }else{
            completed ( @{@"message":@"网络连接断开，请检查网络"} , nil );
        }
        
        
    }];
    
 
/*
    if (nil == dict) {
        [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            
            if ([responseObject isKindOfClass:[NSData class]]) {
            
                id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                completed ( jsonObj , nil );
            }else{
                completed ( @{@"message":Message} , nil );
            }

            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completed ( @{@"message":Message} , nil );
        }];
    }else{
        [manager POST:urlStr parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([responseObject isKindOfClass:[NSData class]]) {
                
                id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                completed ( jsonObj , nil );
            }else{
                completed ( @{@"message":Message} , nil );
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            completed ( @{@"message":Message} , nil );
        }];
    }
 */
    
    
}

- (void)startWithPostCompletion:(NSString *)url withParmeter:(NSDictionary *)dict completed:(void (^)(id content, NSError *err))completed
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [self checkNetwork:manager block:^(BOOL isNat) {
        //判断网络状态
        if (isNat) {
            NSString *baseUrl = [self printDataString:CBASE_URL_KEY];
            if ([@"" isStringBlank:baseUrl]) {
                completed ( @{@"message":@"请设置服务器参数再登录"} , nil );
                return ;
            }
            NSString *urlStr = [self postRequestUrl:url];
            
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            
            manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            
            [manager POST:urlStr parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    
                    id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                    completed ( jsonObj , nil );
                }else{
                    completed ( @{@"message":Message} , nil );
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                completed ( @{@"message":Message} , nil );
            }];
            
        }else{
            completed ( @{@"message":@"网络连接断开，请检查网络"} , nil );
        }
        
        
    }];

}

/*@"http://123.57.43.174:8080"*/
- (NSString *)buildRequestUrl:(NSString *)addUrl andDic:(NSDictionary *)dict
{
    NSString *detailUrl = [self parameterStringForDictionary:dict];
    NSString *basUrl = [NSString stringWithFormat:@"http://%@:%@",[self printDataString:CBASE_URL_KEY],[self printDataString:CPORT_KEY]];
    NSString *addStr = [addUrl stringByAppendingString:[self printDataString:CGORGE_KEY]];
    return [NSString stringWithFormat:@"%@%@&%@",basUrl,addStr,detailUrl];
}

- (NSString *)postRequestUrl:(NSString *)addUrl
{
    NSString *basUrl = [NSString stringWithFormat:@"http://%@:%@",[self printDataString:CBASE_URL_KEY],[self printDataString:CPORT_KEY]];
    NSString *addStr = [addUrl stringByAppendingString:[self printDataString:CGORGE_KEY]];
    return [NSString stringWithFormat:@"%@%@",basUrl,addStr];
}

/**
 *  把字典拼接成字符串以Data的形式传到请求的Body 中
 *
 */
- (NSString*)parameterStringForDictionary:(NSDictionary *)parameters {
    NSMutableArray *stringParameters = [NSMutableArray arrayWithCapacity:parameters.count];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if([obj isKindOfClass:[NSString class]]) {
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        else if([obj isKindOfClass:[NSNumber class]]) {
            [stringParameters addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
        else{
            [NSException raise:NSInvalidArgumentException format:@"error: requests only accept NSString, NSNumber and NSData parameters."];
        }
    }];
    
    return [stringParameters componentsJoinedByString:@"&"];
}

- (void)saveDataString:(NSString *)address key:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:address forKey:key];
    [defaults synchronize];
}

- (NSString *)printDataString:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}
@end
