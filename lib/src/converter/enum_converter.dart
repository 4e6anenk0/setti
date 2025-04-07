import 'package:setti/src/converter/converter_interface.dart';
import 'package:setti/src/setting_types/base/setting.dart';
import 'package:setti/src/setting_types/enum/enum_setting.dart';

class EnumSettingConverter implements ISettingConverter<EnumSetting> {
  Map<String, Enum> _parse(EnumSetting property) {
    var parsed = <String, Enum>{};
    for (Enum value in property.values) {
      parsed[value.name] = value;
    }
    return parsed;
  }

  final Map<String, Map<String, Enum>> _cache = {};

  @override
  Map<String, Enum> getCache(EnumSetting targetSetting) {
    if (_cache[targetSetting.id] != null) {
      return _cache[targetSetting.id]!;
    } else {
      var cacheForProperty = _parse(targetSetting);
      _cache[targetSetting.id] = cacheForProperty;
      return cacheForProperty;
    }
  }

  @override
  void clearCache() {
    _cache.clear();
  }

  @override
  EnumSetting convertFrom<V>(V value, EnumSetting targetSetting) {
    var cache = getCache(targetSetting);
    return targetSetting.copyWith(defaultValue: cache[value]);
  }

  @override
  Setting convertTo(EnumSetting targetSetting) {
    return Setting(
      defaultValue: targetSetting.defaultValue.name,
      id: targetSetting.id,
      saveMode: targetSetting.saveMode,
    );
  }

  @override
  V2 convertValue<V1, V2>(V1 value, EnumSetting targetSetting) {
    var cache = getCache(targetSetting);
    return cache[value] as V2;
  }

  @override
  void preset<V>(
      {required EnumSetting targetSetting,
      required String id,
      required V data}) {
    assert(data is Enum);
    _cache[targetSetting.id]![id] = data as Enum;
  }
}
