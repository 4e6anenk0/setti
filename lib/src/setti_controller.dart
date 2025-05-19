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

/// A controller for managing immutable settings configurations.
///
/// Provides methods for initializing, updating, and retrieving settings,
/// with support for both local and session storage.
class SettiController implements ISettingsController {
  SettiController._({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
    bool autoManageStorageMode = true,
  })  : _settings = settings,
        _isDebug = isDebug,
        _converter = converter,
        _storage = storageOverlay,
        _caseFormat = caseFormat,
        _autoManageStorageMode = autoManageStorageMode;

  /// Creates a controller with lazy initialization.
  /// Call [init] to initialize the controller when needed.
  factory SettiController.lazy({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
    bool autoManageStorageMode = true,
  }) {
    SettiController controller = SettiController._(
      settings: settings,
      converter: converter,
      storageOverlay: storageOverlay,
      isDebug: isDebug,
      caseFormat: caseFormat,
      autoManageStorageMode: autoManageStorageMode,
    );

    return controller;
  }

  /// Creates and initializes a controller asynchronously.
  ///
  /// Loads data from storage (e.g., SharedPreferences), which may cause a delay
  /// if the data volume is large. Use in an asynchronous context.
  static Future<SettiController> consist({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
    bool autoManageStorageMode = true,
  }) async {
    SettiController controller = SettiController._(
      settings: settings,
      converter: converter,
      storageOverlay: storageOverlay,
      isDebug: isDebug,
      caseFormat: caseFormat,
      autoManageStorageMode: autoManageStorageMode,
    );

    await controller._init();

    return controller;
  }

  final CaseFormat _caseFormat;

  /// A converter is required to convert properties to the Property type
  final ISettingConverter _converter;

  /// A class that handles a single repository or multiple repositories.
  final StorageOverlay _storage;

  /// Flag to check initialization status. Required for lazy initialization cases.
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// A set of properties that are declarative descriptions of settings parameters.
  final List<BaseSetting>? _settings;

  final HashMap<String, Setting> _localSettings = HashMap();

  final HashMap<String, Setting> _sessionSettings = HashMap();

  /// snapshot is used for initialization to analyze fields already saved
  /// in local storage and restore it, otherwise save new unsaved settings and
  /// remove the unnecessary ones.
  late Setting<List<String>> _snapshot;

  final SessionStorage _session = SessionStorage();

  final bool _autoManageStorageMode;

  final bool _isDebug;

  bool _isSessionOnly = false;

  /// Initializes the controller, loading settings into session and local storage.
  Future<void> init() async {
    if (!_isInitialized) {
      await _init();
    }
  }

  Future<void> _init() async {
    if (_isDebug) {
      await _storage.clear();
    }

    if (_settings != null && _settings!.isNotEmpty) {
      assert(_isAllUnique(_settings!), "A non-unique ID was passed");

      _snapshot = Setting(
          id: _caseFormat.apply('snapshot'),
          defaultValue: [],
          saveMode: SaveMode.local);

      _separateSettings(_settings!);

      if (_localSettings.isEmpty) {
        _isSessionOnly = true;
      } else {
        await _restoreSnapshot();
      }

      await _initDeclarativeSettings(_settings!);

      _isInitialized = true;
    }
  }

