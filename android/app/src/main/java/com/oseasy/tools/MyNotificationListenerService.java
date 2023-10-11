package com.oseasy.tools;

import android.service.notification.NotificationListenerService;
import android.service.notification.StatusBarNotification;
import android.util.Log;

public class MyNotificationListenerService extends NotificationListenerService {
    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        Log.i("SevenNLS","Notification posted");
    }

    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        Log.i("SevenNLS","Notification removed");
    }
}
