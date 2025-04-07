/* import 'package:setti/src/setti_config.dart';
import 'package:setti/src/setting_types/base/setting.dart';
import 'package:setti/src/storage/interfaces/storage_worker_interface.dart';
import 'package:setti/src/storage/storage_overlay.dart';

class SettingsMigrator {
  final StorageOverlay sourceStorage;

  SettingsMigrator(this.sourceStorage);

  List<String> _tokenize(String rs, Delimiter separator) {
    return rs.split(separator.delimiter);
  }

  StorageOverlay configure

  Future<void> migrateSnapshot({
    required String snapshotId,
    required String oldPrefix,
    required String newPrefix,
    required Delimiter oldDelimiter,
    required Delimiter newDelimiter,
    CaseFormat newCaseFormat = CaseFormat.preserve,
  }) async {
    final snapshot = await storage.getSetting(snapshotId, []);

    if (snapshot != null) {
      Map<String, List<String>> splitSnapshot = {};

      for (String id in snapshot) {
        final tokenizedId = _tokenize(id, oldDelimiter);
        tokenizedId.map((id) => newCaseFormat.apply(id));
        splitSnapshot[tokenizedId.last] = _tokenize(id, oldDelimiter);
      }

      final updatedSnapshot =
          snapshot.map((id) => id.replaceFirst(oldPrefix, newPrefix)).toList();

      await storage.setSetting(
          newCaseFormat.apply(snapshotId), updatedSnapshot);
    }
  }

  Future<void> migrateIds({
    required List<Setting> oldSettings,
    required String oldPrefix,
    required String newPrefix,
  }) async {
    for (final setting in oldSettings) {
      if (setting.id.startsWith(oldPrefix)) {
        final value =
            await storage.getSetting(setting.id, setting.defaultValue);
        if (value != null) {
          final newId = setting.id.replaceFirst(oldPrefix, newPrefix);
          await storage.setSetting(newId, value);
          await storage.removeSetting(
              setting.id); // Видаляємо старі ключі, якщо потрібно
        }
      }
    }
  }
}
 */
