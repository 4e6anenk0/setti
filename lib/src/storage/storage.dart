import 'dart:async';

import '../exceptions/exceptions.dart';
import 'interfaces/settings_storage_interface.dart';
import 'interfaces/storage_worker_interface.dart';
import 'local/workers/multi_storage_worker.dart';
import 'local/workers/single_storage_worker.dart';
import 'session_storage.dart';

/// Зберігає доступ до всіх ініціалізованих сховищ та надає доступ до воркерів які працюють з підмножиною сховищ як з одним сховищем
class SettingsStorage {
  SettingsStorage._();

  static final SettingsStorage _storage = SettingsStorage._();

  Future<void> init() async {
    if (_storages.isNotEmpty) {
      await Future.wait(_storages.map((storage) async => await storage.init()));
      _isInitialized = true;
    } else {
      throw LocalStorageException(
        msg: "Not any storages for initialization.",
        solutionMsg:
            """Try installing the package required to support the desired storage.
If the package is already installed, make sure you have mixed it with your custom configuration class based on Setti.""",
      );
    }
  }

  final Set<ISettingsStorage> _storages = {};

  factory SettingsStorage.getInstance() {
    return _storage;
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool get isNotInitialized => !_isInitialized;

  void addStorage(ISettingsStorage storage) {
    _storages.add(storage);
  }

  void addStorages(Set<ISettingsStorage> storages) {
    _storages.addAll(storages);
  }

  /// Метод який дозволяє отримати воркер який працює з обмеженою множиною сховищ
  ISettingsWorker getWorker(List<Type> storageTypes) {
    Iterable<ISettingsStorage> neededStorages = _storages
        .where((storage) => storageTypes.contains(storage.runtimeType));

    if (neededStorages.length == 1) {
      return SingleSettingsStorage(neededStorages.first);
    } else if (neededStorages.isEmpty) {
      return SessionStorage();
      /* throw Exception([
        'There are no repositories matching the given types: ${storageTypes.toString()}.'
      ]); */
    } else {
      return MultiSettingsStorage(storages: neededStorages.toList());
    }
  }

  ISettingsStorage? getStorage(Type typeOfStorage) {
    return _storages
        .firstWhere((storage) => storage.runtimeType == typeOfStorage);
  }
}
