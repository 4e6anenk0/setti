import 'dart:async';

import 'storage_worker_interface.dart';

abstract interface class ISettingsStorage implements ISettingsWorker {
  FutureOr<bool> init();

  String get id;
}
