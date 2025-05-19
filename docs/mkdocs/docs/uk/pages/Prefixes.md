
# Система префіксів

## Вступ

Однією з ключових особливостей бібліотеки є **система префіксів**, реалізована через клас `StorageOverlay`. Ця система дозволяє ізолювати налаштування Setti від інших даних у сховищі, що робить бібліотеку сумісною з уже існуючими налаштуваннями в програмі. Цей розділ пояснює, що таке система префіксів, як вона працює, і як її використовувати для безконфліктного зберігання налаштувань.

#### Що таке система префіксів?

Система префіксів у бібліотеці **Setti** — це механізм, який додає унікальний рядковий префікс до ідентифікаторів налаштувань перед їх збереженням у сховищі. Це забезпечує ізоляцію налаштувань Setti від інших даних, що можуть бути збережені в тому ж сховищі (наприклад, SharedPreferences, файли чи бази даних). Префікси дозволяють:

- Уникнути конфліктів із ключами, що використовуються іншими частинами програми.
- Групувати налаштування за конфігураціями чи модулями.
- Легко інтегрувати Setti в програми з уже існуючими сховищами.

Система префіксів реалізована в класі `StorageOverlay`, який виступає посередником між `SettiController` і сховищем (реалізує `ISettingsStorage`), додаючи префікс до всіх ключів налаштувань.

##### Структура `StorageOverlay`

```dart
class StorageOverlay implements ISettingsWorker {
  StorageOverlay({
    required List<Type> storages,
    String? prefix,
    Type? bind,
  }) : _prefix = prefix {
    _setPrefixIfExist();
    _storageWorker = _storage.getWorker(storages);
  }

  final SettingsStorage _storage = SettingsStorage.getInstance();
  late final ISettingsWorker _storageWorker;
  final String? _prefix;
  final HashMap<String, String> _keysDump = HashMap();
  late String Function(String name) _name;
}
```

- **`_prefix`**: Опціональний рядок префікса, який додається до ключів налаштувань.
- **`_name`**: Функція, яка обгортає ключі, додаючи префікс (якщо він є) або залишаючи їх без змін.
- **`_keysDump`**: Кеш для зберігання відображень між оригінальними ключами та ключами з префіксом, що зменшує кількість операцій додавання префікса.
- **`_storageWorker`**: Робочий об’єкт, який взаємодіє з одним або кількома сховищами (`ISettingsStorage`).

#### Як працює система префіксів?

Система префіксів працює шляхом автоматичного додавання префікса до всіх ключів налаштувань перед їх збереженням або отриманням із сховища. Це забезпечує ізоляцію даних Setti в межах спільного сховища.

##### 1. Налаштування префікса

При створенні `StorageOverlay` можна вказати опціональний параметр `prefix`:

```dart
StorageOverlay(
  storages: [SharedPreferencesStorage],
  prefix: 'setti_app_',
)
```

- Якщо `prefix` задано, усі ключі налаштувань обгортаються функцією `_name`, яка додає префікс:

  ```dart
  _name = (name) => "$_prefix$name";
  ```

  Наприклад, ключ `'theme'` стає `'setti_app_theme'`.
- Якщо `prefix` дорівнює `null`, ключі залишаються без змін:

  ```dart
  _name = (name) => name;
  ```

Ця логіка ініціалізується в методі `_setPrefixIfExist`:

```dart
void _setPrefixIfExist() {
  if (_prefix == null) {
    _name = (name) => name;
  } else {
    _name = (name) => "$_prefix$name";
  }
}
```

##### 2. Кешування ключів

Щоб зменшити кількість операцій додавання префікса, `StorageOverlay` використовує кеш `_keysDump` для зберігання відображень між оригінальними ключами та ключами з префіксом:

```dart
String prefixed(Setting setting) {
  return _keysDump.putIfAbsent(setting.id, () => _name(setting.id));
}
```

- Якщо ключ уже є в `_keysDump`, повертається збережений варіант із префіксом.
- Якщо ключа немає, він створюється через `_name` і додається до кеша.

Це оптимізує продуктивність, особливо при роботі з великою кількістю налаштувань.

##### 3. Робота з методами сховища

`StorageOverlay` перевизначає методи `ISettingsWorker` (`getSetting`, `setSetting`, `contains`, `removeSetting`, `setSettings`, `removeSettings`), додаючи префікс до ключів перед передачею їх у `_storageWorker`:

- **Отримання налаштування**:

  ```dart
  FutureOr<T?> getSetting<T>(String id, T defaultValue) async {
    return await _storageWorker.getSetting(
        _keysDump[id] ?? _name(id), defaultValue);
  }
  ```

  Ключ `id` перетворюється на ключ із префіксом (наприклад, `'theme'` → `'setti_app_theme'`).

