import 'package:flutter/material.dart';
// import '../views/home.dart';
import '../views/my.dart';

final Map<String, WidgetBuilder> routers = {
  '/my': (context) => const MyHomePage(title: '123')
};
