import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:setti/setti.dart';
import 'package:setti/src/converter/converter_interface.dart';
import 'package:setti/src/storage/storage_overlay.dart';
import 'package:test/test.dart';

// Генерація моків за допомогою mockito
@GenerateMocks([StorageOverlay, ISettingConverter, ISettingsStorage])
import 'mock.mocks.dart';
