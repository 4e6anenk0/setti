import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';

import '../setting_types/base/setting.dart';
import 'interfaces/storage_worker_interface.dart';
import 'storage.dart';

/// Це абстракція яка дозволяє працювати з з підмножиною створених сховищ налаштувань через префікс
@internal
class StorageOverlay implements ISettingsWorker {
  StorageOverlay({
    required List<Type> storages,
    String? prefix,
    Type? bind,
  }) : _prefix = prefix {
    _setPrefixIfExist();
    _storageWorker = _storage.getWorker(storages);
  }

  /// Поставщик сховищ який є статичним класом який зберігає усі ініціалізовані сховища
  final SettingsStorage _storage = SettingsStorage.getInstance();

  /// Worker сховища який працює з одним або багатьма сховищами за один запит
  late final ISettingsWorker _storageWorker;

  final String? _prefix;

  /// Дамп ключей. Використовується для того, щоб зменшити кількість запитів
  final HashMap<String, String> _keysDump = HashMap();

  /// Обгортка що додає префікс до імені якщо він є
  late String Function(String name) _name;

  /// Якщо переданий префікс то встановлює обгортку `(name) => "$_prefix$name"` яка додаватиме префікс до імені
  void _setPrefixIfExist() {
    if (_prefix == null) {
      _name = (name) => name;
    } else {
      _name = (name) => "$_prefix$name";
    }
  }

  bool isPrefixedKey(String key) {
    print('Key Dump: $_keysDump');
    return _keysDump.containsKey(key);
  }

  bool isNotPrefixedKey(String key) {
    return !isPrefixedKey(key);
  }

  bool isPrefixedValue(String value) {
    return _keysDump.containsValue(value);
  }

  bool isNotPrefixedValue(String value) {
    return !isPrefixedValue(value);
  }

  /// Метод для кешування ідентифікаторів з префіксами.
  ///
  /// Мінімізує кількість створення ідентифікаторів з префіксами
  String prefixed(Setting setting) {
    return _keysDump.putIfAbsent(setting.id, () => _name(setting.id));
  }

  void removeCache() {
    _keysDump.clear();
  }

  void removeCacheFor(String id) {
    _keysDump.remove(id);
  }

  @override
  FutureOr<void> clear() async {
    await _storageWorker.clear();
  }

  @override
  FutureOr<T?> getSetting<T>(String id, T defaultValue) async {
    return await _storageWorker.getSetting(
        _keysDump[id] ?? _name(id), defaultValue);
  }

  @override
  FutureOr<bool> contains(String id) async {
    return await _storageWorker.contains(_keysDump[id] ?? _name(id));
  }

  @override
  FutureOr<bool> removeSetting(String id) async {
    return await _storageWorker.removeSetting(_keysDump[id] ?? _name(id));
  }

  @override
  FutureOr<bool> setSetting(String id, Object value) async {
    return await _storageWorker.setSetting(_keysDump[id] ?? _name(id), value);
  }

  @override
  FutureOr<void> removeSettings(Set<String> keys) async {
    if (keys.isEmpty) return;
    var prefixedKeys = <String>{};
    for (var key in keys) {
      var prefixedKey = _keysDump[key] ??= _name(key);
      prefixedKeys.add(prefixedKey);
    }
    await _storageWorker.removeSettings(prefixedKeys);
  }

  @override
  FutureOr<void> setSettings(Map<String, Object> settings) async {
    if (settings.isEmpty) return;
    var prefixedSettings = <String, Object>{};
    for (var entry in settings.entries) {
      var key = _keysDump[entry.key] ??= _name(entry.key);
      prefixedSettings[key] = entry.value;
    }
    await _storageWorker.setSettings(prefixedSettings);
  }
}
