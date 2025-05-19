## `EnumSetting`

### Опис

`EnumSetting` — це спеціалізована версія `Setting`, призначена для роботи з перелічуваними типами (`enum`). Вона обмежує значення налаштування значеннями, визначеними в `enum`, забезпечуючи безпеку типів.

### Структура

```dart
class EnumSetting<T extends Enum> extends BaseSetting<T> {
  const EnumSetting({
    required this.values,
    required super.defaultValue,
    required super.id,
    super.saveMode,
    super.declarative,
  });

  @override
  String get type => 'EnumSetting';

  final List<T> values;

  EnumSetting<T> copyWith({
    List<T>? values,
    T? defaultValue,
    SaveMode? saveMode,
    bool? declarative,
  }) {
    if (values == this.values &&
        defaultValue == this.defaultValue &&
        saveMode == this.saveMode &&
        declarative == this.declarative) {
      return this;
    }
    return EnumSetting(
      values: values ?? this.values,
      defaultValue: defaultValue ?? this.defaultValue,
      id: id,
      saveMode: saveMode ?? this.saveMode,
      declarative: declarative ?? this.declarative,
    );
  }
}
```

- **Обмеження типу**: `T` має бути підтипом `Enum`, що гарантує, що значення належить до переліку.
- **Успадкування**: Розширює `BaseSetting`, успадковуючи всі його атрибути (`id`, `defaultValue`, `saveMode`, `declarative`).

### Призначення

`EnumSetting` використовується для:

- **<Типобезпечних налаштувань**: Обмеження значень до значень `enum`, що зменшує ймовірність помилок.
- **Чіткої семантики**: Наприклад, для вибору режимів, тем чи інших категорій із фіксованим набором варіантів.
- **Інтеграції з `SettiController`**: Працює так само, як `Setting`, але з додатковою перевіркою типу.
- Для стандартних налаштувань Flutter: Наприклад ThemeMode.

### Приклад

```dart
// Визначення enum для теми
enum AppTheme { light, dark, system }

// Налаштування теми з enum
final themeSetting = EnumSetting<AppTheme>(
  id: 'app_theme',
  values: AppTheme.values,
  defaultValue: AppTheme.light,
  saveMode: SaveMode.local,
  declarative: true,
);

// Використання
final config = AppConfig();
await config.init();
print(config[themeSetting]); // Виведе: AppTheme.light
config[themeSetting] = AppTheme.dark; // Оновлення значення
```
