import 'package:setti/setti.dart';

enum SettiPlatform {
  ios,
  android,
  macos,
  linux,
  windows,
  fuchsia,
  web,
  other,
  ;

  @override
  String toString() => name;
}

abstract class SettiPlatforms {
  static const List<SettiPlatform> desktop = [
    SettiPlatform.linux,
    SettiPlatform.windows,
    SettiPlatform.macos
  ];

  static const List<SettiPlatform> mobile = [
    SettiPlatform.ios,
    SettiPlatform.android
  ];

  static const List<SettiPlatform> io = [
    SettiPlatform.android,
    SettiPlatform.ios,
    SettiPlatform.fuchsia,
    SettiPlatform.linux,
    SettiPlatform.macos,
    SettiPlatform.windows,
  ];

  static const List<SettiPlatform> general = [
    SettiPlatform.android,
    SettiPlatform.ios,
    SettiPlatform.fuchsia,
    SettiPlatform.linux,
    SettiPlatform.macos,
    SettiPlatform.windows,
    SettiPlatform.web,
  ];

  static final List<SettiPlatform> web = const [SettiPlatform.web];

  static const List<SettiPlatform> ios = [SettiPlatform.ios];
  static const List<SettiPlatform> android = [SettiPlatform.android];
  static const List<SettiPlatform> fuchsia = [SettiPlatform.fuchsia];
  static const List<SettiPlatform> windows = [SettiPlatform.windows];
  static const List<SettiPlatform> linux = [SettiPlatform.linux];
  static const List<SettiPlatform> macos = [SettiPlatform.macos];
}

/// Використовується для визначення роздільника в іменах ідентифікаторів налаштувань.
///
/// Наприклад:
/// `Delimiter.dot - setti.config`,
/// `Delimiter.space - setti config`,
/// `Delimiter.none - setticonfig`,
/// `Delimiter.underscore - setti_config`,
/// `Delimiter.forwardSlash - setti/config`,
/// `Delimiter.backSlash - setti\config`,
/// `Delimiter.hyphen - setti-config`.
enum Delimiter {
  dot('.'),
  space(" "),
  none(""),
  underscore("_"),
  forwardSlash("/"),
  backSlash("\\"),
  hyphen("-");

  const Delimiter(this._delimiter);
  final String _delimiter;

  String get delimiter => _delimiter;
}

/* /// Визначити у якому регістрі будуть вказані префікси ідентифікаторів
enum CaseFormat {
  uppercase, // змінює всі ідентифікатори на uppercase
  lowercase, // змінює всі ідентифікатори на lowercase
  preserve, // не змінює загальний стиль
} */

enum CaseFormat {
  preserve,
  lowercase,
  uppercase;

  String apply(String text) {
    switch (this) {
      case CaseFormat.preserve:
        return text;
      case CaseFormat.lowercase:
        return text.toLowerCase();
      case CaseFormat.uppercase:
        return text.toUpperCase();
    }
  }
}

class SettiConfig {
  const SettiConfig({
    this.useSettiPrefix = true,
    this.useModelPrefix = true,
    this.globalLoadModeRule = LoadMode.preload,
    this.delimiter = Delimiter.dot,
    this.caseFormat = CaseFormat.preserve,
    this.storageFileName = 'config',
  });

  /// Чи перекривати префіксом "setti." проєктні налаштування
  final bool useSettiPrefix;

  /// Чи додавати префікс моделі до налаштування.
  ///
  /// Корисно визначити false коли необхідно використовувати назву моделі як секцію
  final bool useModelPrefix;

  /// Глобальна конфігурація для логіки завантаження налаштувань
  final LoadMode globalLoadModeRule;

  final Delimiter delimiter;

  /// Формат назв ідентифікаторів налаштувань.
  ///
  /// Якщо `preserve` - то буде так, як ідентифікатори зазначені в декларативному описі.
  /// Якщо `lowercase` - то всі ідентифікатори будуть зазначені у нижньому регістрі.
  /// Якщо `uppercase` - то всі ідентифікатори будуть зазначені у верхньому регістрі.
  final CaseFormat caseFormat;

