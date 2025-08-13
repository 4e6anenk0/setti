import 'dart:async';
import 'dart:collection';

import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';
import 'package:setti_core/src/setting/rules/storage_rules.dart';
import 'package:setti_core/src/setting/types/base.dart';

import 'setting/setting_key.dart';
import 'setting/setting_meta.dart';
import 'setting/setting_value.dart';

/* class SettingEntry<T> {
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
} */

/* mixin Ini on Config {
  @override
  SaveMode get configSaveMode => SaveMode.hybrid;
}

class Config {
  SettingsSession get session => SettingsSession();

  SaveMode get configSaveMode => SaveMode.session;

  final Map<String, SettingEntry> _entries = {};

  SettingEntry<T?> buildSetting<T>(
    String id, {
    T? defaultValue,
    T? exampleValue,
    List<Validator>? validators,
    SaveMode saveMode = SaveMode.session,
    bool declarative = true,
  }) {
    if (session.contains(id)) {
      final entry = _entries[id];
      if (entry != null && entry is SettingEntry<T>) {
        return entry;
      }
      throw StateError('fdf');
    }
    session.add(
      id: id,
      defaultValue: defaultValue,
      exampleValue: exampleValue,
      validators: validators,
      saveMode: saveMode,
      declarative: declarative,
    );
    final entry = SettingEntry<T>(id, session);
    _entries[id] = entry;
    return entry;
  }
} */

/* class SettingsSession implements ISettingsManager {
  final Map<String, CompositeValidator> _validators = {};
  final Map<String, Object?> _values = {};
  final Map<String, bool> _isEnabled = {};
  final Map<String, SettingMeta> _meta = {};

  /// Добавление настройки.
  /// Если [override] = true, существующая настройка будет перезаписана.
  void add<T>({
    required String id,
    required T? defaultValue,
    required T? exampleValue,
    required List<Validator>? validators,
    required SaveMode saveMode,
    required bool declarative,
    bool override = false,
  }) {
    if (!override && _values.containsKey(id)) {
      throw StateError('Setting with id $id already registered.');
    }

    final validator = _createValidator(validators);
    if (validator != null) {
      _validateValue(validator, defaultValue);
      _validators[id] = validator;
    }

    _meta[id] = SettingMeta(
      defaultValue,
      exampleValue,
      saveMode,
      declarative,
      validators,
    );
    _values[id] = defaultValue;
    _isEnabled[id] = true;
  }

  /// Создаёт валидатор, если он есть.
  CompositeValidator? _createValidator<T>(List<Validator>? validators) {
    if (validators != null && validators.isNotEmpty) {
      return AndValidator<T>(validators, ValidationContext.defaultContext());
    }
    return null;
  }

  /// Валидирует значение, выбрасывает StateError при неуспехе.
  void _validateValue(CompositeValidator validator, Object? value) {
    final result = validator.validate(value);
    if (!result.isValid) {
      throw StateError('Validation failed: ${result.toMessageString()}');
    }
  }

  /// Проверка дефолтного значения настройки.
  void validateSetting<T>(BaseSetting<T> setting) {
    final validator = _validators[setting.id] ?? _createValidator(setting);
    if (validator != null) {
      _validateValue(validator, setting.defaultValue);
    }
  }

  CompositeValidator? getValidator(BaseSetting setting) =>
      _validators[setting.id];

  /// Возвращает копию всех значений.
  Map<String, Object?> getAllValues() => Map.unmodifiable(_values);

  int get count => _values.length;

  @override
  T? get<T>(BaseSetting<T?> setting) {
    return (_isEnabled[setting.id] ?? false) ? _values[setting.id] as T? : null;
  }

  @override
  bool contains<T>(String id) => _values.containsKey(id);

  @override
  void set<T>(BaseSetting<T?> setting, T? value) {
    final id = setting.id;
    if (!(_isEnabled[id] ?? false)) return;
    if (_values[id].runtimeType != value.runtimeType) {
      throw StateError('Type is not match');
    }

    final validator = _validators[id];
    if (validator != null) {
      _validateValue(validator, value);
    }
    _values[id] = value;
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    if (_isEnabled[setting.id] ?? false) {
      _values[setting.id] = setting.defaultValue;
    }
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    final id = setting.id;
    _settings.remove(id);
    _validators.remove(id);
    _values.remove(id);
    _isEnabled.remove(id);
  }

  @override
  void clear() {
    _settings.clear();
    _validators.clear();
    _values.clear();
    _isEnabled.clear();
  }

  void overrideSetting<T>(BaseSetting<T> setting) {
    add(setting, override: true);
  }
} */

