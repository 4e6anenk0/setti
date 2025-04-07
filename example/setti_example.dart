import 'dart:io';

import 'package:setti/setti.dart';
/* import 'package:setti/src/config_manager.dart';
import 'package:setti/src/setti.dart'; */

/* class AltConfig extends SettiLayer {
  AltConfig();

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.linux;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  /* final counter = const Setting(id: 'COUNTER', defaultValue: 3); */
  final counter = AppConfig.counter.copyWith(defaultValue: 3);
  final pathToProfiler =
      const Setting(id: 'PROFILER', defaultValue: '~/.src/profiler.txt');
} */

class AltConfig extends SettiLayer {
  AltConfig();

  @override
  String get name => 'MainLayer';

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.linux;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  /* final counter = const Setting(id: 'COUNTER', defaultValue: 3); */
  final counter = AppConfig.counter.copyWith(defaultValue: 3);
  final pathToProfiler =
      AppConfig.pathToProfiler.copyWith(defaultValue: '~/.src/profiler.txt');
}

class AltConfig2 extends SettiLayer {
  AltConfig2();

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.linux;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  /* final counter = const Setting(id: 'COUNTER', defaultValue: 3); */
  final counter = AppConfig.counter.copyWith(defaultValue: 100);
  final pathToProfiler = AppConfig.pathToProfiler.copyWith(defaultValue: '~/');
}

/* class AltConfig2 extends SettiLayer {
  AltConfig2({required this.counter, required this.pathToProfiler});

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.macos;

  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  final Setting<int> counter;
  final Setting<String> pathToProfiler;
} */

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
    defaultValue: 'С://.src/profiler.txt',
    saveMode: SaveMode.local,
  );
}

class Config extends SettiManager {
  @override
  List<BaseSetti> get configs => [AppConfig()];

  @override
  ConfigPolicy get missingConfigPolicy => ConfigPolicy.returnDefault;
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

  final config = Config();
  await config.init();

  config[AppConfig]![AppConfig.counter];

  config.getConfig<AppConfig>()!.get(AppConfig.counter);

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
