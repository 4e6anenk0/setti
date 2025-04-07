import 'dart:async';

import 'package:setti/src/setti.dart';
import 'package:setti/src/storage/interfaces/storage_worker_interface.dart';

import '../../interfaces/settings_storage_interface.dart';

mixin Yaml on BaseSetti {
  @override
  Set<ISettingsStorage> get storages => {};
}

class YamlStorage implements ISettingsStorage {
  @override
  Future<void> clear() {
    throw UnimplementedError();
  }

  @override
  Future<T?> getSetting<T>(String id, T defaultValue) {
    throw UnimplementedError();
  }

  @override
  Future<bool> init() {
    throw UnimplementedError();
  }

  @override
  Future<bool> contains(String id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeSetting(String id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setSetting(String id, Object value) {
    throw UnimplementedError();
  }

  @override
  // TODO: implement id
  String get id => throw UnimplementedError();
}
