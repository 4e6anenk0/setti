import 'dart:io';

import '../../setti.dart';
import '../../setti_configurations.dart';

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