  /// Назва файлу локального зберігання конфігурації якщо це потребує сховище.
  final String storageFileName;

  //final bool showDebugWith

  SettiConfig copyWith({
    bool? useSettiPrefix,
    bool? useModelPrefix,
    LoadMode? globalLoadModeRule,
    Delimiter? delimiter,
    CaseFormat? caseFormat,
    String? storageFileName,
    String? prefix,
  }) {
    return SettiConfig(
      useSettiPrefix: useSettiPrefix ?? this.useModelPrefix,
      useModelPrefix: useModelPrefix ?? this.useModelPrefix,
      globalLoadModeRule: globalLoadModeRule ?? this.globalLoadModeRule,
      delimiter: delimiter ?? this.delimiter,
      caseFormat: caseFormat ?? this.caseFormat,
      storageFileName: storageFileName ?? this.storageFileName,
    );
  }
}

class BaseSettiLayer extends SettiLayer {
  final Setting<bool> useSettiPrefix;
  final Setting<bool> useModelPrefix;
  final Setting<String> storageFileName;

  final EnumSetting<LoadMode> globalLoadModeRule;
  final EnumSetting<Delimiter> delimiter;
  final EnumSetting<CaseFormat> caseFormat;

  const BaseSettiLayer({
    required this.useSettiPrefix,
    required this.useModelPrefix,
    required this.storageFileName,
    required this.globalLoadModeRule,
    required this.delimiter,
    required this.caseFormat,
  });

  @override
  List<BaseSetting> get settings => [
        useSettiPrefix,
        useModelPrefix,
        globalLoadModeRule,
        delimiter,
        caseFormat,
        storageFileName,
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;

  factory BaseSettiLayer.fromValues({
    bool useSettiPrefix = true,
    bool useModelPrefix = true,
    String storageFileName = 'config',
    SaveMode globalSaveModeRule = SaveMode.session,
    LoadMode globalLoadModeRule = LoadMode.preload,
    Delimiter delimiter = Delimiter.dot,
    CaseFormat caseFormat = CaseFormat.preserve,
  }) {
    return BaseSettiLayer(
      useSettiPrefix:
          Setting(id: 'useSettiPrefix', defaultValue: useSettiPrefix),
      useModelPrefix:
          Setting(id: 'useModelPrefix', defaultValue: useModelPrefix),
      storageFileName:
          Setting(id: 'storageFileName', defaultValue: storageFileName),
      globalLoadModeRule: EnumSetting(
          id: 'globalLoadModeRule',
          defaultValue: globalLoadModeRule,
          values: LoadMode.values),
      delimiter: EnumSetting(
          id: 'delimiter', defaultValue: delimiter, values: Delimiter.values),
      caseFormat: EnumSetting(
          id: 'caseFormat',
          defaultValue: caseFormat,
          values: CaseFormat.values),
    );
  }

  static const BaseSettiLayer defaultConfig = BaseSettiLayer(
    useSettiPrefix: Setting(id: 'useSettiPrefix', defaultValue: true),
    useModelPrefix: Setting(id: 'useModelPrefix', defaultValue: true),
    storageFileName: Setting(id: 'storageFileName', defaultValue: 'config'),
    globalLoadModeRule: EnumSetting(
        id: 'globalLoadModeRule',
        defaultValue: LoadMode.preload,
        values: LoadMode.values),
    delimiter: EnumSetting(
        id: 'delimiter', defaultValue: Delimiter.dot, values: Delimiter.values),
    caseFormat: EnumSetting(
        id: 'caseFormat',
        defaultValue: CaseFormat.preserve,
        values: CaseFormat.values),
  );

  BaseSettiLayer copyWith({
    bool? useSettiPrefix,
    bool? useModelPrefix,
    String? storageFileName,
    SaveMode? globalSaveModeRule,
    LoadMode? globalLoadModeRule,
    Delimiter? delimiter,
    CaseFormat? caseFormat,
  }) {
    return BaseSettiLayer(
      useSettiPrefix: Setting(
          id: this.useSettiPrefix.id,
          defaultValue: useSettiPrefix ?? this.useSettiPrefix.defaultValue),
      useModelPrefix: Setting(
          id: this.useModelPrefix.id,
          defaultValue: useModelPrefix ?? this.useModelPrefix.defaultValue),
      storageFileName: Setting(
          id: this.storageFileName.id,
          defaultValue: storageFileName ?? this.storageFileName.defaultValue),
      globalLoadModeRule: EnumSetting(
          id: this.globalLoadModeRule.id,
          values: this.globalLoadModeRule.values,
          defaultValue:
              globalLoadModeRule ?? this.globalLoadModeRule.defaultValue),
      delimiter: EnumSetting(
          id: this.delimiter.id,
          values: this.delimiter.values,
          defaultValue: delimiter ?? this.delimiter.defaultValue),
      caseFormat: EnumSetting(
          id: this.caseFormat.id,
          values: this.caseFormat.values,
          defaultValue: caseFormat ?? this.caseFormat.defaultValue),
    );
  }
}

class BaseSettiLayerBuilder {
  Setting<bool>? useSettiPrefix;
  Setting<bool>? useModelPrefix;
  Setting<String>? storageFileName;
  EnumSetting<SaveMode>? globalSaveModeRule;
  EnumSetting<LoadMode>? globalLoadModeRule;
  EnumSetting<Delimiter>? delimiter;
  EnumSetting<CaseFormat>? caseFormat;

