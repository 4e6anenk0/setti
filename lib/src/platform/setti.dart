import 'package:setti/src/setti_configurations.dart';

import '../setti.dart';

/// A high-level API for managing application settings across different platforms.
///
/// `Setti` provides a unified interface for accessing, modifying, and managing settings,
/// regardless of the underlying storage mechanism. It allows retrieving default values,
/// updating settings, and clearing stored data. The class is designed to support multiple
/// platforms, ensuring a consistent approach to handling configuration across various environments.
///
/// ## Features:
/// - Retrieve and update settings using `get`, `update`, `remove`, `getAll` and `clear` methods.
/// - Check whether a setting exists with `contains`.
/// - Access platform-specific settings using `platforms` and `getCurrentPlatform()`.
///
/// ## Initialization
/// Before using `Setti`, it **must** be initialized to ensure proper configuration and loading of settings.
/// This is typically done by creating a custom implementation that extends `Setti` and defining
/// the necessary settings.
///
/// ## Example Usage:
/// ```dart
/// class AppConfig extends Setti with Ini {
///   @override
///   List<BaseSetting> get settings => [counter, pathToProfiler];
///
///   @override
///   List<SettiPlatform> get platforms => SettiPlatforms.general;
///
///   @override
///   String get name => "APP_CONFIG";
///
///   @override
///   SettiConfig get config =>
///       storageConfig.copyWith(useModelPrefix: false, useSettiPrefix: true);
///
///   static final counter = Setting(
///     id: 'COUNTER',
///     defaultValue: 0,
///     saveMode: SaveMode.local,
///   );
///
///   static final pathToProfiler = Setting(
///     id: 'PROFILER',
///     defaultValue: '~/.src/profiler.txt',
///     saveMode: SaveMode.local,
///   );
/// }
///
/// Future<void> main() async {
///   final appConfig = AppConfig();
///   await appConfig.init();
///
///   int counter = await appConfig.get(AppConfig.counter);
///   print('Counter value: $counter');
/// }
/// ```
///
/// **Note:** This class serves as a placeholder for IDE hints and type safety in conditional
/// imports. It does not provide a working implementation but defines the expected API
/// that platform-specific versions should follow.
abstract class Setti extends BaseSetti {
  @override
  SettiPlatform getCurrentPlatform() {
    throw UnimplementedError();
  }

  @override
  List<SettiPlatform> get platforms => throw UnimplementedError();
}
