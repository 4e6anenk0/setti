import 'dart:async';
import 'dart:collection';

import 'converter/converter.dart';
import 'exceptions/exceptions.dart';
import 'setti_configurations.dart';
import 'setti_controller.dart';
import 'setti_layer.dart';
import 'setting_types/base/setting.dart';
import 'settings_controller_interface.dart';
import 'storage/interfaces/settings_storage_interface.dart';
import 'storage/storage.dart';
import 'storage/storage_overlay.dart';

abstract class BaseSetti
    implements ISettingsController, IMatchableSettings, ILayerController {
  BaseSetti();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Визначте декларативні налаштування і передайте їх через цей геттер.
  List<BaseSetting> get settings;

  SettiController get controller => _controller;

  late final SettiController _controller;

  late final SettingsStorage _storage;

  /// Визначити перелік платформ для яких призначена конфігурація.
  List<SettiPlatform> get platforms;

  /// Отримати платформу на якій запущена конфігурація.
  SettiPlatform getCurrentPlatform();

  /// Назва класу конфігурації.
  ///
  /// Дозволяє визначити назву секції, якщо сховище використовує секції для збереження налаштувань.
  /// Також, може використовуватися для додаткового префіксу, якщо встановлено `useModelPrefix = true`.
  /// За замовчанням це `runtimeType.toString()` класу
  String get name => runtimeType.toString();

  SettiConfig get config => const SettiConfig();

  Set<ISettingsStorage> get storages => {};

  /// Можна визначити власний префікс замість дефолтних префіксів `setti` та `name`.
  String? get prefix => null;

  bool get debug => false;

  final SettingConverter converter = SettingConverter();

  Map<String, String> get appliedLayers => _appliedLayers;

  final Map<String, String> _appliedLayers = {};

  bool isCorrectPlatform() {
    if (platforms.contains(getCurrentPlatform())) return true;
    return false;
  }

  bool isAppliedLayer(String name) {
    return _appliedLayers.values.any((value) => value.contains(name));
  }

  Future<void> init({Set<SettiLayer>? layers}) async {
    if (layers == null) {
      if (!isCorrectPlatform()) return;
      await _init(settings);
    } else {
      final currentPlatform = getCurrentPlatform();
      SettiLayer? actualLayer = layers
          .where((layer) => layer.platforms.contains(currentPlatform))
          .toList()
          .lastOrNull;

      if (actualLayer != null) {
        _appliedLayers['InitialLayer'] =
            "${actualLayer.name}, ${actualLayer.runtimeType}";
        await _init(actualLayer.settings);
      } else {
        if (!isCorrectPlatform()) return;
        await _init(settings);
      }
    }
    print(_isInitialized);
  }

  Future<void> _init(List<BaseSetting> settings) async {
    _storage = SettingsStorage.getInstance();
    _storage.addStorages(storages);

    try {
      if (_storage.isNotInitialized) {
        await _storage.init();
      }

      List<Type> types =
          storages.map((storage) => storage.runtimeType).toList();

      var overlay = StorageOverlay(storages: types, prefix: configurePrefix());

      _controller = await SettiController.consist(
        converter: converter,
        settings: settings,
        storageOverlay: overlay,
        isDebug: debug,
        caseFormat: config.caseFormat,
      );

      _isInitialized = true;
    } catch (e) {
      throw InitializationError(
          msg:
              "Initialization failed, and the settings were not applied. ${e.toString()}");
    }
  }

  String? configurePrefix() {
    if (prefix != null) {
      return prefix!;
    } else {
      var buffer = StringBuffer();
      if (config.useSettiPrefix) {
        buffer.write(
            '${config.caseFormat.apply('setti')}${config.delimiter.delimiter}');
      }
      if (config.useModelPrefix) {
        buffer.write(
            "${config.caseFormat.apply(name)}${config.delimiter.delimiter}");
      }

      if (buffer.isNotEmpty) {
        return buffer.toString();
      } else {
        return null;
      }
    }
  }

  operator [](Setting setting) {
    return get(setting);
  }

  operator []=(Setting setting, newValue) {
    _controller.update(setting.copyWith(defaultValue: newValue),
        sessionOnly: true);
  }

  Future<void> mut<T>(Setting<T> setting, T Function(T value) setter) async {
    _controller.update(
      setting.copyWith(defaultValue: setter(_controller.get(setting))),
      sessionOnly: false,
      onlyExisting: true,
    );
  }

  @override
  T get<T>(BaseSetting<T> setting) {
    return _controller.get(setting);
  }

  @override
  HashMap<String, Object> getAll() {
    return _controller.getAll();
  }

  @override
  bool contains<T>(BaseSetting<T> setting) {
    return _controller.contains(setting);
  }

  /// Дозволяє зберегти новий стан локальних налаштувань змінених через сесію
  @override
  Future<void> match() async {
    await _controller.match();
  }

  @override
  Future<void> update<T>(BaseSetting<T> setting) async {
    await _controller.update(setting);
  }

  @override
  void applyLayer(SettiLayer layer) {
    for (BaseSetting setting in layer.settings) {
      _controller.update(setting, sessionOnly: true);
      _appliedLayers['SessionLayer'] = "${layer.name}, ${layer.runtimeType}";
    }
  }

  @override
  FutureOr<bool> remove<T>(BaseSetting<T> setting) async {
    return await _controller.remove(setting);
  }

  @override
  FutureOr<bool> clear() async {
    return await _controller.clear();
  }
}
