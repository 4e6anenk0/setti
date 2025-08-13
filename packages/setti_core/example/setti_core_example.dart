import 'package:setti_core/setti_core.dart';
import 'package:setti_core/src/config.dart';
import 'package:setti_core/src/setting/types/base.dart';

class MyConfig extends Config {
  @override
  // TODO: implement setting
  List<BaseSetting> get setting => [Setting(id: 'counter')];
}

void main() async {
  final config = MyConfig();

  await config.init(); // Optional. Build all settings

  final counter = config.getSetting(); // Its build only need setting

  print(counter.get());

  print(config.get('counter'));
}
