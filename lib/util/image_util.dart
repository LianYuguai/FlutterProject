import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

class ImageUtil {
  //通过 文件读取Image
  static Future<ui.Image> loadImageByFile(String path) async {
    var list = await File(path).readAsBytes();
    return loadImageByUint8List(list);
  }

//通过[Uint8List]获取图片,默认宽高[width][height]
  static Future<ui.Image> loadImageByUint8List(Uint8List list) async {
    ui.Codec codec = await ui.instantiateImageCodec(list);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }
}
