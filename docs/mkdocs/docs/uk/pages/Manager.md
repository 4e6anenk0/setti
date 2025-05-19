
# Менеджер конфігурацій

## Вступ

Бібліотека **Setti** надає гнучкий і декларативний підхід до управління налаштуваннями в Dart-програмах. Для спрощення роботи з кількома конфігураціями (`Setti`), особливо в програмах, що підтримують різні платформи, бібліотека включає клас `ConfigManager`. Цей розділ пояснює, що таке менеджер конфігурацій, як він працює, і як його використовувати для агрегації та доступу до налаштувань, специфічних для поточної платформи.

## Що таке `ConfigManager`?

`ConfigManager` — це абстрактний клас, призначений для централізованого управління конфігураціями (`Setti`) у програмі. Він агрегує кілька конфігурацій, ініціалізує їх для поточної платформи та забезпечує зручний доступ до ініціалізованих конфігурацій через типи класів. `ConfigManager` спрощує роботу з платформозалежними налаштуваннями, дозволяючи розробникам уникнути ручного управління кожною конфігурацією окремо.

### Призначення

`ConfigManager` призначений для:

- **Централізованого управління**: Об’єднання кількох конфігурацій в одному місці.
- **Платформозалежної ініціалізації**: Автоматична ініціалізація лише тих конфігурацій, які відповідають поточній платформі.
- **Зручного доступу**: Отримання конфігурацій за їхніми типами через оператор `[]` або метод `getConfig`.
- **Обробки помилок**: Інформативні винятки (`ConfigManagerException`) у разі відсутності конфігурації.

## Як працює `ConfigManager`?

`ConfigManager` виконує три основні функції: ініціалізацію, зберігання та надання доступу до конфігурацій.

### 1. Ініціалізація

Метод `init` асинхронно ініціалізує всі конфігурації, визначені в `configs`:

```dart
Future<void> init() async {
  for (final config in configs) {
    await config.init();
    if (config.isInitialized) {
      _initializedConfigs[config.runtimeType] = config;
    } else {
      _notInitializedConfigs.add(config.name);
    }
  }
}
```

- Кожна конфігурація (`Setti`) викликає свій метод `init`, який перевіряє відповідність платформи (`isCorrectPlatform`) і ініціалізує налаштування через `SettiController`.
- Якщо конфігурація успішно ініціалізована (`isInitialized == true`), вона додається до `_initializedConfigs` за своїм типом (`runtimeType`).
- Якщо ініціалізація не вдалася (наприклад, через невідповідність платформи), назва конфігурації додається до `_notInitializedConfigs`.

### 2. Зберігання

- Ініціалізовані конфігурації зберігаються в `_initializedConfigs` як словник, де ключ — це тип конфігурації (`Type`), а значення — екземпляр `BaseSetti`.
- Невдалі ініціалізації відстежуються в `_notInitializedConfigs` для діагностики.

### 3. Доступ

Методи `getConfig` і `operator []` дозволяють отримати ініціалізовану конфігурацію за її типом:

```dart
BaseSetti getConfig(Type configType) {
  final config = _initializedConfigs[configType];
  if (config != null) return config;
  throw ConfigManagerException(...);
}
```

- Якщо конфігурація знайдена в `_initializedConfigs`, вона повертається.
- Якщо конфігурація відсутня, викидається `ConfigManagerException` із детальним описом проблеми та списком неініціалізованих конфігурацій.

## Приклад використання

Припустимо, у вас є програма, яка підтримує Android і Web, із різними конфігураціями для кожної платформи.

1. **Визначення конфігурацій**:

```dart
enum AppTheme { light, dark, system }

class AndroidConfig extends Setti {
  @override
  List<BaseSetting> get settings => [
        Setting<String>(
          id: 'language',
          defaultValue: 'en',
          saveMode: SaveMode.local,
        ),
        EnumSetting<AppTheme>(
          id: 'theme',
          defaultValue: AppTheme.dark,
          saveMode: SaveMode.local,
        ),
      ];

  @override
  List<SettiPlatform> get platforms => [SettiPlatform.android];
}

class WebConfig extends Setti {
  @override
  List<BaseSetting> get settings => [
        Setting<String>(
          id: 'language',
          defaultValue: 'en',
          saveMode: SaveMode.local,
        ),
        EnumSetting<AppTheme>(
          id: 'theme',
          defaultValue: AppTheme.light,
          saveMode: SaveMode.local,
        ),
      ];

  @override
  List<SettiPlatform> get platforms => [SettiPlatform.web];
}
```

2. **Створення менеджера**:

```dart
class AppConfigManager extends ConfigManager {
  @override
  List<BaseSetti> get configs => [
        AndroidConfig(),
        WebConfig(),
      ];
}
```

3. **Ініціалізація та використання**:

```dart
void main() async {
  final manager = AppConfigManager();
  await manager.init();

  // Отримання конфігурації для Android
  final androidConfig = manager[AndroidConfig];
  print(androidConfig[Setting(id: 'language', defaultValue: 'en')]); // 'en'
  print(androidConfig[EnumSetting(id: 'theme', defaultValue: AppTheme.light)]); // AppTheme.dark

  // Спроба отримати неініціалізовану конфігурацію
  try {
    final webConfig = manager[WebConfig]; // Викличе ConfigManagerException
  } catch (e) {
    print(e); // Виведе повідомлення про помилку
  }
}
```

У цьому прикладі:

- На платформі Android ініціалізується лише `AndroidConfig`, оскільки `WebConfig` не відповідає поточній платформі.
- `manager[AndroidConfig]` повертає ініціалізовану конфігурацію.
- Спроба отримати `WebConfig` викликає `ConfigManagerException`, оскільки вона не була ініціалізована.

## Переваги використання `ConfigManager`

1. **Централізація**: Об’єднує всі конфігурації в одному місці, спрощуючи їх управління.
2. **Платформозалежність**: Автоматично ініціалізує і зберігає лише ті конфігурації, які відповідають поточній платформі.
3. **Зручний доступ**: Оператор `[]` і метод `getConfig` дозволяють отримувати конфігурації за типом.
4. **Обробка помилок**: Інформативні винятки допомагають діагностувати проблеми з ініціалізацією.
5. **Модульність**: Дозволяє легко додавати нові конфігурації без зміни основного коду.

## Обмеження

- **Унікальність типів**: Кожна конфігурація повинна мати унікальний `runtimeType`, інакше виникне конфлікт у `_initializedConfigs`.

## Рекомендації

- **Визначайте `configs` як `const`**: Якщо можливо, використовуйте константний список конфігурацій для оптимізації продуктивності.
- **Логуйте помилки**: Використовуйте `_notInitializedConfigs` для дебагінгу, щоб зрозуміти, чому певні конфігурації не ініціалізовані.
- **Тестуйте ініціалізацію**: Створюйте юніт-тести для `ConfigManager`, щоб перевірити ініціалізацію на різних платформах.
