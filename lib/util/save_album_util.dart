import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;

import 'image_util.dart';

// 保存到相册的UTil
class SaveToAlbumUtil {
  static Future<dynamic> saveLocalImageData(Uint8List? bytes) async {
    if (bytes != null) {
      final result = await ImageGallerySaver.saveImage(bytes, quality: 100);
      print("SaveToAlbumUtil result:${result}");
      return result;
    } else {
      throw StateError("saveLocalImage error");
    }
  }

  static Future<dynamic> saveLocalImage(String imagePath) async {
    var image = await ImageUtil.loadImageByFile(imagePath);
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result = await ImageGallerySaver.saveImage(
          byteData.buffer.asUint8List(),
          quality: 100);
      print("SaveToAlbumUtil result:${result}");
      return result;
    } else {
      throw StateError("saveLocalImage error imagePath:${imagePath}");
    }
  }

  static void saveNetworkImage(String imageUrl) async {
    var response = await Dio()
        .get(imageUrl, options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "hello");
    print(result);
  }
}
