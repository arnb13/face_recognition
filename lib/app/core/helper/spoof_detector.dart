import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Passive (single-frame) texture/CNN anti-spoofing detector.
///
/// This is integration scaffolding: it loads a TFLite classifier that scores a
/// face crop as live vs. spoof (print / screen-replay / mask) from one frame,
/// with no user action. Drop a trained model at [modelAsset] to activate it.
///
/// ── Bring your own model ───────────────────────────────────────────────────
/// No model is bundled. A good open option is a MiniFASNet from the
/// "Silent-Face-Anti-Spoofing" project converted to `.tflite`. After adding the
/// file at `asset/antispoof.tflite`, review the constants below — input size,
/// normalization, output layout and the "live" class index all depend on the
/// specific model you ship. The defaults match a common 80×80 / 3-class
/// (print, live, replay) MiniFASNet export.
///
/// The detector fails *open*: if the model is missing or inference throws,
/// [liveProbability] returns `null` and the caller skips the spoof gate so the
/// app keeps working. Tighten this to fail-closed once you trust your model.
class SpoofDetector {
  /// Where the model is loaded from. The `asset/` folder is already declared in
  /// pubspec.yaml, so simply placing the file here ships it.
  static const String modelAsset = 'asset/antispoof.tflite';

  // ─── Model-specific knobs — ADJUST to match your exported model ───────────

  /// Square input resolution the model expects (MiniFASNet = 80).
  static const int inputSize = 80;

  /// How much to expand the face box (about its centre) before cropping, so
  /// the model also sees bezels/paper edges — strong spoof cues. 1.0 = tight.
  static const double cropScale = 2.7;

  /// Number of output classes (2 = live/spoof, 3 = print/live/replay).
  static const int numClasses = 3;

  /// Index of the "live/real" class within the output vector.
  static const int liveIndex = 1;

  /// Whether to apply softmax to the raw outputs before reading [liveIndex].
  /// Set false if your model already outputs probabilities.
  static const bool applySoftmax = true;

  /// Per-channel input normalization: `value = pixel / 255 * scale - shift`.
  /// Defaults give the [0,1] range. For [-1,1] use scale 2, shift 1.
  static const double normScale = 1.0;
  static const double normShift = 0.0;

  Interpreter? _interpreter;
  bool _loaded = false;
  String? loadError;

  bool get isAvailable => _loaded;

  /// Attempts to load the model. Never throws — inspect [isAvailable] /
  /// [loadError] afterwards.
  Future<void> load() async {
    try {
      _interpreter = await Interpreter.fromAsset(modelAsset);
      _loaded = true;
      loadError = null;
    } catch (e) {
      _loaded = false;
      loadError = e.toString();
    }
  }

  /// Returns the model's estimated probability the face is a live person, in
  /// `[0, 1]`. Returns `null` when the model is unavailable or inference fails,
  /// signalling the caller to skip the spoof gate.
  ///
  /// [frame] is the upright RGB frame; [faceBox] is the ML Kit face rectangle
  /// in that frame's coordinate space.
  double? liveProbability(img.Image frame, Rect faceBox) {
    final interpreter = _interpreter;
    if (interpreter == null || !_loaded) return null;
    try {
      final img.Image crop = _marginCrop(frame, faceBox, cropScale);
      final img.Image resized =
          img.copyResize(crop, width: inputSize, height: inputSize);

      final input = _toInputTensor(resized);
      final output =
          List.generate(1, (_) => List.filled(numClasses, 0.0));
      interpreter.run(input, output);

      final scores = applySoftmax ? _softmax(output[0]) : output[0];
      final idx = liveIndex.clamp(0, scores.length - 1);
      return scores[idx].toDouble();
    } catch (_) {
      return null;
    }
  }

  /// Crops [box] expanded by [scale] about its centre, clamped to [frame].
  img.Image _marginCrop(img.Image frame, Rect box, double scale) {
    final double cx = box.left + box.width / 2;
    final double cy = box.top + box.height / 2;
    final double side = max(box.width, box.height) * scale;

    final int x = (cx - side / 2).round().clamp(0, frame.width - 1);
    final int y = (cy - side / 2).round().clamp(0, frame.height - 1);
    final int w = side.round().clamp(1, frame.width - x);
    final int h = side.round().clamp(1, frame.height - y);

    return img.copyCrop(frame, x: x, y: y, width: w, height: h);
  }

  /// Builds the `[1, inputSize, inputSize, 3]` float input tensor (NHWC).
  Object _toInputTensor(img.Image image) {
    final buffer = Float32List(1 * inputSize * inputSize * 3);
    int i = 0;
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final p = image.getPixel(x, y);
        buffer[i++] = p.r / 255.0 * normScale - normShift;
        buffer[i++] = p.g / 255.0 * normScale - normShift;
        buffer[i++] = p.b / 255.0 * normScale - normShift;
      }
    }
    return buffer.reshape([1, inputSize, inputSize, 3]);
  }

  List<double> _softmax(List<double> logits) {
    final double m = logits.reduce(max);
    double sum = 0;
    final exps = List<double>.filled(logits.length, 0);
    for (int i = 0; i < logits.length; i++) {
      exps[i] = exp(logits[i] - m);
      sum += exps[i];
    }
    if (sum == 0) return logits;
    for (int i = 0; i < exps.length; i++) {
      exps[i] /= sum;
    }
    return exps;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loaded = false;
  }
}
