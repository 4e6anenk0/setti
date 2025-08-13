import 'dart:io';

import 'package:checkit/checkit.dart';
import 'package:setti/setti.dart';
import 'package:setti_ini/setti_ini.dart';

class AdminLayer extends SettiLayer {
  @override
  List<BaseSetting> get settings => [counter, email, pass];

  final counter = AppConfig.counter.copyWith();

  final email = AppConfig.email.copyWith();

  final pass =
      AppConfig.pass.copyWith(validators: [PasswordValidator.strong()]);
}

class UserLayer extends SettiLayer {
  @override
  List<BaseSetting> get settings => [counter, email, pass];

  final counter = AppConfig.counter.copyWith();

  final email = AppConfig.email.copyWith();

  final pass =
      AppConfig.pass.copyWith(validators: [PasswordValidator.typical()]);
}

class AppConfig extends Setti with Ini {
  @override
  List<BaseSetting> get settings => [];

  @override
  List<LayerDesc> get layers => [
        LayerDesc(platforms: SettiPlatforms.general, factory: () => UserLayer())
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  @override
  String get name => "APP_CONFIG";

  @override
  SettiConfig get config => storageConfig.copyWith(
        useModelPrefix: false,
        useSettiPrefix: true,
      );

  static final counter = Setting<int>(
    id: 'COUNTER',
    defaultValue: 0,
    saveMode: SaveMode.local,
    //declarative: false,
    validators: [NumValidator.min(0)],
  );

  static final email = Setting<String>(
    id: 'EMAIL',
    defaultValue: 'email@domain.com',
    saveMode: SaveMode.local,
    validators: [StringValidator.min(10), StringValidator.email()],
  );

  static final pass = Setting<String>(
      id: 'PASSWORD',
      defaultValue: 'passwoRD123@',
      saveMode: SaveMode.local,
      validators: [PasswordValidator.simple()]);
}

class Config extends ConfigManager {
  @override
  List<BaseSetti> get configs => [AppConfig()];
}

void main() async {
  final isAdmin = true;

  final config = Config();
  await config.init();

  /* if (isAdmin) {
    config[AppConfig].applyLayer(AdminLayer());
  } */

  //config[AppConfig][AppConfig.counter] = 1; // Validation Passed
  //config[AppConfig][AppConfig.email] =
  //    'abc@aa'; // Validation Failed (1 Problem)
  //config[AppConfig][AppConfig.email] = 'abc'; // Validation Failed (2 Problem)
  config[AppConfig][AppConfig.email] = 'test@gmail.com'; // Validation Passed
  //config[AppConfig][AppConfig.pass] = '1234'; // Validation Failed (2 Problem)
  config[AppConfig][AppConfig.pass] = '12#paS932@1';
  print(config[AppConfig].getAll());
  //await config[AppConfig].match();
}
