# Шари

## Що таке шари?

Шари у бібліотеці Setti — це модульні набори налаштувань, які дозволяють групувати конфігурації для різних платформ або функціональних потреб.

Шари значно полегшують організацію та управління налаштуваннями, однак їх застосування виправдане головним чином у складних проєктах із великим обсягом конфігурацій.

Переваги використання шарів:

- Модульність: Шари дозволяють групувати налаштування за платформами чи функціоналом, спрощуючи їх управління.
- Гнучкість: Налаштування можна застосовувати вибірково залежно від платформи або динамічно під час роботи програми.
- Пріоритетність: Налаштування шарів має вищий пріоритет над базовими, що дозволяє легко перевизначати значення.
- Відстеження: Застосовані шари зберігаються в `_appliedLayers`, що полегшує дебагінг і логування.

Шари дозволяють гнучко адаптувати налаштування до різних умов, таких як тип платформи (наприклад, Android, iOS, Web), без необхідності змінювати основну конфігурацію.

Визначення слою:

Клас SettiLayer має наступну структуру:

```dart
abstract class SettiLayer {
  const SettiLayer();

  List<SettiPlatform> get platforms;

  String get name => 'UnnamedLayer';
}
```

- settings: Список об’єктів BaseSetting, які визначають конкретні налаштування (ідентифікатор, значення за замовчуванням, режим збереження).
- name: Назва шару, що використовується для ідентифікації та логування. За замовчуванням — 'UnnamedLayer'.

Опис шару (LayerDesc):

Для зв’язування шарів із платформами використовується клас `LayerDesc`:

```dart
class LayerDesc {
  final List<SettiPlatform> platforms;
  final LayerFactory factory;

  LayerDesc({required this.platforms, required this.factory});
}
```

- platforms: Список платформ, для яких шар буде застосовано.
- factory: Функція (LayerFactory), яка створює екземпляр SettiLayer.



## Приклад використання шарів

Припустимо, у вас є програма, яка працює на Android і Web, і ви хочете визначити різні налаштування для кожної платформи.

1. Визначення шарів:

```dart
class AndroidLayer extends SettiLayer {
  const AndroidLayer();

  @override
  List<BaseSetting> get settings => [
        Setting(id: 'theme', defaultValue: 'dark'),
        Setting(id: 'font_size', defaultValue: 16),
      ];

  @override
  String get name => 'AndroidLayer';
}

class WebLayer extends SettiLayer {
  const WebLayer();

  @override
  List<BaseSetting> get settings => [
        Setting(id: 'theme', defaultValue: 'light'),
        Setting(id: 'font_size', defaultValue: 14),
      ];

  @override
  String get name => 'WebLayer';
}
```

2. Створення конфігурації:

```dart
class AppConfig extends Setti {
  @override
  List<BaseSetting> get settings => [
        Setting(id: 'language', defaultValue: 'en'),
      ];

  @override
  List<LayerDesc> get layers => [
        LayerDesc(
          platforms: SettiPlatforms.android,
          factory: () => AndroidLayer(),
        ),
        LayerDesc(
          platforms: SettiPlatforms.web,
          factory: () => WebLayer(),
        ),
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;
}
```

3. Ініціалізація та використання:

```dart
void main() async {
  final config = AppConfig();
  await config.init();

  // На Android застосовується AndroidLayer
  print(config['theme']); // Виведе: 'dark'
  print(config['font_size']); // Виведе: 16
  print(config['language']); // Виведе: 'en'
}
```

Майте на увазі: конфігурації для шарів та базового класу можуть бути різними. При наявності однакових параметрів (з однаковим ID), налаштування з шару мають вищий пріоритет і використовуються замість базових.

## В чому різниця між шарами ініціалізації і шарами сесії?

Хоча шари ініціалізації і шари сесії виглядають однаково і створюються однаково, але вони мають різне призначення:

1. Шари ініціалізації

