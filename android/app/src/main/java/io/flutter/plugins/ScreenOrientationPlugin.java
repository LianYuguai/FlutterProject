package io.flutter.plugins;

import android.content.Context;
import android.util.Log;
import android.view.OrientationEventListener;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;

public class ScreenOrientationPlugin {
    private  static String EVNET_CHANNEL = "com.oseasy.emp_mobile/event_channel";
    private static OrientationEventListener mScreenOrientationEventListener = null;
    private static int mScreenExifOrientation = 0;
    private static EventChannel.EventSink eventSink = null;
    public static void registerWith(@NonNull FlutterEngine flutterEngine, Context context) {
        EventChannel channel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVNET_CHANNEL);
        channel.setStreamHandler(new EventChannel.StreamHandler(){

            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
                Log.d("EventChannel", "EventChannel onListen called");
            }

            @Override
            public void onCancel(Object arguments) {
                Log.d("EventChannel", "EventChannel onCancel called");
            }
        });
        mScreenOrientationEventListener = new OrientationEventListener(context) {
            @Override
            public void onOrientationChanged(int i) {
                int orientation = 0;
                if (45 <= i && i < 135) {
                    orientation = 90;
                } else if (135 <= i && i < 225) {
                    orientation = 180;
                } else if (225 <= i && i < 315) {
                    orientation = -90;
                } else {
                    orientation = 0;
                }
                if(mScreenExifOrientation == orientation){
                    return;
                }
                mScreenExifOrientation = orientation;
                Log.i("orientation", mScreenExifOrientation+"");
                if(eventSink == null){
                    return;
                }
                eventSink.success(orientation);
            }
        };
        mScreenOrientationEventListener.enable();
    }
    public static void disable(){
        mScreenOrientationEventListener.disable();
        mScreenOrientationEventListener = null;
    }
}
