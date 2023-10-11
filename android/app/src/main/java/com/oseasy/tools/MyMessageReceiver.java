package com.oseasy.tools;

import android.content.Context;
import android.widget.Toast;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;

import java.util.Map;

import io.flutter.Log;

public class MyMessageReceiver extends MessageReceiver {
    @Override
    protected void onNotification(Context context, String s, String s1, Map<String, String> map) {
        // TODO处理推送通知
        Log.e("MyMessageReceiver", "Receive notification, title: " + s + ", summary: " + s1 + ", extraMap: " + map);
    }

    @Override
    protected void onMessage(Context context, CPushMessage cPushMessage) {
        Log.e("MyMessageReceiver", "onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());
    }

    @Override
    protected void onNotificationOpened(Context context, String s, String s1, String s2) {
        Toast.makeText(context, s, Toast.LENGTH_LONG).show();
        Log.e("MyMessageReceiver", "onNotificationOpened, title: " + s + ", summary: " + s1 + ", extraMap:" + s2);
    }

    @Override
    protected void onNotificationClickedWithNoAction(Context context, String s, String s1, String s2) {
        Log.e("MyMessageReceiver", "onNotificationClickedWithNoAction, title: " + s + ", summary: " + s1 + ", extraMap:" + s2);
    }

    @Override
    protected void onNotificationRemoved(Context context, String s) {
        Log.e("MyMessageReceiver", "onNotificationRemoved");
    }

    @Override
    protected void onNotificationReceivedInApp(Context context, String s, String s1, Map<String, String> map, int i, String s2, String s3) {
        Log.e("MyMessageReceiver", "onNotificationReceivedInApp, title: " + s + ", summary: " + s1 + ", extraMap:" + map );
    }
}
