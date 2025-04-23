import 'dart:io';

import 'package:setti/setti.dart';

class LinuxConfig extends SettiLayer {
  LinuxConfig();

  @override
  String get name => 'LinuxLayer';

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.linux;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  final counter = AppConfig.counter.copyWith(defaultValue: 3);
  final pathToProfiler =
      AppConfig.pathToProfiler.copyWith(defaultValue: '~/.src/profiler.txt');
}

class MacConfig extends SettiLayer {
  MacConfig();

  @override
  String get name => 'MacLayer';

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.macos;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  final counter = AppConfig.counter.copyWith(defaultValue: 100);
  final pathToProfiler = AppConfig.pathToProfiler.copyWith(defaultValue: '~/');
}

class WindowsConfig extends SettiLayer {
  @override
  List<SettiPlatform> get platforms => SettiPlatforms.windows;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  final counter = AppConfig.counter.copyWith(defaultValue: 2);
  final pathToProfiler =
      AppConfig.pathToProfiler.copyWith(defaultValue: 'C:\\.src\\profiler.txt');
}

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler, generalSetting];

  @override
  List<SettiLayer> get layers => [
        MacConfig(),
        LinuxConfig(),
        WindowsConfig(),
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  @override
  String get name => "APP_CONFIG";

  @override
  SettiConfig get config =>
      storageConfig.copyWith(useModelPrefix: false, useSettiPrefix: true);

  static const counter = Setting(
    id: 'COUNTER',
    defaultValue: 0,
    saveMode: SaveMode.local,
    //declarative: false,
  );

  static const pathToProfiler = Setting(
    id: 'PROFILER',
    defaultValue: '',
    saveMode: SaveMode.local,
  );

  static const generalSetting = Setting(
    id: 'GENERAL',
    defaultValue: 'general',
    saveMode: SaveMode.local,
  );
}

class Config extends ConfigManager {
  @override
  List<BaseSetti> get configs => [AppConfig()];
}

void main() async {
  final config = Config();
  await config.init();

  print(config[AppConfig][AppConfig.counter]);

  print(config.getConfig(AppConfig).get(AppConfig.counter));

  print(config.getConfig(AppConfig).getCurrentPlatform());

  print(config[AppConfig].get(AppConfig.generalSetting));

  print(config[AppConfig].appliedLayers);
}
