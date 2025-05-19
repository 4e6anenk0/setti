# Швидкий старт

## Встановлення

Встановіть бібліотеку для вашого dart проєкту:

```sh
dart pub get setti
```

Або, якщо ви хочете використовувати цю бібліотеку у вашому Flutter проєкті:

```sh
flutter pub get flutter-setti
```

## Як почати використовувати Setti

```dart
import 'package:setti/setti.dart';

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, pathToProfiler];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  @override
  String get name => "APP_CONFIG";

  static final counter = Setting(
    id: 'COUNTER',
    defaultValue: 0,
    saveMode: SaveMode.local,
  );

  static final pathToProfiler = Setting(
    id: 'PROFILER',
    defaultValue: '~/.src/profiler.txt',
    saveMode: SaveMode.local,
  );
}

void main() async {
  final appConfig = AppConfig();

  await appConfig.init();

  aapConfig[AppConfig.counter] += 1;

  await config.match();

  print(appConfig[AppConfig.counter]);
  print(appConfig[AppConfig.pathToProfiler]);

  await config.remove(AppConfig.pathToProfiler);
}
```
