import 'package:web/web.dart' as web;
import 'package:setti_web/setti_web.dart';
import 'package:setti/setti.dart';

class WebConfig extends Setti with Web {
  @override
  List<BaseSetting> get settings => [lastVisit];

  static final lastVisit = Setting(
    id: 'lastVisit',
    defaultValue: 'XX:XX:XX',
    saveMode: SaveMode.local,
  );
}

void main() async {
  final webConfig = WebConfig();
  await webConfig.init();
  var lastVisit = webConfig.get(WebConfig.lastVisit);

  final now = DateTime.now();
  if (lastVisit == WebConfig.lastVisit.defaultValue) {
    lastVisit = "${now.hour}:${now.minute}:${now.second}";
    print(lastVisit);
  }
  final element = web.document.querySelector('#output') as web.HTMLDivElement;
  element.textContent =
      'The time is ${now.hour}:${now.minute}:${now.second} '
      'and your Dart web app is running! '
      'Last visit: $lastVisit';

  lastVisit = "${now.hour}:${now.minute}:${now.second}";
  webConfig[WebConfig.lastVisit] = lastVisit;
  webConfig.match();
}
