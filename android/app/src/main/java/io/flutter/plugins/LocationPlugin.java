package io.flutter.plugins;

import android.content.Context;
import android.location.Location;
import android.view.OrientationEventListener;

import androidx.annotation.NonNull;

import com.huawei.hms.location.HWLocation;
import com.huawei.hms.location.LocationCallback;
import com.huawei.hms.location.LocationResult;
import com.oseasy.emp_mobile.MainActivity;
import com.oseasy.tools.MyLocationService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

 class CallHandler implements MethodChannel.MethodCallHandler {
     private MainActivity mainContext;
     private MethodChannel.Result requestLocationResult;
     public CallHandler(MainActivity context){
         mainContext = context;
     }
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
         String method = call.method;
         Log.e("定位", method);
        if (method.equals("checkLocationSettings")) {
            MyLocationService.checkLocationSettings(mainContext);
            result.success(true);
        } else if (method.equals("initLocation")) {
            MyLocationService.initLocation(mainContext, new LocationCallback() {
                @Override
                public void onLocationResult(LocationResult locationResult) {
                    if (locationResult != null) {
                        // TODO: 处理位置回调结果
                        List<HWLocation> hwLocations = locationResult.getHWLocationList();
                        List<Location> locations = locationResult.getLocations();
                        String street = "";
                        String countryName = "";
                        String city = "";
                        String county = "";
                        String state = "";
                        double lat = 0;
                        double lng = 0;
                        if(hwLocations.size()>0){
                            HWLocation location = hwLocations.get(0);
                            street = location.getStreet();
                            countryName = location.getCountryName();
                            city = location.getCity();
                            county = location.getCounty();
                            lat = location.getLatitude();
                            lng = location.getLongitude();
                            state = location.getState();
                        }
                        Map<String, Object> locationInfo = new HashMap<>();
                        locationInfo.put("street", street);
                        locationInfo.put("countryName", countryName);
                        locationInfo.put("city", city);
                        locationInfo.put("county", county);
                        locationInfo.put("lat", lat);
                        locationInfo.put("lng", lng);
                        locationInfo.put("state", lng);
                        LocationPlugin.sendEventSuccess(locationInfo);
//                        requestLocationResult.success(true);
//                        requestLocationResult.success(locationInfo);
                    }else {
//                        requestLocationResult.error("000001", null,null);
                    }
                }
            });

        } else if (method.equals("requestLocation")) {
            MyLocationService.requestLocation();
//            requestLocationResult = result;
            result.success(true);
        }else if (method.equals("removeRequestLocation")) {
            MyLocationService.removeRequestLocation();
            result.success(true);
        }
    }
}
public class LocationPlugin {
    private static String CHANNEL = "com.oseasy.emp_mobile/locationMethodChannel";
    private static MethodChannel channel;
    private static MainActivity mainContext;

    private  static String EVNET_CHANNEL = "com.oseasy.emp_mobile/locationEventChannel";
    private static EventChannel.EventSink eventSink = null;

    public static void registerWith(@NonNull FlutterEngine flutterEngine, MainActivity context) {
        mainContext = context;
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(new CallHandler(mainContext));
        LocationPlugin.registerEventWith(flutterEngine, context);
    }

    public static void registerEventWith(@NonNull FlutterEngine flutterEngine, Context context) {
        EventChannel channel = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVNET_CHANNEL);
        channel.setStreamHandler(new EventChannel.StreamHandler() {

            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
                android.util.Log.d("EventChannel", "EventChannel onListen called");
            }

            @Override
            public void onCancel(Object arguments) {
                android.util.Log.d("EventChannel", "EventChannel onCancel called");
            }
        });
    }

    public static void sendEventSuccess(Object event){
        eventSink.success(event);
    }

}
