import 'dart:async';
import 'dart:collection';

import 'converter/converter_interface.dart';
import 'exceptions/exceptions.dart';
import 'setti_configurations.dart';
import 'setting_types/base/setting.dart';
import 'setting_types/storage_rules.dart';
import 'settings_controller_interface.dart';
import 'storage/session_storage.dart';
import 'storage/storage_overlay.dart';

/// A controller that allows you to manage immutable settings configuration
class SettiController implements ISettingsController {
  SettiController._({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
  })  : _settings = settings,
        _isDebug = isDebug,
        _converter = converter,
        _storage = storageOverlay,
        _caseFormat = caseFormat;

  /// Lazy controller. Need to init controller late
  factory SettiController.lazy({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
  }) {
    SettiController controller = SettiController._(
      settings: settings,
      converter: converter,
      storageOverlay: storageOverlay,
      isDebug: isDebug,
      caseFormat: caseFormat,
    );

    return controller;
  }

  /// A static method that allows you to create and initialize a controller asynchronously.
  ///
  /// This will allow you to get the data stored in SharedPreferences,
  /// but may cause a delay, for example, if there is a lot of data.
  ///
  /// `SettingsController.consist()` must be used in an asynchronous function.
  static Future<SettiController> consist({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
  }) async {
    SettiController controller = SettiController._(
      settings: settings,
      converter: converter,
      storageOverlay: storageOverlay,
      isDebug: isDebug,
      caseFormat: caseFormat,
    );

    await controller._init();

    return controller;
  }

  final CaseFormat _caseFormat;

  /// A converter is required to convert properties to the Property type
  final ISettingConverter _converter;

  /// List of all repositories to save settings.
  //final List<IStorageWorker> _storages;

  /// A class that handles a single repository or multiple repositories.
  final StorageOverlay _storage;

  /// Flag to check initialization status. Required for lazy initialization cases.
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// A set of properties that are declarative descriptions of settings parameters.
  final List<BaseSetting>? _settings;

  /// A list of converted properties to the Property type
  ///final List<Setting> _adaptedProperties = [];

  final HashMap<String, Setting> _localSettings = HashMap();

  final HashMap<String, Setting> _sessionSettings = HashMap();

  //final HashMap<String, Setting> _notDeclarativeSettings = HashMap();

  /// snapshot is used for initialization to analyze fields already saved
  /// in local storage and restore it, otherwise save new unsaved settings and
  /// remove the unnecessary ones.
  late Setting<List<String>> _snapshot;

  final SessionStorage _session = SessionStorage();

  final bool _isDebug;

  bool _isSessionOnly = false;

  Future<void> init() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  Future<void> _init() async {
    if (_isDebug) {
      _storage.clear();
    }

    _snapshot = Setting(
        id: _caseFormat.apply('snapshot'),
        defaultValue: [],
        saveMode: SaveMode.local);

    if (_settings != null && _settings!.isNotEmpty) {
      assert(_isAllUnique(_settings!), "A non-unique ID was passed");

      _separateSettings(_settings!);

      if (_localSettings.isEmpty) {
        _isSessionOnly = true;
      } else {
        await _restoreSnapshot();
      }
      await _initSettings(_settings!);
    }

    _isInitialized = true;
  }

