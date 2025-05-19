import 'dart:io';

import 'package:setti/setti.dart';
import 'package:setti_ini/setti_ini.dart';

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => const [counter, pathToProfiler];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.windows;

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
    defaultValue: 'С://.src/profiler.txt',
    saveMode: SaveMode.local,
  );
}

void main() async {
  //var config = AppConfig();

  //final appConfig = AppConfig();

  /* await appConfig.init(layers: {
    //AltConfig(),
    /* AltConfig2(
        pathToProfiler: Setting(
            id: 'PROFILER', defaultValue: '/', saveMode: SaveMode.local),
        counter:
            Setting(id: 'COUNTER', defaultValue: 1, saveMode: SaveMode.local)) */
  }); */

  //print(appConfig.appliedLayers);

  //print(appConfig.getCurrentPlatform());

  //print(appConfig.get(AppConfig.counter));

  //appConfig[AppConfig.counter] += 1; // this change only session setting

  /* appConfig.update(AppConfig.counter
      .copyWith(defaultValue: 1)); */ // this change both. Session and local

  //appConfig.match(); // save all session setting to local

  //appConfig.applyLayer(AltConfig());

  //appConfig.applyLayer(AltConfig2());

  //await appConfig.match();

  //print(appConfig[AppConfig.counter]);

  //print(appConfig.getAll());

  //print(appConfig.appliedLayers);

  //appConfig.applyLayer(layer);

  //appConfig.match();

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
