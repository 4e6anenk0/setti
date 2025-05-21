abstract class Validator<T> {
  const Validator();

  bool call(T value);

  /// Возвращает сообщение об ошибке, если значение невалидно.
  /// Возвращает null, если значение валидно.
  String? explain(T value);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}

abstract class NumValidator<T> extends Validator<T> {
  const NumValidator();
}

abstract class StringValidator<T> extends Validator<T> {
  const StringValidator();
}
