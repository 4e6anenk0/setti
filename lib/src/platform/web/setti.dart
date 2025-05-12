import '../../setti.dart';
import '../../setti_configurations.dart';

abstract class Setti extends BaseSetti {
  @override
  List<SettiPlatform> get platforms => SettiPlatforms.web;

  @override
  SettiPlatform getCurrentPlatform() {
    return SettiPlatform.web;
  }
}
