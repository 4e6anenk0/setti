import 'package:setti_core/src/setting/types/base.dart';

abstract class Config {
  SettingsSession get session => SettingsSession();

  List<BaseSetting> get setting;

  SaveMode get configSaveMode => SaveMode.session;

  final Map<String, SettingEntry> _entries = {};

  SettingEntry<T?> getSetting<T>(
    String id, {
    T? defaultValue,
    T? exampleValue,
    List<Validator>? validators,
    SaveMode saveMode = SaveMode.session,
    bool declarative = true,
  }) {
    if (session.contains(id)) {
      final entry = _entries[id];
      if (entry != null && entry is SettingEntry<T>) {
        return entry;
      }
      throw StateError('fdf');
    }
    session.add(
      id: id,
      defaultValue: defaultValue,
      exampleValue: exampleValue,
      validators: validators,
      saveMode: saveMode,
      declarative: declarative,
    );
    final entry = SettingEntry<T>(id, session);
    _entries[id] = entry;
    return entry;
  }
}
