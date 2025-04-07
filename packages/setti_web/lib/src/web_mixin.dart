import 'package:setti/setti.dart';

import 'web_storage.dart';

mixin Web on Setti {
  final SettiConfig storageConfig = const SettiConfig(
    useModelPrefix: false,
    useSettiPrefix: false,
    delimiter: Delimiter.none,
    caseFormat: CaseFormat.preserve,
  );

  ISettingsStorage get webStorage => WebStorage();

  @override
  Set<ISettingsStorage> get storages => {...super.storages, webStorage};

  @override
  SettiConfig get config => storageConfig;
}
