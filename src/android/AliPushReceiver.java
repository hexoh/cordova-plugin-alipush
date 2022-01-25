package org.apache.cordova.alipush;

import android.content.Context;
import android.util.Log;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;

import java.util.Map;

public class AliPushReceiver extends MessageReceiver {
  // 消息接收部分的LOG_TAG
  public static final String REC_TAG = "AliPushReceiver";

  /**
   * 推送通知的回调方法
   * @param context
   * @param title
   * @param summary
   * @param extraMap
   */
  @Override
  public void onNotification(Context context, String title, String summary, Map<String, String> extraMap) {
    if ( null != extraMap ) {
      for (Map.Entry<String, String> entry : extraMap.entrySet()) {
        Log.i(REC_TAG,"@Get diy param : Key=" + entry.getKey() + " , Value=" + entry.getValue());
      }
    } else {
      Log.i(REC_TAG,"@收到通知 && 自定义消息为空");
    }
    Log.i(REC_TAG, "Receive notification, title: " + title + ", summary: " + summary + ", extraMap: " + extraMap);
  }

  /**
   * 推送消息的回调方法
   * @param context
   * @param cPushMessage
   */
  @Override
  public void onMessage(Context context, CPushMessage cPushMessage) {
    Log.i(REC_TAG, "onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());
  }

  /**
   * 从通知栏打开通知的扩展处理
   * @param context
   * @param title
   * @param summary
   * @param extraMap
   */
  @Override
  public void onNotificationOpened(Context context, String title, String summary, String extraMap) {
    Log.i(REC_TAG, "onNotificationOpened, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
  }

  /**
   * 无动作通知点击回调。当在后台或阿里云控制台指定的通知动作为无逻辑跳转时,通知点击回调为onNotificationClickedWithNoAction而不是onNotificationOpened
   * @param context
   * @param title
   * @param summary
   * @param extraMap
   */
  @Override
  protected void onNotificationClickedWithNoAction(Context context, String title, String summary, String extraMap) {
    Log.i(REC_TAG, "onNotificationClickedWithNoAction, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
  }

  /**
   * 应用处于前台时通知到达回调。注意:该方法仅对自定义样式通知有效,相关详情请参考https://help.aliyun.com/document_detail/30066.html?spm=5176.product30047.6.620.wjcC87#h3-3-4-basiccustompushnotification-api
   * @param context
   * @param title
   * @param summary
   * @param extraMap
   * @param openType
   * @param openActivity
   * @param openUrl
   */
  @Override
  protected void onNotificationReceivedInApp(Context context, String title, String summary, Map<String, String> extraMap, int openType, String openActivity, String openUrl) {
    Log.i(REC_TAG, "onNotificationReceivedInApp, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap + ", openType:" + openType + ", openActivity:" + openActivity + ", openUrl:" + openUrl);
  }

  /**
   * 通知删除回调
   * @param context
   * @param messageId
   */
  @Override
  protected void onNotificationRemoved(Context context, String messageId) {
    Log.i(REC_TAG, "onNotificationRemoved");
  }
}
