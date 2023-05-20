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
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(60),
      color: Colors.blue,
      child: Container(
        margin: const EdgeInsets.all(20),
        color: Colors.yellow,
        height: 50,
        width: 200,
        // child: Expanded(
        child: ElevatedButton(
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll<double>(0.0),
              foregroundColor:
                  const MaterialStatePropertyAll<Color>(Colors.white),
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return Colors.orange;
              }),
              padding: const MaterialStatePropertyAll(EdgeInsets.all(13.67)),
            ),
            onPressed: () {},
            child: const Text(
              "测试点击",
              style: TextStyle(color: Colors.white, fontSize: 19),
            )),
        // )
      ),
    );
  }
}
