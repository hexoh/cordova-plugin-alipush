//
//  AliPushManage.m
//  MyApp
//
//  Created by lenovo on 2022/3/3.
//

#import <Foundation/Foundation.h>


#import "AliPushManage.h"

@implementation AliPushManage

+ (id) getInstance {
    
    static AliPushManage *aliPushManage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aliPushManage = [[self alloc] init];
    });
    return aliPushManage;
    
}


/// 绑定账号
/// @param account 账号名
+ (void)bindAccount:(NSString *) account withCallback:(CallbackHandler)callback {
    [CloudPushSDK bindAccount:account withCallback:callback];
}


/// 解绑账号
+ (void)unbindAccount {
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"AliPush unbindAccount success.");
        } else {
            NSLog(@"AliPush unbindAccount error: %@", res.error);
        }
    }];
}

/// 同步角标到阿里推送服务器
/// @param badgeNum 角标数
+ (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            NSLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

@end
