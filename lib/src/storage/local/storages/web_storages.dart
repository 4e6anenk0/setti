/* import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import '../../../setti.dart';
import '../../../setti_configurations.dart';
import '../../interfaces/settings_storage_interface.dart';

mixin Web on BaseSetti {
  final SettiConfig storageConfig = const SettiConfig(
    useModelPrefix: false,
    useSettiPrefix: false,
    delimiter: Delimiter.underscore,
    caseFormat: CaseFormat.uppercase,
  );

  ISettingsStorage get webStorage => WebStorage(name, config.storageFileName);

  @override
  Set<ISettingsStorage> get storages => {...super.storages, webStorage};

  @override
  SettiConfig get config => storageConfig;
}

@internal
class WebStorage implements ISettingsStorage {
  WebStorage(String sectionName, String fileName)
      : _sectionName = sectionName,
        _fileName = fileName;

  final String _sectionName;
  final String _fileName;

  @override
  Future<void> clear() async {
    _config.removeSection(_sectionName);

    await _saveConfig();
  }

  @override
  T? getSetting<T>(String id, T defaultValue) {
    var str = _config.get(_sectionName, id);
    if (str == null) return null;
    try {
      final result =
          _stringToObject(string: str, targetType: defaultValue.runtimeType)
              as T;
      return result;
    } catch (e) {
      // Логування або обробка помилки
      // print('Error converting setting "$id" to type $T: $e');
      return null;
    }
  }

  @override
  Future<bool> init() async {
    await _createPath();
    await _loadConfig();
    if (!_config.hasSection(_sectionName)) {
      _config.addSection(_sectionName);
    }

    return true;
  }

  @override
  bool contains(String id) {
    return _config.hasOption(_sectionName, id);
  }

  @override
  Future<bool> removeSetting(String id) async {
    _config.removeOption(_sectionName, id);

    await _saveConfig();

    return true;
  }

  @override
  Future<bool> setSetting(String id, Object value) async {
    _setObject(sectionName: _sectionName, option: id, value: value);
    await _saveConfig();
    return true;
  }

  @override
  String get id => runtimeType.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ISettingsStorage && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
 */
