import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_app02/config/application.dart';
import '../utils/icon.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:aliyun_push/aliyun_push.dart';

void main() {
  developer.log('log me', name: 'my.app.category');

  developer.log('log me 1', name: 'my.other.category');
  developer.log('log me 2', name: 'my.other.category');
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex = 0;
  late final List<Widget> _pageList = [
    Container(
      color: Colors.blueGrey,
      alignment: Alignment.center,
      child: TextButton(
        child: const Text('点击定位'),
        onPressed: () {
          // developer.log('发出请求');
          // DioUtil().request('j/puppy/frodo_landing?include=anony_home',
          //     method: DioMethod.get);
          Navigator.of(context).pushNamed('/location');
        },
      ),
    ),
    Container(
      color: Colors.lightGreen,
      alignment: Alignment.center,
      child: TextButton(
        child: const Text('点击请求'),
        onPressed: () {
          // DioUtil().request('j/puppy/frodo_landing?include=anony_home',
          //     method: DioMethod.get);
          Navigator.of(context).pushNamed('/my');
        },
      ),
    ),
    Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: TextButton(
          child: const Text('点击拍照'),
          onPressed: () async {
            try {
              ApplicationConfig.cameras = await availableCameras();
            } on CameraException catch (e) {
              _logError(e.code, e.description);
            }
            if (mounted) {
              Navigator.of(context).pushNamed('/camera');
            }
          },
        ))
  ];
  @override
  void initState() {
    super.initState();
    initAliPush();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true,
      ),
      body: SafeArea(child: _pageList[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(IconFonts.warn), label: '通知'),
            BottomNavigationBarItem(icon: Icon(IconFonts.home), label: '首页'),
            BottomNavigationBarItem(icon: Icon(IconFonts.check), label: '审核')
          ]),
    );
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void initAliPush() {
    String appKey;
    String appSecret;
    if (Platform.isIOS) {
      appKey = "333889013";
      appSecret = "18e31cabaa2745a3a3f31352f4ba296e";
    } else {
      appKey = "";
      appSecret = "";
    }

    AliyunPush aliyunPush = AliyunPush();
    if (Platform.isAndroid) {
      aliyunPush.setAndroidLogLevel(2);
    }

    aliyunPush
        .initPush(appKey: appKey, appSecret: appSecret)
        .then((initResult) {
      var code = initResult['code'];
      if (code == kAliyunPushSuccessCode) {
        debugPrint('Init Aliyun Push successfully');
      } else {
        String errorMsg = initResult['errorMsg'];
        debugPrint('Aliyun Push init failed, errorMsg is: $errorMsg');
      }
      aliyunPush.getDeviceId().then((value) => {debugPrint('设备Id: $value')});
    });
    if (Platform.isAndroid) {
      aliyunPush.initAndroidThirdPush().then((initResult) {
        var code = initResult['code'];
        var errorMsg = initResult['errorMsg'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint("Init Aliyun Third Push successfully");
        } else {
          debugPrint('Aliyun Third Push init failed, errorMsg is: $errorMsg');
        }
      });
      aliyunPush
          .createAndroidChannel("channel-a", '通道A', 3, '测试创建通知通道')
          .then((createResult) {
        var code = createResult['code'];
        if (code == kAliyunPushSuccessCode) {
          debugPrint('通道创建成功');
        } else {
          var errorCode = createResult['code'];
          var errorMsg = createResult['errorMsg'];
          debugPrint('通道创建失败：$errorMsg');
        }
      });
    }
    aliyunPush.addMessageReceiver(
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
        Fluttertoast.showToast(
            msg: "onNotificationOpened: ${message.toString()}");
        return Future.value(true);
      },
      onNotificationRemoved: (message) {
        debugPrint("onNotificationRemoved: ${message.toString()}");
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
  }
}