/* class SettingsSession implements ISettingsManager {
  final Map<String, BaseSetting<Object?>> _settings = {};
  final Map<String, CompositeValidator> _validators = {};
  final Map<String, Object?> _values = {};
  final Map<String, bool> _isEnabled = {};

  /// Добавление настройки.
  /// Если [override] = true, существующая настройка будет перезаписана.
  void add<T>(BaseSetting<T> setting, {bool override = false}) {
    final id = setting.id;

    if (!override && _settings.containsKey(id)) {
      throw StateError('Setting with id $id already registered.');
    }

    final validator = _createValidator(setting);
    if (validator != null) {
      _validateValue(validator, setting.defaultValue);
      _validators[id] = validator;
    }

    _settings[id] = setting as BaseSetting<Object?>;
    _values[id] = setting.defaultValue;
    _isEnabled[id] = true;
  }

  /// Массовое добавление настроек.
  void addAll(Iterable<BaseSetting> settings, {bool override = false}) {
    for (final setting in settings) {
      add(setting, override: override);
    }
  }

  /// Создаёт валидатор, если он есть.
  CompositeValidator? _createValidator<T>(BaseSetting<T> setting) {
    final validators = setting.validators;
    if (validators != null && validators.isNotEmpty) {
      return AndValidator<T>(validators, ValidationContext.defaultContext());
    }
    return null;
  }

  /// Валидирует значение, выбрасывает StateError при неуспехе.
  void _validateValue(CompositeValidator validator, Object? value) {
    final result = validator.validate(value);
    if (!result.isValid) {
      throw StateError('Validation failed: ${result.toMessageString()}');
    }
  }

  /// Проверка дефолтного значения настройки.
  void validateSetting<T>(BaseSetting<T> setting) {
    final validator = _validators[setting.id] ?? _createValidator(setting);
    if (validator != null) {
      _validateValue(validator, setting.defaultValue);
    }
  }

  CompositeValidator? getValidator(BaseSetting setting) =>
      _validators[setting.id];

  /// Возвращает копию всех значений.
  Map<String, Object?> getAllValues() => Map.unmodifiable(_values);

  /// Все зарегистрированные настройки.
  List<BaseSetting> getAllSettings() => List.unmodifiable(_settings.values);

  int get count => _settings.length;

  @override
  T? get<T>(BaseSetting<T?> setting) {
    return (_isEnabled[setting.id] ?? false) ? _values[setting.id] as T? : null;
  }

  @override
  bool contains<T>(BaseSetting<T> setting) => _settings.containsKey(setting.id);

  @override
  void set<T>(BaseSetting<T?> setting, T? value) {
    final id = setting.id;
    if (!(_isEnabled[id] ?? false)) return;
    if (_values[id].runtimeType != value.runtimeType) {
      throw StateError('Type is not match');
    }

    final validator = _validators[id];
    if (validator != null) {
      _validateValue(validator, value);
    }
    _values[id] = value;
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    if (_isEnabled[setting.id] ?? false) {
      _values[setting.id] = setting.defaultValue;
    }
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    final id = setting.id;
    _settings.remove(id);
    _validators.remove(id);
    _values.remove(id);
    _isEnabled.remove(id);
  }

  @override
  void clear() {
    _settings.clear();
    _validators.clear();
    _values.clear();
    _isEnabled.clear();
  }

  void overrideSetting<T>(BaseSetting<T> setting) {
    add(setting, override: true);
  }
} */

/* class SettingsSession implements ISettingsManager {
  final Map<String, BaseSetting> _settings = {};
  final Map<String, CompositeValidator> _validators = {};
  final Map<String, Object?> _values = {};
  final Map<String, bool> _isEnabled = {};

  void add(BaseSetting setting, {bool override = false}) {
    if (!override && _settings.containsKey(setting.id)) {
      throw StateError('Setting with id ${setting.id} already registered.');
    }
    final validator = _createValidator(setting);
    if (validator != null) {
      final result = validator.validate(setting.defaultValue);
      if (!result.isValid) {
        throw StateError('Validation failed: ${result.toMessageString()}');
      }
      _validators[setting.id] = validator;
    }
    _settings[setting.id] = setting;
    _values[setting.id] = setting.defaultValue;
    _isEnabled[setting.id] = true;
  }

  CompositeValidator? _createValidator(BaseSetting setting) {
    final validators = setting.validators;
    return (validators != null && validators.isNotEmpty)
        ? AndValidator(validators, ValidationContext.defaultContext())
        : null;
  }

  void validateSetting(BaseSetting setting) {
    final validator = _validators[setting.id] ?? _createValidator(setting);
    if (validator == null) return;

    final result = validator.validate(setting.defaultValue);
    if (!result.isValid) {
      throw StateError('Validation failed: ${result.toMessageString()}');
    }
  }

  void addAll(List<BaseSetting> settings) {
    for (BaseSetting setting in settings) {
      add(setting);
    }
  }

  CompositeValidator? getValidator(BaseSetting setting) {
    return _validators[setting.id];
  }

  Map<String, dynamic>? getAllValues() {
    return Map.unmodifiable(_values);
  }

  int get count => _settings.length;

  @override
  T? get<T>(BaseSetting<T> setting) {
    final value = _values[setting.id];
    if (value is T && _isEnabled[setting.id] == true) {
      return value;
    }
    return null;
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    _settings.remove(setting.id);
    _validators.remove(setting.id);
    _values.remove(setting.id);
    _isEnabled.remove(setting.id);
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    if (_isEnabled[setting.id] == true) {
      _values[setting.id] = _settings[setting.id]!.defaultValue;
    }
  }

  @override
  void set<T>(BaseSetting<T> setting, T value) {
    if (_isEnabled[setting.id] == true) {
      if (_validators[setting.id] != null) {
        final result = _validators[setting.id]!.validate(value);
        if (result.isValid) {
          _values[setting.id] = value;
        } else {
          throw StateError('Validation failed: ${result.toMessageString()}');
        }
      } else {
        _values[setting.id] = value;
      }
    }
  }

  @override
  void clear() {
    _settings.clear();
    _isEnabled.clear();
    _validators.clear();
    _values.clear();
  }

  @override
  bool contains<T>(BaseSetting<T> setting) {
    return _settings.containsKey(setting.id);
  }

  @override
  void overrideSetting<T>(BaseSetting<T> setting) {
    if (_isEnabled[setting.id] == true) {
      add(setting, override: true);
    }
  }
} */