- **Збереження налаштувань**:

  ```dart
  FutureOr<void> setSettings(Map<String, Object> settings) async {
    if (settings.isEmpty) return;
    var prefixedSettings = <String, Object>{};
    for (var entry in settings.entries) {
      var key = _keysDump[entry.key] ??= _name(entry.key);
      prefixedSettings[key] = entry.value;
    }
    await _storageWorker.setSettings(prefixedSettings);
  }
  ```

  Усі ключі в `settings` отримують префікс перед збереженням.

- **Перевірка наявності**:

  ```dart
  FutureOr<bool> contains(String id) async {
    return await _storageWorker.contains(_keysDump[id] ?? _name(id));
  }
  ```

Аналогічно працюють методи `removeSetting` і `removeSettings`, забезпечуючи, що всі операції використовують ключі з префіксом.

##### 4. Очищення кеша

Методи `removeCache` і `removeCacheFor` дозволяють очистити кеш `_keysDump`:

```dart
void removeCache() {
  _keysDump.clear();
}

void removeCacheFor(String id) {
  _keysDump.remove(id);
}
```

Це корисно, якщо потрібно скинути кешовані ключі, наприклад, після зміни префікса або очищення сховища.

##### 5. Перевірка ключів і значень

Методи `isPrefixedKey`, `isNotPrefixedKey`, `isPrefixedValue`, `isNotPrefixedValue` дозволяють перевірити, чи є ключ або значення в кеші `_keysDump`:

```dart
bool isPrefixedKey(String key) {
  return _keysDump.containsKey(key);
}
```

Ці методи корисні для дебагінгу або перевірки стану кеша.

#### Інтеграція з іншими компонентами

Система префіксів тісно пов’язана з іншими компонентами бібліотеки Setti:

- **BaseSetti**: Визначає префікс через метод `configurePrefix`, який може включати стандартний префікс `'setti'`, назву конфігурації (`name`), і символ-роздільник (`delimiter`):

```dart
String? configurePrefix() {
  if (prefix != null) {
    return prefix!;
  } else {
    var buffer = StringBuffer();
    if (config.useSettiPrefix) {
      buffer.write('${config.caseFormat.apply('setti')}${config.delimiter.delimiter}');
    }
    if (config.useModelPrefix) {
      buffer.write("${config.caseFormat.apply(name)}${config.delimiter.delimiter}");
    }
    return buffer.isEmpty ? null : buffer.toString();
  }
}
```

- **SettiController**: Використовує `StorageOverlay` для збереження та отримання налаштувань, не знаючи про префікси, оскільки `StorageOverlay` обробляє їх прозоро.
- **ConfigManager**: Керує кількома конфігураціями (`BaseSetti`), кожна з яких може мати власний префікс, що дозволяє ізолювати налаштування різних модулів.

## Налаштування префіксів через SettiConfig

Формування префіксів у StorageOverlay залежить від конфігурації SettiConfig, яка визначається для кожного міксина сховища. SettiConfig дозволяє налаштувати використання стандартного префікса 'setti', префікса на основі назви конфігурації, роздільник (наприклад, '_' чи '.') і форматування ключів (наприклад, верхній чи нижній регістр). Детальніше про налаштування SettiConfig для сховищ дивіться у розділі Система сховищ

#### Приклад використання

Припустимо, у вас є програма з двома модулями: основним і для авторизації, кожен із власними налаштуваннями.

1. **Визначення конфігурацій**:

```dart
class MainConfig extends BaseSetti {
  @override
  List<BaseSetting> get settings => [
        Setting<String>(
          id: 'theme',
          defaultValue: 'light',
          saveMode: SaveMode.local,
        ),
      ];

  @override
  List<SettiPlatform> get platforms => [SettiPlatform.android];

  @override
  SettiPlatform getCurrentPlatform() => SettiPlatform.android;

  @override
  String get prefix => 'main_'; // Власний префікс
}

class AuthConfig extends BaseSetti {
  @override
  List<BaseSetting> get settings => [
        Setting<String>(
          id: 'user_id',
          defaultValue: '',
          saveMode: SaveMode.local,
        ),
      ];

  @override
  List<SettiPlatform> get platforms => [SettiPlatform.android];

  @override
  SettiPlatform getCurrentPlatform() => SettiPlatform.android;

  @override
  String get prefix => 'auth_'; // Власний префікс
}
```

2. **Створення менеджера**:

```dart
class AppConfigManager extends ConfigManager {
  @override
  List<BaseSetti> get configs => [
        MainConfig(),
        AuthConfig(),
      ];
}
```

3. **Ініціалізація та використання**:

