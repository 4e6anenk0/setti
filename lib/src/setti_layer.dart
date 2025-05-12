import '../setti.dart';

typedef LayerFactory = SettiLayer Function();

abstract class SettiLayer {
  const SettiLayer();

  List<BaseSetting> get settings;

  List<SettiPlatform> get platforms;

  String get name => 'UnnamedLayer';
}

class LayerDesc {
  final List<SettiPlatform> platforms;
  final LayerFactory factory;

  LayerDesc({required this.platforms, required this.factory});
}
