import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:ini/ini.dart';

import '../../../exceptions/exceptions.dart';
import '../../../setti.dart';
import '../../../setti_configurations.dart';
import '../../interfaces/settings_storage_interface.dart';

mixin Ini on BaseSetti {
  final SettiConfig storageConfig = const SettiConfig(
    useModelPrefix: false,
    useSettiPrefix: false,
    delimiter: Delimiter.underscore,
    caseFormat: CaseFormat.uppercase,
  );

  ISettingsStorage get iniStorage =>
      IniStorage(path, name, config.storageFileName);

  @override
  Set<ISettingsStorage> get storages => {...super.storages, iniStorage};

  String get path => Directory.current.path;

  @override
  SettiConfig get config => storageConfig;
}

@internal
class IniStorage extends ISettingsStorage {
  IniStorage(String path, String sectionName, String fileName)
      : _path = path,
        _sectionName = sectionName,
        _fileName = fileName;

  final String _path;
  final String _sectionName;
  final String _fileName;
  late final Config _config;

  Future<void> _loadConfig() async {
    try {
      final lines = await File("$_path/$_fileName.ini").readAsLines();
      _config = Config.fromStrings(lines);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _createPath() async {
    var path = File("$_path/$_fileName.ini");

    if (!await path.exists()) {
      await path.create(recursive: true);
    }
  }

  void _setObject(
      {required String sectionName,
      required String option,
      required Object value}) {
    if (value is bool || value is int || value is double || value is String) {
      _config.set(sectionName, option, value.toString());
    } else if (value is List<String>) {
      _config.set(sectionName, option, jsonEncode(value));
    } else {
      throw LocalStorageException(
        msg: "Unsupported type: ${value.runtimeType}",
        solutionMsg:
            """Check that you are not trying to store an unsupported value in the local storage.
Supported values are: bool, int, double, String, List<String>""",
      );
    }
  }

  Object _stringToObject({required String string, required Type targetType}) {
    switch (targetType) {
      case const (bool):
        return string.toLowerCase() == 'true';
      case const (int):
        return int.parse(string);
      case const (double):
        return double.parse(string);
      case const (String):
        return string;
      case const (List<String>):
        return List<String>.from(jsonDecode(string));
      default:
        throw UnsupportedError('Unsupported type: $targetType');
    }
  }

  Future<void> _saveConfig() async {
    //print('_saveConfig()');
    final file = File("$_path/config.ini");

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.write);
      await raf.writeString(_config.toString());
    } finally {
      await raf?.close();
    }
  }

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
