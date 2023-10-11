// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:permission_handler/permission_handler.dart';

const String METHOD_CHANNEL = "com.oseasy.emp_mobile/locationMethodChannel";

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  //1.创建Flutter端的MethodChannel
  final MethodChannel _methodChannel = const MethodChannel(METHOD_CHANNEL);

  final EventChannel _channel =
      const EventChannel("com.oseasy.emp_mobile/locationEventChannel");
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _enableEventReceiver();
    requestPermission();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _disableEventReceiver();
    super.dispose();
  }

  ///定位完成添加mark
  void locationFinish() {}

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

  // 初始化
  void _initLocation() async {
    await _methodChannel.invokeMethod("initLocation");
  }

  // 定位
  void _startLocation() async {
    EasyLoading.show();
    //2.通过invokeMethod调用Native方法，拿到返回值
    var location = await _methodChannel.invokeMethod("requestLocation");
    debugPrint('test debugString=${location.toString()}');
  }

  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen((event) {
      EasyLoading.dismiss();
      debugPrint("receiveBroadcastStream: $event");
      // setState(() {
      //   _orientation = event;
      // });
    });
  }

  void _disableEventReceiver() {
    if (_streamSubscription != null) {
      _streamSubscription?.cancel();
      _streamSubscription = null;
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
      body: FlutterEasyLoading(child: bodyView(context)),
    );
  }

  Widget bodyView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
                onPressed: () {
                  ///设置定位参数
                  _initLocation();
                },
                child: const Text("定位初始化")),
            const SizedBox(
              height: 20,
            ),
            OutlinedButton(
                onPressed: () {
                  ///设置定位参数
                  _startLocation();
                },
                child: const Text("获取定位")),
            const SizedBox(
              height: 10,
            ),
            Text("")
          ],
        ),
      ),
    );
  }
}
