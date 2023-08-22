// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:my_app02/config/application.dart';
// import 'package:my_app02/util/save_album_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/icon.dart';
import 'dart:ui' as ui;

enum TakeStatus { taking, confirm }

final GlobalKey<_CameraPageState> _cameraKey = GlobalKey();

/// Camera example home widget.
class CameraPage extends StatefulWidget {
  /// Default Constructor
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() {
    return _CameraPageState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  TakeStatus _takeStatus = TakeStatus.taking;

  final List<CameraDescription> _cameras = ApplicationConfig.cameras;

  final EventChannel _channel =
      const EventChannel("com.oseasy.emp_mobile/event_channel");
  StreamSubscription? _streamSubscription;
  int _orientation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameraController(_cameras[0]);
    _enableEventReceiver();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableEventReceiver();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // final orientation =
    //     WidgetsBinding.instance.window.physicalSize.aspectRatio > 1
    //         ? Orientation.landscape
    //         : Orientation.portrait;
    debugPrint("didChangeMetrics ******");
    super.didChangeMetrics();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  void _enableEventReceiver() {
    _streamSubscription = _channel.receiveBroadcastStream().listen((event) {
      debugPrint("receiveBroadcastStream: $event");
      setState(() {
        _orientation = event;
      });
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
      body: Container(
        color: Colors.black,
        child: SafeArea(
            child: Column(
          children: <Widget>[
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "取消",
                      style: TextStyle(fontSize: 20),
                    )),
                const SizedBox(
                  height: 64,
                )
              ],
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Center(
                  child: _repaintBoundaryView(),
                ),
              ),
            ),
            _captureControlRowWidget(),
          ],
        )),
      ),
    );
  }

  Widget _repaintBoundaryView() {
    return RepaintBoundary(
      key: _cameraKey,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: _cameraPreviewWidget(),
          ),
          _charactorView()
        ],
      ),
    );
  }

  Widget _charactorView() {
    return Positioned(
        left: rotatedLeft,
        right: rotatedRight,
        top: rotatedTop,
        bottom: rotatedBottom,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Container(
            color: Colors.amber,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "11111111111111111111111",
                  style: TextStyle(color: Colors.white),
                ),
                Text("222222222222222222",
                    style: TextStyle(color: Colors.white)),
                Text("3333333333333333333333333333",
                    style: TextStyle(color: Colors.white))
              ],
            ),
          ),
        ));
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    // if (_takeStatus == TakeStatus.confirm) {
    //   return Image.file(
    //     File(imageFile!.path),
    //     fit: BoxFit.fitWidth,
    //   );
    // } else
    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container(
        color: Colors.black,
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  Widget _captureControlRowWidget() {
    final CameraController? cameraController = controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          iconSize: 80,
          icon: const Icon(
            IconFonts.takePicture,
          ),
          color: Colors.blue,
          onPressed:
              cameraController != null && cameraController.value.isInitialized
                  ? onTakePictureButtonPressed
                  : null,
        ),
      ],
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    debugPrint("_initializeCameraController");
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.max,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        Fluttertoast.showToast(
            msg: 'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          Fluttertoast.showToast(msg: 'You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          Fluttertoast.showToast(
              msg: 'Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          Fluttertoast.showToast(msg: 'Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          Fluttertoast.showToast(msg: 'You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          Fluttertoast.showToast(
              msg: 'Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          Fluttertoast.showToast(msg: 'Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) async {
      if (mounted) {
        // Uint8List? bytes = await file?.readAsBytes();
        setState(() {
          imageFile = file;
          _takeStatus = TakeStatus.confirm;
        });
        _confirm();
        // SaveToAlbumUtil.saveLocalImageData(bytes);
        if (file != null) {
          Fluttertoast.showToast(msg: 'Picture saved to ${file.path}');
        }
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      Fluttertoast.showToast(msg: 'Error: select a camera first.');
      return;
    }

    // if (cameraController.value.isPreviewPaused) {
    //   await cameraController.resumePreview();
    // } else {
    //   await cameraController.pausePreview();
    // }
    await cameraController.pausePreview();
    _confirm();

    if (mounted) {
      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      Fluttertoast.showToast(msg: 'Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    Fluttertoast.showToast(msg: 'Error: ${e.code}\n${e.description}');
  }

  /// 确认, 返回图片路径
  void _confirm() async {
    // if (_takeStatus == TakeStatus.taking) return;
    try {
      RenderRepaintBoundary boundary = _cameraKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image =
          await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? imgBytes = byteData?.buffer.asUint8List();
      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getTemporaryDirectory();
      String? basePath = directory?.path;
      File file =
          File('$basePath/${DateTime.now().millisecondsSinceEpoch}.jpg');
      debugPrint("file path: ${file.path}");
      final originalImage = img.decodeImage(imgBytes!);
      var newImg = img.copyRotate(originalImage!, angle: -90);
      file.writeAsBytesSync(img.encodeJpg(newImg));
    } catch (e) {
      debugPrint("e=====$e");
    }
    controller?.resumePreview();
    // _takeStatus = TakeStatus.taking;
  }

  int get quarterTurns {
    int value;
    switch (_orientation) {
      case 0:
        value = 0;
        break;
      case -90:
        value = 1;
        break;
      case 90:
        value = -1;
        break;
      case 180:
        value = 2;
        break;
      default:
        value = 0;
    }
    return value;
  }

  double? get rotatedLeft {
    double? value;
    switch (_orientation) {
      case 0:
        value = 16;
        break;
      case -90:
        value = 16;
        break;
      case 90:
        value = null;
        break;
      case 180:
        value = null;
        break;
      default:
        value = null;
    }
    return value;
  }

  double? get rotatedRight {
    double? value;
    switch (_orientation) {
      case 0:
        value = null;
        break;
      case -90:
        value = null;
        break;
      case 90:
        value = 16;
        break;
      case 180:
        value = 16;
        break;
      default:
        value = null;
    }
    return value;
  }

  double? get rotatedBottom {
    double? value;
    switch (_orientation) {
      case 0:
        value = 20;
        break;
      case -90:
        value = null;
        break;
      case 90:
        value = 20;
        break;
      case 180:
        value = null;
        break;
      default:
        value = null;
    }
    return value;
  }

  double? get rotatedTop {
    double? value;
    switch (_orientation) {
      case 0:
        value = null;
        break;
      case -90:
        value = 20;
        break;
      case 90:
        value = null;
        break;
      case 180:
        value = 20;
        break;
      default:
        value = null;
    }
    return value;
  }
}
