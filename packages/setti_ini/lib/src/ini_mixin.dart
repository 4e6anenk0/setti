import 'dart:io';

import 'package:setti/setti.dart';

import 'ini_storage.dart';

mixin Ini on BaseSetti {
  final SettiConfig storageConfig = const SettiConfig(
    useModelPrefix: false,
    useSettiPrefix: false,
    delimiter: Delimiter.underscore,
    caseFormat: CaseFormat.uppercase,
  );

  ISettingsStorage get iniStorage =>
      IniStorage(path, name, config.storageFileName);

  @override
  Set<ISettingsStorage> get storages => {...super.storages, iniStorage};

  String get path => Directory.current.path;

  @override
  SettiConfig get config => storageConfig;
}
