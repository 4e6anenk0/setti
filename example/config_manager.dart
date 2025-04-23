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

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.windows;

  @override
  String get name => "APP_CONFIG";

  @override
  SettiConfig get config =>
      storageConfig.copyWith(useModelPrefix: false, useSettiPrefix: true);

  static final counter = Setting(
    id: 'COUNTER',
    defaultValue: 0,
    saveMode: SaveMode.local,
    //declarative: false,
  );

  static final pathToProfiler = Setting(
    id: 'PROFILER',
    defaultValue: 'C:\\.src\\profiler.txt',
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

  config[AppConfig][AppConfig.counter];

  config.getConfig(AppConfig).get(AppConfig.counter);
}
