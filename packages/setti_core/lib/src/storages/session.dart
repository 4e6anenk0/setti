import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';

import '../setting/rules/storage_rules.dart';
import '../setting/setting_meta.dart';
import 'storage_interface.dart';

class SettingsSession implements ISettingsStorage {
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
}