/* abstract interface class IStorageWorker {
  FutureOr<T?> get<T>(int index);
  FutureOr<void> set<T>(int index, T value);
  FutureOr<void> remove<T>(int index);
}

abstract interface class ISettingsManager {
  FutureOr<T?> get<T>(String id);
  FutureOr<void> set<T>(String id, T value);
  FutureOr<void> remove<T>(String id);
  FutureOr<void> reset<T>(String id);
  FutureOr<void> clear();
  FutureOr<bool> contains<T>(String id);
}

class PersistentStorage implements IStorageWorker {
  @override
  T get<T>(int index) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  void remove<T>(int index) {
    // TODO: implement remove
  }

  @override
  void reset<T>(int index, T value) {
    // TODO: implement reset
  }

  @override
  void set<T>(int index, T value) {
    // TODO: implement set
  }
} */

/* class SessionStorage implements IStorageWorker {
  SessionStorage(this.size)
    : _entries = List.generate(size, (_) => SettingEntry());

  final int size;
  final List<SettingEntry> _entries;

  @override
  T? get<T>(int index) {
    final entry = _entries[index];
    if (!entry.isEnabled) {
      throw StateError("This setting is unavailable.");
    }
    return entry.value;
  }

  @override
  void set<T>(int index, T? value) {
    final entry = _entries[index];
    entry
      ..value = value
      ..isEnabled = true;
  }

  @override
  void remove<T>(int index) {
    final entry = _entries[index];
    entry
      ..value = null
      ..isEnabled = false;
  }

  bool isAvailable(int index) => _entries[index].isEnabled;
} */

/* enum SettingsMode { sessionOnly, localOnly, hybrid }

abstract class SettingsManager implements ISettingsManager {
  SettingsManager(this._registry);

  final SettingsSession _registry;

  factory SettingsManager.sessionOnly(
    SettingsSession registry,
    SessionStorage session,
  ) {
    return SessionSettingsManager(registry, session);
  }

  factory SettingsManager.localOnly(
    SettingsSession registry,
    IStorageWorker storage,
  ) {
    return PersistentSettingsManager(registry, storage);
  }

  factory SettingsManager.hybrid(
    SettingsSession registry,
    SessionStorage session,
    IStorageWorker storage,
  ) {
    return HybridSettingsManager(registry, session, storage);
  }
}

class SessionSettingsManager extends SettingsManager {
  SessionSettingsManager(super._registry, this._session);

  final SessionStorage _session;

  @override
  T? get<T>(BaseSetting<T> setting) {
    return _session.get(_registry.getIndex(setting));
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    _session.remove(_registry.getIndex(setting));
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    _session.set(_registry.getIndex(setting), setting.defaultValue);
  }

  @override
  void set<T>(BaseSetting<T> setting, T value) {
    _session.set(_registry.getIndex(setting), value);
  }
}

class PersistentSettingsManager extends SettingsManager {
  PersistentSettingsManager(super._registry, this._storage);

  final IStorageWorker _storage;

  @override
  Future<T?> get<T>(BaseSetting<T> setting) async {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    // TODO: implement remove
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    // TODO: implement reset
  }

  @override
  void set<T>(BaseSetting<T> setting, T value) {
    // TODO: implement set
  }
}

class HybridSettingsManager extends SettingsManager {
  HybridSettingsManager(super._registry, this._session, this._storage);

  final SessionStorage _session;
  final IStorageWorker _storage;

  @override
  T? get<T>(BaseSetting<T> setting) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  void remove<T>(BaseSetting<T> setting) {
    // TODO: implement remove
  }

  @override
  void reset<T>(BaseSetting<T> setting) {
    // TODO: implement reset
  }

  @override
  void set<T>(BaseSetting<T> setting, T value) {
    // TODO: implement set
  }
}
 */
