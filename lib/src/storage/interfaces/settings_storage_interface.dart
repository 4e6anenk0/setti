import 'dart:async';

import 'storage_worker_interface.dart';

abstract class ISettingsStorage implements ISettingsWorker {
  FutureOr<bool> init();

  /// Sets multiple settings in a single operation.
  /// Implementations that do not support batch operations should override
  /// this to call [setSetting] for each entry.
  Future<void> setSettings(Map<String, dynamic> settings) async {
    for (var entry in settings.entries) {
      await setSetting(entry.key, entry.value);
    }
  }

  Future<void> removeSettings(Set<String> keys) async {
    for (var key in keys) {
      await removeSetting(key);
    }
  }

  String get id;
}
