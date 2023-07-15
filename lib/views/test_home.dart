import 'package:flutter/material.dart';
import 'package:my_app02/router/routers.dart';
import '../utils/icon.dart';
import '../api/dio_request.dart';
import 'dart:developer' as developer;
import '../utils/utils.dart';

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

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  double keyboradBottomPadding = 0;

  late AnimationController _controller;
  late Animation<EdgeInsets> _paddingAnimation;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(60),
      color: Colors.blue,
      child: Column(
        children: [
          Container(
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
                  padding:
                      const MaterialStatePropertyAll(EdgeInsets.all(13.67)),
                ),
                onPressed: debounce(() {
                  debugPrint('****debounce****');
                  setState(() {
                    // _paddingAnimation = EdgeInsetsTween(
                    //         begin: EdgeInsets.only(top: keyboradBottomPadding),
                    //         end: EdgeInsets.only(
                    //             top: keyboradBottomPadding + 10))
                    //     .animate(_controller);
                    keyboradBottomPadding = keyboradBottomPadding + 10;
                  });
                }, const Duration(milliseconds: 0)),
                child: const Text(
                  "测试点击",
                  style: TextStyle(color: Colors.white, fontSize: 19),
                )),
            // )
          ),
          AnimatedPadding(
            padding: EdgeInsets.only(top: keyboradBottomPadding),
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.yellow,
              height: 400,
              child: Container(
                color: Colors.blueGrey,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50000));
    _paddingAnimation = EdgeInsetsTween(
            begin: const EdgeInsets.only(top: 0),
            end: const EdgeInsets.only(top: 10))
        .animate(_controller);
  }
}
