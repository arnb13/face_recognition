import 'package:face_recognition_engine/face_recognition_engine.dart'
    show RecognitionConfig;
import 'package:shared_value/shared_value.dart';

/// Centralised, user-tweakable configuration for face recognition and the
/// liveness / anti-spoofing checks. Every value is persisted with
/// [SharedValue] (same mechanism as the enrolled face templates) so changes made on the
/// config page survive app restarts.
///
/// Defaults are sourced from the face_recognition_engine package's
/// [RecognitionConfig] so the app and the package never drift apart. The live
/// config values below are seeded with those defaults and overwritten from disk
/// by [loadRecognitionConfig].
class RecognitionDefaults {
  RecognitionDefaults._();

  /// Single source of truth: the package's compile-time defaults.
  static const RecognitionConfig _pkg = RecognitionConfig();

  // Recognition
  static double get matchThreshold => _pkg.matchThreshold;

  // Enrollment (guided multi-angle capture)
  static int get enrollSamples => _pkg.enrollSamples;
  static double get minFaceWidthFraction => _pkg.minFaceWidthFraction;

  // Liveness / anti-spoofing
  static bool get livenessEnabled => _pkg.livenessEnabled;
  static bool get randomizeLiveness => _pkg.randomizeLiveness;
  static bool get requireBlink => _pkg.requireBlink;
  static bool get requireHeadTurn => _pkg.requireHeadTurn;
  static bool get requireSmile => _pkg.requireSmile;
  static double get eyeClosedThreshold => _pkg.eyeClosedThreshold;
  static double get eyeOpenThreshold => _pkg.eyeOpenThreshold;
  static double get headTurnThreshold => _pkg.headTurnThreshold;
  static double get smileThreshold => _pkg.smileThreshold;
  static int get livenessTimeoutSec => _pkg.livenessTimeoutSec;

  // Passive (texture/CNN) anti-spoofing
  static bool get passiveSpoofEnabled => _pkg.passiveSpoofEnabled;
  static double get spoofLiveThreshold => _pkg.spoofLiveThreshold;
}

// ---- Persisted, live configuration values ---------------------------------

final SharedValue<double> cfgMatchThreshold = SharedValue(
  value: RecognitionDefaults.matchThreshold,
  key: 'cfgMatchThreshold',
);

final SharedValue<int> cfgEnrollSamples = SharedValue(
  value: RecognitionDefaults.enrollSamples,
  key: 'cfgEnrollSamples',
);

final SharedValue<double> cfgMinFaceWidthFraction = SharedValue(
  value: RecognitionDefaults.minFaceWidthFraction,
  key: 'cfgMinFaceWidthFraction',
);

final SharedValue<bool> cfgLivenessEnabled = SharedValue(
  value: RecognitionDefaults.livenessEnabled,
  key: 'cfgLivenessEnabled',
);

final SharedValue<bool> cfgRandomizeLiveness = SharedValue(
  value: RecognitionDefaults.randomizeLiveness,
  key: 'cfgRandomizeLiveness',
);

final SharedValue<bool> cfgRequireBlink = SharedValue(
  value: RecognitionDefaults.requireBlink,
  key: 'cfgRequireBlink',
);

final SharedValue<bool> cfgRequireHeadTurn = SharedValue(
  value: RecognitionDefaults.requireHeadTurn,
  key: 'cfgRequireHeadTurn',
);

final SharedValue<bool> cfgRequireSmile = SharedValue(
  value: RecognitionDefaults.requireSmile,
  key: 'cfgRequireSmile',
);

final SharedValue<double> cfgEyeClosedThreshold = SharedValue(
  value: RecognitionDefaults.eyeClosedThreshold,
  key: 'cfgEyeClosedThreshold',
);

final SharedValue<double> cfgEyeOpenThreshold = SharedValue(
  value: RecognitionDefaults.eyeOpenThreshold,
  key: 'cfgEyeOpenThreshold',
);

final SharedValue<double> cfgHeadTurnThreshold = SharedValue(
  value: RecognitionDefaults.headTurnThreshold,
  key: 'cfgHeadTurnThreshold',
);

final SharedValue<double> cfgSmileThreshold = SharedValue(
  value: RecognitionDefaults.smileThreshold,
  key: 'cfgSmileThreshold',
);

