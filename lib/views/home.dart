import 'package:flutter/material.dart';
import 'package:my_app02/router/routers.dart';
import '../utils/icon.dart';
import '../api/dio_request.dart';
import 'dart:developer' as developer;

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
        child: const Text('点击请求'),
        onPressed: () {
          developer.log('发出请求');
          DioUtil().request('j/puppy/frodo_landing?include=anony_home',
              method: DioMethod.get);
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
      color: Colors.yellowAccent,
    )
  ];
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
}
