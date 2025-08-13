// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'setting_key.dart';

class SettingValue<T> {
  const SettingValue(this.key, this.value);

  final SettingKey<T> key;
  final T value;
  //final SettingSource source; // runtime, session, user, global

  SettingValue<T> copyWith({T? value}) {
    return SettingValue<T>(key, value ?? this.value);
  }
}
