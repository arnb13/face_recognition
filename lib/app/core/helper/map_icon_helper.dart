import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  final ByteData data = await rootBundle.load(path);
  final Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  final FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
}