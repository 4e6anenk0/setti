import 'dart:io';

import 'package:setti/setti.dart';
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
  String get path =>
      "${Directory.current.path}/.settings"; // this change the path to settings file

  @override
  SettiConfig get config => storageConfig.copyWith(
      useModelPrefix: false,
      useSettiPrefix: true,
      storageFileName: "my_config"); // this change the filename

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

  print(config[AppConfig][AppConfig.counter]);

  print(config.getConfig(AppConfig).get(AppConfig.counter));

  print(config.getConfig(AppConfig).getCurrentPlatform());

  print(config[AppConfig].get(AppConfig.generalSetting));

  //config[AppConfig][AppConfig.counter] += 10;

  //config[AppConfig][AppConfig.generalSetting] = 'new string';
  /* config[AppConfig]
      .update(AppConfig.generalSetting.copyWith(defaultValue: 'new string')); */

  config[AppConfig].mut(AppConfig.generalSetting, (value) => "new string");

  //await config[AppConfig].match();

  print(config[AppConfig][AppConfig.counter]);

  print(config[AppConfig].appliedLayers);

  config[AppConfig].applyLayer(AdditionalLayer());

  print(config[AppConfig].appliedLayers);

  print(config[AppConfig][AppConfig.counter]);

  config[AppConfig][AppConfig.counter] = 2;

  await config[AppConfig].update(AppConfig.counter.copyWith(defaultValue: 12));

  await config[AppConfig].match();
}
