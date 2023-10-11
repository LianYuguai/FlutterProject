import 'package:flutter/material.dart';
import '../views/camera/camera.dart';
// import '../views/location/location.dart';
import '../views/location/location_hw.dart';
import '../views/my.dart';
// import '../views/camera/camera_example.dart';

final Map<String, WidgetBuilder> routers = {
  '/my': (context) => const MyHomePage(title: '123'),
  '/camera': (context) => const CameraPage(),
  '/location': (context) => const LocationPage()
};
