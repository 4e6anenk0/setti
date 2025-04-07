import 'dart:async';
import 'dart:collection';

import '../../exceptions/exceptions.dart';
import '../../setti.dart';
import '../../setti_configurations.dart';
import '../../setti_controller.dart';
import '../../setting_types/base/setting.dart';
import '../../storage/storage.dart';
import '../../storage/storage_overlay.dart';

abstract class Setti extends BaseSetti {
  @override
  List<SettiPlatform> get platforms => SettiPlatforms.web;

  @override
  SettiPlatform getCurrentPlatform() {
    return SettiPlatform.web;
  }
}
