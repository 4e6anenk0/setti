import 'dart:async';
import 'dart:collection';

import 'setti_layer.dart';
import 'setti.dart';
import 'setting_types/base/setting.dart';

abstract interface class ISettingsController {
  /// A method that helps to update data from the property.
  FutureOr<void> update<T>(BaseSetting<T> setting);

  /// A method that helps to get data from a property.
  FutureOr<T> get<T>(BaseSetting<T> setting);

  /// A method that helps to get data from a property.
  FutureOr<HashMap<String, Object>> getAll();

  FutureOr<bool> remove<T>(BaseSetting<T> setting);

  /// Видалити усі налаштування
  FutureOr<bool> clear();

  /// Перевірити чи є налаштування в сховищах
  FutureOr<bool> contains<T>(BaseSetting<T> setting);
}

/// Інтерфейс для роботи з сесійними налаштуваннями
abstract interface class ISessionSettingsController {
  void setForSession<T>(BaseSetting<T> setting);
}

/// Інтерфейс для роботи з локальним сховищем
abstract interface class ILocalSettingsController {
  Future<void> setForLocal<T>(BaseSetting<T> setting);
}

/// Інтерфейс для синхронізації налаштувань
abstract interface class IMatchableSettings {
  FutureOr<void> match();
}

abstract interface class ILayerController {
  void applyLayer(SettiLayer layer);
}

abstract interface class IConfigsManager {
  FutureOr<void> update<T extends BaseSetti>(BaseSetting<T> setting);

  FutureOr<T> get<T extends BaseSetti>(BaseSetting<T> setting);

  FutureOr<List<BaseSetti>> getAll();

  FutureOr<bool> remove<T extends BaseSetti>(BaseSetting<T> setting);

  FutureOr<bool> clear<T extends BaseSetti>();

  FutureOr<bool> contains<T extends BaseSetti>(BaseSetting<T> setting);
}
