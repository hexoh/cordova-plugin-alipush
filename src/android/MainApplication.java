package xyz.renhe.sxzw;

import android.app.Application;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;

import com.alibaba.sdk.android.push.CloudPushService;
import com.alibaba.sdk.android.push.CommonCallback;
import com.alibaba.sdk.android.push.huawei.HuaWeiRegister;
import com.alibaba.sdk.android.push.noonesdk.PushServiceFactory;
import com.alibaba.sdk.android.push.register.GcmRegister;
import com.alibaba.sdk.android.push.register.MeizuRegister;
import com.alibaba.sdk.android.push.register.MiPushRegister;
import com.alibaba.sdk.android.push.register.OppoRegister;
import com.alibaba.sdk.android.push.register.VivoRegister;

public class MainApplication extends Application {
  private static final String TAG = "Init";

  @Override
  public void onCreate() {
    super.onCreate();
    initAliPushChannel(this);
  }

  /**
   * 初始化阿里云推送
   * @param applicationContext applicationContext
   */
  private void initAliPushChannel(final Context applicationContext) {
    // 创建 notification channel
    this.createNotificationChannel();

    PushServiceFactory.init(applicationContext);
    final CloudPushService pushService = PushServiceFactory.getCloudPushService();
    pushService.register(applicationContext, new CommonCallback() {
      @Override
      public void onSuccess(String s) {
        Log.i(TAG, "init AliPush channel success");
      }

      @Override
      public void onFailed(String errorCode, String errorMessage) {
        Log.e(TAG, "init AliPush channel failed -- errorCode:" + errorCode + " -- errorMessage:" + errorMessage);
      }
    });

    MiPushRegister.register(applicationContext, "XIAOMI_ID", "XIAOMI_KEY"); // 初始化小米辅助推送
    HuaWeiRegister.register(this); // 接入华为辅助推送
    VivoRegister.register(applicationContext);
    OppoRegister.register(applicationContext, "OPPO_KEY", "OPPO_SECRET");
    MeizuRegister.register(applicationContext, "MEIZU_ID", "MEIZU_KEY");

    GcmRegister.register(applicationContext, "send_id", "application_id"); // 接入FCM/GCM初始化推送
  }

  /**
   * 针对 API Level 26 创建 NotificationChannel
   * 用户App的targetSdkVersion大于等于26
   */
  private void createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      NotificationManager mNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
      // 通知渠道的id
      String id = "1";
      // 用户可以看到的通知渠道的名字.
      CharSequence name = "notification channel";
      // 用户可以看到的通知渠道的描述
      String description = "notification description";
      int importance = NotificationManager.IMPORTANCE_HIGH;
      NotificationChannel mChannel = new NotificationChannel(id, name, importance);
      // 配置通知渠道的属性
      mChannel.setDescription(description);
      // 设置通知出现时的闪灯（如果 android 设备支持的话）
      mChannel.enableLights(true);
      mChannel.setLightColor(Color.RED);
      // 设置通知出现时的震动（如果 android 设备支持的话）
      mChannel.enableVibration(true);
      mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
      //最后在 notification manager 中创建该通知渠道
      mNotificationManager.createNotificationChannel(mChannel);
    }
  }
}
