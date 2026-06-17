import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:face_recognition/app/core/style/app_colors.dart';
import '../controllers/config_controller.dart';

/// Single place to tweak every recognition and anti-spoofing / liveness
/// setting. Values are applied live on the next recognition session.
class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        title: const Text(
          'Recognition Settings',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
            ),
            icon: const Icon(Icons.restart_alt, size: 20),
            label: const Text('Defaults'),
            onPressed: () async {
              await controller.resetToDefaults();
              Get.snackbar(
                'Defaults restored',
                'All settings were reset to their default values. '
                    'Tap Save to keep them.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(12),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _sectionTitle('Recognition'),
            _sliderTile(
              label: 'Match threshold',
              help: 'Minimum cosine similarity to accept an identity. '
                  'Higher = stricter, fewer false matches.',
              value: controller.matchThreshold.value,
              min: 0.3,
              max: 0.99,
              divisions: 69,
              display: _pct(controller.matchThreshold.value),
              onChanged: (v) => controller.matchThreshold.value = v,
            ),

            const SizedBox(height: 8),
            _sectionTitle('Enrollment'),
            _sliderTile(
              label: 'Angle samples',
              help: 'How many head angles to capture during guided enrollment '
                  '(1-3 use left/right turns; 4-5 add up/down, which need '
                  'device pitch support). More angles = more robust, but '
                  'slower to enroll.',
              value: controller.enrollSamples.value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              display: '${controller.enrollSamples.value}',
              onChanged: (v) => controller.enrollSamples.value = v.round(),
            ),
            _sliderTile(
              label: 'Min face size',
              help: 'Minimum face width as a fraction of the frame. Faces '
                  'smaller than this are ignored when enrolling and matching.',
              value: controller.minFaceWidthFraction.value,
              min: 0.05,
              max: 0.5,
              divisions: 45,
              display: _pct(controller.minFaceWidthFraction.value),
              onChanged: (v) => controller.minFaceWidthFraction.value = v,
            ),

            const SizedBox(height: 8),
            _sectionTitle('Anti-spoofing / Liveness'),
            _switchTile(
              label: 'Enable liveness check',
              help: 'Require proof of a live person before accepting a match. '
                  'Defeats printed-photo and most replay attacks.',
              value: controller.livenessEnabled.value,
              onChanged: (v) => controller.livenessEnabled.value = v,
            ),

            // Challenge toggles + their thresholds are only relevant when
            // liveness is enabled.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: controller.livenessEnabled.value ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !controller.livenessEnabled.value,
                child: Column(
                  children: [
                    _switchTile(
                      label: 'Randomize challenge',
                      help: 'Ask for one random challenge per attempt (from the '
                          'enabled ones below) so an attacker cannot pre-record '
                          'the expected action. Turn off to require all enabled '
                          'challenges every time.',
                      value: controller.randomizeLiveness.value,
                      onChanged: (v) => controller.randomizeLiveness.value = v,
                    ),
                    _switchTile(
                      label: 'Allow blink',
                      help: 'Include blink in the challenge pool. '
                          'A static photo cannot blink.',
                      value: controller.requireBlink.value,
                      onChanged: (v) => controller.requireBlink.value = v,
                    ),
                    if (controller.requireBlink.value) ...[
                      _sliderTile(
                        label: 'Eye-closed threshold',
                        help: 'Eye-open probability at or below this counts '
                            'as closed.',
                        value: controller.eyeClosedThreshold.value,
                        min: 0.05,
                        max: 0.6,
                        divisions: 55,
                        display: _num(controller.eyeClosedThreshold.value),
                        onChanged: (v) =>
                            controller.eyeClosedThreshold.value = v,
                      ),
                      _sliderTile(
                        label: 'Eye-open threshold',
                        help: 'Eye-open probability at or above this counts '
                            'as open.',
                        value: controller.eyeOpenThreshold.value,
                        min: 0.4,
                        max: 0.95,
                        divisions: 55,
                        display: _num(controller.eyeOpenThreshold.value),
                        onChanged: (v) =>
                            controller.eyeOpenThreshold.value = v,
                      ),
                    ],
                    _switchTile(
                      label: 'Allow head turn',
                      help: 'Include a left/right head turn in the challenge '
                          'pool.',
                      value: controller.requireHeadTurn.value,
                      onChanged: (v) => controller.requireHeadTurn.value = v,
                    ),
                    if (controller.requireHeadTurn.value)
                      _sliderTile(
                        label: 'Head-turn angle',
                        help: 'Minimum head yaw in degrees to register a turn.',
                        value: controller.headTurnThreshold.value,
                        min: 5,
                        max: 45,
                        divisions: 40,
                        display:
                            '${controller.headTurnThreshold.value.toStringAsFixed(0)}°',
                        onChanged: (v) =>
                            controller.headTurnThreshold.value = v,
                      ),
                    _switchTile(
                      label: 'Allow smile',
                      help: 'Include a smile in the challenge pool.',
                      value: controller.requireSmile.value,
                      onChanged: (v) => controller.requireSmile.value = v,
                    ),
                    if (controller.requireSmile.value)
                      _sliderTile(
                        label: 'Smile threshold',
                        help: 'Smiling probability at or above this counts '
                            'as a smile.',
                        value: controller.smileThreshold.value,
                        min: 0.3,
                        max: 0.95,
                        divisions: 65,
                        display: _num(controller.smileThreshold.value),
                        onChanged: (v) => controller.smileThreshold.value = v,
                      ),
                    _sliderTile(
                      label: 'Liveness timeout',
                      help: 'Seconds allowed to complete all challenges '
                          'before the attempt fails.',
                      value: controller.livenessTimeoutSec.value.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 55,
                      display: '${controller.livenessTimeoutSec.value}s',
                      onChanged: (v) =>
                          controller.livenessTimeoutSec.value = v.round(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            _sectionTitle('Passive anti-spoof (texture model)'),
            _switchTile(
              label: 'Enable passive anti-spoof',
              help: 'Score each frame with a CNN texture model to reject '
                  'photos/screens — no user action needed. Requires a model '
                  'file at asset/antispoof.tflite; if absent, the check is '
                  'skipped and a warning is shown.',
              value: controller.passiveSpoofEnabled.value,
              onChanged: (v) => controller.passiveSpoofEnabled.value = v,
            ),
            if (controller.passiveSpoofEnabled.value)
              _sliderTile(
                label: 'Min live probability',
                help: 'Minimum model-estimated probability the face is live '
                    'to accept the frame. Higher = stricter.',
                value: controller.spoofLiveThreshold.value,
                min: 0.1,
                max: 0.95,
                divisions: 85,
                display: _pct(controller.spoofLiveThreshold.value),
                onChanged: (v) => controller.spoofLiveThreshold.value = v,
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Save settings'),
            onPressed: () async {
              await controller.save();
              Get.back();
              Get.snackbar(
                'Settings saved',
                'New settings apply to the next recognition session.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade900,
                icon: const Icon(Icons.check_circle, color: Colors.green),
                margin: const EdgeInsets.all(12),
              );
            },
          ),
        ),
      ),
    );
  }

  static String _pct(double v) => '${(v * 100).toStringAsFixed(0)}%';
  static String _num(double v) => v.toStringAsFixed(2);

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _switchTile({
    required String label,
    required String help,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Switch(
                value: value,
                activeColor: AppColors.primaryColor,
                onChanged: onChanged,
              ),
            ],
          ),
          Text(
            help,
            style: const TextStyle(fontSize: 12, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }

  Widget _sliderTile({
    required String label,
    required String help,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  display,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            help,
            style: const TextStyle(fontSize: 12, color: AppColors.textColor),
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
