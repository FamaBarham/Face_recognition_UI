import 'package:image/image.dart' as img;
import 'dart:io';

Future<File> cropFace(String srcFilePath, String destFilePath, int x, int y,
    int width, int height) async {
  final bytes = await File(srcFilePath).readAsBytes();
  img.Image? src = img.decodeImage(bytes);

  img.Image destImage = img.copyCrop(src!, x, y, width, height);

  final png = img.encodePng(destImage);
  await File(destFilePath).writeAsBytes(png);

  return File(destFilePath);
}
