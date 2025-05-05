import 'dart:async';

abstract interface class ISettingsWorker {
  FutureOr<T?> getSetting<T>(String id, T defaultValue);
  FutureOr<bool> setSetting(String id, Object value);
  FutureOr<void> setSettings(Map<String, Object> settings);
  FutureOr<bool> removeSetting(String id);
  FutureOr<void> removeSettings(Set<String> keys);
  FutureOr<void> clear();
  FutureOr<bool> contains(String id);
}
