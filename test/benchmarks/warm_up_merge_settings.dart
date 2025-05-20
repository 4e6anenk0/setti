import 'dart:collection';

import 'package:setti/setti.dart';

void benchmarkMergeSettings(int size, double duplicateRatio) {
  final baseSettings = List.generate(
      size, (i) => Setting(id: 'base$i', defaultValue: 'baseValue$i'));
  final layerSettings = <BaseSetting>[];
  for (var i = 0; i < size; i++) {
    final id =
        (i < size * duplicateRatio) ? 'dup${i % (size ~/ 10)}' : 'layer$i';
    layerSettings.add(Setting(id: id, defaultValue: 'layerValue$i'));
  }

  // Прогрев
  for (var i = 0; i < 100; i++) {
    final map1 = HashMap<String, BaseSetting>();
    map1.addEntries(layerSettings.map((e) => MapEntry(e.id, e)));
    final map2 = HashMap<String, BaseSetting>();
    for (final setting in layerSettings) {
      map2[setting.id] = setting;
    }
  }

  // Тест addEntries
  var total1 = 0;
  for (var i = 0; i < 100; i++) {
    final stopwatch = Stopwatch()..start();
    final settingsMap = HashMap<String, BaseSetting>();
    settingsMap.addEntries(layerSettings.map((e) => MapEntry(e.id, e)));
    settingsMap.addEntries(baseSettings
        .where((e) => !settingsMap.containsKey(e.id))
        .map((e) => MapEntry(e.id, e)));
    final result = settingsMap.values.toList();
    stopwatch.stop();
    total1 += stopwatch.elapsedMicroseconds;
  }

  // Тест цикла
  var total2 = 0;
  for (var i = 0; i < 100; i++) {
    final stopwatch = Stopwatch()..start();
    final settingsMap = HashMap<String, BaseSetting>();
    for (final setting in layerSettings) {
      settingsMap[setting.id] = setting;
    }
    for (final setting in baseSettings) {
      if (!settingsMap.containsKey(setting.id)) {
        settingsMap[setting.id] = setting;
      }
    }
    final result = settingsMap.values.toList();
    stopwatch.stop();
    total2 += stopwatch.elapsedMicroseconds;
  }

  print('addEntries with map (avg): ${total1 / 100} µs');
  print('Direct loop (avg): ${total2 / 100} µs');
}

void main() {
  // Тест с разными размерами и долей дубликатов
  print('Small list (100 elements, 0% duplicates):');
  benchmarkMergeSettings(100, 0.0);
  print('\nMedium list (1000 elements, 50% duplicates):');
  benchmarkMergeSettings(1000, 0.5);
  print('\nLarge list (10000 elements, 90% duplicates):');
  benchmarkMergeSettings(10000, 0.9);
}
