import 'dart:io';

import 'package:setti/setti.dart';

import 'ini_storage.dart';

mixin Ini on BaseSetti {
  final SettiConfig iniConfig = SettiConfig(
    useModelPrefix: false,
    useSettiPrefix: false,
    delimiter: Delimiter.underscore,
    caseFormat: CaseFormat.uppercase,
  );

  @override
  Set<ISettingsStorage> get storages => {
    IniStorage(path, name, config.storageFileName),
  };

  String get path => Directory.current.path;

  @override
  SettiConfig get config => iniConfig;
}
