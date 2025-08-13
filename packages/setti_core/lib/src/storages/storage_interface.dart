import 'dart:async';

abstract interface class ISettingsStorage {
  FutureOr<T?> get<T>(String id);
  FutureOr<void> set<T>(String id, T value);
  FutureOr<void> remove<T>(String id);
  FutureOr<void> reset<T>(String id);
  FutureOr<void> clear();
  FutureOr<bool> contains<T>(String id);
}
