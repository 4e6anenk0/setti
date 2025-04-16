import 'dart:async';

import '../setti.dart';

enum ConfigPolicy {
  returnNull,
  throwException,
  returnDefault,
}

abstract class ConfigManager {
  final Map<Type, BaseSetti> _initializedConfigs = {};

  final List<String> _notInitializedConfigs = [];

  List<BaseSetti> get configs;

  Future<void> init() async {
    for (final config in configs) {
      await config.init();
      if (config.isInitialized) {
        _initializedConfigs[config.runtimeType] = config;
      } else {
        _notInitializedConfigs.add(config.name);
      }
    }
  }

  BaseSetti operator [](Type configType) => getConfig(configType);

  BaseSetti getConfig(Type configType) {
    final config = _initializedConfigs[configType];

    if (config != null) return config;

    throw ConfigManagerException(
      msg: '''
Config of type `$configType` was requested but not found.

Possible reasons:
- The config was never initialized.
- The platform-specific setup may be incorrect.

Not initialized configs:
${_notInitializedConfigs.join(', ')}
''',
      solutionMsg:
          'Ensure that `$configType` is properly initialized before accessing it, or that its target platform matches the current platform.',
    );
  }
}
