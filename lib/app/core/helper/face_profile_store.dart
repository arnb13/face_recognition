import 'dart:convert';
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:shared_value/shared_value.dart';

import 'face_recognition_util.dart';

/// One enrolled person: a name, a saved face photo and one or more angle
/// embeddings ("templates") used for matching.
class FaceProfile {
  final String id;
  final String name;

  /// Absolute path to the saved JPEG face photo (may be empty).
  final String photoPath;

  /// Multi-angle embeddings for this person.
  final List<List<double>> templates;

  const FaceProfile({
    required this.id,
    required this.name,
    required this.photoPath,
    required this.templates,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoPath': photoPath,
        'templates': templates,
      };

  factory FaceProfile.fromJson(Map<String, dynamic> json) {
    final rawTemplates = (json['templates'] as List?) ?? const [];
    return FaceProfile(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Unknown',
      photoPath: (json['photoPath'] as String?) ?? '',
      templates: rawTemplates
          .map<List<double>>((e) =>
              (e as List).map<double>((n) => (n as num).toDouble()).toList())
          .toList(),
    );
  }
}

/// Persisted store of enrolled [FaceProfile]s. Saved as a JSON string (rather
/// than a typed `SharedValue`) because the package's `deserialize` would throw
/// on nested typed lists. Photos are written to the app documents directory and
/// referenced by path.
final SharedValue<String> faceProfilesRaw = SharedValue(
  value: '',
  key: 'faceProfiles',
);

class FaceProfileStore {
  FaceProfileStore._();

  /// Upper bound on stored templates per person, so repeated re-enrollment
  /// doesn't grow a profile without limit. Oldest templates are dropped first.
  static const int maxTemplatesPerProfile = 12;

  /// Loads persisted profiles into memory. Call once at startup.
  static Future<void> load() => faceProfilesRaw.load();

  /// All enrolled people. Empty when nothing is enrolled or unreadable.
  static List<FaceProfile> get all {
    final raw = faceProfilesRaw.$;
    if (raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => FaceProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static bool get isEmpty => all.isEmpty;

  static int get count => all.length;

  /// Appends [profile] and persists.
  static Future<void> add(FaceProfile profile) async {
    final list = all..add(profile);
    await _persist(list);
  }

  /// Replaces the profile with the same id (or appends if not found) and
  /// persists.
  static Future<void> update(FaceProfile profile) async {
    final list = all;
    final idx = list.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      list[idx] = profile;
    } else {
      list.add(profile);
    }
    await _persist(list);
  }

  /// Returns the already-enrolled person whose closest template matches any of
  /// [probes] at or above [threshold] (the best such match), or null if this is
  /// a new face. Used to detect re-enrollment of the same person.
  static FaceProfile? findDuplicate(
    List<List<double>> probes,
    double threshold,
  ) {
    FaceProfile? best;
    double bestSim = -1;
    for (final profile in all) {
      for (final probe in probes) {
        final s =
            FaceRecognitionUtil.bestSimilarity(probe, profile.templates);
        if (s > bestSim) {
          bestSim = s;
          best = profile;
        }
      }
    }
    return (best != null && bestSim >= threshold) ? best : null;
  }

  /// Merges [newTemplates] (and optionally a new [photoPath]) into [existing],
  /// capping the template count, persists, and returns the updated profile.
  static Future<FaceProfile> mergeInto(
    FaceProfile existing, {
    required List<List<double>> newTemplates,
    String? photoPath,
  }) async {
    final merged = [...existing.templates, ...newTemplates];
    final capped = merged.length > maxTemplatesPerProfile
        ? merged.sublist(merged.length - maxTemplatesPerProfile)
        : merged;
    final updated = FaceProfile(
      id: existing.id,
      name: existing.name,
      photoPath: photoPath ?? existing.photoPath,
      templates: capped,
    );
    await update(updated);
    return updated;
  }

  /// Removes the profile with [id] (and deletes its photo file) and persists.
  static Future<void> removeById(String id) async {
    final list = all;
    final removed = list.where((p) => p.id == id).toList();
    list.removeWhere((p) => p.id == id);
    for (final p in removed) {
      _deletePhoto(p.photoPath);
    }
    await _persist(list);
  }

  /// Removes every profile (and their photos) and persists the empty state.
  static Future<void> clear() async {
    for (final p in all) {
      _deletePhoto(p.photoPath);
    }
    faceProfilesRaw.$ = '';
    await faceProfilesRaw.save();
  }

  static Future<void> _persist(List<FaceProfile> list) async {
    faceProfilesRaw.$ = jsonEncode(list.map((p) => p.toJson()).toList());
    await faceProfilesRaw.save();
  }

  static void _deletePhoto(String path) {
    if (path.isEmpty) return;
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  /// Saves [image] as a JPEG under the app's documents `faces/` folder and
  /// returns the absolute path.
  static Future<String> savePhoto(img.Image image, String id) async {
    final dir = await getApplicationDocumentsDirectory();
    final facesDir = Directory('${dir.path}/faces');
    if (!facesDir.existsSync()) facesDir.createSync(recursive: true);
    final path = '${facesDir.path}/$id.jpg';
    File(path).writeAsBytesSync(img.encodeJpg(image, quality: 90));
    return path;
  }
}
