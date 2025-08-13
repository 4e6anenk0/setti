import 'package:checkit/checkit.dart';

import 'rules/storage_rules.dart';

class SettingMeta<T> {
  const SettingMeta(
    this.defaultValue,
    this.exampleValue,
    this.saveMode,
    this.declarative,
    this.validators,
  );

  final T? defaultValue;
  final T? exampleValue;
  final SaveMode saveMode;
  final bool declarative;
  final List<Validator<T>>? validators;

  SettingMeta<T> copyWith({
    T? defaultValue,
    T? exampleValue,
    SaveMode? saveMode,
    bool? declarative,
    List<Validator<T>>? validators,
  }) {
    return SettingMeta<T>(
      defaultValue ?? this.defaultValue,
      exampleValue ?? this.exampleValue,
      saveMode ?? this.saveMode,
      declarative ?? this.declarative,
      validators ?? this.validators,
    );
  }
}
