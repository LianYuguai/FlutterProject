package com.oseasy.emp_mobile
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.LocationPlugin
import io.flutter.plugins.ScreenOrientationPlugin


class MainActivity: FlutterActivity(){
//    var mScreenOrientationEventListener: OrientationEventListener? = null;
//    var mScreenExifOrientation: Int = 0;
//    var eventSink: EventSink? = null;
    //通讯名称,回到手机桌面
    private val CHANNEL = "android/back/desktop"
//    private  val EVNET_CHANNEL = "com.oseasy.emp_mobile/event_channel"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { methodCall, result ->
//            if (methodCall.method == "backDesktop") {
//                result.success(true)
//                moveTaskToBack(false)
//            }
        };

    ScreenOrientationPlugin.registerWith(flutterEngine,this);
    LocationPlugin.registerWith(flutterEngine, this);
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine);
        ScreenOrientationPlugin.disable();
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        var title: String? = intent.getStringExtra("title")
        var summary: String? = intent.getStringExtra("summary")
        var extra = intent.extras;
//        Toast.makeText(context, "$title: $summary", Toast.LENGTH_LONG).show()
        Toast.makeText(context, extra.toString(), Toast.LENGTH_LONG).show();
        Log.e("测试", extra.toString())
        handleIntent();
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent();
    }

    fun handleIntent() {
        if (intent != null) {
            val value1 = intent.getStringExtra("key1")
            val value2 = intent.getStringExtra("key2")
            Log.e("测试", "" + value1)
            Log.e("测试", "" + value2)
        }
    }

}
