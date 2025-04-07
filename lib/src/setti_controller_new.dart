/* import 'dart:async';
import 'dart:collection';

import '../setti.dart';
import 'converter/converter_interface.dart';
import 'settings_controller_interface.dart';
import 'storage/session_storage.dart';
import 'storage/storage_overlay.dart';

class SessionSettingsController implements ISettingsController {
  final SessionStorage _session = SessionStorage();
  final ISettingConverter _converter;
  final HashMap<String, Setting> _sessionSettings = HashMap();

  SessionSettingsController({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
  }) : _converter = converter {
    if (settings != null) {
      _separateSessionSettings(settings);
      _initSessionSettings();
    }
  }

  void _separateSessionSettings(List<BaseSetting> settings) {
    for (final setting in settings) {
      if (setting.saveMode == SaveMode.session) {
        _sessionSettings[setting.id] = _converter.convertTo(setting);
      }
    }
  }

  void _initSessionSettings() {
    for (final setting in _sessionSettings.values) {
      _session.setSetting(setting.id, setting.defaultValue);
    }
  }

  @override
  void update<T>(BaseSetting<T> setting) {
    final adaptedSetting = _converter.convertTo(setting);
    _session.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);
    _sessionSettings[setting.id] = adaptedSetting; // Оновлюємо кеш
  }

  @override
  T get<T>(BaseSetting<T> setting) {
    if (_session.contains(setting.id)) {
      return _session.getSetting(setting.id, setting.defaultValue) as T;
    }
    throw SettingNotFoundException(msg: "Setting ${setting.id} not found.");
  }

  void clear() {
    _session.clear();
    _sessionSettings.clear();
  }

  @override
  bool contains<T>(BaseSetting<T> setting) => _session.contains(setting.id);

  @override
  FutureOr<HashMap<String, Object>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> remove<T>(BaseSetting<T> setting) {
    // TODO: implement remove
    throw UnimplementedError();
  }
}

class LocalSettingsController
    implements ISettingsController, IMatchableSettings {
  final SessionStorage _session = SessionStorage();
  final StorageOverlay _storage;
  final ISettingConverter _converter;
  final HashMap<String, Setting> _localSettings = HashMap();
  late Setting<List<String>> _snapshot;
  final CaseFormat _caseFormat;

  LocalSettingsController({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storage,
    required CaseFormat caseFormat,
    bool isDebug = false,
  })  : _converter = converter,
        _storage = storage,
        _caseFormat = caseFormat;

  void _separateLocalSettings(List<BaseSetting> settings) {
    for (final setting in settings) {
      if (setting.saveMode == SaveMode.local) {
        _localSettings[setting.id] = _converter.convertTo(setting);
      }
    }
  }

  Future<void> init() async {
    if (_isDebug) {
      _storage.clear();
    }

    _snapshot = Setting(
        id: _caseFormat.apply('snapshot'),
        defaultValue: [],
        saveMode: SaveMode.local);

    if (_settings != null && _settings!.isNotEmpty) {
      assert(_isAllUnique(_settings!), "A non-unique ID was passed");

      _separateLocalSettings(_settings!);

      if (_localSettings.isEmpty) {
        _isSessionOnly = true;
      } else {
        await _restoreSnapshot();
      }
      await _initSettings(_settings!);
    }

    _isInitialized = true;
    await _restoreSnapshot();
    await _setLocalSettings();
    await _makeSettingsSnapshot();
  }

  Future<void> _restoreSnapshot() async {
    if (await _storage.contains(_snapshot.id)) {
      final snapshotData =
          await _storage.getSetting(_snapshot.id, _snapshot.defaultValue);
      _snapshot = _snapshot.copyWith(defaultValue: snapshotData ?? []);
    }
  }

  Future<void> _setLocalSettings() async {
    for (final setting in _localSettings.values) {
      if (_snapshot.defaultValue.contains(setting.id)) {
        final value =
            await _storage.getSetting(setting.id, setting.defaultValue);
        _session.setSetting(setting.id, value ?? setting.defaultValue);
      } else {
        await _storage.setSetting(setting.id, setting.defaultValue);
        _session.setSetting(setting.id, setting.defaultValue);
      }
    }
  }

  Future<void> _makeSettingsSnapshot() async {
    final keysList = _localSettings.keys.toList();
    _snapshot = _snapshot.copyWith(defaultValue: keysList);
    await _storage.setSetting(_snapshot.id, _snapshot.defaultValue);
  }

  @override
  Future<void> update<T>(BaseSetting<T> setting,
      {bool onlyExisting = false, bool sessionOnly = false}) async {
    if (onlyExisting && !_session.contains(setting.id)) {
      throw SettingNotFoundException(msg: "Setting ${setting.id} not found.");
    }
    final adaptedSetting = _converter.convertTo(setting);
    _session.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);
    _localSettings[setting.id] = adaptedSetting; // Оновлюємо кеш
    if (!sessionOnly && setting.saveMode == SaveMode.local) {
      await _storage.setSetting(adaptedSetting.id, adaptedSetting.defaultValue);
    }
  }

  @override
  Future<void> match() async {
    for (final setting in _session.getAllSettings()) {
      // Беремо всі з сесії
      if (setting.saveMode == SaveMode.local) {
        await _storage.setSetting(
            setting.id, setting.value ?? setting.defaultValue);
        _localSettings[setting.id] = setting; // Оновлюємо кеш
      }
    }
    await _makeSettingsSnapshot();
  }

  @override
  Future<T> get<T>(BaseSetting<T> setting) async {
    if (_session.contains(setting.id)) {
      return _session.getSetting(setting.id, setting.defaultValue) as T;
    }
    if (setting.saveMode == SaveMode.local) {
      final value = await _storage.getSetting(setting.id, setting.defaultValue);
      _session.setSetting(setting.id, value ?? setting.defaultValue);
      return value ?? setting.defaultValue;
    }
    throw SettingNotFoundException(msg: "Setting ${setting.id} not found.");
  }

  @override
  Future<bool> clear() async {
    _session.clear();
    await _storage.clear();
    _localSettings.clear();
    return true;
  }

  @override
  Future<bool> contains<T>(BaseSetting<T> setting) async {
    return _session.contains(setting.id) || await _storage.contains(setting.id);
  }

  @override
  Future<bool> remove<T>(BaseSetting<T> setting) async {
    _session.removeSetting(setting.id);
    if (setting.saveMode == SaveMode.local) {
      await _storage.removeSetting(setting.id);
      _localSettings.remove(setting.id);
      await _makeSettingsSnapshot();
    }
    return true;
  }

  Future<void> setForLocal<T>(BaseSetting<T> setting) async {
    if (setting.saveMode != SaveMode.local) {
      throw InvalidSaveModeException(
          msg: "Expected SaveMode.local for ${setting.id}");
    }
    final adapted = _converter.convertTo(setting);
    await _storage.setSetting(adapted.id, adapted.defaultValue);
    _session.setSetting(adapted.id, adapted.defaultValue);
    _localSettings[adapted.id] = adapted;
  }

  @override
  FutureOr<HashMap<String, Object>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}

class SettiController implements ISettingsController, IMatchableSettings {
  final SessionStorage _session = SessionStorage();
  final LocalSettingsController _localController;
  final List<BaseSetting> _settings;

  SettiController._({
    required LocalSettingsController localController,
    required List<BaseSetting> settings,
  })  : _localController = localController,
        _settings = settings;

  factory SettiController({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
  }) {
    final localController = LocalSettingsController(
      settings: settings,
      converter: converter,
      storage: storageOverlay,
      caseFormat: caseFormat,
      isDebug: isDebug,
    );

    return SettiController._(
      settings: settings ?? [],
      localController: localController,
    );
  }

  static Future<SettiController> create({
    List<BaseSetting>? settings,
    required ISettingConverter converter,
    required StorageOverlay storageOverlay,
    required CaseFormat caseFormat,
    bool isDebug = false,
  }) async {
    final controller = SettiController(
      settings: settings,
      converter: converter,
      storageOverlay: storageOverlay,
      caseFormat: caseFormat,
      isDebug: isDebug,
    );
    await controller.init();
    return controller;
  }

  Future<void> init() async {
    await _localController.init();
  }

  @override
  Future<void> update<T>(
    BaseSetting<T> setting, {
    bool onlyExisting = false,
    bool sessionOnly = false,
  }) async {
    if (setting.saveMode == SaveMode.local && !sessionOnly) {
      await _localController.update(setting,
          onlyExisting: onlyExisting, sessionOnly: sessionOnly);
    } else {
      _session.setSetting(setting.id, setting.defaultValue);
    }
  }

  @override
  Future<T> get<T>(BaseSetting<T> setting) async {
    if (_sessionController.contains(setting)) {
      return _sessionController.get(setting);
    }
    if (setting.saveMode == SaveMode.local) {
      return await _localController.get(setting);
    }
    throw SettingNotFoundException(msg: "Setting ${setting.id} not found.");
  }

  @override
  Future<void> match() async {
    await _localController.match();
  }

  @override
  Future<bool> clear() async {
    _sessionController.clear();
    await _localController.clear();
    return true;
  }

  @override
  Future<bool> contains<T>(BaseSetting<T> setting) async {
    return _sessionController.contains(setting) ||
        await _localController.contains(setting);
  }

  @override
  Future<bool> remove<T>(BaseSetting<T> setting) async {
    if (setting.saveMode == SaveMode.local) {
      return await _localController.remove(setting);
    }
    _sessionController.clear(); // Очищаємо лише сесію, якщо не локальне
    return true;
  }

  void setForSession<T>(BaseSetting<T> setting) {
    _sessionController.setForSession(setting);
  }

  Future<void> setForLocal<T>(BaseSetting<T> setting) async {
    await _localController.setForLocal(setting);
  }

  // Додатковий метод для доступу до результуючих налаштувань
  List<BaseSetting> get effectiveSettings {
    return [
      ..._sessionController._sessionSettings.values,
      ..._localController._localSettings.values,
    ];
  }

  @override
  FutureOr<HashMap<String, Object>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}
 */
