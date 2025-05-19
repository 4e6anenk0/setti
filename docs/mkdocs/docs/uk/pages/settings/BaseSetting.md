## `BaseSetting`

### Опис

`BaseSetting` — це абстрактний базовий клас, який визначає основну структуру для всіх налаштувань у бібліотеці Setti. Він є шаблонним (`generic`), що дозволяє працювати з різними типами даних (`T`), такими як `int`, `String`, `bool` тощо.

### Структура

```dart
abstract class BaseSetting<T> {
  const BaseSetting({
    required this.id,
    required this.defaultValue,
    this.saveMode = SaveMode.session,
    this.declarative = true,
  });

  String get type;

  final String id;

  final T defaultValue;

  final SaveMode saveMode;

  final bool declarative;

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
```

- **`id`**: Унікальний рядковий ідентифікатор налаштування (наприклад, `'theme'`)
- **`defaultValue`**: Значення за замовчуванням типу `T`, яке використовується, якщо налаштування відсутнє в сховищі.
- **`saveMode`**: Визначає, де зберігати значення:
    1. `SaveMode.local`: У локальному сховищі (`StorageOverlay`).
    2. `SaveMode.session`: Лише в сесійному сховищі (`SessionStorage`).
- **`declarative`**: Підтримка декларативного режиму роботи:
    1. Декларативні налаштування ініціалізуються з `defaultValue`, якщо їх немає в сховищі.
    2. Недекларативні налаштування викликають `ControllerException`, якщо відсутні в сховищі. Наприклад, їх можна використовувати лише для валідації локальних налаштувань.

### Призначення

`BaseSetting` є основою для всіх конкретних типів налаштувань. Він забезпечує:

- **Типізацію**: Гарантує, що значення налаштування відповідає типу `T`.
- **Гнучкість**: Дозволяє створювати похідні класи для специфічних потреб (наприклад, `Setting`, `EnumSetting`).
- **Уніфікацію**: Надає єдиний інтерфейс для роботи з налаштуваннями в `SettiController`.
