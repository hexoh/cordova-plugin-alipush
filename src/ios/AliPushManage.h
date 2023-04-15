//
//  AliPushManage.h
//  MyApp
//
//  Created by lenovo on 2022/3/3.
//

#ifndef AliPushManage_h
#define AliPushManage_h

#import <CloudPushSDK/CloudPushSDK.h>

/// 阿里推送
@interface AliPushManage : NSObject {
    
}

/// 实例化方法
+ (id) getInstance;

/// 绑定账号
/// @param account 账号
+ (void) bindAccount:(NSString*) account withCallback:(CallbackHandler)callback;

/// 解绑账号
+ (void) unbindAccount:(CallbackHandler) callback;


/// 同步角标到阿里服务器
/// @param badgeNum 角标数
+ (void) syncBadgeNum:(NSUInteger) badgeNum;

/// 获取设备号
+ (NSString *) getDeviceId;

@end


#endif /* AliPushManage_h */