Шари ініціалізації зазвичай використовуються для перевизначення налаштувань базової конфігурації. Їх потрібно задекларувати в базовій конфігурації заздалегідь. Під час ініціалізації ці налаштування будуть відновлені зі сховища або з декларації, якщо їх ще немає у сховищі. Наприклад: коли ви хочете мати інші налаштування на іншій платформі. Слід також пам'ятати, що використання шарів може призвести до незначного збільшення споживання пам'яті та вплинути на продуктивність.

Обов'язково слід визначити шари ініціалізації в базовій конфігурації:

```dart hl_lines="7-17"
class AppConfig extends Setti {
  @override
  List<BaseSetting> get settings => [
        Setting(id: 'language', defaultValue: 'en'),
      ];

  @override
  List<LayerDesc> get layers => [
        LayerDesc(
          platforms: SettiPlatforms.android,
          factory: () => AndroidLayer(),
        ),
        LayerDesc(
          platforms: SettiPlatforms.web,
          factory: () => WebLayer(),
        ),
      ];

  @override
  List<SettiPlatform> get platforms => SettiPlatforms.general;
}
```

2. Шари сесії

Шари сесії  можна використати під час роботи програми. Наприклад, їх можна використати для завантаження збережених пресетів налаштувань.

Для того щоб використати динамічний шар, достатньо лише застосувати описаний шар через спеціальний метод `applyLayer(layer)`:

```dart
appConfig.applyLayer(AdditionalLayer());
```


## Як працюють шари?

Шари інтегруються в бібліотеку через клас BaseSetti. Вони дозволяють:

- Ініціалізацію налаштувань із урахуванням поточної платформи.
- Комбінування налаштувань із різних шарів і базових налаштувань.
- Динамічне застосування шарів під час роботи програми.

### 1. Ініціалізація шарів

Під час ініціалізації (init) BaseSetti перевіряє поточну платформу (getCurrentPlatform) і застосовує налаштування з відповідних шарів:

```dart
Future<void> init() async {
  if (_isInitialized) return;

  final currentPlatform = getCurrentPlatform();
  List<BaseSetting> combinedSettings = List.from(settings);
  if (layers.isNotEmpty) {
    final applicableFactories =
        layers.where((desc) => desc.platforms.contains(currentPlatform));

    for (final desc in applicableFactories) {
      final layer = desc.factory();
      _activeLayers.add(layer);
      _appliedLayers
          .putIfAbsent('InitialLayer', () => [])
          .add("${layer.name}-${layer.runtimeType}");
      combinedSettings = _mergeSettings(combinedSettings, layer.settings);
    }
  }

  if (_activeLayers.isEmpty && !isCorrectPlatform()) {
    return;
  }

  await _init(combinedSettings);
}
```

- Перевірка платформи: Метод перевіряє, чи поточна платформа входить до списку platforms конфігурації або шарів.
- Застосування шарів: Якщо є шар, що відповідає поточній платформі, то його налаштування додаються до базових (settings) через _mergeSettings.
- Збереження активних шарів: Застосовані шари зберігаються в_activeLayers і `_appliedLayers` для відстеження.

### 2. Об’єднання налаштувань

Метод `_mergeSettings` комбінує базові налаштування та налаштування шарів, надаючи пріоритет налаштуванням із шарів у разі конфлікту ID:

- Налаштування з однаковими ID замінюються тими, що визначені в слоях.
- Результат — об’єднаний список унікальних налаштувань.

### 3. Динамічне застосування шарів

Метод `applyLayer` дозволяє додавати шари під час роботи програми:

```dart
void applyLayer(SettiLayer layer) {
  for (BaseSetting setting in layer.settings) {
    _controller.update(setting, sessionOnly: true);
    _appliedLayers
        .putIfAbsent('SessionLayer', () => [])
        .add("${layer.name}-${layer.runtimeType}");
  }
}
```

- Налаштування шару застосовуються до SessionStorage через _controller.update із параметром sessionOnly: true.
- Інформація про шар додається до_appliedLayers для відстеження.
