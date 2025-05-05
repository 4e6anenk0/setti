import 'dart:async';

import '../../interfaces/settings_storage_interface.dart';
import '../../interfaces/storage_worker_interface.dart';

class MultiSettingsStorage implements ISettingsWorker {
  MultiSettingsStorage({
    required List<ISettingsStorage> storages,
  }) {
    assert(storages.whereType<MultiSettingsStorage>().isEmpty,
        "Cannot add MultiSettingsStorage to the storages list.");
    _storages = storages;
  }

  late final List<ISettingsStorage> _storages;

  ISettingsStorage getStorage(int id) {
    return _storages[id];
  }

  List<ISettingsStorage> getAllStorages() {
    return _storages;
  }

  @override
  FutureOr<void> clear() async {
    for (ISettingsStorage storage in _storages) {
      await storage.clear();
    }
    //await Future.wait(_storages.map((storage) => storage.clear()));
  }

  @override
  FutureOr<T?> getSetting<T>(String id, T defaultValue) async {
    for (ISettingsStorage storage in _storages) {
      FutureOr<T?> setting = await storage.getSetting(id, defaultValue);
      if (setting != null) {
        return setting;
      }
    }
    return null;
  }

  @override
  FutureOr<bool> contains(String id) async {
    for (ISettingsStorage storage in _storages) {
      if (await storage.contains(id)) {
        return true;
      }
    }
    return false;
  }

  @override
  FutureOr<bool> removeSetting(String id) async {
    for (ISettingsStorage storage in _storages) {
      await storage.removeSetting(id);
    }
    //await Future.wait(_storages.map((storage) => storage.removeSetting(id)));
    return true;
  }

  @override
  FutureOr<bool> setSetting(String id, Object value) async {
    /* await Future.wait(
        _storages.map((storage) => storage.setSetting(id, value))); */

    for (ISettingsStorage storage in _storages) {
      await storage.setSetting(id, value);
    }

    return true;
  }

  @override
  FutureOr<void> removeSettings(Set<String> keys) async {
    for (ISettingsStorage storage in _storages) {
      await storage.removeSettings(keys);
    }
  }

  @override
  FutureOr<void> setSettings(Map<String, Object> settings) async {
    for (ISettingsStorage storage in _storages) {
      await storage.setSettings(settings);
    }
  }
}
