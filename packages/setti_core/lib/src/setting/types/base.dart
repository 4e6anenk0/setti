import 'package:checkit/checkit.dart';
import 'package:checkit/checkit_core.dart';
import 'package:setti_core/src/setting/setting_key.dart';

import '../rules/storage_rules.dart';

abstract class BaseSetting<T> {
  const BaseSetting({
    required this.id,
    this.defaultValue,
    this.exampleValue,
    this.saveMode = SaveMode.session,
    this.declarative = true,
    this.validators,
  });

  /// A unique identifier for the setting, typically used as a key.
  final String id;

  /// The default value assigned to the setting when no other value is provided.
  final T? defaultValue;

  final T? exampleValue;

  /// Optional configuration that overrides the global save mode for this setting.
  final SaveMode saveMode;

  /// Determines whether the setting values are defined declaratively in code (`true`)
  /// or should be loaded from an external source such as a file, api (`false`).
  final bool declarative;

  final List<Validator<T>>? validators;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseSetting &&
          id == other.id &&
          runtimeType == other.runtimeType &&
          defaultValue == other.defaultValue;

  @override
  int get hashCode => Object.hash(id, defaultValue);
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
    super.defaultValue,
    super.exampleValue,
    super.saveMode,
    super.declarative,
    super.validators,
  });

  /// Creates a new setting instance with modified values,
  /// preserving the immutability of the original object.
  ///
  /// This method is useful for updating specific values within existing settings
  /// while maintaining the integrity of other properties.
  /// It prevents redundant object creation and reduces the risk of errors.
  ///
  /// Example usage:
  /// ```dart
  /// final counter = Setting(id: 'COUNTER', defaultValue: 0);
  /// final updatedCounter = counter.copyWith(defaultValue: 5);
  /// final path = Setting(id: 'PATH', defaultValue: '/home');
  /// final updatedPath = path.copyWith(defaultValue: '/tmp');
  /// context.updateSetting(updatedCounter);
  /// context.updateSetting(path.copyWith(defaultValue: '/'));
  /// ```
  ///
  /// Instead of manually creating a nearly identical setting object,
  /// we can copy an existing one while applying necessary changes.
  Setting<T> copyWith({
    T? defaultValue,
    T? exampleValue,
    SaveMode? saveMode,
    bool? declarative,
    List<Validator<T>>? validators,
  }) {
    /* if (defaultValue == this.defaultValue &&
        saveMode == this.saveMode &&
        declarative == this.declarative) {
      return this;
    } */ // It's potentially good, but it doesn't work effectively with validator types.
    return Setting(
      defaultValue: defaultValue ?? this.defaultValue,
      exampleValue: exampleValue ?? this.exampleValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
      validators: validators ?? this.validators,
    );
  }
}
