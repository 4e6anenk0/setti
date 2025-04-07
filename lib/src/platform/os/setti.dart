import 'dart:async';
import 'dart:collection';
import 'dart:io';

import '../../exceptions/exceptions.dart';
import '../../setti.dart';
import '../../setti_configurations.dart';
import '../../setti_controller.dart';
import '../../setting_types/base/setting.dart';
import '../../storage/storage.dart';
import '../../storage/storage_overlay.dart';

abstract class Setti extends BaseSetti {
  @override
  SettiPlatform getCurrentPlatform() {
    if (Platform.isAndroid) return SettiPlatform.android;
    if (Platform.isIOS) return SettiPlatform.ios;
    if (Platform.isMacOS) return SettiPlatform.macos;
    if (Platform.isWindows) return SettiPlatform.windows;
    if (Platform.isLinux) return SettiPlatform.linux;
    if (Platform.isFuchsia) return SettiPlatform.fuchsia;
    return SettiPlatform.other;
  }
}
