import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:setti/setti.dart';
import 'package:web/web.dart';

@internal
class WebStorage implements ISettingsStorage {
  WebStorage();

  @override
  void clear() {
    window.localStorage.clear();
  }

  void _setObject({required String id, required Object value}) {
    if (value is bool || value is int || value is double || value is String) {
      window.localStorage.setItem(id, value.toString());
    } else if (value is List<String>) {
      window.localStorage.setItem(id, jsonEncode(value));
    } else {
      throw LocalStorageException(
        msg: "Unsupported type: ${value.runtimeType}",
        solutionMsg:
            """Check that you are not trying to store an unsupported value in the local storage.
Supported values are: bool, int, double, String, List<String>""",
      );
    }
  }

  Object _stringToObject({required String string, required Type targetType}) {
    switch (targetType) {
      case const (bool):
        return string.toLowerCase() == 'true';
      case const (int):
        return int.parse(string);
      case const (double):
        return double.parse(string);
      case const (String):
        return string;
      case const (List<String>):
        return List<String>.from(jsonDecode(string));
      default:
        throw UnsupportedError('Unsupported type: $targetType');
    }
  }

  @override
  T? getSetting<T>(String id, T defaultValue) {
    var str = window.localStorage.getItem(id);

    if (str == null) return null;
    try {
      final result =
          _stringToObject(string: str, targetType: defaultValue.runtimeType)
              as T;
      return result;
    } catch (e) {
      // Логування або обробка помилки
      // print('Error converting setting "$id" to type $T: $e');
      return null;
    }
  }

  @override
  Future<bool> init() async {
    return true;
  }

  @override
  bool contains(String id) {
    return window.localStorage.getItem(id) != null;
  }

  @override
  bool removeSetting(String id) {
    window.localStorage.removeItem(id);
    return true;
  }

  @override
  bool setSetting(String id, Object value) {
    _setObject(id: id, value: value);
    return true;
  }

  @override
  String get id => runtimeType.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ISettingsStorage && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
