/********* AliPush.m Cordova Plugin Implementation *******/

#import "CDVAliPush.h"
#import "AliPushManage.h"

@implementation CDVAliPush

- (void)bindAccount:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult *pluginResult = nil;
    NSString *account = [command.arguments objectAtIndex:0];

    if (account != nil && [account length] > 0) {
        
        NSLog(@"Start bindAccount: %@", account);
        
        [AliPushManage bindAccount:account withCallback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:account];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:res.error.description];
            }
        }];
        
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"account is nil"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
