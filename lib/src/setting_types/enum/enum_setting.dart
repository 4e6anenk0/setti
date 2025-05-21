import 'package:setti/src/setting_types/storage_rules.dart';
import 'package:setti/src/validation/validators/base_validator.dart';

import '../base/setting.dart';

/// A class for building settings associated with Enum values.
///
/// EnumSetting can be treated as a Setting. It can also be accessed through
/// methods similar to those in a standard Setting. The difference is its
/// ability to handy use Enum in a local storage for re-mapping with
/// the corresponding Enum after initialized new session.
///
/// The [defaultValue] must be one of the [values].
///
/// Example usage:
/// ```dart
/// enum Theme { light, dark }
/// final themeSetting = EnumSetting(
///   id: 'THEME',
///   values: Theme.values,
///   defaultValue: Theme.light,
/// );
/// final updatedSetting = themeSetting.copyWith(defaultValue: Theme.dark);
/// ```
class EnumSetting<T extends Enum> extends BaseSetting<T> {
  const EnumSetting({
    required this.values,
    required super.defaultValue,
    required super.id,
    super.saveMode,
    super.declarative,
    super.validator,
  });

  @override
  String get type => 'EnumSetting';

  /// The list of possible Enum values, typically obtained from `Enum.values`.
  final List<T> values;

  EnumSetting<T> copyWith({
    List<T>? values,
    T? defaultValue,
    SaveMode? saveMode,
    bool? declarative,
    Validator<T>? validator,
  }) {
    /* if (values == this.values &&
        defaultValue == this.defaultValue &&
        saveMode == this.saveMode &&
        declarative == this.declarative) {
      return this;
    } */
    return EnumSetting(
      values: values ?? this.values,
      defaultValue: defaultValue ?? this.defaultValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
      validator: validator ?? this.validator,
    );
  }
}
