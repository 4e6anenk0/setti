import 'dart:async';

import 'storage_worker_interface.dart';

abstract class ISettingsStorage implements ISettingsWorker {
  FutureOr<bool> init();

  String get typeId;

  /// Sets multiple settings in a single operation.
  ///
  /// Implementations that support batch operations should override
  /// this method. Otherwise this approach will call [setSetting] for each entry.
  @override
  Future<void> setSettings(Map<String, dynamic> settings) async {
    for (var entry in settings.entries) {
      await setSetting(entry.key, entry.value);
    }
  }

  /// Removes multiple settings in a single operation.
  ///
  /// Implementations that support batch operations should override
  /// this method. Otherwise this approach will call [removeSetting] for each entry.
  @override
  Future<void> removeSettings(Set<String> keys) async {
    for (var key in keys) {
      await removeSetting(key);
    }
  }

  //String get id;
}
