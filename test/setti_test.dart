import 'package:mockito/mockito.dart';
import 'package:setti/setti.dart';
import 'package:setti/src/setti_controller.dart';
import 'package:test/test.dart';

import 'mocks/mock.dart';
import 'mocks/mock.mocks.dart';

void main() {
  group('SettiController', () {
    late MockStorageOverlay storageOverlay;
    late MockISettingConverter converter; // Згенерований mockito
    late CaseFormat caseFormat;
    late SettiController controller;

    setUp(() async {
      storageOverlay = MockStorageOverlay();
      converter = MockISettingConverter();
      caseFormat = CaseFormat.uppercase;
      when(storageOverlay.storages).thenReturn([storage]);
      when(storageOverlay.prefix).thenReturn(null);

      // Налаштування поведінки converter
      when(converter.convertTo(any)).thenAnswer((inv) {
        final setting = inv.positionalArguments[0] as BaseSetting;
        return Setting(
          id: setting.id,
          defaultValue: setting.defaultValue,
          saveMode: setting.saveMode,
          declarative: (setting as Setting).declarative ?? true,
        );
      });
      when(converter.convertValue(any, any))
          .thenAnswer((inv) => inv.positionalArguments[0]);
    });

    test('Initializes with declarative settings in autoManageStorageMode true',
        () async {
      final settings = [
        Setting(id: 'COUNTER', defaultValue: 0, saveMode: SaveMode.local),
      ];
      when(storage.contains('COUNTER')).thenAnswer((_) async => false);
      when(storage.getSetting('COUNTER', any)).thenAnswer((_) async => null);
      when(storage.contains('snapshot')).thenAnswer((_) async => false);

      controller = await SettiController.consist(
        settings: settings,
        converter: converter,
        storageOverlay: storageOverlay,
        caseFormat: caseFormat,
        autoManageStorageMode: true,
      );

      await controller.init();
      verify(storage.setSettings({'COUNTER': 0})).called(1);
      expect(controller.get(Setting(id: 'COUNTER', defaultValue: 0)), 0);
    });

    // Інші тести без змін
    test('Initializes with declarative settings in autoManageStorageMode false',
        () async {
      final settings = [
        Setting(id: 'COUNTER', defaultValue: 0, saveMode: SaveMode.local),
      ];
      when(storage.contains('COUNTER')).thenAnswer((_) async => false);
      when(storage.getSetting('COUNTER', any)).thenAnswer((_) async => null);

      controller = await SettiController.consist(
        settings: settings,
        converter: converter,
        storageOverlay: storageOverlay,
        caseFormat: caseFormat,
        autoManageStorageMode: false,
      );

      await controller.init();
      verify(storage.setSettings({'COUNTER': 0})).called(1);
      expect(controller.get(Setting(id: 'COUNTER', defaultValue: 0)), 0);
    });

    test('Throws ControllerException for non-declarative missing settings',
        () async {
      final settings = [
        Setting(
            id: 'COUNTER',
            defaultValue: 0,
            saveMode: SaveMode.local,
            declarative: false),
      ];
      when(storage.contains('COUNTER')).thenAnswer((_) async => false);
      when(storage.getSetting('COUNTER', any)).thenAnswer((_) async => null);

      controller = await SettiController.consist(
        settings: settings,
        converter: converter,
        storageOverlay: storageOverlay,
        caseFormat: caseFormat,
        autoManageStorageMode: true,
      );

      expect(() => controller.init(), throwsA(isA<ControllerException>()));
    });

    test('Handles session-only settings', () async {
      final settings = [
        Setting(id: 'THEME', defaultValue: 'light', saveMode: SaveMode.session),
      ];

      controller = await SettiController.consist(
        settings: settings,
        converter: converter,
        storageOverlay: storageOverlay,
        caseFormat: caseFormat,
        autoManageStorageMode: true,
      );

      await controller.init();
      expect(
          controller.get(Setting(id: 'THEME', defaultValue: 'light')), 'light');
      verifyNever(storage.setSettings(any));
    });
  });
}
