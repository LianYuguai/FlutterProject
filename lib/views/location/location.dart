import 'package:flutter/material.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
// import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _locationStr = "";
  BaiduLocation _loationResult = BaiduLocation();
  final LocationFlutterPlugin _myLocPlugin = LocationFlutterPlugin();
  bool _suc = false;

  @override
  void initState() {
    super.initState();
    requestPermission();
    _myLocPlugin.setAgreePrivacy(true);

    ///单次定位时如果是安卓可以在内部进行判断调用连续定位
    if (Platform.isIOS) {
      _myLocPlugin.authAK("GvQTLPrPIg2IZMdfLI8UXgeGnBuT6FGw");

      ///接受定位回调
      _myLocPlugin.singleLocationCallback(callback: (BaiduLocation result) {
        setState(() {
          _loationResult = result;

          locationFinish();
        });
      });
    } else if (Platform.isAndroid) {
      ///接受定位回调
      _myLocPlugin.seriesLocationCallback(callback: (BaiduLocation result) {
        setState(() {
          _loationResult = result;
          locationFinish();
          _myLocPlugin.stopLocation();
        });
      });
    }
  }

  ///定位完成添加mark
  void locationFinish() {
    debugPrint("_loationResult: $_loationResult");

    /// 创建BMFMarker
    setState(() {
      _locationStr = _loationResult.address ?? "未知";
    });
  }

  void _locationAction() async {
    /// 设置android端和ios端定位参数
    /// android 端设置定位参数
    /// ios 端设置定位参数
    Map iosMap = initIOSOptions().getMap();
    Map androidMap = initAndroidOptions().getMap();

    _suc = await _myLocPlugin.prepareLoc(androidMap, iosMap);
    debugPrint('设置定位参数：$iosMap');
  }

  /// 设置地图参数
  BaiduLocationAndroidOption initAndroidOptions() {
    BaiduLocationAndroidOption options = BaiduLocationAndroidOption(
        coorType: 'bd09ll',
        locationMode: BMFLocationMode.hightAccuracy,
        isNeedAddress: true,
        isNeedAltitude: true,
        isNeedLocationPoiList: true,
        isNeedNewVersionRgc: true,
        isNeedLocationDescribe: true,
        openGps: true,
        locationPurpose: BMFLocationPurpose.sport,
        coordType: BMFLocationCoordType.bd09ll);
    return options;
  }

  BaiduLocationIOSOption initIOSOptions() {
    BaiduLocationIOSOption options = BaiduLocationIOSOption(
        coordType: BMFLocationCoordType.bd09ll,
        BMKLocationCoordinateType: 'BMKLocationCoordinateTypeBMK09LL',
        desiredAccuracy: BMFDesiredAccuracy.best);
    return options;
  }

  /// 启动定位
  Future<void> _startLocation() async {
    if (Platform.isIOS) {
      _suc = await _myLocPlugin
          .singleLocation({'isReGeocode': true, 'isNetworkState': true});
      debugPrint('开始单次定位：$_suc');
    } else if (Platform.isAndroid) {
      _suc = await _myLocPlugin.startLocation();
    }
  }

  // 动态申请定位权限
  void requestPermission() async {
    // 申请权限
    bool hasLocationPermission = await requestLocationPermission();
    if (hasLocationPermission) {
      // 权限申请通过
    } else {}
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.location.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.location.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("定位"),
      ),
      body: bodyView(context),
    );
  }

  Widget bodyView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            OutlinedButton(
                onPressed: () {
                  ///设置定位参数
                  _locationAction();
                  _startLocation();
                },
                child: Text("获取")),
            SizedBox(
              height: 10,
            ),
            Text(_locationStr)
          ],
        ),
      ),
    );
  }
}
