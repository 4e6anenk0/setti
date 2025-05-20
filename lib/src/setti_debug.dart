import 'dart:async';

import 'dart:collection';

import 'package:setti/src/setting_types/base/setting.dart';
import 'package:setti/src/settings_controller_interface.dart';

class DebugFlag {
  /// Автоматически определённый debug-режим
  static final bool _isAssertBasedDebug = () {
    var debug = false;
    assert(() {
      debug = true;
      return true;
    }());
    return debug;
  }();

  /// Принудительный флаг (если null — используется auto)
  static bool? _manualOverride;

  /// Определяет, в debug ли сейчас
  static bool get isDebug => _manualOverride ?? _isAssertBasedDebug;

  /// Включает debug-режим вручную
  static void enableDebug() => _manualOverride = true;

  /// Выключает debug-режим вручную
  static void disableDebug() => _manualOverride = false;

  /// Сбрасывает ручное переопределение (возвращает к авто)
  static void reset() => _manualOverride = null;
}

class DebugController implements ISettingsController {
  @override
  FutureOr<bool> clear() {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  FutureOr<bool> contains<T>(BaseSetting<T> setting) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  FutureOr<T> get<T>(BaseSetting<T> setting) {
    // TODO: implement get
    throw UnimplementedError();
  }

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

  @override
  FutureOr<void> update<T>(BaseSetting<T> setting) {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class SettiDebug {
  SettiDebug(this.controller);

  bool _debug = false;

  ISettingsController get debug {
    return controller;
  }

  final ISettingsController controller;

  void configureDebug(
      Function({
        ISettingsController controller,
      }) runner) {}

  void debugRun(Function(ISettingsController controller) method) {
    method(controller);
  }
}
