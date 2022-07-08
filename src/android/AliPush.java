package org.apache.cordova.alipush;

import android.util.Log;

import com.alibaba.sdk.android.ams.common.util.StringUtil;
import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class AliPush extends CordovaPlugin {

  public static final String AliPush_TAG = "AliPush";

  private final CloudPushService mPushService = PushServiceFactory.getCloudPushService();

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("bindAccount")) {
      String account = args.getString(0);
      this.bindAccount(account, callbackContext);
      return true;
    } else if (action.equals("unbindAccount")) {
      this.unbindAccount(callbackContext);
      return true;
    } else if (action.equals("getDeviceId")) {
      this.getDeviceId(callbackContext);
      return true;
    }
    return false;
  }

  /**
   * bind account 绑定账号
   * 将应用内账号和推送通道相关联，可以实现按账号的定点消息推送
   * @param account         account 账号
   * @param callbackContext callbackContext 回调Context
   */
  private void bindAccount(String account, CallbackContext callbackContext) {
    if (account == null || account.isEmpty()) {
      Log.e(AliPush_TAG, "bindAccount: account is empty");
      callbackContext.error("account is empty");
      return;
    }

    Log.d(AliPush_TAG, "start bindAccount: " + account);
    cordova.getThreadPool().execute(new Runnable() {
      @Override
      public void run() {
        mPushService.bindAccount(account, new CommonCallback() {
          @Override
          public void onSuccess(String s) {
            Log.d(AliPush_TAG, "bindAccount '" + account + "' success: " + s);
            callbackContext.success("bindAccount '" + account + "' success");
          }

          @Override
          public void onFailed(String errorCode, String errorMsg) {
            Log.d(AliPush_TAG, "bindAccount '" + account + "' failed: " + "errorCode: " + errorCode + ", errorMsg:" + errorMsg);
            callbackContext.error("bindAccount '" + account + "' failed: " + "errorCode: " + errorCode + ", errorMsg:" + errorMsg);
          }
        });
      }
    });
  }

  /**
   * unbind account 解绑账号
   * 将应用内账号和推送通道取消关联
   * @param callbackContext callbackContext 回调Context
   */
  private void unbindAccount(CallbackContext callbackContext) {
    Log.d(AliPush_TAG, "start unbindAccount...");
    cordova.getThreadPool().execute(new Runnable() {
      @Override
      public void run() {
        mPushService.unbindAccount(new CommonCallback() {
          @Override
          public void onSuccess(String s) {
            Log.d(AliPush_TAG, "unbindAccount success: " + s);
            callbackContext.success("unbindAccount success");
          }

          @Override
          public void onFailed(String errorCode, String errorMsg) {
            Log.d(AliPush_TAG, "unbindAccount failed: " + "errorCode: " + errorCode + ", errorMsg:" + errorMsg);
            callbackContext.error("unbindAccount failed: " + "errorCode: " + errorCode + ", errorMsg:" + errorMsg);
          }
        });
      }
    });
  }

  /**
   * get deviceId 获取设备唯一标识
   * 获取设备唯一标识，指定设备推送时需要。
   * @param callbackContext callbackContext 回调Context
   */
  private void getDeviceId(CallbackContext callbackContext) {
    Log.d(AliPush_TAG, "start getDeviceId...");
    cordova.getThreadPool().execute(new Runnable() {
      @Override
      public void run() {
        String deviceId = mPushService.getDeviceId();
        if (!StringUtil.isEmpty(deviceId)) {
          Log.d(AliPush_TAG, "getDeviceId success: " + deviceId);
          callbackContext.success(deviceId);
        } else {
          Log.d(AliPush_TAG, "getDeviceId failed: " + deviceId);
          callbackContext.error(deviceId);
        }
      }
    });
  }
}
