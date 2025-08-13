import 'dart:async';

class SettingEntry<T> {
  const SettingEntry(this.id, this._provider);

  final String id;
  final ISettingsManager _provider;

  FutureOr<void> clear() {
    _provider.clear();
  }

  FutureOr<bool> contains() {
    return _provider.contains(id);
  }

  FutureOr<T?> get() {
    return _provider.get(id);
  }

  FutureOr<void> remove() {
    _provider.remove(id);
  }

  FutureOr<void> reset() {
    _provider.reset(id);
  }

  FutureOr<void> set(T value) {
    _provider.set(id, value);
  }
}
