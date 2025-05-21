abstract class Validator<T> {
  bool call(T value);

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;
}
