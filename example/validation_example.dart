import 'dart:io';

import 'package:setti/setti.dart';
import 'package:setti/src/validation/validators/num_validators.dart';
import 'package:setti/src/validation/validators/string_validators.dart';
import 'package:setti_ini/setti_ini.dart';

class LinuxConfig extends SettiLayer {
  final counter = AppConfig.counter.copyWith(defaultValue: 3);
  final profiler =
      AppConfig.pathToProfiler.copyWith(defaultValue: '~/.src/profiler.txt');

  @override
  String get name => 'LinuxLayer';

  @override
  List<BaseSetting> get settings => [
        counter,
        profiler,
      ];
}

class MacConfig extends SettiLayer {
  final counter = AppConfig.counter.copyWith(defaultValue: 100);
  final profiler = AppConfig.pathToProfiler.copyWith(defaultValue: '~/');

  @override
  String get name => 'MacLayer';

  @override
  List<BaseSetting> get settings => [
        counter,
        profiler,
      ];
}

class WindowsConfig extends SettiLayer {
  final counter = AppConfig.counter.copyWith(defaultValue: 2);
  final profiler =
      AppConfig.pathToProfiler.copyWith(defaultValue: 'C:\\.src\\profiler.txt');

  @override
  List<BaseSetting> get settings => [
        counter,
        profiler,
      ];
}

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler, generalSetting];

  @override
  List<LayerDesc> get layers => [
        LayerDesc(
          platforms: SettiPlatforms.linux,
          factory: () => LinuxConfig(),
        ),
        LayerDesc(
          platforms: SettiPlatforms.macos,
          factory: () => MacConfig(),
        ),
        LayerDesc(
          platforms: SettiPlatforms.windows,
          factory: () => WindowsConfig(),
        )
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  @override
  String get name => "APP_CONFIG";

  @override
  SettiConfig get config =>
      storageConfig.copyWith(useModelPrefix: false, useSettiPrefix: true);

  static const counter = Setting<int>(
    id: 'COUNTER',
    defaultValue: 0,
    saveMode: SaveMode.local,
    //declarative: false,
    validator: MinValueValidator(0),
  );

  static const pathToProfiler = Setting<String>(
    id: 'PROFILER',
    defaultValue: '~/',
    saveMode: SaveMode.local,
    validator: NonEmptyValidator(),
  );

  static const generalSetting = Setting<String>(
      id: 'GENERAL',
      defaultValue: 'general',
      saveMode: SaveMode.local,
      validator: OneOfValidator({'general', 'advanced', 'custom'}));
}

class Config extends ConfigManager {
  @override
  List<BaseSetti> get configs => [AppConfig()];
}

class AdditionalLayer extends SettiLayer {
  const AdditionalLayer();

  @override
  List<BaseSetting> get settings => [
        Setting(id: 'COUNTER', defaultValue: 1000),
      ];
}

void main() async {
  final config = Config();
  await config.init();

  //config[AppConfig][AppConfig.counter] = -1; // Validation Failed
  //config[AppConfig][AppConfig.pathToProfiler] = ''; // Validation Failed
  //config[AppConfig][AppConfig.generalSetting] = 'other'; // Validation Failed

  config[AppConfig][AppConfig.counter] = 1; // Validation Pass
  config[AppConfig][AppConfig.pathToProfiler] = '/opt'; // Validation Pass
  config[AppConfig][AppConfig.generalSetting] = 'custom'; // Validation Pass
  print(config[AppConfig].getAll());
  //await config[AppConfig].match();
}
