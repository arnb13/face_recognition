import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_recognition/app/core/helper/face_profile_store.dart';
import 'package:face_recognition/app/core/style/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Face Recognition',
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() => controller.profiles.isNotEmpty
              ? IconButton(
                  tooltip: 'Clear all',
                  icon: const Icon(Icons.delete_sweep_outlined,
                      color: AppColors.danger),
                  onPressed: () => _confirmClearAll(context),
                )
              : const SizedBox.shrink()),
          IconButton(
            tooltip: 'Recognition settings',
            icon: const Icon(Icons.settings, color: AppColors.primaryColor),
            onPressed: () => Get.toNamed(Routes.CONFIG),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.startEnrollment(),
                  icon: const Icon(Icons.face_retouching_natural),
                  label: const Text('Add Person (Guided)'),
                  style: _fullWidth(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => controller.pickImage(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Quick Enroll (1 photo)'),
                  style: _fullWidth(),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => controller.startLiveRecognition(),
                  icon: const Icon(Icons.videocam),
                  label: const Text('Start Live Recognition'),
                  style: _fullWidth(
                    bg: AppColors.primaryColor,
                    fg: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.surfaceVariant, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Text(
                  'Enrolled People',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                      '${controller.profiles.length}',
                      style: const TextStyle(color: AppColors.textColor),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final people = controller.profiles;
              if (people.isEmpty) {
                return const Center(
                  child: Text(
                    'No one enrolled yet.\nAdd a person to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textColor),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: people.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = people[i];
                  final hasPhoto = p.photoPath.isNotEmpty &&
                      File(p.photoPath).existsSync();
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage:
                            hasPhoto ? FileImage(File(p.photoPath)) : null,
                        child: hasPhoto
                            ? null
                            : const Icon(Icons.person,
                                color: AppColors.textColor),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${p.templates.length} angle'
                        '${p.templates.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppColors.textColor),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger),
                        onPressed: () => _confirmRemove(context, p),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  ButtonStyle _fullWidth({Color? bg, Color? fg}) => ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        minimumSize: const Size.fromHeight(46),
      );

  void _confirmRemove(BuildContext context, FaceProfile profile) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove person'),
        content: Text('Remove ${profile.name} from enrolled people?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeProfile(profile);
            },
            child: const Text('Remove',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear all'),
        content: const Text('Remove all enrolled people?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearAll();
            },
            child: const Text('Clear all',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
