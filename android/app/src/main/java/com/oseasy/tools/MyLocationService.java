package com.oseasy.tools;

import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Looper;

import androidx.core.app.ActivityCompat;

import com.huawei.hmf.tasks.OnFailureListener;
import com.huawei.hmf.tasks.OnSuccessListener;
import com.huawei.hms.location.FusedLocationProviderClient;
import com.huawei.hms.location.LocationCallback;
import com.huawei.hms.location.LocationRequest;
import com.huawei.hms.location.LocationResult;
import com.huawei.hms.location.LocationServices;
import com.huawei.hms.location.LocationSettingsRequest;
import com.huawei.hms.location.LocationSettingsResponse;
import com.huawei.hms.location.LocationSettingsStates;
import com.huawei.hms.location.SettingsClient;
import com.oseasy.emp_mobile.MainActivity;

import io.flutter.Log;

public class MyLocationService {
    // 声明fusedLocationProviderClient对象
    private static FusedLocationProviderClient fusedLocationProviderClient;
    private static LocationRequest mLocationRequest;
    private static LocationCallback mLocationCallback;

    public static void requestLocationPermission(MainActivity activity){
        // Android SDK<=28 所需权限动态申请
        if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.P) {
            Log.i("定位", "android sdk <= 28 Q");
            if (ActivityCompat.checkSelfPermission(activity,
                    android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(activity,
                    android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                String[] strings =
                        {android.Manifest.permission.ACCESS_FINE_LOCATION, android.Manifest.permission.ACCESS_COARSE_LOCATION};
                ActivityCompat.requestPermissions(activity, strings, 1);
            }
        } else {
            // Android SDK>28 所需权限动态申请，需添加“android.permission.ACCESS_BACKGROUND_LOCATION”权限
            if (ActivityCompat.checkSelfPermission(activity,
                    android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(activity,
                    android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(activity,
                    "android.permission.ACCESS_BACKGROUND_LOCATION") != PackageManager.PERMISSION_GRANTED) {
                String[] strings = {android.Manifest.permission.ACCESS_FINE_LOCATION,
                        android.Manifest.permission.ACCESS_COARSE_LOCATION,
                        "android.permission.ACCESS_BACKGROUND_LOCATION"};
                ActivityCompat.requestPermissions(activity, strings, 2);
            }
        }

    }
    public static void checkLocationSettings(MainActivity activity){
        SettingsClient settingsClient = LocationServices.getSettingsClient(activity);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
        LocationRequest mLocationRequest = new LocationRequest();
        builder.addLocationRequest(mLocationRequest);
        LocationSettingsRequest locationSettingsRequest = builder.build();
// 检查设备定位设置
        settingsClient.checkLocationSettings(locationSettingsRequest)
                // 检查设备定位设置接口调用成功监听
                .addOnSuccessListener(new OnSuccessListener<LocationSettingsResponse>() {
                    @Override
                    public void onSuccess(LocationSettingsResponse locationSettingsResponse) {
                        LocationSettingsStates locationSettingsStates =
                                locationSettingsResponse.getLocationSettingsStates();
                        StringBuilder stringBuilder = new StringBuilder();
                        // 定位开关是否打开
                        stringBuilder.append(",\nisLocationUsable=")
                                .append(locationSettingsStates.isLocationUsable());
                        // HMS Core是否可用
                        stringBuilder.append(",\nisHMSLocationUsable=")
                                .append(locationSettingsStates.isHMSLocationUsable());
                        Log.i("定位", "checkLocationSetting onComplete:" + stringBuilder.toString());
                    }
                })
                // 检查设备定位设置接口失败监听回调
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        Log.i("定位", "checkLocationSetting onFailure:" + e.getMessage());
                    }
                });

    }
    public static void initLocation(MainActivity activity, LocationCallback callback){
// 实例化fusedLocationProviderClient对象
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(activity);
        mLocationRequest = new LocationRequest();
        mLocationRequest.setNeedAddress(true);
// 设置定位类型
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
// 设置回调次数为1
        mLocationRequest.setNumUpdates(1);

        /**
        mLocationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult != null) {
                    // TODO: 处理位置回调结果
                }
            }
        };*/
        mLocationCallback = callback;


    }
    static public void requestLocation(){
        fusedLocationProviderClient.requestLocationUpdates(mLocationRequest, mLocationCallback, Looper.getMainLooper())
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        // TODO: 接口调用成功的处理
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        // TODO: 接口调用失败的处理
                    }
                });

    }
    public static void removeRequestLocation(){
        // 注意：停止位置更新时，mLocationCallback必须与requestLocationUpdates方法中的LocationCallback参数为同一对象。
        fusedLocationProviderClient.removeLocationUpdates(mLocationCallback)
                // 停止位置更新成功监听回调
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        // TODO: 停止位置更新成功的处理
                    }
                })
                // 停止位置更新失败监听回调
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        // TODO：停止位置更新失败的处理
                    }
                });

    }
}
