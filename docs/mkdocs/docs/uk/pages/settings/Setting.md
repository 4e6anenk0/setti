## `Setting`

### Опис

`Setting` — це основна реалізація `BaseSetting`. Це найпоширеніший клас для визначення налаштувань у бібліотеці.

### Структура

```dart
class Setting<T> extends BaseSetting<T> {
  const Setting({
    required super.id,
    required super.defaultValue,
    super.saveMode,
    super.declarative,
  });

  @override
  String get type => 'Setting';

  Setting<T> copyWith({
    T? defaultValue,
    SaveMode? saveMode,
    bool? declarative,
  }) {
    if (defaultValue == this.defaultValue &&
        saveMode == this.saveMode &&
        declarative == this.declarative) {
      return this;
    }
    return Setting(
      defaultValue: defaultValue ?? this.defaultValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
    );
  }
}
```

### Призначення

`Setting` використовується для **Стандартних налаштувань**: Визначення типових параметрів, таких як мова чи числові значення, строкові значення.

### Приклад

```dart
// Налаштування теми
final themeSetting = Setting<String>(
  id: 'theme',
  defaultValue: 'light',
  saveMode: SaveMode.local,
  declarative: true,
);

// Налаштування, яке вимагає збереження
final userIdSetting = Setting<String>(
  id: 'user_id',
  defaultValue: '',
  saveMode: SaveMode.local,
  declarative: false,
);
```
