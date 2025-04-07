import 'dart:async';

abstract interface class ISettingsWorker {
  FutureOr<T?> getSetting<T>(String id, T defaultValue);
  FutureOr<bool> setSetting(String id, Object value);
  FutureOr<bool> removeSetting(String id);
  FutureOr<void> clear();
  FutureOr<bool> contains(String id);
}
