import 'package:mocktail/mocktail.dart';
import 'package:setti/setti.dart';
import 'package:setti/src/converter/converter.dart';
import 'package:setti/src/converter/converter_interface.dart';
import 'package:setti/src/setti_controller.dart';
import 'package:setti/src/storage/storage_overlay.dart';
import 'package:test/test.dart';

class MockStorageOverlay extends Mock implements StorageOverlay {}

void main() {
  group('SettiController', () {
    late MockStorageOverlay storageOverlay;
    late ISettingConverter converter;
    late CaseFormat caseFormat;
    late SettiController controller;

    setUp(() async {
      storageOverlay = MockStorageOverlay();
      converter = SettingConverter();
      caseFormat = CaseFormat.uppercase;
    });

    test(
      'Test 1: Verify that the snapshot is not created. (autoManageStorageMode: false)',
      () async {
        final settings = [
          Setting(id: 'COUNTER', defaultValue: 0, saveMode: SaveMode.local),
        ];
        when(() => storageOverlay.contains(any()))
            .thenAnswer((_) async => false);
        when(() => storageOverlay.getSetting(any(), any()))
            .thenAnswer((_) async => null);
        when(() => storageOverlay.contains(any()))
            .thenAnswer((_) async => false);

        controller = await SettiController.consist(
          settings: settings,
          converter: converter,
          storageOverlay: storageOverlay,
          caseFormat: caseFormat,
          autoManageStorageMode: false,
        );

        await controller.init();
        verify(() => storageOverlay.setSettings({'COUNTER': 0})).called(1);
        expect(controller.get(Setting(id: 'COUNTER', defaultValue: 0)), 0);
      },
    );

    test(
      'Test 2: Verify that the snapshot is created (autoManageStorageMode: true)',
      () async {
        final settings = [
          Setting(id: 'COUNTER', defaultValue: 0, saveMode: SaveMode.local),
        ];

        when(() => storageOverlay.contains('SNAPSHOT')).thenAnswer((_) async {
          print('Called contains(SNAPSHOT)');
          return true;
        });

        when(() => storageOverlay.getSetting('SNAPSHOT', <String>[]))
            .thenAnswer((invocation) async {
          final defaultValue = invocation.positionalArguments[1];
          print(
              'Called getSetting(SNAPSHOT, $defaultValue, type: ${defaultValue.runtimeType})');
          return <String>[];
        });

        when(() => storageOverlay.getSetting('SNAPSHOT', <String>['COUNTER']))
            .thenAnswer((invocation) async {
          final defaultValue = invocation.positionalArguments[1];
          print(
              'Called getSetting(SNAPSHOT, $defaultValue, type: ${defaultValue.runtimeType})');
          return <String>['COUNTER'];
        });

        when(() => storageOverlay.getSetting('COUNTER', any()))
            .thenAnswer((_) async => 0);

        when(() => storageOverlay.contains('COUNTER'))
            .thenAnswer((_) async => true);

        when(() => storageOverlay.setSettings(any()))
            .thenAnswer((_) async => true);

        when(() => storageOverlay.setSetting(any(), any()))
            .thenAnswer((invocation) async {
          final id = invocation.positionalArguments[0];
          final value = invocation.positionalArguments[1];
          print('Called setSetting($id, $value, type: ${value.runtimeType})');
          return true;
        });

        when(() => storageOverlay.removeSettings(any()))
            .thenAnswer((_) async {});

        when(() => storageOverlay.removeSetting(any()))
            .thenAnswer((_) async => true);

        when(() => storageOverlay.clear()).thenAnswer((_) async {});

        when(() => storageOverlay.removeCache()).thenAnswer((_) {});

        when(() => storageOverlay.removeCacheFor(any()))
            .thenAnswer((_) async {});

        controller = await SettiController.consist(
          settings: settings,
          converter: converter,
          storageOverlay: storageOverlay,
          caseFormat: caseFormat,
          autoManageStorageMode: true,
        );

        await controller.init();

        expect(controller.get(Setting(id: 'COUNTER', defaultValue: 0)), 0);
      },
    );
  });
}
