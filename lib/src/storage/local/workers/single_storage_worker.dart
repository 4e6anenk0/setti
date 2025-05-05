import 'dart:async';

import '../../interfaces/settings_storage_interface.dart';
import '../../interfaces/storage_worker_interface.dart';

class SingleSettingsStorage implements ISettingsWorker {
  SingleSettingsStorage(ISettingsStorage storage) {
    assert(storage.runtimeType != SingleSettingsStorage,
        "Cannot add SingleSettingsStorage to the SingleSettingsStorage.");
    _storage = storage;
  }

  late final ISettingsStorage _storage;

  ISettingsStorage getStorage() {
    return _storage;
  }

  @override
  FutureOr<void> clear() async {
    await _storage.clear();
  }

  @override
  FutureOr<T?> getSetting<T>(String id, T defaultValue) async {
    return await _storage.getSetting(id, defaultValue);
  }

  @override
  FutureOr<bool> contains(String id) async {
    return await _storage.contains(id);
  }

  @override
  FutureOr<bool> removeSetting(String id) async {
    return await _storage.removeSetting(id);
  }

  @override
  FutureOr<bool> setSetting(String id, Object value) async {
    return await _storage.setSetting(id, value);
  }

  @override
  FutureOr<void> removeSettings(Set<String> keys) async {
    await _storage.removeSettings(keys);
  }

  @override
  FutureOr<void> setSettings(Map<String, Object> settings) async {
    await _storage.setSettings(settings);
  }
}
