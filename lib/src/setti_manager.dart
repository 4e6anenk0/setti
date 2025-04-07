import 'dart:async';

import '../setti.dart';

enum ConfigPolicy { returnNull, throwException, returnDefault }

abstract class SettiManager {
  Future<void> init() async {
    for (BaseSetti config in configs) {
      await config.init();

      if (config.isInitialized) {
        _initializedConfigs[config.runtimeType] = config;
      }
    }
  }

  ConfigPolicy get missingConfigPolicy => ConfigPolicy.returnDefault;
  List<BaseSetti> get configs;

  final Map<Type, BaseSetti> _initializedConfigs = {};

  BaseSetti? operator [](Type configType) {
    return _initializedConfigs[configType] ??
        _missingConfigPolicy(defaultPolicy: missingConfigPolicy);
  }

  T? getConfig<T extends BaseSetti>() {
    return _initializedConfigs[T] ??
        _missingConfigPolicy(defaultPolicy: missingConfigPolicy);
  }

  _missingConfigPolicy<T extends BaseSetti>({
    required ConfigPolicy defaultPolicy,
    BaseSetting? setting,
  }) {
    switch (defaultPolicy) {
      case ConfigPolicy.returnNull:
        return null;

      case ConfigPolicy.throwException:
        throw StateError("Configuration is not initialized!");

      case ConfigPolicy.returnDefault:
        if (setting == null) {
          throw SettingNotFoundException(msg: "No default value!");
        }
        return setting.defaultValue;
    }
  }
}
