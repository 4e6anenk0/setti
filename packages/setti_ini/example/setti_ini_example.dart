import 'dart:io';

import 'package:setti/setti.dart';
import 'package:setti_ini/setti_ini.dart';

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  @override
  String get path => Directory.current.path;

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
    defaultValue: '~/.src/profiler.txt',
    saveMode: SaveMode.local,
  );
}

void main() async {
  //var config = AppConfig();

  final appConfig = AppConfig();

  await appConfig.init();

  print(appConfig.getCurrentPlatform());

  //await config.init();

  //await config.mut(AppConfig.counter, (value) => value + 1);

  //config[AppConfig.counter] += 1;

  //await config.update(AppConfig.counter.copyWith(defaultValue: 2));

  //await config.update(AppConfig.counter.set((value) => value + 1));

  //print(config[AppConfig.counter]);
  //print(config[AppConfig.pathToProfiler]);

  //await config.match();

  //await config.remove(AppConfig.pathToProfiler);
}
