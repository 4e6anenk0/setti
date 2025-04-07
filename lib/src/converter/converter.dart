import 'package:setti/src/setting_types/base/setting.dart';

import '../exceptions/exceptions.dart';
import 'converter_interface.dart';
import 'enum_converter.dart';

/// A manager for converting settings between different formats.
///
/// `SettingConverter` acts as a centralized hub for handling the transformation
/// of various setting types to and from a universal format. It ensures that
/// settings are properly converted when interacting with different parts
/// of the application.
///
/// This class maintains a registry of `ISettingConverter` implementations,
/// allowing custom converters to be registered dynamically.
/// If a requested converter is missing, an `AdapterException` is thrown.
///
/// ## Key Responsibilities:
/// - Stores a collection of registered converters.
/// - Provides access to converters based on setting type.
/// - Converts settings between different representations.
/// - Supports caching mechanisms for improved performance.
class SettingConverter implements ISettingConverter {
  /// List of registered converters for converting properties
  /// to the general type of universal settings or the other way around.
  final Map<String, ISettingConverter> _converters = {
    'EnumProperty': EnumSettingConverter(),
    //'ThemeProperty': ThemePropertyConverter(),
  };

  /// A method that will help to register custom converters.
  ///
  /// To do this, use this method in the Setti class before initialization.
  void registerConverter({
    required ISettingConverter converter,
    required String settingTypeID,
  }) {
    _converters[settingTypeID] = converter;
  }

  /// Method to access the appropriate converter based on the type of the passed setting.
  ISettingConverter getConverter(BaseSetting setting) {
    var adapter = _converters[setting.type];

    if (adapter == null) {
      throw AdapterException(
          msg:
              """The converter for this type [${setting.type}] was not registered with SettingConverter.
You can't get the converter from getConverter method""",
          solutionMsg:
              """Check if the necessary libraries provide the appropriate converters.
You can also register your own converters using the [registerConverter] method.""");
    } else {
      return adapter;
    }
  }

  @override
  BaseSetting convertFrom<V>(V value, BaseSetting targetSetting) {
    if (targetSetting is Setting) {
      return targetSetting;
    }
    var converter = getConverter(targetSetting);
    return converter.convertFrom(value, targetSetting);
  }

  @override
  Setting convertTo(BaseSetting targetSetting) {
    if (targetSetting is Setting) {
      return targetSetting;
    }
    var converter = getConverter(targetSetting);
    return converter.convertTo(targetSetting);
  }

  @override
  V2 convertValue<V1, V2>(V1 value, BaseSetting targetSetting) {
    if (targetSetting is Setting) {
      return value as V2;
    }
    var converter = getConverter(targetSetting);
    return converter.convertValue(value, targetSetting);
  }

  @override
  void clearCache() {
    for (ISettingConverter converter in _converters.values) {
      converter.clearCache();
    }
  }

  @override
  getCache(BaseSetting targetSetting) {
    ISettingConverter converter = getConverter(targetSetting);
    return converter.getCache(targetSetting);
  }

  @override
  void preset<V>(
      {required BaseSetting targetSetting,
      required String id,
      required V data}) {
    ISettingConverter converter = getConverter(targetSetting);
    converter.preset(targetSetting: targetSetting, id: id, data: data);
  }
}
