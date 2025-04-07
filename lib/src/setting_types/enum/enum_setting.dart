import 'package:setti/src/setting_types/storage_rules.dart';

import '../base/setting.dart';

/// A class for building settings associated with Enum values.
///
/// EnumSetting can be treated as a Setting. It can also be accessed through
/// methods similar to those in a standard Setting. The difference is its
/// ability to handy use Enum in a local storage for re-mapping with
/// the corresponding Enum after initialized new session.
class EnumSetting<T extends Enum> extends BaseSetting<T> {
  const EnumSetting({
    required this.values,
    required super.defaultValue,
    required super.id,
    super.saveMode,
    super.declarative,
  });

  @override
  String get type => 'EnumProperty';

  final List<T> values;

  EnumSetting<T> copyWith({
    List<T>? values,
    T? defaultValue,
    SaveMode? saveMode,
    bool? declarative,
  }) {
    return EnumSetting(
      values: values ?? this.values,
      defaultValue: defaultValue ?? this.defaultValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
    );
  }
}
