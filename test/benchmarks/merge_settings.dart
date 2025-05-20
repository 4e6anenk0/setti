import 'dart:collection';

import 'package:setti/setti.dart';

void benchmarkMergeSettings(int size, double duplicateRatio) {
  // Генерация тестовых данных
  final baseSettings = List.generate(
      size, (i) => Setting(id: 'base$i', defaultValue: 'baseValue$i'));
  final layerSettings = <Setting>[];
  for (var i = 0; i < size; i++) {
    // Создаём дубликаты для duplicateRatio элементов
    final id =
        (i < size * duplicateRatio) ? 'dup${i % (size ~/ 10)}' : 'layer$i';
    layerSettings.add(Setting(id: id, defaultValue: 'layerValue$i'));
  }

  // Вариант 1: addEntries с map
  final stopwatch1 = Stopwatch()..start();

  final settingsMap1 = HashMap<String, BaseSetting>();

  settingsMap1.addEntries(layerSettings.map((e) => MapEntry(e.id, e)));

  settingsMap1.addEntries(baseSettings
      .where((e) => !settingsMap1.containsKey(e.id))
      .map((e) => MapEntry(e.id, e)));

  final result1 = settingsMap1.values.toList();
  stopwatch1.stop();

  // Вариант 2: Прямой цикл
  final stopwatch2 = Stopwatch()..start();

  final settingsMap2 = HashMap<String, BaseSetting>();

  for (final setting in layerSettings) {
    settingsMap2[setting.id] = setting;
  }

  for (final setting in baseSettings) {
    if (!settingsMap2.containsKey(setting.id)) {
      settingsMap2[setting.id] = setting;
    }
  }
  final result2 = settingsMap2.values.toList();
  stopwatch2.stop();

  print('First: addEntries with map: ${stopwatch1.elapsedMicroseconds} µs');
  print('Second: Direct loop: ${stopwatch2.elapsedMicroseconds} µs');
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
