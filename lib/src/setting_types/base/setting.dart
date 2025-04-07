import 'package:setti/src/setting_types/storage_rules.dart';

abstract class BaseSetting<T> {
  const BaseSetting({
    required this.id,
    required this.defaultValue,
    this.saveMode = SaveMode.session,
    this.declarative = true,
  });

  /// Defines the type of setting.
  String get type;

  /// A unique identifier for the setting, typically used as a key.
  final String id;

  /// The default value assigned to the setting when no other value is provided.
  final T defaultValue;

  /// Optional configuration that overrides the global save mode for this setting.
  final SaveMode saveMode;

  /// Determines whether the setting values are defined declaratively in code (`true`)
  /// or should be loaded from an external source such as a file, api (`false`).
  final bool declarative;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Setting &&
          runtimeType == other.runtimeType &&
          defaultValue == other.defaultValue;

  @override
  int get hashCode => defaultValue.hashCode;
}

/// Represents a specific application setting with declarative configuration.
///
/// This class provides a structured way to define settings declaratively.
/// The defined properties allow the application to build a configuration structure,
/// ensuring that settings can be restored to their default values when necessary.
///
/// The `defaultValue` is used in two primary cases:
/// - When restoring settings to their default state.
/// - When loading default values for initialization.
///
/// In all other cases, setting values are stored within `SessionStorage`,
/// which acts as an immutable cache of configuration data.
class Setting<T> extends BaseSetting<T> {
  const Setting({
    required super.id,
    required super.defaultValue,
    super.saveMode,
    super.declarative,
  });

  @override
  String get type => 'Property';

  /// Creates a new setting instance with modified values,
  /// preserving the immutability of the original object.
  ///
  /// This method is useful for updating specific values within existing settings
  /// while maintaining the integrity of other properties.
  /// It prevents redundant object creation and reduces the risk of errors.
  ///
  /// Example usage:
  ///
  /// ```dart
  /// context.updateSetting(counterSetting.copyWith(defaultValue: newValue));
  /// ```
  ///
  /// Instead of manually creating a nearly identical setting object,
  /// we can copy an existing one while applying necessary changes.
  Setting<T> copyWith({
    T? defaultValue,
    SaveMode? saveMode,
    bool? declarative,
  }) {
    return Setting(
      defaultValue: defaultValue ?? this.defaultValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
    );
  }
}