  /// Restores the snapshot of saved settings from local storage.
  Future<void> _restoreSnapshot() async {
    if (!_autoManageStorageMode) return;

    if (await _storage.contains(_snapshot.id)) {
      List<String>? snapshotData =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);
      if (snapshotData == null) {
        throw ControllerException(
            msg: "Snapshot could not be restored from storage.",
            solutionMsg: "Verify that storage contains a valid snapshot.");
      }
      _snapshot = _snapshot.copyWith(defaultValue: snapshotData);
    }
  }

  Future<void> updateSettings() async {
    if (_autoManageStorageMode) {
      var snapshotData =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);
      _snapshot = _snapshot.copyWith(defaultValue: snapshotData);
    }

    await _initDeclarativeSettings(_settings!);
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
      if (setting.saveMode == SaveMode.local) {
        _localSettings[setting.id] = _converter.convertTo(setting);
      } else {
        _sessionSettings[setting.id] = _converter.convertTo(setting);
      }
    }
  }

  Future<void> _initDeclarativeSettings(List<BaseSetting> settings) async {
    if (_isSessionOnly) {
      _setSessionSettings(_sessionSettings.values);
    } else {
      await _setLocalSettings(_localSettings.values);
      _setSessionSettings(_sessionSettings.values);

      if (_autoManageStorageMode) {
        await clearCache();
        await _makeSettingsSnapshot();
      }
    }
  }

  Future<void> _setSessionSettings(Iterable<Setting> sessionSettings) async {
    List<Setting> notDeclarativeSettings = [];
    for (Setting setting in sessionSettings) {
      if (!setting.declarative) {
        notDeclarativeSettings.add(setting);
      } else {
        _session.setSetting(setting.id, setting.defaultValue);
      }
    }
    if (notDeclarativeSettings.isNotEmpty) {
      await _restoreSettings(notDeclarativeSettings);
    }
  }

  Future<void> _setLocalSettings(Iterable<Setting> localSettings) async {
    await _restoreSettings(localSettings);
  }

  /// Method to restore data from local storage
  Future<void> _restoreSetting(Setting setting) async {
    var value = await _storage.getSetting(setting.id, setting.defaultValue);
    if (value == null) {
      if (setting.declarative == false) {
        throw ControllerException(
            msg: "Setting '${setting.id}' must be stored locally.\n",
            solutionMsg:
                "Ensure that '${setting.id}' is stored in local storage.");
      } else {
        await _initSetting(setting);
      }
    } else {
      _session.setSetting(setting.id, value);
    }
  }

  Future<void> _restoreSettings(Iterable<Setting> localSettings) async {
    List<Setting> settingsToInit = [];
    for (Setting setting in localSettings) {
      var value = await _storage.getSetting(setting.id, setting.defaultValue);
      if (value == null) {
        if (setting.declarative == false) {
          throw ControllerException(
              msg: "Setting '${setting.id}' must be stored locally.\n",
              solutionMsg:
                  "Ensure that '${setting.id}' is stored in local storage.");
        } else {
          settingsToInit.add(setting);
        }
      } else {
        _session.setSetting(setting.id, value);
      }
    }

    if (settingsToInit.isNotEmpty) {
      await _initLocalSettings(settingsToInit);
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

  Future<void> _initLocalSettings(List<Setting> localSettings) async {
    var settingsToStore = <String, Object>{};

    for (Setting setting in localSettings) {
      settingsToStore[setting.id] = setting.defaultValue;
    }
    await _storage.setSettings(settingsToStore);
    _session.setSettings(settingsToStore);
  }

  /// Creates a snapshot of current local settings to track active keys.
  ///
  /// The snapshot allows you to remove the local storage settings automatically
  /// if they are not in declarative configuration.
  Future<void> _makeSettingsSnapshot() async {
    var keysList = _localSettings.keys.toList();
    var snapshotProperty = _snapshot.copyWith(defaultValue: keysList);
    await _storage.setSetting(
        snapshotProperty.id, snapshotProperty.defaultValue);
  }

  /// Clears unused settings from local storage based on the snapshot.
  ///
  /// A method that helps to remove settings that are not in the
  /// current list of settings and clear unused keys dump
  Future<void> clearCache() async {
    if (await _storage.contains(_snapshot.id)) {
      // if the snapshot already exists, we get it
      List<String>? snapshot =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);

      if (snapshot == null) {
        throw ControllerException(msg: 'Snapshot is null');
      }

      var keysToRemove = <String>{};
      for (String key in snapshot) {
        if (!_localSettings.containsKey(key)) {
          keysToRemove.add(key);
        }
      }

      if (keysToRemove.isNotEmpty) {
        await _storage.removeSettings(keysToRemove);
        for (String key in keysToRemove) {
          _storage.removeCacheFor(key);
          _localSettings.remove(key);
        }
      }
    }
  }

  FutureOr<void> _applySetting<T>(BaseSetting<T> setting,
      {bool sessionOnly = false}) {
    if (setting.defaultValue !=
        _session.getSetting(setting.id, setting.defaultValue)) {
      var adaptedSetting = _converter.convertTo(setting);
      _session.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);

      if (!sessionOnly && setting.saveMode == SaveMode.local) {
        return _storage.setSetting(
            adaptedSetting.id, adaptedSetting.defaultValue);
      }
    }

    return null;
  }

  @override
  FutureOr<void> update<T>(
    BaseSetting<T> setting, {
    bool onlyExisting = false,
    bool sessionOnly = false,
  }) {
    if (onlyExisting && !_session.contains(setting.id)) {
      throw SettingNotFoundException(
          msg: "Setting with id ${setting.id} not found in session.");
    }
    return _applySetting(setting, sessionOnly: sessionOnly);
  }

  /*  /// Синхронно обновляет настройку только в сессии.
  void updateSync<T>(
    BaseSetting<T> setting, {
    bool onlyExisting = false,
  }) {
    if (onlyExisting && !_session.contains(setting.id)) {
      throw SettingNotFoundException(
          msg: "Setting with id ${setting.id} not found in session.");
    }
    _applySetting(setting, sessionOnly: true);
  } */

  /// Synchronizes session settings with local storage for settings with [SaveMode.local].
  ///
  /// Uses batch processing to optimize performance for supported storage backends.
  Future<void> match() async {
    if (_settings != null && _settings!.isNotEmpty) {
      Map<String, Object> batchSettings = {}; // think about usage dynamic
      for (Setting setting in _localSettings.values) {
        if (setting.saveMode == SaveMode.local &&
            _session.contains(setting.id)) {
          batchSettings[setting.id] =
              _session.getSetting(setting.id, setting.defaultValue);
        }
      }
      if (batchSettings.isNotEmpty) {
        await _storage.setSettings(batchSettings);
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
      return _converter.convertValue(value, setting);
    } else {
      throw SettingNotFoundException(
          msg: "Setting with id ${setting.id} not found.");
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
  Future<bool> remove<T>(BaseSetting<T> setting) async {
    if (_isSessionOnly) {
      _session.removeSetting(setting.id);
    } else {
      _session.removeSetting(setting.id);
      await _storage.removeSetting(setting.id);

      _storage.removeCacheFor(setting.id);
      _localSettings.remove(setting.id);

      if (_autoManageStorageMode) {
        await _makeSettingsSnapshot();
      }
    }

    return true;
  }
}
