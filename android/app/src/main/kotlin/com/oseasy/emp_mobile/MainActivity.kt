package com.oseasy.emp_mobile
import android.util.Log
import android.view.OrientationEventListener
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity(){
    var mScreenOrientationEventListener: OrientationEventListener? = null;
    var mScreenExifOrientation: Int = 0;
    //通讯名称,回到手机桌面
    private val CHANNEL = "android/back/desktop"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result ->
            if (methodCall.method == "backDesktop") {
                result.success(true)
                moveTaskToBack(false)
            }
        };
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "")
        mScreenOrientationEventListener = object : OrientationEventListener(this) {
            override fun onOrientationChanged(i: Int) {
                var orientation: Int = 0
                if (45 <= i && i < 135) {
                    orientation = 90
                } else if (135 <= i && i < 225) {
                    orientation = 180
                } else if (225 <= i && i < 315) {
                    orientation = -90
                } else {
                    orientation = 0
                }
                if(mScreenExifOrientation == orientation){
                    return
                }
                mScreenExifOrientation = orientation;
                Log.i("orientation", mScreenExifOrientation.toString());
            }
        }
        mScreenOrientationEventListener?.enable();

    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine);
        mScreenOrientationEventListener?.disable()
        mScreenOrientationEventListener = null;
    }
}
