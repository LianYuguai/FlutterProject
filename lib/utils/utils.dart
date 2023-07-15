import 'dart:async';

/// 函数防抖
///
/// [func]: 要执行的方法
/// [delay]: 要迟延的时长
void Function()? debounce(
  Function func, [
  Duration delay = const Duration(milliseconds: 2000),
]) {
  Timer? timer;
  void target() {
    if (timer != null && timer?.isActive == true) {
      timer?.cancel();
    }
    timer = Timer(delay, () {
      func.call();
    });
  }

  return target;
}