  BaseSettiLayerBuilder({
    bool? useSettiPrefix,
    bool? useModelPrefix,
    String? storageFileName,
    SaveMode? globalSaveModeRule,
    LoadMode? globalLoadModeRule,
    Delimiter? delimiter,
    CaseFormat? caseFormat,
  }) {
    this.useSettiPrefix = useSettiPrefix != null
        ? Setting(id: 'useSettiPrefix', defaultValue: useSettiPrefix)
        : null;
    this.useModelPrefix = useModelPrefix != null
        ? Setting(id: 'useModelPrefix', defaultValue: useModelPrefix)
        : null;
    this.storageFileName = storageFileName != null
        ? Setting(id: 'storageFileName', defaultValue: storageFileName)
        : null;
    this.globalSaveModeRule = globalSaveModeRule != null
        ? EnumSetting(
            id: 'globalSaveModeRule',
            defaultValue: globalSaveModeRule,
            values: SaveMode.values)
        : null;
    this.globalLoadModeRule = globalLoadModeRule != null
        ? EnumSetting(
            id: 'globalLoadModeRule',
            defaultValue: globalLoadModeRule,
            values: LoadMode.values)
        : null;
    this.delimiter = delimiter != null
        ? EnumSetting(
            id: 'delimiter', defaultValue: delimiter, values: Delimiter.values)
        : null;
    this.caseFormat = caseFormat != null
        ? EnumSetting(
            id: 'caseFormat',
            defaultValue: caseFormat,
            values: CaseFormat.values)
        : null;
  }

  BaseSettiLayer build() {
    return BaseSettiLayer(
      useSettiPrefix: useSettiPrefix ??
          const Setting(id: 'useSettiPrefix', defaultValue: true),
      useModelPrefix: useModelPrefix ??
          const Setting(id: 'useModelPrefix', defaultValue: true),
      storageFileName: storageFileName ??
          const Setting(id: 'storageFileName', defaultValue: 'config'),
      globalLoadModeRule: globalLoadModeRule ??
          const EnumSetting(
              id: 'globalLoadModeRule',
              defaultValue: LoadMode.preload,
              values: LoadMode.values),
      delimiter: delimiter ??
          const EnumSetting(
              id: 'delimiter',
              defaultValue: Delimiter.dot,
              values: Delimiter.values),
      caseFormat: caseFormat ??
          const EnumSetting(
              id: 'caseFormat',
              defaultValue: CaseFormat.preserve,
              values: CaseFormat.values),
    );
  }
}
