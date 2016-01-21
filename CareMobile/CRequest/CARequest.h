//
//  CARequest.h
//  CareMobile
//
//  Created by Guibin on 15/10/31.
//  Copyright © 2015年 MobileCare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CARequest : NSObject

+ (id)shareInstance;

- (void)startWithRequestCompletion:(NSString *)url  withParameter:(NSDictionary *)dict completed:(void (^)(id content, NSError *err))completed;
- (void)startWithPostCompletion:(NSString *)url withParmeter:(NSDictionary *)dict completed:(void (^)(id content, NSError *err))completed;
- (void)saveDataString:(NSString *)address key:(NSString *)key;
- (NSString *)printDataString:(NSString *)key;
@end
