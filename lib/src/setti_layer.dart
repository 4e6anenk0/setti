import '../setti.dart';

abstract class SettiLayer {
  const SettiLayer();

  List<BaseSetting> get settings;

  List<SettiPlatform> get platforms;

  String get name => 'UnnamedLayer';
}
