import 'package:shared_value/shared_value.dart';

/// Centralised, user-tweakable configuration for face recognition and the
/// liveness / anti-spoofing checks. Every value is persisted with
/// [SharedValue] (same mechanism as the enrolled face templates) so changes made on the
/// config page survive app restarts.
///
/// Defaults live in [RecognitionDefaults]; the live config values below are
/// seeded with those defaults and overwritten from disk by
/// [loadRecognitionConfig].
class RecognitionDefaults {
  RecognitionDefaults._();

  // Recognition
  static const double matchThreshold = 0.8;

  // Enrollment (guided multi-angle capture)
  /// Number of angle samples to capture during guided enrollment. Defaults to
  /// 3 (front, right, left) which rely only on yaw (`headEulerAngleY`) and are
  /// available on all devices; samples 4-5 add up/down, which need pitch
  /// (`headEulerAngleX`) support.
  static const int enrollSamples = 3;

  /// Minimum face width as a fraction of the frame width, used as a quality
  /// gate so distant/tiny faces are not captured or matched.
  static const double minFaceWidthFraction = 0.18;

  // Liveness / anti-spoofing
  static const bool livenessEnabled = true;

  /// When true, one challenge is chosen at random per attempt from the enabled
  /// pool (instead of requiring all enabled challenges).
  static const bool randomizeLiveness = true;

  static const bool requireBlink = true;
  static const bool requireHeadTurn = false;
  static const bool requireSmile = true;

  /// `eyeOpenProbability` at or below this counts the eye as closed.
  static const double eyeClosedThreshold = 0.35;

  /// `eyeOpenProbability` at or above this counts the eye as open.
  static const double eyeOpenThreshold = 0.65;

  /// Absolute head yaw (`headEulerAngleY`, degrees) needed for a head turn.
  static const double headTurnThreshold = 20.0;

  /// `smilingProbability` at or above this counts as a smile.
  static const double smileThreshold = 0.7;

  /// Seconds allowed to complete all liveness challenges before failing.
  static const int livenessTimeoutSec = 20;

  // Passive (texture/CNN) anti-spoofing
  /// Off by default: requires a trained model at `asset/antispoof.tflite`
  /// (see `SpoofDetector`) to be present.
  static const bool passiveSpoofEnabled = false;

  /// Minimum P(live) from the texture model to accept the frame as a real
  /// face. Higher = stricter.
  static const double spoofLiveThreshold = 0.5;
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
