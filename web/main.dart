import 'package:setti/setti.dart';

class WebConfig extends Setti with Web {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

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

  var webConfig = WebConfig();

  await webConfig.init();

  print(webConfig.getCurrentPlatform());

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