  Future<void> _restoreSnapshot() async {
    if (await _storage.contains(_snapshot.id)) {
      List<String>? snapshotData =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);
      assert(snapshotData != null);
      _snapshot = _snapshot.copyWith(defaultValue: snapshotData);
    }
  }

  void updateSettings() async {
    var snapshotData =
        await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);
    _snapshot = _snapshot.copyWith(defaultValue: snapshotData);
    await _initSettings(_settings!);
  }

  bool _isAllUnique(List<BaseSetting> settings) {
    final Set<String> uniqueIds = {};
    for (BaseSetting setting in settings) {
      uniqueIds.add(setting.id);
    }
    if (uniqueIds.length != settings.length) {
      return false;
    } else {
      return true;
    }
  }

  void _separateSettings(List<BaseSetting> settings) {
    for (BaseSetting setting in settings) {
      /* if (!setting.declarative) {
        _notDeclarativeSettings[setting.id] = _converter.convertTo(setting);
      }  */
      if (setting.saveMode == SaveMode.local) {
        _localSettings[setting.id] = _converter.convertTo(setting);
      } else {
        _sessionSettings[setting.id] = _converter.convertTo(setting);
      }
    }
  }

  Future<void> _initSettings(List<BaseSetting> settings) async {
    //assert(_isAllUnique(settings), "A non-unique ID was passed");
    if (_isSessionOnly) {
      _setSessionSettings(_sessionSettings.values.toList());
      //await _setNotDeclarativeSettings(_notDeclarativeSettings.values.toList());
    } else {
      //await _setNotDeclarativeSettings(_notDeclarativeSettings.values.toList());
      await _setLocalSettings(_localSettings.values.toList());
      _setSessionSettings(_sessionSettings.values.toList());

      await clearCache();
      await _makeSettingsSnapshot();
    }
  }

  Future<void> _setSessionSettings(List<Setting> sessionSettings) async {
    for (Setting setting in sessionSettings) {
      if (!setting.declarative) {
        await _restoreSetting(setting);
      } else {
        _session.setSetting(setting.id, setting.defaultValue);
      }
    }
  }

  Future<void> _setLocalSettings(List<Setting> localProperties) async {
    for (Setting setting in localProperties) {
      if (!setting.declarative) {
        await _restoreSetting(setting);
      } else {
        /* if (_snapshot.defaultValue.isNotEmpty &&
            _snapshot.defaultValue.contains(_storage.prefixed(setting))) { */
        if (_snapshot.defaultValue.isNotEmpty &&
            _snapshot.defaultValue.contains(setting.id)) {
          await _restoreSetting(setting);
        } else {
          await _initSetting(setting);
        }
      }
    }
  }

  /// Method to restore data from local storage
  FutureOr<void> _restoreSetting(Setting setting) async {
    var value = await _storage.getSetting(setting.id, setting.defaultValue);
    if (value == null) {
      if (setting.declarative == false) {
        throw ControllerException(
            msg:
                "Setting '${setting.id}' is not declarative and must be stored locally.\n",
            solutionMsg:
                "Ensure that '${setting.id}' is stored in local storage.");
      } else {
        await _initSetting(setting);
      }
    } else {
      _session.setSetting(setting.id, value);
      //_session.setFromValue(value: value, id: setting.id);
      //_storage.setSetting(setting.id, setting.defaultValue);
    }
  }

  /// Method for setting data to local storage
  Future<void> _initSetting(Setting setting) async {
    if (_isSessionOnly) {
      _session.setSetting(setting.id, setting.defaultValue);
    } else {
      await _storage.setSetting(setting.id, setting.defaultValue);
      _session.setSetting(setting.id, setting.defaultValue);
    }
  }

  /// Method to create a snapshot.
  ///
  /// The snapshot allows you to clear the local storage
  Future<void> _makeSettingsSnapshot() async {
    List<String> keysList = [];

    for (Setting setting in _localSettings.values) {
      //keysList.add(_storage.prefixed(setting));
      keysList.add(setting.id);
    }

    Setting snapshotProperty = _snapshot.copyWith(defaultValue: keysList);
    await _storage.setSetting(
        snapshotProperty.id, snapshotProperty.defaultValue);
  }

  /// A method that helps to remove settings that are not in the
  /// current list of properties and clear unused keys dump
  Future<void> clearCache() async {
    if (await _storage.contains(_snapshot.id)) {
      // if the snapshot already exists, we get it
      List<String>? snapshot =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);

      if (snapshot == null) {
        throw Exception();
      }

      await Future.forEach(snapshot, (key) {
        // if the key is in the list of current keys,
        // then there is no need to delete in settings, it is still actuality
        if (!_localSettings.containsKey(key)) {
          Future.value(_storage.removeSetting(key));
          _storage.removeCacheFor(key);
          _localSettings.remove(key);
        }
      });
    }
  }

  Future<void> _applySetting<T>(BaseSetting<T> setting,
      {bool sessionOnly = false}) async {
    var adaptedSetting = _converter.convertTo(setting);
    _session.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);

    if (!sessionOnly && setting.saveMode == SaveMode.local) {
      await _storage.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);
    }
  }

  @override
  Future<void> update<T>(
    BaseSetting<T> setting, {
    bool onlyExisting = false,
    bool sessionOnly = false,
  }) async {
    if (onlyExisting && !_session.contains(setting.id)) {
      throw SettingNotFoundException(
          msg: "Setting with id ${setting.id} not found in session.");
    }
    await _applySetting(setting, sessionOnly: sessionOnly);
  }

  Future<void> match() async {
    if (_settings != null) {
      for (Setting setting in _localSettings.values) {
        if (setting.saveMode == SaveMode.local &&
            _session.contains(setting.id)) {
          var needToStoreValue =
              _session.getSetting(setting.id, setting.defaultValue);
          await _storage.setSetting(setting.id, needToStoreValue!);
        }
      }
    }
  }

  @override
  HashMap<String, Object> getAll() {
    return _session.settings;
  }

  @override
  T get<T>(BaseSetting<T> setting) {
    if (_session.contains(setting.id)) {
      var value = _session.getSetting(setting.id, setting.defaultValue);
      print("Get: $value");
      return _converter.convertValue(value, setting);
    } else {
      throw SettingNotFoundException(
          msg: "Setting with id ${setting.id} not found.");
      //return setting.defaultValue;
    }
  }

  @override
  Future<bool> clear() async {
    if (_settings != null) {
      if (_isSessionOnly) {
        _session.clear();
      } else {
        _session.clear();
        await _storage.clear();
      }
    }
    return true;
  }

  @override
  bool contains<T>(BaseSetting<T> setting) {
    return _session.contains(setting.id);
  }

  @override
  FutureOr<bool> remove<T>(BaseSetting<T> setting) async {
    if (_isSessionOnly) {
      _session.removeSetting(setting.id);
    } else {
      _session.removeSetting(setting.id);
      await _storage.removeSetting(setting.id);

      _storage.removeCacheFor(setting.id);
      _localSettings.remove(setting.id);

      await _makeSettingsSnapshot();
    }

    return true;
  }
}