final SharedValue<int> cfgLivenessTimeoutSec = SharedValue(
  value: RecognitionDefaults.livenessTimeoutSec,
  key: 'cfgLivenessTimeoutSec',
);

final SharedValue<bool> cfgPassiveSpoofEnabled = SharedValue(
  value: RecognitionDefaults.passiveSpoofEnabled,
  key: 'cfgPassiveSpoofEnabled',
);

final SharedValue<double> cfgSpoofLiveThreshold = SharedValue(
  value: RecognitionDefaults.spoofLiveThreshold,
  key: 'cfgSpoofLiveThreshold',
);

/// All config [SharedValue]s, so callers can load/reset them in one place.
final List<SharedValue> _allConfigValues = [
  cfgMatchThreshold,
  cfgEnrollSamples,
  cfgMinFaceWidthFraction,
  cfgLivenessEnabled,
  cfgRandomizeLiveness,
  cfgRequireBlink,
  cfgRequireHeadTurn,
  cfgRequireSmile,
  cfgEyeClosedThreshold,
  cfgEyeOpenThreshold,
  cfgHeadTurnThreshold,
  cfgSmileThreshold,
  cfgLivenessTimeoutSec,
  cfgPassiveSpoofEnabled,
  cfgSpoofLiveThreshold,
];

/// Loads every persisted config value from disk. Call once at startup before
/// the values are read by the recognition flow.
Future<void> loadRecognitionConfig() async {
  await Future.wait(_allConfigValues.map((v) => v.load()));
}

/// Restores every config value to its compile-time default and persists it.
Future<void> resetRecognitionConfig() async {
  cfgMatchThreshold.$ = RecognitionDefaults.matchThreshold;
  cfgEnrollSamples.$ = RecognitionDefaults.enrollSamples;
  cfgMinFaceWidthFraction.$ = RecognitionDefaults.minFaceWidthFraction;
  cfgLivenessEnabled.$ = RecognitionDefaults.livenessEnabled;
  cfgRandomizeLiveness.$ = RecognitionDefaults.randomizeLiveness;
  cfgRequireBlink.$ = RecognitionDefaults.requireBlink;
  cfgRequireHeadTurn.$ = RecognitionDefaults.requireHeadTurn;
  cfgRequireSmile.$ = RecognitionDefaults.requireSmile;
  cfgEyeClosedThreshold.$ = RecognitionDefaults.eyeClosedThreshold;
  cfgEyeOpenThreshold.$ = RecognitionDefaults.eyeOpenThreshold;
  cfgHeadTurnThreshold.$ = RecognitionDefaults.headTurnThreshold;
  cfgSmileThreshold.$ = RecognitionDefaults.smileThreshold;
  cfgLivenessTimeoutSec.$ = RecognitionDefaults.livenessTimeoutSec;
  cfgPassiveSpoofEnabled.$ = RecognitionDefaults.passiveSpoofEnabled;
  cfgSpoofLiveThreshold.$ = RecognitionDefaults.spoofLiveThreshold;
  await Future.wait(_allConfigValues.map((v) => v.save()));
}

/// Snapshots the current persisted [SharedValue] config into an immutable
/// [RecognitionConfig] for the face_recognition_engine package's camera flows
/// (`FaceRecognitionKit.enroll` / `.detect`). Call after [loadRecognitionConfig].
RecognitionConfig currentRecognitionConfig() => RecognitionConfig(
      matchThreshold: cfgMatchThreshold.$,
      enrollSamples: cfgEnrollSamples.$,
      minFaceWidthFraction: cfgMinFaceWidthFraction.$,
      livenessEnabled: cfgLivenessEnabled.$,
      randomizeLiveness: cfgRandomizeLiveness.$,
      requireBlink: cfgRequireBlink.$,
      requireHeadTurn: cfgRequireHeadTurn.$,
      requireSmile: cfgRequireSmile.$,
      eyeClosedThreshold: cfgEyeClosedThreshold.$,
      eyeOpenThreshold: cfgEyeOpenThreshold.$,
      headTurnThreshold: cfgHeadTurnThreshold.$,
      smileThreshold: cfgSmileThreshold.$,
      livenessTimeoutSec: cfgLivenessTimeoutSec.$,
      passiveSpoofEnabled: cfgPassiveSpoofEnabled.$,
      spoofLiveThreshold: cfgSpoofLiveThreshold.$,
    );
