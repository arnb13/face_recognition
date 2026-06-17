import 'package:get/get.dart';

import 'package:face_recognition/app/core/config/recognition_config.dart';

/// Backs the config page. Holds editable copies of every recognition /
/// liveness setting as GetX observables so the sliders and switches update
/// reactively, then writes them back to the persisted [SharedValue]s on save.
class ConfigController extends GetxController {
  // Recognition
  final matchThreshold = RecognitionDefaults.matchThreshold.obs;

  // Enrollment
  final enrollSamples = RecognitionDefaults.enrollSamples.obs;
  final minFaceWidthFraction = RecognitionDefaults.minFaceWidthFraction.obs;

  // Liveness / anti-spoofing
  final livenessEnabled = RecognitionDefaults.livenessEnabled.obs;
  final randomizeLiveness = RecognitionDefaults.randomizeLiveness.obs;
  final requireBlink = RecognitionDefaults.requireBlink.obs;
  final requireHeadTurn = RecognitionDefaults.requireHeadTurn.obs;
  final requireSmile = RecognitionDefaults.requireSmile.obs;
  final eyeClosedThreshold = RecognitionDefaults.eyeClosedThreshold.obs;
  final eyeOpenThreshold = RecognitionDefaults.eyeOpenThreshold.obs;
  final headTurnThreshold = RecognitionDefaults.headTurnThreshold.obs;
  final smileThreshold = RecognitionDefaults.smileThreshold.obs;
  final livenessTimeoutSec = RecognitionDefaults.livenessTimeoutSec.obs;

  // Passive (texture/CNN) anti-spoofing
  final passiveSpoofEnabled = RecognitionDefaults.passiveSpoofEnabled.obs;
  final spoofLiveThreshold = RecognitionDefaults.spoofLiveThreshold.obs;

  @override
  void onInit() {
    super.onInit();
    _readFromStore();
  }

  /// Seeds the observables from the currently persisted config values.
  void _readFromStore() {
    matchThreshold.value = cfgMatchThreshold.$;
    enrollSamples.value = cfgEnrollSamples.$;
    minFaceWidthFraction.value = cfgMinFaceWidthFraction.$;
    livenessEnabled.value = cfgLivenessEnabled.$;
    randomizeLiveness.value = cfgRandomizeLiveness.$;
    requireBlink.value = cfgRequireBlink.$;
    requireHeadTurn.value = cfgRequireHeadTurn.$;
    requireSmile.value = cfgRequireSmile.$;
    eyeClosedThreshold.value = cfgEyeClosedThreshold.$;
    eyeOpenThreshold.value = cfgEyeOpenThreshold.$;
    headTurnThreshold.value = cfgHeadTurnThreshold.$;
    smileThreshold.value = cfgSmileThreshold.$;
    livenessTimeoutSec.value = cfgLivenessTimeoutSec.$;
    passiveSpoofEnabled.value = cfgPassiveSpoofEnabled.$;
    spoofLiveThreshold.value = cfgSpoofLiveThreshold.$;
  }

  /// Persists the current observable values to disk.
  Future<void> save() async {
    cfgMatchThreshold.$ = matchThreshold.value;
    cfgEnrollSamples.$ = enrollSamples.value;
    cfgMinFaceWidthFraction.$ = minFaceWidthFraction.value;
    cfgLivenessEnabled.$ = livenessEnabled.value;
    cfgRandomizeLiveness.$ = randomizeLiveness.value;
    cfgRequireBlink.$ = requireBlink.value;
    cfgRequireHeadTurn.$ = requireHeadTurn.value;
    cfgRequireSmile.$ = requireSmile.value;
    cfgEyeClosedThreshold.$ = eyeClosedThreshold.value;
    cfgEyeOpenThreshold.$ = eyeOpenThreshold.value;
    cfgHeadTurnThreshold.$ = headTurnThreshold.value;
    cfgSmileThreshold.$ = smileThreshold.value;
    cfgLivenessTimeoutSec.$ = livenessTimeoutSec.value;
    cfgPassiveSpoofEnabled.$ = passiveSpoofEnabled.value;
    cfgSpoofLiveThreshold.$ = spoofLiveThreshold.value;

    await Future.wait([
      cfgMatchThreshold.save(),
      cfgEnrollSamples.save(),
      cfgMinFaceWidthFraction.save(),
      cfgLivenessEnabled.save(),
      cfgRandomizeLiveness.save(),
      cfgRequireBlink.save(),
      cfgRequireHeadTurn.save(),
      cfgRequireSmile.save(),
      cfgEyeClosedThreshold.save(),
      cfgEyeOpenThreshold.save(),
      cfgHeadTurnThreshold.save(),
      cfgSmileThreshold.save(),
      cfgLivenessTimeoutSec.save(),
      cfgPassiveSpoofEnabled.save(),
      cfgSpoofLiveThreshold.save(),
    ]);
  }

  /// Restores defaults, persists them, and refreshes the observables.
  Future<void> resetToDefaults() async {
    await resetRecognitionConfig();
    _readFromStore();
  }
}
