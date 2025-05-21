import 'dart:io';

import 'package:setti/setti.dart';
import 'package:setti/src/validation/validators/num_validators.dart';
import 'package:setti/src/validation/validators/string_validators.dart';
import 'package:setti/src/validation/validators/validators.dart';
import 'package:setti_ini/setti_ini.dart';

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [counter, email, pass];

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

  static final email = Setting<String>(
    id: 'EMAIL',
    defaultValue: 'email@domain.com',
    saveMode: SaveMode.local,
    validator: AndValidator([
      MinLengthValidator(5),
      PatternValidator(RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$'))
    ]),
  );

  static const pass = Setting<String>(
      id: 'GENERAL',
      defaultValue: 'general',
      saveMode: SaveMode.local,
      validator: AndValidator([]));
}

class Config extends ConfigManager {
  @override
  List<BaseSetti> get configs => [AppConfig()];
}

void main() async {
  final config = Config();
  await config.init();

  //config[AppConfig][AppConfig.counter] = 1; // Validation Pass
  /* config[AppConfig][AppConfig.email] =
      'abc@aa'; // Validation Failed (1 Problem)
  config[AppConfig][AppConfig.email] = 'abc'; // Validation Failed (2 Problem) */
  config[AppConfig][AppConfig.email] = 'test@gmail.com'; // Validation Pass
  //config[AppConfig][AppConfig.generalSetting] = 'custom'; // Validation Pass
  print(config[AppConfig].getAll());
  //await config[AppConfig].match();
}
