import 'dart:io';

import 'package:flutter/material.dart';
import './views/home.dart';
import 'router/routers.dart';
import 'package:aliyun_push/aliyun_push.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  String appKey;
  String appSecret;
  if (Platform.isIOS) {
    appKey = "填写自己iOS项目的appKey";
    appSecret = "填写自己iOS项目的appSecret";
  } else {
    appKey = "";
    appSecret = "";
  }

  AliyunPush _aliyunPush = AliyunPush();

  _aliyunPush.initPush(appKey: appKey, appSecret: appSecret).then((initResult) {
    var code = initResult['code'];
    if (code == kAliyunPushSuccessCode) {
      debugPrint('Init Aliyun Push successfully');
    } else {
      String errorMsg = initResult['errorMsg'];
      debugPrint('Aliyun Push init failed, errorMsg is: $errorMsg');
    }
  });
  _aliyunPush.addMessageReceiver(
    onNotification: (message) {
      debugPrint("onNotification: ${message.toString()}");
      return Future.value(true);
    },
    onMessage: (message) {
      debugPrint("onMessage: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onNotificationOpened: (message) {
      debugPrint("onNotificationOpened: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onNotificationRemoved: (message) {
      debugPrint("onNotificationRemoved: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onAndroidNotificationReceivedInApp: (message) {
      debugPrint("onAndroidNotificationReceivedInApp: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onAndroidNotificationClickedWithNoAction: (message) {
      debugPrint(
          "onAndroidNotificationClickedWithNoAction: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onIOSChannelOpened: (message) {
      debugPrint("onIOSChannelOpened: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onIOSRegisterDeviceTokenSuccess: (message) {
      debugPrint("onIOSRegisterDeviceTokenSuccess: ${message.toString()}");
      ;
      return Future.value(true);
    },
    onIOSRegisterDeviceTokenFailed: (message) {
      debugPrint("onIOSRegisterDeviceTokenFailed: ${message.toString()}");
      ;
      return Future.value(true);
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: routers,
      home: const Home(),
    );
  }
}