```dart
void main() async {
  final manager = AppConfigManager();
  await manager.init();

  final mainConfig = manager[MainConfig];
  final authConfig = manager[AuthConfig];

  // Збереження налаштувань
  mainConfig[Setting(id: 'theme', defaultValue: 'light')] = 'dark';
  authConfig[Setting(id: 'user_id', defaultValue: '')] = 'user123';

  // У сховищі (наприклад, SharedPreferences):
  // main_theme = 'dark'
  // auth_user_id = 'user123'
}
```

У цьому прикладі:

- Налаштування `MainConfig` зберігаються з префіксом `'main_'` (наприклад, `'main_theme'`).
- Налаштування `AuthConfig` зберігаються з префіксом `'auth_'` (наприклад, `'auth_user_id'`).
- Це дозволяє ізолювати налаштування двох модулів у спільному сховищі.

#### Переваги системи префіксів

1. **Ізоляція налаштувань**:
   - Префікси запобігають конфліктам із ключами, що використовуються іншими частинами програми або сторонніми бібліотеками.
2. **Сумісність**:
   - Setti можна інтегрувати в програми з уже існуючими сховищами (наприклад, SharedPreferences), не перезаписуючи їхні дані.
3. **Модульність**:
   - Кожна конфігурація (`BaseSetti`) може мати власний префікс, що дозволяє групувати налаштування за модулями.
4. **Оптимізація**:
   - Кеш `_keysDump` зменшує кількість операцій додавання префікса, підвищуючи продуктивність.
5. **Гнучкість**:
   - Префікси можна налаштовувати через `configurePrefix` або задавати вручну через `prefix`.

#### Обмеження

- **Довжина ключів**:
  - Додавання префікса збільшує довжину ключів, що може бути обмеженням у сховищах із обмеженнями на розмір ключів.
- **Ручне управління**:
  - Розробник повинен забезпечити унікальність префіксів між різними конфігураціями.
- **Кешування**:
  - Неправильне очищення `_keysDump` може призвести до некоректної роботи, якщо префікс змінюється під час роботи програми.

#### Рекомендації

1. **Використовуйте унікальні префікси**:
   - Переконайтеся, що префікси для різних конфігурацій не перетинаються (наприклад, `'main_'` і `'auth_'`).
2. **Налаштовуйте через `configurePrefix`**:
   - Використовуйте `useSettiPrefix` і `useModelPrefix` у `SettiConfig` для автоматичного створення префіксів.
3. **Очищайте кеш за потреби**:
   - Викликайте `removeCache` або `removeCacheFor`, якщо змінюєте префікс або очищаєте сховище.
4. **Тестуйте префікси**:
   - Створюйте юніт-тести для перевірки коректності додавання префіксів і роботи з кешем.
5. **Мінімізуйте довжину префіксів**:
   - Використовуйте короткі, але змістовні префікси, щоб уникнути проблем із обмеженнями сховища.

#### Приклад із автоматичним префіксом

Якщо ви використовуєте `configurePrefix` із `SettiConfig`:

```dart
class AppConfig extends BaseSetti {
  @override
  List<BaseSetting> get settings => [
        Setting<String>(
          id: 'theme',
          defaultValue: 'light',
          saveMode: SaveMode.local,
        ),
      ];

  @override
  List<SettiPlatform> get platforms => [SettiPlatform.android];

  @override
  SettiPlatform getCurrentPlatform() => SettiPlatform.android;

  @override
  SettiConfig get config => SettiConfig(
        useSettiPrefix: true,
        useModelPrefix: true,
        caseFormat: CaseFormat.snakeCase,
        delimiter: Delimiter.dot,
      );

  @override
  String get name => 'app';
}
```

У цьому випадку:

- Префікс буде `'setti.app.'` (з `useSettiPrefix` і `useModelPrefix`).
- Налаштування `'theme'` зберігатиметься як `'setti.app.theme'`.

---

### Наступні кроки

Цей розділ документації пояснює систему префіксів у бібліотеці Setti, її реалізацію через `StorageOverlay` і важливість для ізоляції налаштувань. Якщо ви хочете продовжити створення документації, я можу додати:

- Опис `SettiController` і його ролі в управлінні налаштуваннями.
- Деталі про `SettingsStorage` і взаємодію зі сховищами.
- Інструкції з використання INI-файлів для `loadFromFile` (якщо метод доданий).
- Приклади тестування системи префіксів із `mockito`.

**Питання**:

- Чи потрібні додаткові розділи документації (наприклад, про інші компоненти)?
- Чи хочете додати приклади INI-файлів або тестів для `StorageOverlay`?
- Чи є специфічні аспекти системи префіксів, які потрібно детальніше описати?
