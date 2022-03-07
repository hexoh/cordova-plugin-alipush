/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  MyApp
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import "AliPushManage.h"

// ios 10 notifiation
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate
{
    // ios 10 通知中心
    UNUserNotificationCenter *_notificationCenter;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // APNs 注册，获取 deviceToken 并上报
    [self registerAPNs:application];
    
    // 初始化推送SDK
    [self initAliCloudPush];
    
    // 监听推送消息到达
    [self registerMessageReceive];
    
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    // [CloudPushSDK handleLaunching:launchOptions];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:launchOptions];
    
    self.viewController = [[MainViewController alloc] init];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}


/// 向 APNs 服务注册，获取 deviceToken
/// @param application   应用程序
- (void)registerAPNs:(UIApplication *)application
{
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue ];
    if (systemVersionNum >= 10.0) { // ios 10 以上推送处理
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建 category 并注册到通知中心
        [self createCustomNotificationCategory];
        _notificationCenter.delegate = self;
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {  // ios 8 和 ios 9
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [application registerForRemoteNotifications];
        #pragma clang diagnostic pop
    } else { // ios 8 以下
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
        #pragma clang diagnostic pop
    }
}


/// APNs 注册成功回调，然后将返回的 deviceToken 上传到 AliCloudPush 服务器
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    NSLog(@"APNs register success -> Upload deviceToken to AliCloudPush server.");
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Upload deviceToken to AliCloudPush success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Upload deviceToken to AliCloudPush deviceToken failed, error: %@", res.error);
        }
    }];
}


/// APNs 注册失败回调
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"APNs register error -> didFailToRegisterForRemoteNotificationsWithError %@", error);
}

/// 创建并注册通知 category (ios 10+)
- (void)createCustomNotificationCategory
{
    // 自定义 action1 和 action2
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"alipushaction1" title:@"pushAction1" options:UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"alipushaction2" title:@"pushAction2" options:UNNotificationActionOptionNone];
    // 创建 id 为 'aliCategory' 的 category，并注册两个 action 到 category
    // UNNotificationCategoryOptionCustomDismissAction 表明可以触发通知的 dismiss 回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"aliCategory" actions:@[action1, action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    // 注册 category 到通知中心
    [_notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}


/// 处理 ios 10 通知
/// @param notification 通知
- (void)handleiOS10Notification:(UNNotification *)notification
{
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 同步角标数到服务端
    [AliPushManage syncBadgeNum:0];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
}


/// App 处于前台时收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSLog(@"Receive a notification in foregound.");
    // 处理iOS 10通知，并上报通知打开回执
    [self handleiOS10Notification:notification];
    // 通知不弹出
    // completionHandler(UNNotificationPresentationOptionNone);
    
    // 通知弹出，且带有声音、内容和角标
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}


/// 触发通知动作时回调，比如点击、删除通知和点击自定义 action (iOS 10+)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSString *userAction = response.actionIdentifier;
    // 点击打开通知
    if ([userAction isEqualToString: UNNotificationDefaultActionIdentifier]) {
        NSLog(@"User opened the notification.");
        // 处理 ios 10 通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification];
    }
    
    // 通知 dismiss，category 创建时传入 UNNotificationCategoryOptionCustomDismissAction 才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        [CloudPushSDK sendDeleteNotificationAck:response.notification.request.content.userInfo];
    }
    
    NSString *customAction1 = @"alipushaction1";
    NSString *customAction2 = @"alipushaction2";
    // 点击用户自定义Action1
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom alipushaction1.");
    }
    // 点击用户自定义Action2
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom alipushaction2.");
    }
    completionHandler();
}


/// 初始化阿里云推送
- (void)initAliCloudPush
{
    // 开启debug 正式上线关闭
    [CloudPushSDK turnOnDebug];
    
    // SDK 初始化 手动输入appKey和appSecret
    //    [CloudPushSDK asyncInit:@"appKey" appSecret:@"appSecret" callback:^(CloudPushCallbackResult *res) {
    //        if (res.success) {
    //            NSLog(@"AliPush SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
    //        } else {
    //            NSLog(@"AliPush SDK init failed, error: %@", res.error);
    //        }
    //    }];
    
    // SDK 初始化，无需手动输入，直接读取配置文件
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"AliPush SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"AliPush SDK init failed, error: %@", res.error);
        }
    }];
}


/// App处于启动状态时，通知打开回调
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Receive one notification.");
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [aps valueForKey:@"alert"];
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;
    // 同步通知角标数到服务端
    [AliPushManage syncBadgeNum:0];
    // 通知打开回执上报
    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:userInfo];
}


/// 注册推送通道打开监听
- (void)listenerOnChannelOpened
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onChannelOpened:) name:@"CCPDidChannelConnectedSuccess" object:nil];
}


/// 推送通道打开回调
- (void)onChannelOpened:(NSNotification *)notification
{
    NSLog(@"消息通道建立成功");
}


/// 监听推送消息到达
- (void)registerMessageReceive
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(onMessageReceived:) name:@"CCPDidReceiveMessageNotification" object:nil];
}


/// 处理接收到的通知消息
/// @param notification 消息参数
- (void)onMessageReceived:(NSNotification *)notification
{
    NSLog(@"Receive one message!");
   
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
}

@end
